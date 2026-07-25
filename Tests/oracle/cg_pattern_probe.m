/* Apple oracle: a colored CGPattern tiled over a fill.  A 4x4 pattern cell
   paints its left half (x 0..2) green and leaves the right half clear; the
   pattern steps by 4 in x and y, so filling a 12x8 rect should repeat the
   green/clear stripes every 4 pixels.  Reports the alpha (and colour) at a row
   of sample points so the tiling period and origin are known.  Also tries an
   uncolored pattern tinted by the fill components. */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>
#include <stdlib.h>

#define W 12
#define H 8

static void drawCell(void *info, CGContextRef c)
{
  /* Colored: paint our own green in the left half of the 4x4 cell. */
  CGContextSetRGBFillColor(c, 0, 1, 0, 1);
  CGContextFillRect(c, CGRectMake(0, 0, 2, 4));
}

static void drawCellUncolored(void *info, CGContextRef c)
{
  /* Uncolored: paint the left half with whatever colour is current. */
  CGContextFillRect(c, CGRectMake(0, 0, 2, 4));
}

static void drawCellBottom(void *info, CGContextRef c)
{
  /* Colored: paint the bottom half (y 0..2) green. */
  CGContextSetRGBFillColor(c, 0, 1, 0, 1);
  CGContextFillRect(c, CGRectMake(0, 0, 4, 2));
}

static int A(unsigned char *d, int x, int y) { return d[(y*W + x)*4 + 3]; }
static int G(unsigned char *d, int x, int y) { return d[(y*W + x)*4 + 1]; }

int main(void)
{
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();

  /* Colored pattern. */
  {
    unsigned char *buf = calloc(W*H*4, 1);
    CGContextRef c = CGBitmapContextCreate(buf, W, H, 8, W*4, dev,
      kCGImageAlphaPremultipliedLast);
    CGPatternCallbacks cb = {0, drawCell, NULL};
    CGPatternRef pat = CGPatternCreate(NULL, CGRectMake(0, 0, 4, 4),
      CGAffineTransformIdentity, 4, 4, kCGPatternTilingNoDistortion, 1, &cb);
    CGColorSpaceRef pcs = CGColorSpaceCreatePattern(NULL);
    CGContextSetFillColorSpace(c, pcs);
    CGFloat alpha = 1;
    CGContextSetFillPattern(c, pat, &alpha);
    CGContextFillRect(c, CGRectMake(0, 0, W, H));
    unsigned char *d = CGBitmapContextGetData(c);
    printf("colored row y=4:");
    for (int x = 0; x < 12; x++) printf(" %d/%d", A(d,x,4), G(d,x,4));
    printf("\n");
    free(buf);
  }

  /* Vertical variation: bottom-half cell, to pin the vertical tiling. */
  {
    unsigned char *buf = calloc(W*H*4, 1);
    CGContextRef c = CGBitmapContextCreate(buf, W, H, 8, W*4, dev,
      kCGImageAlphaPremultipliedLast);
    CGPatternCallbacks cbb = {0, drawCellBottom, NULL};
    CGPatternRef pat = CGPatternCreate(NULL, CGRectMake(0, 0, 4, 4),
      CGAffineTransformIdentity, 4, 4, kCGPatternTilingNoDistortion, 1, &cbb);
    CGColorSpaceRef pcs = CGColorSpaceCreatePattern(NULL);
    CGContextSetFillColorSpace(c, pcs);
    CGFloat alpha = 1;
    CGContextSetFillPattern(c, pat, &alpha);
    CGContextFillRect(c, CGRectMake(0, 0, W, H));
    unsigned char *d = CGBitmapContextGetData(c);
    printf("vertical col x=1:");
    for (int y = 0; y < 8; y++) printf(" %d/%d", A(d,1,y), G(d,1,y));
    printf("\n");
    free(buf);
  }

  /* Uncolored pattern tinted blue via the fill components. */
  {
    unsigned char *buf = calloc(W*H*4, 1);
    CGContextRef c = CGBitmapContextCreate(buf, W, H, 8, W*4, dev,
      kCGImageAlphaPremultipliedLast);
    CGPatternCallbacks cb = {0, drawCellUncolored, NULL};
    CGPatternRef pat = CGPatternCreate(NULL, CGRectMake(0, 0, 4, 4),
      CGAffineTransformIdentity, 4, 4, kCGPatternTilingNoDistortion, 0, &cb);
    CGColorSpaceRef pcs = CGColorSpaceCreatePattern(CGColorSpaceCreateDeviceRGB());
    CGContextSetFillColorSpace(c, pcs);
    CGFloat blue[] = {0, 0, 1, 1};
    CGContextSetFillPattern(c, pat, blue);
    CGContextFillRect(c, CGRectMake(0, 0, W, H));
    unsigned char *d = CGBitmapContextGetData(c);
    printf("uncolored x=1: a=%d r=%d g=%d b=%d\n",
      d[(4*W+1)*4+3], d[(4*W+1)*4], d[(4*W+1)*4+1], d[(4*W+1)*4+2]);
    printf("uncolored x=3: a=%d\n", A(d,3,4));
    free(buf);
  }

  return 0;
}
