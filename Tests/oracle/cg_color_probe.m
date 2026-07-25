/* Apple oracle: CGColor components, alpha, number of components, equality
   and copy-with-alpha for the generic colour spaces. */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>

static void dump(const char *name, CGColorRef c)
{
  size_t n = CGColorGetNumberOfComponents(c);
  const CGFloat *comp = CGColorGetComponents(c);
  printf("%s: n=%zu alpha=%g comps=[", name, n, CGColorGetAlpha(c));
  for (size_t i = 0; i < n; i++)
    printf("%s%g", i ? "," : "", comp[i]);
  printf("]\n");
}

int main(void)
{
  CGColorRef rgb = CGColorCreateGenericRGB(0.1, 0.2, 0.3, 0.4);
  CGColorRef gray = CGColorCreateGenericGray(0.5, 0.8);
  CGColorRef cmyk = CGColorCreateGenericCMYK(0.1, 0.2, 0.3, 0.4, 0.5);

  dump("RGB(.1,.2,.3,.4)", rgb);
  dump("Gray(.5,.8)", gray);
  dump("CMYK(.1,.2,.3,.4,.5)", cmyk);

  CGColorRef rgb2 = CGColorCreateGenericRGB(0.1, 0.2, 0.3, 0.4);
  printf("Equal(rgb,rgb2)=%d Equal(rgb,gray)=%d\n",
    CGColorEqualToColor(rgb, rgb2), CGColorEqualToColor(rgb, gray));

  CGColorRef rgbA = CGColorCreateCopyWithAlpha(rgb, 0.9);
  dump("CopyWithAlpha(rgb,0.9)", rgbA);

  CGColorRef copy = CGColorCreateCopy(rgb);
  printf("Equal(rgb,copy)=%d\n", CGColorEqualToColor(rgb, copy));

  CGColorSpaceRef cs = CGColorGetColorSpace(rgb);
  printf("rgb colorspace model=%d (RGB=%d)\n",
    (int)CGColorSpaceGetModel(cs), (int)kCGColorSpaceModelRGB);

  /* Render: fill a 1x1 premultiplied-RGBA bitmap with a colour and read
     the pixel back. */
  unsigned char pxo[4] = {0, 0, 0, 0};
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();
  CGContextRef ctx = CGBitmapContextCreate(pxo, 1, 1, 8, 4, dev,
    kCGImageAlphaPremultipliedLast);
  CGFloat dc1[] = {0.2, 0.4, 0.6, 1.0}; CGColorRef fill = CGColorCreate(dev, dc1);
  CGContextSetFillColorWithColor(ctx, fill);
  CGContextFillRect(ctx, CGRectMake(0, 0, 1, 1));
  printf("fill(0.2,0.4,0.6,1.0) opaque pixel RGBA = %d %d %d %d\n",
    pxo[0], pxo[1], pxo[2], pxo[3]);

  unsigned char pxt[4] = {0, 0, 0, 0};
  CGContextRef ctx2 = CGBitmapContextCreate(pxt, 1, 1, 8, 4, dev,
    kCGImageAlphaPremultipliedLast);
  CGFloat dc2[] = {1.0, 0.0, 0.0, 0.5}; CGColorRef fill2 = CGColorCreate(dev, dc2);
  CGContextSetFillColorWithColor(ctx2, fill2);
  CGContextFillRect(ctx2, CGRectMake(0, 0, 1, 1));
  printf("fill(1,0,0,0.5) premultiplied pixel RGBA = %d %d %d %d\n",
    pxt[0], pxt[1], pxt[2], pxt[3]);

  CGColorRelease(rgb); CGColorRelease(gray); CGColorRelease(cmyk);
  CGColorRelease(rgb2); CGColorRelease(rgbA); CGColorRelease(copy);
  return 0;
}
