#import "Header.h"
#import <UIKit/UIImage+Private.h>

%hook CAMFlipButton

%new
- (UIImage *)_flipImage2 {
	NSBundle *bundle = [cameraBundle retain];
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
- (UIImage *)_flipOnImage {
	NSBundle *bundle = [cameraBundle retain];
    UIImage *image = [[UIImage imageNamed:@"CAMFilterButtonOn2" inBundle:bundle] retain];
    UIImage *trueImage = [[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] retain];
    [image release];
    [bundle release];
	return [trueImage autorelease];
}

%new
- (void)setOn:(BOOL)on {
	[self setSelected:on];
}

- (void)_commonCAMFlipButtonInitialization {
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
- (void)cms_updateImage:(BOOL)isVideo {
	UIImage *filterImage = isVideo ? [[self _flipImage] retain] : [[self _flipImage2] retain];
	[self setImage:filterImage forState:0];
	[self setImage:filterImage forState:2];
	[filterImage release];
	self.tintColor = UIColor.whiteColor;
}

%end

%hook CAMFilterButton

%new
- (UIImage *)_filterImage2 {
	NSBundle *bundle = [cameraBundle retain];
	UIImage *image = [[UIImage imageNamed:@"CAMFlipButton2" inBundle:bundle] retain];
    UIImage *trueImage = [[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] retain];
    [image release];
    [bundle release];
	return [trueImage autorelease];
}

- (void)_commonCAMFilterButtonInitialization {
	UIColor *tintColor = [UIColor.whiteColor retain];
	self.tintColor = tintColor;
	[tintColor release];
	UIImage *flipImage = [[self _filterImage] retain];
	[self setImage:flipImage forState:0];
	[self setImage:flipImage forState:2];
	[flipImage release];
}

%new
- (void)cms_updateImage:(BOOL)isVideo {
	UIImage *image = isVideo ? [[self _filterImage] retain] : [[self _filterImage2] retain];
	[self setImage:image forState:0];
	[self setImage:image forState:2];
	[image autorelease];
}

%end

%ctor {
    %init;
}