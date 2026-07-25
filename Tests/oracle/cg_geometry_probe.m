/* Apple oracle: CGGeometry rect algebra and the null/empty/infinite edges. */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>

static void r(const char *name, CGRect v)
{
  printf("%s: x=%g y=%g w=%g h=%g\n",
    name, v.origin.x, v.origin.y, v.size.width, v.size.height);
}

int main(void)
{
  CGRect a = CGRectMake(0, 0, 10, 10);
  CGRect b = CGRectMake(5, 5, 10, 10);
  CGRect disjoint = CGRectMake(100, 100, 5, 5);
  CGRect neg = CGRectMake(10, 10, -4, -6);

  /* accessors */
  printf("MinX=%g MidX=%g MaxX=%g Width=%g Height=%g\n",
    CGRectGetMinX(a), CGRectGetMidX(a), CGRectGetMaxX(a),
    CGRectGetWidth(a), CGRectGetHeight(a));
  printf("neg MinX=%g MaxX=%g Width=%g (accessors standardize?)\n",
    CGRectGetMinX(neg), CGRectGetMaxX(neg), CGRectGetWidth(neg));

  r("Standardize(neg)", CGRectStandardize(neg));
  r("Intersection(a,b)", CGRectIntersection(a, b));
  r("Intersection(a,disjoint)", CGRectIntersection(a, disjoint));
  printf("Intersection(a,disjoint) IsNull=%d IsEmpty=%d\n",
    CGRectIsNull(CGRectIntersection(a, disjoint)),
    CGRectIsEmpty(CGRectIntersection(a, disjoint)));
  r("Union(a,b)", CGRectUnion(a, b));
  r("Union(a,Null)", CGRectUnion(a, CGRectNull));
  r("Union(a,Zero)", CGRectUnion(a, CGRectZero));
  r("Inset(a,2,3)", CGRectInset(a, 2, 3));
  r("Inset(a,-2,-3)", CGRectInset(a, -2, -3));
  r("Inset(a,6,6)", CGRectInset(a, 6, 6));
  printf("Inset(a,6,6) IsEmpty=%d IsNull=%d\n",
    CGRectIsEmpty(CGRectInset(a, 6, 6)), CGRectIsNull(CGRectInset(a, 6, 6)));
  r("Offset(a,3,4)", CGRectOffset(a, 3, 4));
  r("Integral(1.2,2.7,3.3,4.6)",
    CGRectIntegral(CGRectMake(1.2, 2.7, 3.3, 4.6)));

  CGRect slice, rem;
  CGRectDivide(a, &slice, &rem, 3, CGRectMinXEdge);
  r("Divide slice(3,MinX)", slice);
  r("Divide rem(3,MinX)", rem);

  /* predicates */
  printf("Contains a,(5,5)=%d a,(10,10)=%d a,(0,0)=%d\n",
    CGRectContainsPoint(a, CGPointMake(5, 5)),
    CGRectContainsPoint(a, CGPointMake(10, 10)),
    CGRectContainsPoint(a, CGPointMake(0, 0)));
  printf("ContainsRect a,(2,2,3,3)=%d a,b=%d\n",
    CGRectContainsRect(a, CGRectMake(2, 2, 3, 3)),
    CGRectContainsRect(a, b));
  printf("Intersects a,b=%d a,disjoint=%d\n",
    CGRectIntersectsRect(a, b), CGRectIntersectsRect(a, disjoint));
  printf("Equal a,a=%d a,b=%d\n",
    CGRectEqualToRect(a, a), CGRectEqualToRect(a, b));

  /* special rects */
  printf("Null IsNull=%d IsEmpty=%d IsInfinite=%d\n",
    CGRectIsNull(CGRectNull), CGRectIsEmpty(CGRectNull),
    CGRectIsInfinite(CGRectNull));
  printf("Zero IsNull=%d IsEmpty=%d\n",
    CGRectIsNull(CGRectZero), CGRectIsEmpty(CGRectZero));
  printf("Infinite IsInfinite=%d IsEmpty=%d IsNull=%d\n",
    CGRectIsInfinite(CGRectInfinite), CGRectIsEmpty(CGRectInfinite),
    CGRectIsNull(CGRectInfinite));
  r("CGRectNull", CGRectNull);
  printf("empty(0,0,0,5) IsEmpty=%d\n", CGRectIsEmpty(CGRectMake(0, 0, 0, 5)));

  return 0;
}
