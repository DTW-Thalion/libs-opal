/* Apple oracle: CGContextClipToMask.  Clip a green fill by (a) an image mask
   whose left half is black and right half white, and (b) a normal image whose
   left half is opaque and right half transparent.  Report which half is
   painted, to pin the coverage convention. */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>
#include <stdlib.h>

#define W 8

static int A(unsigned char *d, int x, int y) { return d[(y*W + x)*4 + 3]; }

/* An 8x8 one-component image: left half = lo, right half = hi. */
static CGImageRef halfMask(int lo, int hi, bool asMask, CGColorSpaceRef gray)
{
  unsigned char *m = malloc(W*W);
  for (int y = 0; y < W; y++)
    for (int x = 0; x < W; x++)
      m[y*W+x] = (x < W/2) ? lo : hi;
  CGDataProviderRef dp = CGDataProviderCreateWithData(NULL, m, W*W, NULL);
  CGImageRef img;
  if (asMask)
    img = CGImageMaskCreate(W, W, 8, 8, W, dp, NULL, false);
  else
    img = CGImageCreate(W, W, 8, 8, W, gray,
      kCGImageAlphaNone, dp, NULL, false, kCGRenderingIntentDefault);
  return img;
}

static void run(const char *label, CGImageRef mask)
{
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();
  unsigned char *buf = calloc(W*W*4, 1);
  CGContextRef c = CGBitmapContextCreate(buf, W, W, 8, W*4, dev,
    kCGImageAlphaPremultipliedLast);
  CGContextClipToMask(c, CGRectMake(0, 0, W, W), mask);
  CGContextSetRGBFillColor(c, 0, 1, 0, 1);
  CGContextFillRect(c, CGRectMake(0, 0, W, W));
  unsigned char *d = CGBitmapContextGetData(c);
  printf("%s: left(2,4) alpha=%d right(6,4) alpha=%d\n", label, A(d,2,4), A(d,6,4));
  free(buf);
}

int main(void)
{
  CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
  run("imagemask black|white", halfMask(0, 255, true, gray));
  /* A normal grey image used as a mask: alpha is None, so use luminance. */
  run("grayimage black|white", halfMask(0, 255, false, gray));
  return 0;
}
