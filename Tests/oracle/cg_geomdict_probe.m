/* Apple oracle: the dictionary representations of CGPoint/CGSize/CGRect - what
   keys they use and that they round-trip. */
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#include <stdio.h>

int main(void)
{
  @autoreleasepool {
    CFDictionaryRef pd = CGPointCreateDictionaryRepresentation(CGPointMake(3, 4));
    CFDictionaryRef sd = CGSizeCreateDictionaryRepresentation(CGSizeMake(5, 6));
    CFDictionaryRef rd = CGRectCreateDictionaryRepresentation(CGRectMake(1, 2, 7, 8));

    NSLog(@"point dict = %@", (NSDictionary *)pd);
    NSLog(@"size dict  = %@", (NSDictionary *)sd);
    NSLog(@"rect dict  = %@", (NSDictionary *)rd);

    CGPoint p; CGSize s; CGRect r;
    bool okp = CGPointMakeWithDictionaryRepresentation(pd, &p);
    bool oks = CGSizeMakeWithDictionaryRepresentation(sd, &s);
    bool okr = CGRectMakeWithDictionaryRepresentation(rd, &r);
    printf("point rt=%d (%g,%g)\n", okp, p.x, p.y);
    printf("size  rt=%d (%g,%g)\n", oks, s.width, s.height);
    printf("rect  rt=%d (%g,%g,%g,%g)\n", okr, r.origin.x, r.origin.y, r.size.width, r.size.height);

    /* A malformed dictionary should be rejected. */
    CGPoint q;
    bool bad = CGPointMakeWithDictionaryRepresentation(
      (CFDictionaryRef)[NSDictionary dictionary], &q);
    printf("empty-dict rt=%d\n", bad);
  }
  return 0;
}
