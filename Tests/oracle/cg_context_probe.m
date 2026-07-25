/* Apple oracle: CGContext graphics state - the CTM of a bitmap context,
   transforms, save/restore, clipping and global alpha. */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>
#include <stdlib.h>

static CGContextRef makeCtx(unsigned char **data)
{
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();
  *data = calloc(10 * 10 * 4, 1);
  return CGBitmapContextCreate(*data, 10, 10, 8, 40, dev,
    kCGImageAlphaPremultipliedLast);
}

static void m(const char *name, CGAffineTransform t)
{
  printf("%s: a=%g b=%g c=%g d=%g tx=%g ty=%g\n",
    name, t.a, t.b, t.c, t.d, t.tx, t.ty);
}

int main(void)
{
  unsigned char *data;
  CGContextRef ctx = makeCtx(&data);

  m("initial CTM", CGContextGetCTM(ctx));
  CGContextTranslateCTM(ctx, 2, 3);
  m("after translate(2,3)", CGContextGetCTM(ctx));
  CGContextScaleCTM(ctx, 2, 2);
  m("after scale(2,2)", CGContextGetCTM(ctx));

  CGContextSaveGState(ctx);
  CGContextTranslateCTM(ctx, 100, 100);
  CGContextRestoreGState(ctx);
  m("after save/translate/restore", CGContextGetCTM(ctx));

  /* Clip: fill a full green rect but clip to (2,2,4,4). */
  unsigned char *cdata;
  CGContextRef cctx = makeCtx(&cdata);
  CGFloat green[] = {0, 1, 0, 1};
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();
  CGColorRef gc = CGColorCreate(dev, green);
  CGContextSetFillColorWithColor(cctx, gc);
  CGContextClipToRect(cctx, CGRectMake(2, 2, 4, 4));
  CGContextFillRect(cctx, CGRectMake(0, 0, 10, 10));
  unsigned char *cd = (unsigned char *)CGBitmapContextGetData(cctx);
  int inC = (4 * 10 + 4) * 4, outC = (0 * 10 + 0) * 4;
  printf("clip: inside(4,4)=%d %d %d %d outside(0,0)=%d %d %d %d\n",
    cd[inC], cd[inC+1], cd[inC+2], cd[inC+3],
    cd[outC], cd[outC+1], cd[outC+2], cd[outC+3]);

  /* Global alpha: opaque red at alpha 0.5. */
  unsigned char *adata;
  CGContextRef actx = makeCtx(&adata);
  CGFloat red[] = {1, 0, 0, 1};
  CGColorRef rc = CGColorCreate(dev, red);
  CGContextSetAlpha(actx, 0.5);
  CGContextSetFillColorWithColor(actx, rc);
  CGContextFillRect(actx, CGRectMake(0, 0, 10, 10));
  unsigned char *ad = (unsigned char *)CGBitmapContextGetData(actx);
  printf("alpha 0.5 red pixel = %d %d %d %d\n", ad[0], ad[1], ad[2], ad[3]);

  return 0;
}
