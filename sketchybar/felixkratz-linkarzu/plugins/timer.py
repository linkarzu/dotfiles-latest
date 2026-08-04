#!/usr/bin/env python3

# import libs:
import sys
import os
import time
import signal
import subprocess
from datetime import datetime


# define colours:
WHITE = str("0xffcad3f5")
RED = str("0xffed8796")
PID_FILE = "/tmp/sketchybar_timer.pid"
STANDING_SEQUENCE_STOP_HOUR = 20


# main function:
def main(argv):
    if len(argv) < 2:
        print_usage()
        sys.exit(1)

    command = argv[1]

    if command == "stop":
        stop_running(clear_label=True)
        return

    seconds = None
    phases = None

    if command == "timer" and len(argv) == 3:
        try:
            seconds = int(argv[2])
        except ValueError:
            print_usage()
            sys.exit(1)
    elif command == "sequence" and len(argv) == 3:
        try:
            phases = parse_sequence(argv[2])
        except ValueError as error:
            print(error, file=sys.stderr)
            print_usage()
            sys.exit(1)
    elif command != "stopwatch" or len(argv) != 2:
        print_usage()
        sys.exit(1)

    stop_running(clear_label=False)
    write_pid()
    setup_signal_handlers()

    # set start time:
    start_time = int(time.time())

    if command == "stopwatch":
        stopwatch(start_time)
        return

    if command == "timer":
        # set end time:
        end_time = start_time + seconds

        # start countdown:
        count_down(start_time, end_time)

        # finish message and make a sound:
        if is_current_process():
            remove_pid_file()
            finish_event()
        return

    if command == "sequence":
        run_sequence(phases)
        return


def print_usage():
    print(
        "Usage: timer.py stopwatch|timer <seconds>|sequence <label:seconds,...>|stop",
        file=sys.stderr,
    )


def parse_sequence(sequence):
    phases = []

    for phase in sequence.split(","):
        label, separator, seconds = phase.partition(":")

        if not separator or not label.strip():
            raise ValueError("Invalid sequence phase: " + phase)

        try:
            duration = int(seconds)
        except ValueError as error:
            raise ValueError("Invalid sequence duration: " + phase) from error

        if duration <= 0:
            raise ValueError("Sequence duration must be greater than zero: " + phase)

        phases.append((label.strip(), duration))

    if not phases:
        raise ValueError("Sequence must include at least one phase")

    return phases


def setup_signal_handlers():
    signal.signal(signal.SIGTERM, handle_exit)
    signal.signal(signal.SIGINT, handle_exit)


def handle_exit(signum, frame):
    remove_pid_file()
    sys.exit(0)


def write_pid():
    with open(PID_FILE, "w", encoding="utf-8") as pid_file:
        pid_file.write(str(os.getpid()))


def read_pid():
    try:
        with open(PID_FILE, "r", encoding="utf-8") as pid_file:
            return int(pid_file.read().strip())
    except (FileNotFoundError, ValueError):
        return None


def remove_pid_file():
    if is_current_process():
        try:
            os.remove(PID_FILE)
        except FileNotFoundError:
            pass


def is_process_running(pid):
    try:
        os.kill(pid, 0)
        return True
    except OSError:
        return False


def is_timer_process(pid):
    result = subprocess.run(
        ["ps", "-p", str(pid), "-o", "command="],
        capture_output=True,
        check=False,
        text=True,
    )

    return os.path.basename(__file__) in result.stdout


def is_current_process():
    return read_pid() == os.getpid()


def stop_running(clear_label):
    pid = read_pid()

    if pid and pid != os.getpid() and is_process_running(pid) and is_timer_process(pid):
        try:
            os.kill(pid, signal.SIGTERM)
        except ProcessLookupError:
            pass

        for _ in range(10):
            if not is_process_running(pid):
                break
            time.sleep(0.1)

        if is_process_running(pid):
            try:
                os.kill(pid, signal.SIGKILL)
            except ProcessLookupError:
                pass

    try:
        os.remove(PID_FILE)
    except FileNotFoundError:
        pass

    if clear_label:
        set_timer_label("")


def stopwatch(start_time):
    while True:
        current_time = int(time.time())
        delta = current_time - start_time

        set_timer_label("Timer: " + format_seconds(delta), WHITE)

        time.sleep(1)


def run_sequence(phases):
    should_stop_after_cutoff = is_standing_sequence(phases)

    while is_current_process():
        for index, (label, seconds) in enumerate(phases):
            start_time = int(time.time())
            end_time = start_time + seconds

            count_down(start_time, end_time, label)

            if is_current_process():
                next_label = phases[(index + 1) % len(phases)][0]
                finish_event(next_action_message(next_label), clear_label=False)

                if should_stop_after_cutoff and is_after_standing_sequence_cutoff():
                    set_timer_label("")
                    remove_pid_file()
                    return


def is_standing_sequence(phases):
    labels = {label.strip().lower() for label, _ in phases}
    return "sit" in labels or "stand" in labels


def is_after_standing_sequence_cutoff():
    return datetime.now().hour >= STANDING_SEQUENCE_STOP_HOUR


def next_action_message(label):
    normalized_label = label.strip().lower()

    if normalized_label == "stand":
        return "Standup!!"

    if normalized_label == "sit":
        return "Sit Down!!"

    return "Time Up!"


def count_down(start_time, end_time, label="Timer"):
    delta = end_time - start_time

    while delta > 1:
        current_time = int(time.time())
        delta = end_time - current_time

        # highlight the text if remaining time is less than 60sec:
        if delta < 60:
            color = RED
        else:
            color = WHITE

        set_timer_label(label + ": " + format_seconds(delta), color)

        time.sleep(1)


def set_timer_label(label, color=None):
    args = ["sketchybar", "--set", "timer", "label=" + label]

    if color:
        args.append("label.color=" + color)

    subprocess.run(args, check=False)


def format_seconds(seconds):
    output = ""

    # 3600sec -> 01:00:00
    if seconds >= 3600:
        for duration in (3600, 60, 1):
            output += str(seconds // duration).zfill(2) + ":"
            seconds = seconds % duration

    # 3599sec -> 59:59
    else:
        for duration in (60, 1):
            output += str(seconds // duration).zfill(2) + ":"
            seconds = seconds % duration

    return output.rstrip(":")


def finish_event(message="Time Up!", clear_label=True):
    set_timer_label(message, WHITE)

    for i in range(2):
        os.system("afplay /System/Library/Sounds/Blow.aiff")

    if clear_label:
        set_timer_label("")


if __name__ == "__main__":
    main(sys.argv)
