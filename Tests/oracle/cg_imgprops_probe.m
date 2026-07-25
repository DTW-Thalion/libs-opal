/* Apple oracle: CGImageSourceCopyPropertiesAtIndex for a generated PNG and
   JPEG - which keys/values Apple returns for pixel dimensions, depth, colour
   model, alpha and DPI. */
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import <Foundation/Foundation.h>
#include <stdio.h>

static CGImageRef solid(CGColorSpaceRef dev, int w, int h)
{
  CGContextRef c = CGBitmapContextCreate(NULL, w, h, 8, w*4, dev,
    kCGImageAlphaPremultipliedLast);
  CGContextSetRGBFillColor(c, 0, 1, 0, 1);
  CGContextFillRect(c, CGRectMake(0, 0, w, h));
  CGImageRef img = CGBitmapContextCreateImage(c);
  CGContextRelease(c);
  return img;
}

static void dumpProps(const char *label, NSData *data)
{
  CGImageSourceRef s = CGImageSourceCreateWithData((CFDataRef)data, NULL);
  NSDictionary *p = (NSDictionary *)CGImageSourceCopyPropertiesAtIndex(s, 0, NULL);
  NSLog(@"%s props = %@", label, p);
}

int main(void)
{
  @autoreleasepool {
    CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();

    NSMutableData *png = [NSMutableData data];
    CGImageDestinationRef pd = CGImageDestinationCreateWithData(
      (CFMutableDataRef)png, CFSTR("public.png"), 1, NULL);
    CGImageDestinationAddImage(pd, solid(dev, 3, 5), NULL);
    CGImageDestinationFinalize(pd);
    dumpProps("PNG(3x5)", png);

    NSMutableData *jpg = [NSMutableData data];
    CGImageDestinationRef jd = CGImageDestinationCreateWithData(
      (CFMutableDataRef)jpg, CFSTR("public.jpeg"), 1, NULL);
    CGImageDestinationAddImage(jd, solid(dev, 7, 4), NULL);
    CGImageDestinationFinalize(jd);
    dumpProps("JPEG(7x4)", jpg);
  }
  return 0;
}
