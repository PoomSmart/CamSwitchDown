#define UNRESTRICTED_AVAILABILITY
#import "../PSHeader/Availability.h"
#import "../PSHeader/CameraApp/CameraApp.h"
#import "../PSHeader/PhotoLibrary/PhotoLibrary.h"
#import "../PSHeader/iOSVersions.h"
#import <UIKit/UIApplication+Private.h>

@interface CAMFlipButton (ToBeFilterButton)
- (void)setOn:(BOOL)on;
- (UIImage *)_flipOnImage;
@end

@interface CAMFlipButton (CamSwitchDown)
- (void)cms_updateImage:(BOOL)isVideo;
- (UIImage *)_flipImage2;
@end

@interface CAMFilterButton (CamSwitchDown)
- (void)cms_updateImage:(BOOL)isVideo;
- (UIImage *)_filterImage2;
@end

#define isPhotoMode(mode) (mode == 0 || mode == 4)
#define isVideoMode(mode) (mode == 1 || mode == 2 || mode == 3 || mode == 6)
#define cameraBundle [NSBundle bundleForClass:NSClassFromString(@"CAMShutterButton")]
