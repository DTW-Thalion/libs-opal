/* Apple oracle: draw a black-to-white linear gradient across a 10x1 strip
   and dump every pixel. */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>
#include <stdlib.h>

int main(void)
{
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();
  unsigned char *data = calloc(10 * 4, 1);
  CGContextRef ctx = CGBitmapContextCreate(data, 10, 1, 8, 40, dev,
    kCGImageAlphaPremultipliedLast);

  CGFloat comps[] = {0, 0, 0, 1,  1, 1, 1, 1};
  CGFloat locs[] = {0.0, 1.0};
  CGGradientRef g = CGGradientCreateWithColorComponents(dev, comps, locs, 2);
  CGContextDrawLinearGradient(ctx, g, CGPointMake(0, 0), CGPointMake(10, 0), 0);

  unsigned char *d = (unsigned char *)CGBitmapContextGetData(ctx);
  for (int x = 0; x < 10; x++)
    printf("x=%d: %d %d %d %d\n", x,
      d[x * 4], d[x * 4 + 1], d[x * 4 + 2], d[x * 4 + 3]);

  return 0;
}
