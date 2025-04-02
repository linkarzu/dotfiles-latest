#!/usr/bin/env python3

# import libs:
import sys
import os
import time


# define colours:
WHITE = str("0xffcad3f5")
RED = str("0xffed8796")


# main function:
def main(argv):
    # set start time:
    start_time = int(time.time())

    # stopwatch mode:
    if len(argv) == 1:
        # start stopwatch:
        stopwatch(start_time)

    # timer mode:
    if len(argv) == 2:
        seconds = int(argv[1])

        # set end time:
        end_time = start_time + seconds

        # start countdown:
        count_down(start_time, end_time)

        # finish message and make a sound:
        finish_event()


def stopwatch(start_time):
    while True:
        current_time = int(time.time())
        delta = current_time - start_time

        os.system(
            'sketchybar --set timer label="Timer: '
            + format_seconds(delta)
            + '" label.color='
            + WHITE
        )

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

        os.system(
            'sketchybar --set timer label="Timer: '
            + format_seconds(delta)
            + '" label.color='
            + color
        )

        time.sleep(1)


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
    os.system('sketchybar --set timer label="Time Up!" ' + "label.color=" + WHITE)

    for i in range(2):
        os.system("afplay /System/Library/Sounds/Funk.aiff")

    os.system('sketchybar --set timer label=""')


if __name__ == "__main__":
    main(sys.argv)
