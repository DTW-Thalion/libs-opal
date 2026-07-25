/* Apple oracle: CGColorSpace models, component counts, and the model enum
   values, for the device and named colour spaces. */
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>

static void dump(const char *name, CGColorSpaceRef cs)
{
  printf("%s: model=%d numComponents=%zu\n", name,
    (int)CGColorSpaceGetModel(cs), CGColorSpaceGetNumberOfComponents(cs));
}

int main(void)
{
  printf("enum: Monochrome=%d RGB=%d CMYK=%d Lab=%d Indexed=%d\n",
    (int)kCGColorSpaceModelMonochrome, (int)kCGColorSpaceModelRGB,
    (int)kCGColorSpaceModelCMYK, (int)kCGColorSpaceModelLab,
    (int)kCGColorSpaceModelIndexed);

  dump("DeviceRGB", CGColorSpaceCreateDeviceRGB());
  dump("DeviceGray", CGColorSpaceCreateDeviceGray());
  dump("DeviceCMYK", CGColorSpaceCreateDeviceCMYK());
  dump("GenericRGB", CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB));
  dump("GenericGray", CGColorSpaceCreateWithName(kCGColorSpaceGenericGray));
  dump("SRGB", CGColorSpaceCreateWithName(kCGColorSpaceSRGB));

  return 0;
}
