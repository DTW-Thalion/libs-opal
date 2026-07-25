/* Apple oracle: an axial (and radial) CGShading built from a CGFunction that
   ramps black->white, drawn into a 10x10 device-RGB bitmap.  Reports pixels
   along the axis so the gradient shape and the extend behaviour are known. */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>
#include <stdlib.h>

static void ramp(void *info, const CGFloat *in, CGFloat *out)
{
  CGFloat t = in[0];
  out[0] = t; out[1] = t; out[2] = t; out[3] = 1; /* black -> white, opaque */
}

static CGFunctionRef makeFn(void)
{
  CGFloat domain[] = {0, 1};
  CGFloat range[] = {0, 1, 0, 1, 0, 1, 0, 1};
  CGFunctionCallbacks cb = {0, ramp, NULL};
  return CGFunctionCreate(NULL, 1, domain, 4, range, &cb);
}

static void axis(const char *label, int extend)
{
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();
  unsigned char *buf = calloc(10 * 10 * 4, 1);
  CGContextRef c = CGBitmapContextCreate(buf, 10, 10, 8, 40, dev,
    kCGImageAlphaPremultipliedLast);
  CGFunctionRef fn = makeFn();
  CGShadingRef sh = CGShadingCreateAxial(dev, CGPointMake(2, 5),
    CGPointMake(8, 5), fn, extend, extend);
  CGContextDrawShading(c, sh);
  unsigned char *d = CGBitmapContextGetData(c);
  printf("%s (extend=%d):", label, extend);
  int xs[] = {0, 2, 5, 8, 9};
  for (int i = 0; i < 5; i++)
    {
      int o = (5 * 10 + xs[i]) * 4;
      printf(" x%d=(%d,%d,%d,%d)", xs[i], d[o], d[o+1], d[o+2], d[o+3]);
    }
  printf("\n");
  free(buf);
}

int main(void)
{
  axis("axial", 0);
  axis("axial", 1);

  /* Radial: concentric, centre (5,5), r 0 -> 5. */
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();
  unsigned char *buf = calloc(10 * 10 * 4, 1);
  CGContextRef c = CGBitmapContextCreate(buf, 10, 10, 8, 40, dev,
    kCGImageAlphaPremultipliedLast);
  CGFunctionRef fn = makeFn();
  CGShadingRef sh = CGShadingCreateRadial(dev, CGPointMake(5, 5), 0,
    CGPointMake(5, 5), 5, fn, 1, 1);
  CGContextDrawShading(c, sh);
  unsigned char *d = CGBitmapContextGetData(c);
  int oc = (5 * 10 + 5) * 4, oe = (5 * 10 + 0) * 4;
  printf("radial: centre=(%d,%d,%d,%d) edge=(%d,%d,%d,%d)\n",
    d[oc], d[oc+1], d[oc+2], d[oc+3], d[oe], d[oe+1], d[oe+2], d[oe+3]);
  free(buf);
  return 0;
}
