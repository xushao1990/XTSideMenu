//
//  XTBlurView.m
//  NewXTNews
//
//  Created by XT on 14-8-10.
//  Copyright (c) 2014年 XT. All rights reserved.
//

#import "XTBlurView.h"
#import "UIImage+ImageEffects.h"

@implementation UIView (rn_Screenshot)

- (UIImage *)rn_screenshot {
    UIGraphicsBeginImageContext(self.bounds.size);
    if([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]){
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    }
    else{
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

NSString * const XTBlurViewImageKey = @"XTBlurViewImageKey";

@implementation XTBlurView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.blurRadius = 20;
        self.saturationDelta = 1.5;
        self.tintColor = nil;
        self.viewToBlur = nil;
        self.clipsToBounds = YES;
        self.blur = YES;
    }
    return self;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:[UIImage imageWithCGImage:(CGImageRef)self.layer.contents] forKey:XTBlurViewImageKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    self.layer.contents = (id)[[coder decodeObjectForKey:XTBlurViewImageKey] CGImage];
}

- (UIView *)viewToBlur {
    if(_viewToBlur)
        return _viewToBlur;
    return self.superview;
}

- (void)updateBlur {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *blurredImage = [self applyBlurToImage:[self.viewToBlur rn_screenshot]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.layer.contents = (id)blurredImage.CGImage;
        });
    });
}

- (UIImage *)applyBlurToImage:(UIImage *)image {
    return [image applyBlurWithRadius:self.blurRadius
                            tintColor:self.tintColor
                saturationDeltaFactor:self.saturationDelta
                            maskImage:nil];
}

- (void)didMoveToSuperview {
    if (self.blur) {        
        if(self.superview && self.viewToBlur.superview) {
            self.backgroundColor = [UIColor clearColor];
            [self updateBlur];
        }
        else if (!self.layer.contents) {
            self.backgroundColor = [UIColor whiteColor];
        }
    }
}


@end
