/* Apple oracle: PNG round-trip through CGImageDestination and CGImageSource.
   Build a 2x2 image with four distinct opaque colours, encode it to PNG in
   memory, decode it back, and report the source count/type and the pixels of
   the decoded image (drawn into a device-RGB bitmap). */
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import <CoreFoundation/CoreFoundation.h>
#include <stdio.h>
#include <stdlib.h>

static CGImageRef makeImage(CGColorSpaceRef dev)
{
  /* Row 0 (top): red, green.  Row 1 (bottom): blue, white. */
  unsigned char px[] = {
    255,0,0,255,   0,255,0,255,
    0,0,255,255,   255,255,255,255,
  };
  CGContextRef c = CGBitmapContextCreate(NULL, 2, 2, 8, 8, dev,
    kCGImageAlphaPremultipliedLast);
  unsigned char *d = CGBitmapContextGetData(c);
  for (int i = 0; i < 16; i++) d[i] = px[i];
  CGImageRef img = CGBitmapContextCreateImage(c);
  CGContextRelease(c);
  return img;
}

int main(void)
{
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();
  CGImageRef img = makeImage(dev);

  CFMutableDataRef data = CFDataCreateMutable(NULL, 0);
  CGImageDestinationRef dst =
    CGImageDestinationCreateWithData(data, CFSTR("public.png"), 1, NULL);
  printf("destination nonnull = %d\n", dst != NULL);
  CGImageDestinationAddImage(dst, img, NULL);
  bool ok = CGImageDestinationFinalize(dst);
  printf("finalize ok = %d, bytes = %ld\n", ok, (long)CFDataGetLength(data));

  CGImageSourceRef src = CGImageSourceCreateWithData(data, NULL);
  printf("source nonnull = %d\n", src != NULL);
  printf("count = %ld\n", (long)CGImageSourceGetCount(src));
  CFStringRef type = CGImageSourceGetType(src);
  char buf[64] = {0};
  if (type) CFStringGetCString(type, buf, sizeof(buf), kCFStringEncodingUTF8);
  printf("type = %s\n", buf);

  CGImageRef back = CGImageSourceCreateImageAtIndex(src, 0, NULL);
  printf("decoded w=%ld h=%ld\n",
    (long)CGImageGetWidth(back), (long)CGImageGetHeight(back));

  unsigned char *out = calloc(2 * 2 * 4, 1);
  CGContextRef rc = CGBitmapContextCreate(out, 2, 2, 8, 8, dev,
    kCGImageAlphaPremultipliedLast);
  CGContextDrawImage(rc, CGRectMake(0, 0, 2, 2), back);
  unsigned char *o = CGBitmapContextGetData(rc);
  /* Bitmap row 0 is the bottom of the image. */
  printf("bottom-left  = %d %d %d %d\n", o[0], o[1], o[2], o[3]);
  printf("bottom-right = %d %d %d %d\n", o[4], o[5], o[6], o[7]);
  printf("top-left     = %d %d %d %d\n", o[8], o[9], o[10], o[11]);
  printf("top-right    = %d %d %d %d\n", o[12], o[13], o[14], o[15]);

  return 0;
}
