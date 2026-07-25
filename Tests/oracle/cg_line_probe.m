/* Apple oracle: how stroke line attributes (width, cap, dash) paint pixels.
   Green stroke on a transparent 12x12 device-RGB bitmap; reports the alpha at
   sample points so painted vs unpainted regions are known. */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>
#include <stdlib.h>

#define W 12

static CGContextRef newCtx(unsigned char *buf, CGColorSpaceRef dev)
{
  CGContextRef c = CGBitmapContextCreate(buf, W, W, 8, W*4, dev,
    kCGImageAlphaPremultipliedLast);
  CGFloat green[] = {0,1,0,1};
  CGColorRef gc = CGColorCreate(dev, green);
  CGContextSetStrokeColorWithColor(c, gc);
  return c;
}

static int A(CGContextRef c, int x, int y)
{
  unsigned char *d = CGBitmapContextGetData(c);
  return d[(y*W + x)*4 + 3];
}

int main(void)
{
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();

  /* Line width: horizontal line y=6, width 1 vs 6. */
  {
    unsigned char *b = calloc(W*W*4,1);
    CGContextRef c = newCtx(b, dev);
    CGContextSetLineWidth(c, 1);
    CGContextMoveToPoint(c, 0, 6); CGContextAddLineToPoint(c, W, 6);
    CGContextStrokePath(c);
    printf("width1: y6=%d y3=%d y9=%d\n", A(c,6,6), A(c,6,3), A(c,6,9));
    free(b);
  }
  {
    unsigned char *b = calloc(W*W*4,1);
    CGContextRef c = newCtx(b, dev);
    CGContextSetLineWidth(c, 6);
    CGContextMoveToPoint(c, 0, 6); CGContextAddLineToPoint(c, W, 6);
    CGContextStrokePath(c);
    printf("width6: y6=%d y3=%d y9=%d\n", A(c,6,6), A(c,6,3), A(c,6,9));
    free(b);
  }

  /* Line cap: segment x=4..8 at y=6, width 4, butt vs square.
     Sample just beyond the start (x=2). */
  {
    unsigned char *b = calloc(W*W*4,1);
    CGContextRef c = newCtx(b, dev);
    CGContextSetLineWidth(c, 4);
    CGContextSetLineCap(c, kCGLineCapButt);
    CGContextMoveToPoint(c, 4, 6); CGContextAddLineToPoint(c, 8, 6);
    CGContextStrokePath(c);
    printf("butt: x2=%d x6=%d\n", A(c,2,6), A(c,6,6));
    free(b);
  }
  {
    unsigned char *b = calloc(W*W*4,1);
    CGContextRef c = newCtx(b, dev);
    CGContextSetLineWidth(c, 4);
    CGContextSetLineCap(c, kCGLineCapSquare);
    CGContextMoveToPoint(c, 4, 6); CGContextAddLineToPoint(c, 8, 6);
    CGContextStrokePath(c);
    printf("square: x2=%d x6=%d\n", A(c,2,6), A(c,6,6));
    free(b);
  }

  /* Line dash: horizontal line y=6, width 2, dash [2,2] phase 0.
     Paint [0,2] gap [2,4] paint [4,6] ... sample x=1,3,5. */
  {
    unsigned char *b = calloc(W*W*4,1);
    CGContextRef c = newCtx(b, dev);
    CGContextSetLineWidth(c, 2);
    CGFloat dash[] = {2,2};
    CGContextSetLineDash(c, 0, dash, 2);
    CGContextMoveToPoint(c, 0, 6); CGContextAddLineToPoint(c, W, 6);
    CGContextStrokePath(c);
    printf("dash: x1=%d x3=%d x5=%d\n", A(c,1,6), A(c,3,6), A(c,5,6));
    free(b);
  }

  return 0;
}
