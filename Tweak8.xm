#import "Header.h"

%hook CAMCameraView

- (void)_updateFilterButtonOnState {
	if (isVideoMode(self.cameraMode)) {
		%orig;
		return;
	}
	[MSHookIvar<CAMFilterButton *>(self, "__flipButton") setOn:[(CAMCaptureController *)[%c(CAMCaptureController) sharedInstance] effectFilterIndexForMode:self.cameraMode] != NSNotFound ? 1 : 0];
}

- (void)_filterButtonTapped:(id)arg1 {
	if (isVideoMode(self.cameraMode)) {
		%orig;
		return;
	}
	[NSClassFromString(@"CAMCameraView") cancelPreviousPerformRequestsWithTarget:self selector:@selector(_toggleCameraButtonWasPressed:) object:nil];
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
	CAMEffectsRenderer *renderer = [[captureController effectsRenderer] retain];
	BOOL showingGrid = [renderer isShowingGrid];
	[renderer setShowGrid:!showingGrid animated:YES];
	if (!showingGrid)
		self._numFilterSelectionsBeforeCapture++;
	[renderer release];
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

- (void)_updateEnabledControlsWithReason:(id)arg1 forceLog:(BOOL)arg2 {
	%orig;
	[self._filterButton cms_updateImage:isVideoMode(self.cameraMode)];
	[self._flipButton cms_updateImage:isVideoMode(self.cameraMode)];
}

%end

%ctor {
	if (isiOS8) {
		%init;
	}
}