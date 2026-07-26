/* Apple oracle: CGContextDrawTiledImage.  A 4x4 tile (left half green, right
   half blue) is tiled across a 12x12 context; report a row and a column of
   sample pixels so the tiling period, coverage and orientation are known. */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>
#include <stdlib.h>

#define W 12

static CGImageRef tile(CGColorSpaceRef dev)
{
  CGContextRef c = CGBitmapContextCreate(NULL, 4, 4, 8, 16, dev,
    kCGImageAlphaPremultipliedLast);
  CGContextSetRGBFillColor(c, 0, 1, 0, 1);        /* left half green */
  CGContextFillRect(c, CGRectMake(0, 0, 2, 4));
  CGContextSetRGBFillColor(c, 0, 0, 1, 1);        /* right half blue */
  CGContextFillRect(c, CGRectMake(2, 0, 2, 4));
  CGImageRef img = CGBitmapContextCreateImage(c);
  CGContextRelease(c);
  return img;
}

int main(void)
{
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();
  unsigned char *buf = calloc(W*W*4, 1);
  CGContextRef c = CGBitmapContextCreate(buf, W, W, 8, W*4, dev,
    kCGImageAlphaPremultipliedLast);
  CGContextDrawTiledImage(c, CGRectMake(0, 0, 4, 4), tile(dev));
  unsigned char *d = CGBitmapContextGetData(c);

  printf("row y=6 (G/B):");
  for (int x = 0; x < 12; x++)
    printf(" %d/%d", d[(6*W+x)*4+1], d[(6*W+x)*4+2]);
  printf("\n");
  printf("far corner (10,10) = %d,%d,%d,%d\n",
    d[(10*W+10)*4], d[(10*W+10)*4+1], d[(10*W+10)*4+2], d[(10*W+10)*4+3]);
  return 0;
}
