#!/usr/bin/env python3

# import libs:
import sys
import os
import time
import signal
import subprocess


# define colours:
WHITE = str("0xffcad3f5")
RED = str("0xffed8796")
PID_FILE = "/tmp/sketchybar_timer.pid"


# main function:
def main(argv):
    if len(argv) < 2:
        print("Usage: timer.py stopwatch|timer <seconds>|stop", file=sys.stderr)
        sys.exit(1)

    command = argv[1]

    if command == "stop":
        stop_running(clear_label=True)
        return

    seconds = None

    if command == "timer" and len(argv) == 3:
        try:
            seconds = int(argv[2])
        except ValueError:
            print("Usage: timer.py stopwatch|timer <seconds>|stop", file=sys.stderr)
            sys.exit(1)
    elif command != "stopwatch" or len(argv) != 2:
        print("Usage: timer.py stopwatch|timer <seconds>|stop", file=sys.stderr)
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


def count_down(start_time, end_time):
    delta = end_time - start_time

    while delta > 1:
        current_time = int(time.time())
        delta = end_time - current_time

        # highlight the text if remaining time is less than 60sec:
        if delta < 60:
            color = RED
        else:
            color = WHITE

        set_timer_label("Timer: " + format_seconds(delta), color)

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


def finish_event():
    set_timer_label("Time Up!", WHITE)

    for i in range(2):
        os.system("afplay /System/Library/Sounds/Funk.aiff")

    set_timer_label("")


if __name__ == "__main__":
    main(sys.argv)
