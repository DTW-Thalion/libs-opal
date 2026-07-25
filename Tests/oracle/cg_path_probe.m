/* Apple oracle: CGPath bounding boxes, current point, containment, emptiness,
   equality, and filling a path into a bitmap. */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>

static void rb(const char *name, CGRect r)
{
  printf("%s = (%g,%g,%g,%g)\n", name,
    r.origin.x, r.origin.y, r.size.width, r.size.height);
}

int main(void)
{
  CGMutablePathRef rect = CGPathCreateMutable();
  CGPathAddRect(rect, NULL, CGRectMake(10, 20, 30, 40));
  rb("rect BoundingBox", CGPathGetBoundingBox(rect));
  rb("rect PathBoundingBox", CGPathGetPathBoundingBox(rect));
  CGPoint cur = CGPathGetCurrentPoint(rect);
  printf("rect current=(%g,%g) isEmpty=%d\n", cur.x, cur.y, CGPathIsEmpty(rect));
  printf("rect contains (15,30)=%d (5,5)=%d (40,60)=%d\n",
    CGPathContainsPoint(rect, NULL, CGPointMake(15, 30), false),
    CGPathContainsPoint(rect, NULL, CGPointMake(5, 5), false),
    CGPathContainsPoint(rect, NULL, CGPointMake(40, 60), false));

  CGMutablePathRef line = CGPathCreateMutable();
  CGPathMoveToPoint(line, NULL, 5, 5);
  CGPathAddLineToPoint(line, NULL, 15, 25);
  cur = CGPathGetCurrentPoint(line);
  printf("line current=(%g,%g)\n", cur.x, cur.y);
  rb("line BoundingBox", CGPathGetBoundingBox(line));

  CGMutablePathRef curve = CGPathCreateMutable();
  CGPathMoveToPoint(curve, NULL, 0, 0);
  CGPathAddCurveToPoint(curve, NULL, 0, 100, 100, 100, 100, 0);
  rb("curve BoundingBox", CGPathGetBoundingBox(curve));
  rb("curve PathBoundingBox", CGPathGetPathBoundingBox(curve));

  CGMutablePathRef empty = CGPathCreateMutable();
  printf("empty isEmpty=%d\n", CGPathIsEmpty(empty));

  CGMutablePathRef rect2 = CGPathCreateMutable();
  CGPathAddRect(rect2, NULL, CGRectMake(10, 20, 30, 40));
  printf("equal(rect,rect2)=%d equal(rect,line)=%d\n",
    CGPathEqualToPath(rect, rect2), CGPathEqualToPath(rect, line));

  /* Fill a rect path into a bitmap and sample inside and outside. */
  CGColorSpaceRef dev = CGColorSpaceCreateDeviceRGB();
  unsigned char *data = calloc(10 * 10 * 4, 1);
  CGContextRef ctx = CGBitmapContextCreate(data, 10, 10, 8, 40, dev,
    kCGImageAlphaPremultipliedLast);
  CGFloat comps[] = {0.0, 1.0, 0.0, 1.0};
  CGColorRef green = CGColorCreate(dev, comps);
  CGContextSetFillColorWithColor(ctx, green);
  CGMutablePathRef fillp = CGPathCreateMutable();
  CGPathAddRect(fillp, NULL, CGRectMake(2, 2, 4, 4));
  CGContextAddPath(ctx, fillp);
  CGContextFillPath(ctx);
  unsigned char *d = (unsigned char *)CGBitmapContextGetData(ctx);
  int in = (4 * 10 + 4) * 4;   /* pixel (4,4) inside */
  int out = (0 * 10 + 0) * 4;  /* pixel (0,0) outside */
  printf("fill rect(2,2,4,4): inside(4,4)=%d %d %d %d outside(0,0)=%d %d %d %d\n",
    d[in], d[in+1], d[in+2], d[in+3], d[out], d[out+1], d[out+2], d[out+3]);

  return 0;
}
