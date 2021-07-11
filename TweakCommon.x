#import "Header.h"
#import <UIKit/UIImage+Private.h>

%hook CAMFlipButton

%new
- (UIImage *)_flipImage2 {
    UIImage *image = [UIImage imageNamed:@"CAMFilterButton2" inBundle:cameraBundle];
    image = [image _flatImageWithColor:UIColor.whiteColor];
    UIImage *trueImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return trueImage;
}

%new
- (UIImage *)_flipOnImage {
    UIImage *image = [UIImage imageNamed:@"CAMFilterButtonOn2" inBundle:cameraBundle];
    UIImage *trueImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return trueImage;
}

%new
- (void)setOn:(BOOL)on {
    [self setSelected:on];
}

- (void)_commonCAMFlipButtonInitialization {
    UIImage *filterImage = [self _flipImage];
    [self setImage:filterImage forState:0];
    [self setImage:filterImage forState:2];
    UIImage *filterOnImage = [self _flipOnImage];
    [self setImage:filterOnImage forState:4];
    [self setImage:filterOnImage forState:5];
    [self setImage:filterOnImage forState:6];
}

%new
- (void)cms_updateImage:(BOOL)isVideo {
    UIImage *filterImage = isVideo ? [self _flipImage] : [self _flipImage2];
    [self setImage:filterImage forState:0];
    [self setImage:filterImage forState:2];
    self.tintColor = UIColor.whiteColor;
}

%end

%hook CAMFilterButton

%new
- (UIImage *)_filterImage2 {
    UIImage *image = [UIImage imageNamed:@"CAMFlipButton2" inBundle:cameraBundle];
    UIImage *trueImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return trueImage;
}

- (void)_commonCAMFilterButtonInitialization {
    self.tintColor = UIColor.whiteColor;
    UIImage *flipImage = [self _filterImage];
    [self setImage:flipImage forState:0];
    [self setImage:flipImage forState:2];
}

%new
- (void)cms_updateImage:(BOOL)isVideo {
    UIImage *image = isVideo ? [self _filterImage] : [self _filterImage2];
    [self setImage:image forState:0];
    [self setImage:image forState:2];
}

%end
