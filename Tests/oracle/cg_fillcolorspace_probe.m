/* Apple oracle: CGContextSetFillColorSpace / SetStrokeColorSpace reset the
   current fill/stroke colour to the colour space's default (opaque, zero
   intensity).  Set a non-default colour first, then set the colour space, then
   paint, and report the resulting pixel. */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>
#include <stdlib.h>

#define W 4

int main(void)
{
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();

  /* Fill: set red, then set the RGB colour space, then fill. */
  {
    unsigned char *buf = calloc(W*W*4, 1);
    CGContextRef c = CGBitmapContextCreate(buf, W, W, 8, W*4, dev,
      kCGImageAlphaPremultipliedLast);
    CGContextSetRGBFillColor(c, 1, 0, 0, 1);
    CGContextSetFillColorSpace(c, dev);
    CGContextFillRect(c, CGRectMake(0, 0, W, W));
    unsigned char *d = CGBitmapContextGetData(c);
    printf("fill after SetFillColorSpace: %d %d %d %d\n", d[0], d[1], d[2], d[3]);
    free(buf);
  }

  /* Stroke: set red, then set the RGB colour space, then stroke a wide line. */
  {
    unsigned char *buf = calloc(W*W*4, 1);
    CGContextRef c = CGBitmapContextCreate(buf, W, W, 8, W*4, dev,
      kCGImageAlphaPremultipliedLast);
    CGContextSetRGBStrokeColor(c, 1, 0, 0, 1);
    CGContextSetStrokeColorSpace(c, dev);
    CGContextSetLineWidth(c, 8);
    CGContextMoveToPoint(c, 0, 2);
    CGContextAddLineToPoint(c, W, 2);
    CGContextStrokePath(c);
    unsigned char *d = CGBitmapContextGetData(c);
    printf("stroke after SetStrokeColorSpace: %d %d %d %d\n", d[0], d[1], d[2], d[3]);
    free(buf);
  }

  return 0;
}
