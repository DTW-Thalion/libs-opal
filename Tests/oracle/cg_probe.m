/* Apple oracle: CGAffineTransform construction, composition order,
   inversion, and application to point/size/rect. */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>

static void dump(const char *name, CGAffineTransform t)
{
  printf("%s: a=%g b=%g c=%g d=%g tx=%g ty=%g\n",
    name, t.a, t.b, t.c, t.d, t.tx, t.ty);
}

int main(void)
{
  CGAffineTransform tr = CGAffineTransformMakeTranslation(5, 7);
  CGAffineTransform sc = CGAffineTransformMakeScale(2, 3);
  CGAffineTransform rot = CGAffineTransformMakeRotation(M_PI / 6);

  dump("MakeTranslation(5,7)", tr);
  dump("MakeScale(2,3)", sc);
  dump("MakeRotation(pi/6)", rot);

  /* Composition order: does Concat(t1,t2) apply t1 first or t2 first? */
  CGAffineTransform t1 = CGAffineTransformMakeTranslation(10, 0);
  CGAffineTransform t2 = CGAffineTransformMakeScale(2, 2);
  dump("Concat(translate10,scale2)", CGAffineTransformConcat(t1, t2));
  dump("Concat(scale2,translate10)", CGAffineTransformConcat(t2, t1));

  /* Builder helpers layer onto an existing transform. */
  dump("Scale(translate5_7, 2,3)", CGAffineTransformScale(tr, 2, 3));
  dump("Translate(scale2_3, 5,7)", CGAffineTransformTranslate(sc, 5, 7));
  dump("Rotate(translate5_7, pi/6)", CGAffineTransformRotate(tr, M_PI / 6));

  dump("Invert(scale2_4)", CGAffineTransformInvert(CGAffineTransformMakeScale(2, 4)));
  dump("Invert(translate5_7)", CGAffineTransformInvert(tr));

  /* Application. */
  CGPoint p = CGPointApplyAffineTransform(CGPointMake(1, 1),
    CGAffineTransformConcat(t1, t2));
  printf("apply point(1,1) Concat(translate10,scale2): x=%g y=%g\n", p.x, p.y);

  CGSize s = CGSizeApplyAffineTransform(CGSizeMake(4, 5), sc);
  printf("apply size(4,5) scale(2,3): w=%g h=%g\n", s.width, s.height);

  CGRect r = CGRectApplyAffineTransform(CGRectMake(1, 2, 3, 4), rot);
  printf("apply rect(1,2,3,4) rot(pi/6): x=%g y=%g w=%g h=%g\n",
    r.origin.x, r.origin.y, r.size.width, r.size.height);

  printf("identity isIdentity=%d\n", CGAffineTransformIsIdentity(CGAffineTransformIdentity));
  printf("equal(scale2_3, MakeScale(2,3))=%d\n",
    CGAffineTransformEqualToTransform(sc, CGAffineTransformMakeScale(2, 3)));

  return 0;
}
