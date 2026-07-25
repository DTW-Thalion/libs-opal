/* Apple oracle: CGImageCreateCopyWithColorSpace - what it returns for a
   matching colour space, a mismatched component count, and a mask, and whether
   it converts the pixel data (compared by drawing the copy). */
#import <CoreGraphics/CoreGraphics.h>
#include <stdio.h>
#include <stdlib.h>

static CGImageRef rgbImage(CGColorSpaceRef dev)
{
  CGContextRef c = CGBitmapContextCreate(NULL, 2, 2, 8, 8, dev,
    kCGImageAlphaPremultipliedLast);
  CGContextSetRGBFillColor(c, 200/255.0, 100/255.0, 50/255.0, 1);
  CGContextFillRect(c, CGRectMake(0, 0, 2, 2));
  CGImageRef img = CGBitmapContextCreateImage(c);
  CGContextRelease(c);
  return img;
}

static void drawFirstPixel(const char *label, CGImageRef img, CGColorSpaceRef dev)
{
  unsigned char *b = calloc(2*2*4, 1);
  CGContextRef c = CGBitmapContextCreate(b, 2, 2, 8, 8, dev,
    kCGImageAlphaPremultipliedLast);
  CGContextDrawImage(c, CGRectMake(0, 0, 2, 2), img);
  unsigned char *d = CGBitmapContextGetData(c);
  printf("%s drawn = %d,%d,%d,%d\n", label, d[0], d[1], d[2], d[3]);
  free(b);
}

int main(void)
{
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();
  CGColorSpaceRef srgb = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
  CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();

  CGImageRef img = rgbImage(dev);
  drawFirstPixel("original", img, dev);

  CGImageRef sameComps = CGImageCreateCopyWithColorSpace(img, srgb);
  printf("copy to sRGB: nonnull=%d w=%zu h=%zu bpc=%zu csModel=%d\n",
    sameComps != NULL,
    sameComps ? CGImageGetWidth(sameComps) : 0,
    sameComps ? CGImageGetHeight(sameComps) : 0,
    sameComps ? CGImageGetBitsPerComponent(sameComps) : 0,
    sameComps ? (int)CGColorSpaceGetModel(CGImageGetColorSpace(sameComps)) : -1);
  if (sameComps) drawFirstPixel("copy", sameComps, dev);

  CGImageRef toGray = CGImageCreateCopyWithColorSpace(img, gray);
  printf("copy to Gray (mismatch): nonnull=%d\n", toGray != NULL);

  CGImageRef mask = CGImageMaskCreate(2, 2, 8, 8, 8, CGImageGetDataProvider(img),
    NULL, false);
  CGImageRef maskCopy = mask ? CGImageCreateCopyWithColorSpace(mask, srgb) : NULL;
  printf("mask nonnull=%d, copy of mask nonnull=%d\n",
    mask != NULL, maskCopy != NULL);

  return 0;
}
