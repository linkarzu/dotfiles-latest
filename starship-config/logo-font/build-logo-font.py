import os
import sys

import fontforge
import psMat


CODEPOINT = 0xE000
GLYPH_NAME = "linkarzu-logo"


def main():
    if len(sys.argv) != 3:
        raise SystemExit("usage: build-logo-font.py <input.svg> <output.ttf>")

    svg_path = os.path.abspath(sys.argv[1])
    output_path = os.path.abspath(sys.argv[2])

    font = fontforge.font()
    font.encoding = "UnicodeFull"
    font.fontname = "LinkarzuLogo"
    font.familyname = "Linkarzu Logo"
    font.fullname = "Linkarzu Logo Regular"
    font.version = "1.0"
    font.em = 1000
    font.ascent = 850
    font.descent = 150

    glyph = font.createChar(CODEPOINT, GLYPH_NAME)
    glyph.importOutlines(svg_path)
    glyph.correctDirection()
    glyph.removeOverlap()
    glyph.simplify()

    xmin, ymin, xmax, ymax = glyph.boundingBox()
    width = xmax - xmin
    height = ymax - ymin
    if width <= 0 or height <= 0:
        raise SystemExit("imported SVG did not produce a valid glyph outline")

    target = 900.0
    scale = min(target / width, target / height)

    glyph.transform(psMat.translate(-xmin, -ymin))
    glyph.transform(psMat.scale(scale))

    xmin, ymin, xmax, ymax = glyph.boundingBox()
    width = xmax - xmin
    height = ymax - ymin

    x_offset = (1000.0 - width) / 2.0 - xmin
    y_offset = -120.0 + ((1000.0 - height) / 2.0) - ymin
    glyph.transform(psMat.translate(x_offset, y_offset))
    glyph.width = 1000
    glyph.round()

    font.generate(output_path)
    font.close()


if __name__ == "__main__":
    main()
