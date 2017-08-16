#import "Header.h"

%hook PLCameraView

- (void)_updateFilterButtonOnState {
	if (isVideoMode(self.cameraMode)) {
		%orig;
		return;
	}
	[MSHookIvar<CAMFilterButton *>(self, "__flipButton") setOn:[(PLCameraController *)[%c(PLCameraController) sharedInstance] effectFilterIndexForMode:self.cameraMode] != NSNotFound ? 1 : 0];
}

- (void)_filterButtonTapped:(id)arg1 {
	if (isVideoMode(self.cameraMode)) {
		%orig;
		return;
	}
	[NSClassFromString(@"PLCameraView") cancelPreviousPerformRequestsWithTarget:self selector:@selector(_toggleCameraButtonWasPressed:) object:nil];
	[self _clearFocusViews];
    self._flipping = YES;
    [self performSelector:@selector(_reallyToggleCamera) withObject:nil afterDelay:0.066667];
}

- (void)_toggleCameraButtonWasPressed:(id)arg1 {
	if (isVideoMode(self.cameraMode)) {
		%orig;
		return;
	}
	PLCameraController *cameraController = [%c(PLCameraController) sharedInstance];
	PLCameraEffectsRenderer *renderer = [[cameraController effectsRenderer] retain];
	BOOL showingGrid = [renderer isShowingGrid];
	[renderer setShowGrid:!showingGrid animated:YES];
	if (!showingGrid)
		self._numFilterSelectionsBeforeCapture++;
	[renderer release];
}

- (BOOL)_shouldHideFlipButtonForMode:(NSInteger)mode {
	return isVideoMode(mode) ? %orig : [UIApplication shouldMakeUIForDefaultPNG];
}

- (BOOL)_shouldHideFilterButtonForMode:(NSInteger)mode {
	if (isVideoMode(mode))
		return %orig;
	PLCameraController *cameraController = [%c(PLCameraController) sharedInstance];
	return ([cameraController hasRearCamera] && ![cameraController hasFrontCamera]) || [self _isCapturing] || [UIApplication shouldMakeUIForDefaultPNG];
}

- (void)_updateEnabledControlsWithReason:(id)arg1 forceLog:(BOOL)arg2 {
	%orig;
	[self._filterButton cms_updateImage:isVideoMode(self.cameraMode)];
	[self._flipButton cms_updateImage:isVideoMode(self.cameraMode)];
}

%end

%ctor {
	if (isiOS7) {
		%init;
	}
}