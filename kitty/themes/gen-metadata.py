#! kitty +launch
# vim:fileencoding=utf-8
# License: GPLv3 Copyright: 2021, Kovid Goyal <kovid at kovidgoyal.net>

import glob
import json
import subprocess
import sys
from operator import itemgetter


def parse_themes(paths):
    cp = subprocess.run(['kitten', '__parse_theme_metadata__'],
                        input='\n'.join(paths).encode('utf-8'), capture_output=True)
    if cp.returncode != 0:
        print(cp.stderr.decode('utf-8'), file=sys.stderr)
        raise SystemExit(cp.returncode)
    return json.loads(cp.stdout)


def main():
    themes = []
    seen = {}
    files = glob.glob('themes/*.conf')
    parsed = parse_themes(files)
    for theme, td in zip(files, parsed):
        td['file'] = theme
        if td['name'] in seen:
            raise SystemExit(
                f'The theme {td["name"]!r} is defined multiple times')
        seen[td['name']] = theme
        td = {k: v for k, v in td.items() if v}
        themes.append(td)

    themes.sort(key=itemgetter('name'))
    with open('themes.json', 'w') as f:
        json.dump(themes, f, indent=4, sort_keys=True)


if __name__ == '__main__':
    main()
