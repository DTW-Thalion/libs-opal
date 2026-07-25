/* Apple oracle: CGContext text state conventions - the default text matrix,
   whether the text position and the text matrix share the tx/ty storage, and
   whether the text position advances after drawing text.  Also reports whether
   drawing text paints any pixels. */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>
#include <stdlib.h>

#define W 30

int main(void)
{
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();
  unsigned char *buf = calloc(W*W*4,1);
  CGContextRef c = CGBitmapContextCreate(buf, W, W, 8, W*4, dev,
    kCGImageAlphaPremultipliedLast);

  CGAffineTransform tm = CGContextGetTextMatrix(c);
  printf("default matrix = %g %g %g %g %g %g\n",
    tm.a, tm.b, tm.c, tm.d, tm.tx, tm.ty);

  CGContextSetTextPosition(c, 3, 4);
  CGPoint p = CGContextGetTextPosition(c);
  CGAffineTransform tm2 = CGContextGetTextMatrix(c);
  printf("after SetTextPosition(3,4): pos=(%g,%g) matrix.tx/ty=(%g,%g)\n",
    p.x, p.y, tm2.tx, tm2.ty);

  CGContextSetTextMatrix(c, CGAffineTransformMake(2, 0, 0, 2, 5, 6));
  CGPoint p2 = CGContextGetTextPosition(c);
  printf("after SetTextMatrix(...,5,6): pos=(%g,%g)\n", p2.x, p2.y);

  /* Advance after drawing. */
  CGContextSelectFont(c, "Helvetica", 10, kCGEncodingMacRoman);
  CGContextSetTextMatrix(c, CGAffineTransformIdentity);
  CGContextSetTextPosition(c, 1, 12);
  CGContextSetRGBFillColor(c, 0, 0, 0, 1);
  CGContextShowText(c, "AB", 2);
  CGPoint p3 = CGContextGetTextPosition(c);
  printf("after ShowText(\"AB\") from x=1: pos=(%g,%g)  advanced=%d\n",
    p3.x, p3.y, p3.x > 1.0);

  /* Did anything get painted? */
  unsigned char *d = CGBitmapContextGetData(c);
  int painted = 0;
  for (int i = 0; i < W*W; i++) if (d[i*4+3] != 0) painted++;
  printf("painted pixels = %d\n", painted);

  return 0;
}
