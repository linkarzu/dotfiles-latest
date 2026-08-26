#!/usr/bin/env python3

import fcntl
import json
import os
import sys
from datetime import datetime
from pathlib import Path


DEFAULT_MAX_BYTES = 1024 * 1024
DEFAULT_BACKUP_COUNT = 3


class _Mirror:
    def __init__(self, session, stream):
        self.session = session
        self.stream = stream

    def write(self, text):
        written = self.stream.write(text)
        self.session.append(text)
        return written

    def flush(self):
        self.stream.flush()

    def isatty(self):
        return self.stream.isatty()

    @property
    def encoding(self):
        return self.stream.encoding


class DiagnosticSession:
    def __init__(
        self,
        component,
        log_path,
        *,
        max_bytes=DEFAULT_MAX_BYTES,
        backup_count=DEFAULT_BACKUP_COUNT,
    ):
        self.component = component
        self.log_path = Path(log_path)
        self.max_bytes = max_bytes
        self.backup_count = backup_count
        self.original_stdout = sys.stdout
        self.original_stderr = sys.stderr
        self.finished = False

        self.log_path.parent.mkdir(parents=True, exist_ok=True)
        self.lock_file = self.log_path.with_name(f".{self.log_path.name}.lock").open("a")
        sys.stdout = _Mirror(self, self.original_stdout)
        sys.stderr = _Mirror(self, self.original_stderr)
        self.marker("diagnostic-path", path=str(self.log_path))
        self.marker("invocation-start")

    @staticmethod
    def timestamp():
        return datetime.now().astimezone().isoformat(timespec="milliseconds")

    def marker(self, event, **fields):
        details = " ".join(
            f"{key}={json.dumps(value, ensure_ascii=True)}" for key, value in fields.items()
        )
        line = f"timestamp={self.timestamp()} component={self.component} event={event}"
        if details:
            line = f"{line} {details}"
        print(line)

    def _rotate(self, incoming_size):
        current_size = self.log_path.stat().st_size if self.log_path.exists() else 0
        if current_size == 0 or current_size + incoming_size <= self.max_bytes:
            return
        if self.backup_count == 0:
            self.log_path.unlink(missing_ok=True)
            return
        oldest = self.log_path.with_name(f"{self.log_path.name}.{self.backup_count}")
        oldest.unlink(missing_ok=True)
        for index in range(self.backup_count - 1, 0, -1):
            source = self.log_path.with_name(f"{self.log_path.name}.{index}")
            if source.exists():
                os.replace(source, self.log_path.with_name(f"{self.log_path.name}.{index + 1}"))
        if self.log_path.exists():
            os.replace(self.log_path, self.log_path.with_name(f"{self.log_path.name}.1"))

    def append(self, text):
        if not text:
            return
        payload = text.encode("utf-8", errors="backslashreplace")
        fcntl.flock(self.lock_file, fcntl.LOCK_EX)
        try:
            for offset in range(0, len(payload), self.max_bytes):
                chunk = payload[offset : offset + self.max_bytes]
                self._rotate(len(chunk))
                with self.log_path.open("ab") as log_file:
                    log_file.write(chunk)
                    log_file.flush()
                    os.fsync(log_file.fileno())
        finally:
            fcntl.flock(self.lock_file, fcntl.LOCK_UN)

    def finish(self, status, exit_status, *, error_type=None):
        if self.finished:
            return
        fields = {"status": status, "exit_status": exit_status}
        if error_type:
            fields["error_type"] = error_type
        self.marker("invocation-end", **fields)
        self.finished = True

    def close(self):
        sys.stdout = self.original_stdout
        sys.stderr = self.original_stderr
        self.lock_file.close()


def install_diagnostics(component, log_path, **kwargs):
    return DiagnosticSession(component, log_path, **kwargs)
