/* Apple oracle: CGContext clipping.  Green fill over a transparent 10x10
   device-RGB bitmap, confined by different clips; reports the alpha at sample
   points so the clipped region is known.  Covers a path clip, an even-odd clip
   (which leaves a hole), a multi-rect clip, and nested clips (intersection). */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>
#include <stdlib.h>

#define W 10

static CGContextRef newCtx(unsigned char *buf, CGColorSpaceRef dev)
{
  CGContextRef c = CGBitmapContextCreate(buf, W, W, 8, W*4, dev,
    kCGImageAlphaPremultipliedLast);
  CGContextSetRGBFillColor(c, 0, 1, 0, 1);
  return c;
}
static int A(unsigned char *d, int x, int y) { return d[(y*W + x)*4 + 3]; }

int main(void)
{
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();

  /* Path clip: clip to a centred rect, then fill everything. */
  {
    unsigned char *b = calloc(W*W*4,1);
    CGContextRef c = newCtx(b, dev);
    CGContextBeginPath(c);
    CGContextAddRect(c, CGRectMake(2, 2, 6, 6));
    CGContextClip(c);
    CGContextFillRect(c, CGRectMake(0, 0, W, W));
    unsigned char *d = CGBitmapContextGetData(c);
    printf("path-clip: in(5,5)=%d out(0,0)=%d edge(1,1)=%d\n",
      A(d,5,5), A(d,0,0), A(d,1,1));
    free(b);
  }

  /* Even-odd clip: outer + inner rect -> inner is a hole. */
  {
    unsigned char *b = calloc(W*W*4,1);
    CGContextRef c = newCtx(b, dev);
    CGContextBeginPath(c);
    CGContextAddRect(c, CGRectMake(0, 0, 10, 10));
    CGContextAddRect(c, CGRectMake(3, 3, 4, 4));
    CGContextEOClip(c);
    CGContextFillRect(c, CGRectMake(0, 0, W, W));
    unsigned char *d = CGBitmapContextGetData(c);
    printf("eo-clip: ring(1,1)=%d hole(5,5)=%d\n", A(d,1,1), A(d,5,5));
    free(b);
  }

  /* Multi-rect clip: two vertical bars. */
  {
    unsigned char *b = calloc(W*W*4,1);
    CGContextRef c = newCtx(b, dev);
    CGRect rects[] = { CGRectMake(0,0,2,10), CGRectMake(6,0,2,10) };
    CGContextClipToRects(c, rects, 2);
    CGContextFillRect(c, CGRectMake(0, 0, W, W));
    unsigned char *d = CGBitmapContextGetData(c);
    printf("rects-clip: bar1(1,5)=%d gap(4,5)=%d bar2(7,5)=%d\n",
      A(d,1,5), A(d,4,5), A(d,7,5));
    free(b);
  }

  /* Nested clips intersect. */
  {
    unsigned char *b = calloc(W*W*4,1);
    CGContextRef c = newCtx(b, dev);
    CGContextClipToRect(c, CGRectMake(0, 0, 7, 7));
    CGContextClipToRect(c, CGRectMake(4, 4, 6, 6));
    CGContextFillRect(c, CGRectMake(0, 0, W, W));
    unsigned char *d = CGBitmapContextGetData(c);
    printf("nested-clip: inBoth(5,5)=%d inFirst(1,1)=%d inSecond(8,8)=%d\n",
      A(d,5,5), A(d,1,1), A(d,8,8));
    free(b);
  }

  return 0;
}
