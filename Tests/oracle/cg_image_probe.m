/* Apple oracle: CGImage metadata from a bitmap context, and drawing the
   image back into a context. */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>
#include <stdlib.h>

int main(void)
{
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();
  unsigned char *src = calloc(2 * 2 * 4, 1);
  CGContextRef sctx = CGBitmapContextCreate(src, 2, 2, 8, 8, dev,
    kCGImageAlphaPremultipliedLast);
  CGFloat g[] = {0, 1, 0, 1};
  CGColorRef green = CGColorCreate(dev, g);
  CGContextSetFillColorWithColor(sctx, green);
  CGContextFillRect(sctx, CGRectMake(0, 0, 2, 2));

  CGImageRef img = CGBitmapContextCreateImage(sctx);
  printf("img w=%zu h=%zu bpc=%zu bpp=%zu bpr=%zu alpha=%d isMask=%d model=%d\n",
    CGImageGetWidth(img), CGImageGetHeight(img),
    CGImageGetBitsPerComponent(img), CGImageGetBitsPerPixel(img),
    CGImageGetBytesPerRow(img), (int)CGImageGetAlphaInfo(img),
    CGImageIsMask(img),
    (int)CGColorSpaceGetModel(CGImageGetColorSpace(img)));

  unsigned char *dst = calloc(2 * 2 * 4, 1);
  CGContextRef dctx = CGBitmapContextCreate(dst, 2, 2, 8, 8, dev,
    kCGImageAlphaPremultipliedLast);
  CGContextDrawImage(dctx, CGRectMake(0, 0, 2, 2), img);
  unsigned char *d = (unsigned char *)CGBitmapContextGetData(dctx);
  printf("drawn pixel(0,0) = %d %d %d %d\n", d[0], d[1], d[2], d[3]);

  CGImageRef sub = CGImageCreateWithImageInRect(img, CGRectMake(0, 0, 1, 1));
  printf("sub image w=%zu h=%zu\n", CGImageGetWidth(sub), CGImageGetHeight(sub));

  return 0;
}
