/* Apple oracle: CGContextSetBlendMode.  Fill an opaque red base, set a blend
   mode, then fill a half-transparent blue over it; report the resulting pixel
   for every blend mode so the cairo operator mapping can be validated. */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>
#include <stdlib.h>

static const char *names[] = {
  "Normal","Multiply","Screen","Overlay","Darken","Lighten","ColorDodge",
  "ColorBurn","SoftLight","HardLight","Difference","Exclusion","Hue",
  "Saturation","Color","Luminosity","Clear","Copy","SourceIn","SourceOut",
  "SourceAtop","DestOver","DestIn","DestOut","DestAtop","XOR","PlusDarker",
  "PlusLighter"
};

int main(void)
{
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();
  for (int m = 0; m <= 27; m++)
    {
      unsigned char *buf = calloc(4*4*4, 1);
      CGContextRef c = CGBitmapContextCreate(buf, 4, 4, 8, 16, dev,
        kCGImageAlphaPremultipliedLast);
      CGContextSetRGBFillColor(c, 200/255.0, 0, 0, 1);        /* opaque red */
      CGContextFillRect(c, CGRectMake(0, 0, 4, 4));
      CGContextSetBlendMode(c, (CGBlendMode)m);
      CGContextSetRGBFillColor(c, 0, 0, 200/255.0, 0.5);      /* 50% blue */
      CGContextFillRect(c, CGRectMake(0, 0, 4, 4));
      unsigned char *d = CGBitmapContextGetData(c);
      printf("%-12s %d,%d,%d,%d\n", names[m], d[0], d[1], d[2], d[3]);
      free(buf);
    }
  return 0;
}
