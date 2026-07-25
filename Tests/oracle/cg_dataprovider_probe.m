/* Apple oracle: CGDataProvider behaviours - CopyData round-trips the bytes of
   a data-backed provider, and the releaseData callback passed to
   CGDataProviderCreateWithData is invoked (once) when the provider is released,
   with the original info pointer and buffer. */
#import <CoreGraphics/CoreGraphics.h>
#import <CoreFoundation/CoreFoundation.h>
#include <stdio.h>
#include <string.h>

static int releaseCalls = 0;
static void *seenInfo = (void *)0;
static const void *seenData = (void *)0;
static size_t seenSize = 0;

static void myRelease(void *info, const void *data, size_t size)
{
  releaseCalls++;
  seenInfo = info;
  seenData = data;
  seenSize = size;
}

int main(void)
{
  static const unsigned char bytes[] = {10, 20, 30, 40, 50};
  int marker = 0;

  /* CopyData round-trip. */
  CGDataProviderRef p = CGDataProviderCreateWithData(&marker, bytes,
    sizeof(bytes), myRelease);
  CFDataRef out = CGDataProviderCopyData(p);
  const unsigned char *ob = CFDataGetBytePtr(out);
  printf("copydata len=%ld match=%d\n", (long)CFDataGetLength(out),
    (int)(CFDataGetLength(out) == sizeof(bytes)
          && memcmp(ob, bytes, sizeof(bytes)) == 0));
  CFRelease(out);

  /* releaseData should not have fired yet. */
  printf("before release: calls=%d\n", releaseCalls);

  CGDataProviderRelease(p);
  printf("after release: calls=%d infoMatch=%d dataMatch=%d size=%ld\n",
    releaseCalls, (int)(seenInfo == &marker), (int)(seenData == bytes),
    (long)seenSize);

  return 0;
}
