#import "Header.h"

%hook CAMBottomBar

- (void)_layoutFilterButtonForTraitCollection:(UITraitCollection *)collection {
    // This would layout our flip button, here we have to fix its layout because image is now different
    %orig;
    if (![[self class] wantsVerticalBarForTraitCollection:collection]) {
        CGFloat imageGap = (self.filterButton.frame.size.height - self.filterButton.imageView.frame.size.height) * 0.5;
        self.filterButton.center = CGPointMake(self.filterButton.center.x, CGRectGetMidY(self.bounds) + imageGap - 4.0);
    }
}

%end

%hook CAMViewfinderViewController

- (void)_updateFilterButtonOnState {
    if (isVideoMode(self._currentMode)) {
        %orig;
        return;
    }
    // Have to set filter button state, but we do so for flip button instead
    [(CAMFilterButton *)[self valueForKey:@"__flipButton"] setOn:[self _effectFilterTypeForMode:self._currentMode] ? 1 : 0];
}

- (void)_handleFilterButtonTapped:(id)arg1 {
    if (isVideoMode(self._currentMode)) {
        %orig;
        return;
    }
    // This is flip button
    NSInteger desiredCaptureDevice = self._desiredCaptureDevice;
    [self _handleUserChangedFromDevice:desiredCaptureDevice toDevice:desiredCaptureDevice == 1 ? 0 : 1];
}

- (void)_handleFlipButtonReleased:(id)arg1 {
    if (isVideoMode(self._currentMode)) {
        %orig;
        return;
    }
    // This is filter button
    [self _collapseExpandedButtonsAnimated:YES];
    CAMEffectsRenderer *renderer = [(CAMPreviewViewController *)[self valueForKey:@"__previewViewController"] effectsRenderer];
    BOOL showingGrid = [renderer isShowingGrid];
    [renderer setShowGrid:!showingGrid animated:YES];
    if (!showingGrid)
        ++self._numFilterSelectionsBeforeCapture;
}

- (BOOL)_shouldHideFlipButtonForMode:(NSInteger)mode device:(NSInteger)device {
    if (isVideoMode(mode))
        return %orig;
    // Should we hide filter button?
    return [self _isCapturingFromTimer] || [UIApplication shouldMakeUIForDefaultPNG] || [self._topBar shouldHideFlipButtonForMode:mode device:device] || isVideoMode(mode);
}

- (BOOL)_shouldHideFilterButtonForMode:(NSInteger)mode device:(NSInteger)device {
    if (isVideoMode(mode))
        return %orig;
    // Should we hide flip button?
    CAMCaptureCapabilities *capabilities = [%c(CAMCaptureCapabilities) capabilities];
    CUCaptureController *captureController = self._captureController;
    BOOL value = [capabilities isBackCameraSupported] && ![capabilities isFrontCameraSupported];
    value |= [captureController isCapturingVideo] || [UIApplication shouldMakeUIForDefaultPNG] || [captureController isCapturingTimelapse] || [self _isCapturingFromTimer];
    return value || mode == 2 || mode == 3 || mode > 5;
}

- (void)_updateEnabledControlsWithReason:(id)reason forceLog:(BOOL)forceLog {
    %orig;
    [self._filterButton cms_updateImage:isVideoMode(self._currentMode)];
    [self._flipButton cms_updateImage:isVideoMode(self._currentMode)];
}

%end

%ctor {
    if (IS_IOS_OR_NEWER(iOS_9_0)) {
        %init;
    }
}