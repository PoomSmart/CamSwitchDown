#import "Header.h"

%hook CAMCameraView

- (void)_updateFilterButtonOnState {
    if (isVideoMode(self.cameraMode)) {
        %orig;
        return;
    }
    [(CAMFilterButton *)[self valueForKey:@"__flipButton"] setOn:[(CAMCaptureController *)[%c(CAMCaptureController) sharedInstance] effectFilterIndexForMode:self.cameraMode] != NSNotFound ? 1 : 0];
}

- (void)_filterButtonTapped:(id)arg1 {
    if (isVideoMode(self.cameraMode)) {
        %orig;
        return;
    }
    [%c(CAMCameraView) cancelPreviousPerformRequestsWithTarget:self selector:@selector(_toggleCameraButtonWasPressed:) object:nil];
    [self _clearFocusViews];
    self._flipping = YES;
    [self performSelector:@selector(_reallyToggleCamera) withObject:nil afterDelay:0.066667];
}

- (void)_toggleCameraButtonWasPressed:(id)arg1 {
    if (isVideoMode(self.cameraMode)) {
        %orig;
        return;
    }
    [self _collapseExpandedButtonsAnimated:YES];
    CAMCaptureController *captureController = [%c(CAMCaptureController) sharedInstance];
    CAMEffectsRenderer *renderer = [captureController effectsRenderer];
    BOOL showingGrid = [renderer isShowingGrid];
    [renderer setShowGrid:!showingGrid animated:YES];
    if (!showingGrid)
        ++self._numFilterSelectionsBeforeCapture;
}

- (BOOL)_shouldHideFlipButtonForMode:(NSInteger)mode {
    if (isVideoMode(mode))
        return %orig;
    return [self _performingDelayedCapture] || [UIApplication shouldMakeUIForDefaultPNG];
}

- (BOOL)_shouldHideFilterButtonForMode:(NSInteger)mode {
    if (isVideoMode(mode))
        return %orig;
    CAMCaptureController *captureController = [%c(CAMCaptureController) sharedInstance];
    return ([captureController hasRearCamera] && ![captureController hasFrontCamera]) || [self _isCapturing] || [UIApplication shouldMakeUIForDefaultPNG] || [self _performingDelayedCapture];
}

- (void)_updateEnabledControlsWithReason:(id)reason forceLog:(BOOL)forceLog {
    %orig;
    [self._filterButton cms_updateImage:isVideoMode(self.cameraMode)];
    [self._flipButton cms_updateImage:isVideoMode(self.cameraMode)];
}

%end

%ctor {
    if (IS_IOS_BETWEEN_EEX(iOS_8_0, iOS_9_0)) {
        %init;
    }
}