#import "../PS.h"

extern "C" NSBundle *CAMCameraUIFrameworkBundle();

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

// Swap them? Very very confusing
// Just reverse and copy API from iOS 9 CameraUI.framework, so it does not support iOS <= 8 yet
// Currently supports only non-iPad devices running iOS 9

%hook CAMFlipButton

%new
- (UIImage *)_flipImage2
{
	NSBundle *bundle = [CAMCameraUIFrameworkBundle() retain];
    UIImage *image = [[UIImage imageNamed:@"CAMFilterButton2" inBundle:bundle] retain];
    UIColor *whiteColor = [UIColor.whiteColor retain];
    image = [[image _flatImageWithColor:whiteColor] retain];
    UIImage *trueImage = [[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] retain];
    [image release];
    [whiteColor release];
    [bundle release];
	return [trueImage autorelease];
}

%new
- (UIImage *)_flipOnImage
{
	NSBundle *bundle = [CAMCameraUIFrameworkBundle() retain];
    UIImage *image = [[UIImage imageNamed:@"CAMFilterButtonOn2" inBundle:bundle] retain];
    UIImage *trueImage = [[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] retain];
    [image release];
    [bundle release];
	return [trueImage autorelease];
}

%new
- (void)setOn:(BOOL)on
{
	[self setSelected:on];
}

- (void)_commonCAMFlipButtonInitialization
{
	UIImage *filterImage = [[self _flipImage] retain];
	[self setImage:filterImage forState:0];
	[self setImage:filterImage forState:2];
	[filterImage release];
	UIImage *filterOnImage = [[self _flipOnImage] retain];
	[self setImage:filterOnImage forState:4];
	[self setImage:filterOnImage forState:5];
	[self setImage:filterOnImage forState:6];
	[filterOnImage release];
}

%new
- (void)cms_updateImage:(BOOL)isVideo
{
	UIImage *filterImage = isVideo ? [[self _flipImage] retain] : [[self _flipImage2] retain];
	//UIImage *filterOnImage = isVideo ? [[self _flipOnImage] retain] : [[self _flipOnImage2] retain];
	[self setImage:filterImage forState:0];
	[self setImage:filterImage forState:2];
	[filterImage release];
	self.tintColor = UIColor.whiteColor;
	/*[self setImage:filterOnImage forState:4];
	[self setImage:filterOnImage forState:5];
	[self setImage:filterOnImage forState:6];
	[filterOnImage release];*/
}

%end

%hook CAMFilterButton

%new
- (UIImage *)_filterImage2
{
	NSBundle *bundle = [CAMCameraUIFrameworkBundle() retain];
	UIImage *image = [[UIImage imageNamed:@"CAMFlipButton2" inBundle:bundle] retain];
    UIImage *trueImage = [[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] retain];
    [image release];
    [bundle release];
	return [trueImage autorelease];
}

- (void)_commonCAMFilterButtonInitialization
{
	UIColor *tintColor = [UIColor.whiteColor retain];
	self.tintColor = tintColor;
	[tintColor release];
	UIImage *flipImage = [[self _filterImage] retain];
	[self setImage:flipImage forState:0];
	[self setImage:flipImage forState:2];
	[flipImage release];
}

%new
- (void)cms_updateImage:(BOOL)isVideo
{
	UIImage *image = isVideo ? [[self _filterImage] retain] : [[self _filterImage2] retain];
	[self setImage:image forState:0];
	[self setImage:image forState:2];
	[image autorelease];
}

%end

%hook CAMBottomBar

- (void)_layoutFilterButtonForTraitCollection:(UITraitCollection *)collection
{
	// This would layout our flip button, here we have to fix its layout because image is now different
	%orig;
	if (![[self class] wantsVerticalBarForTraitCollection:collection]) {
		CGFloat imageGap = (self.filterButton.frame.size.height - self.filterButton.imageView.frame.size.height) * 0.5;
		self.filterButton.center = CGPointMake(self.filterButton.center.x, CGRectGetMidY(self.bounds) + imageGap - 4);
	}
}

%end

%hook CAMViewfinderViewController

- (void)_updateFilterButtonOnState
{
	if (isVideoMode(self._currentMode)) {
		%orig;
		return;
	}
	// Have to set filter button state, but we do so for flip button instead
	[MSHookIvar<CAMFilterButton *>(self, "__flipButton") setOn:[self _effectFilterTypeForMode:self._currentMode] ? 1 : 0];
}

- (void)_handleFilterButtonTapped:(id)arg1
{
	if (isVideoMode(self._currentMode)) {
		%orig;
		return;
	}
	// This is flip button
	NSInteger desiredCaptureDevice = self._desiredCaptureDevice;
	[self _handleUserChangedFromDevice:desiredCaptureDevice toDevice:desiredCaptureDevice == 1 ? 0 : 1];
}

- (void)_handleFlipButtonReleased:(id)arg1
{
	if (isVideoMode(self._currentMode)) {
		%orig;
		return;
	}
	// This is filter button
	[self _collapseExpandedButtonsAnimated:YES];
	CAMPreviewViewController *previewViewController(MSHookIvar<CAMPreviewViewController *>(self, "__previewViewController"));
	CAMEffectsRenderer *renderer = [[previewViewController effectsRenderer] retain];
	BOOL showingGrid = [renderer isShowingGrid];
	[renderer setShowGrid:!showingGrid animated:YES];
	if (!showingGrid)
		[self _setNumFilterSelectionsBeforeCapture:[self _numFilterSelectionsBeforeCapture] + 1];
	[renderer release];
}

- (BOOL)_shouldHideFlipButtonForMode:(NSInteger)mode device:(NSInteger)device
{
	if (isVideoMode(mode))
		return %orig;
	// Should we hide filter button?
	return [self _isCapturingFromTimer] || [UIApplication shouldMakeUIForDefaultPNG] || [self._topBar shouldHideFlipButtonForMode:mode device:device] || isVideoMode(mode);
}

- (BOOL)_shouldHideFilterButtonForMode:(NSInteger)mode device:(NSInteger)device
{
	if (isVideoMode(mode))
		return %orig;
	// Should we hide flip button?
	CAMCaptureCapabilities *capabilities = [[CAMCaptureCapabilities capabilities] retain];
	CUCaptureController *captureController = [self._captureController retain];
	BOOL value = YES;
	if ([capabilities isBackCameraSupported])
		value = ![capabilities isFrontCameraSupported];
	value = [captureController isCapturingVideo] || [UIApplication shouldMakeUIForDefaultPNG] || [captureController isCapturingTimelapse] || [self _isCapturingFromTimer];
	[captureController release];
	[capabilities release];
	return value || mode == 2 || mode == 3 || mode > 5;
}

- (void)_updateEnabledControlsWithReason:(id)arg1 forceLog:(BOOL)arg2
{
	%orig;
	[self._filterButton cms_updateImage:isVideoMode(self._currentMode)];
	[self._flipButton cms_updateImage:isVideoMode(self._currentMode)];
}

%end

%ctor
{
	%init;
}