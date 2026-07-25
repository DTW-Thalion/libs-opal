/* Apple oracle: CGLayer size, its context, and compositing a layer drawn
   green into a destination context. */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>
#include <stdlib.h>

int main(void)
{
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();
  unsigned char *dest = calloc(10 * 10 * 4, 1);
  CGContextRef dctx = CGBitmapContextCreate(dest, 10, 10, 8, 40, dev,
    kCGImageAlphaPremultipliedLast);

  CGLayerRef layer = CGLayerCreateWithContext(dctx, CGSizeMake(4, 4), NULL);
  CGSize sz = CGLayerGetSize(layer);
  printf("layer size = %g %g\n", sz.width, sz.height);
  printf("layer context nonnull = %d\n", CGLayerGetContext(layer) != NULL);

  CGContextRef lctx = CGLayerGetContext(layer);
  CGFloat green[] = {0, 1, 0, 1};
  CGColorRef gc = CGColorCreate(dev, green);
  CGContextSetFillColorWithColor(lctx, gc);
  CGContextFillRect(lctx, CGRectMake(0, 0, 4, 4));

  CGContextDrawLayerAtPoint(dctx, CGPointMake(2, 2), layer);
  unsigned char *d = (unsigned char *)CGBitmapContextGetData(dctx);
  int in = (4 * 10 + 4) * 4, out = 0;
  printf("composited: inside(4,4)=%d %d %d %d outside(0,0)=%d %d %d %d\n",
    d[in], d[in+1], d[in+2], d[in+3], d[out], d[out+1], d[out+2], d[out+3]);

  return 0;
}
