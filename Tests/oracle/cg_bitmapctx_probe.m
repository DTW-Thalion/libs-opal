/* Apple oracle: CGBitmapContext accessors for a few configurations, so the
   width/height/bpc/bpp/bytesPerRow/alphaInfo/bitmapInfo/colorspace they report
   are known - in particular whether Apple echoes the requested bytesPerRow or
   rounds it up, and what GetBitmapInfo returns. */
#import <CoreGraphics/CoreGraphics.h>
#include <stdio.h>
#include <stdlib.h>

static void dump(const char *label, CGContextRef c)
{
  if (!c) { printf("%s: NULL\n", label); return; }
  CGColorSpaceRef cs = CGBitmapContextGetColorSpace(c);
  printf("%s: w=%zu h=%zu bpc=%zu bpp=%zu bpr=%zu alpha=%d bitmapInfo=0x%x csModel=%d\n",
    label,
    CGBitmapContextGetWidth(c), CGBitmapContextGetHeight(c),
    CGBitmapContextGetBitsPerComponent(c), CGBitmapContextGetBitsPerPixel(c),
    CGBitmapContextGetBytesPerRow(c),
    (int)CGBitmapContextGetAlphaInfo(c),
    (unsigned)CGBitmapContextGetBitmapInfo(c),
    (int)CGColorSpaceGetModel(cs));
}

int main(void)
{
  CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
  CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();

  /* RGBA, explicit bytesPerRow exactly = w*4. */
  CGContextRef a = CGBitmapContextCreate(NULL, 10, 8, 8, 40, rgb,
    kCGImageAlphaPremultipliedLast);
  dump("rgba-bpr40", a);

  /* RGBA, bytesPerRow = 0 -> Apple computes (and may align). */
  CGContextRef b = CGBitmapContextCreate(NULL, 10, 8, 8, 0, rgb,
    kCGImageAlphaPremultipliedLast);
  dump("rgba-bpr0", b);

  /* RGBA, odd width to expose row alignment. */
  CGContextRef c = CGBitmapContextCreate(NULL, 13, 8, 8, 0, rgb,
    kCGImageAlphaPremultipliedLast);
  dump("rgba-w13-bpr0", c);

  /* Gray + alpha. */
  CGContextRef d = CGBitmapContextCreate(NULL, 10, 8, 8, 0, gray,
    kCGImageAlphaPremultipliedLast);
  dump("graya-bpr0", d);

  return 0;
}
