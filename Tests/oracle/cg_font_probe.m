/* Apple oracle: CGFont metrics for a couple of system fonts, so the sign and
   source conventions (ascent vs bounding-box top, descent sign, cap/x height,
   glyph advance units) are known. */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>

static void dump(const char *name)
{
  CGFontRef f = CGFontCreateWithFontName(CFSTR(""));
  CFStringRef n = CFStringCreateWithCString(NULL, name, kCFStringEncodingUTF8);
  f = CGFontCreateWithFontName(n);
  if (!f) { printf("%s: NULL\n", name); return; }

  int upm = CGFontGetUnitsPerEm(f);
  int ascent = CGFontGetAscent(f);
  int descent = CGFontGetDescent(f);
  int cap = CGFontGetCapHeight(f);
  int xh = CGFontGetXHeight(f);
  int leading = CGFontGetLeading(f);
  CGRect bb = CGFontGetFontBBox(f);
  size_t ng = CGFontGetNumberOfGlyphs(f);

  printf("%s: upm=%d numGlyphs=%zu\n", name, upm, ng);
  printf("  ascent=%d descent=%d capHeight=%d xHeight=%d leading=%d italic=%g\n",
    ascent, descent, cap, xh, leading, CGFontGetItalicAngle(f));
  printf("  fontBBox=(%g,%g,%g,%g)  bboxTop=%g bboxBottom=%g\n",
    bb.origin.x, bb.origin.y, bb.size.width, bb.size.height,
    bb.origin.y + bb.size.height, bb.origin.y);

  UniChar ch = 'A';
  CGGlyph g = 0;
  CGFontGetGlyphWithGlyphName(f, CFSTR("A")); /* touch */
  /* Map 'A' via a CTFont is heavier; use the glyph-name path Apple supports. */
  g = CGFontGetGlyphWithGlyphName(f, CFSTR("A"));
  int adv = 0;
  CGFontGetGlyphAdvances(f, &g, 1, &adv);
  CGRect gb;
  CGFontGetGlyphBBoxes(f, &g, 1, &gb);
  printf("  glyphA=%u advance=%d bbox=(%g,%g,%g,%g)\n",
    g, adv, gb.origin.x, gb.origin.y, gb.size.width, gb.size.height);
  (void)ch;
}

int main(void)
{
  dump("Helvetica");
  dump("Times New Roman");
  dump("Courier");
  return 0;
}
