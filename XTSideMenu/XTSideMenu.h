//
//  XTSideMenu.h
//  NewXTNews
//
//  Created by XT on 14-8-9.
//  Copyright (c) 2014年 XT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+XTFrame.h"
#import "XTBlurView.h"

@protocol XTSideMenuDelegate;

@interface XTSideMenu : UIViewController

@property (nonatomic, strong) UIViewController *contentViewController;

@property (nonatomic, strong) UIViewController *leftMenuViewController;

@property (nonatomic, strong) UIViewController *rightMenuViewController;

@property (nonatomic, weak) id <XTSideMenuDelegate> delegate;

@property (nonatomic) BOOL contentBlur;

@property (nonatomic) BOOL panGestureEnabled;

@property (nonatomic) NSTimeInterval animationDuration;

@property (nonatomic, strong) UIColor *contentBlurViewTintColor;

@property (nonatomic) CGFloat contentBlurViewMinAlpha;

@property (nonatomic) CGFloat contentBlurViewMaxAlpha;

@property (nonatomic) CGFloat leftMenuViewVisibleWidth;

@property (nonatomic) CGFloat rightMenuViewVisibleWidth;

@property (nonatomic, strong) UIColor *menuOpacityViewLeftBackgroundColor;

@property (nonatomic, strong) UIColor *menuOpacityViewRightBackgroundColor;

@property (nonatomic) CGFloat menuOpacityViewLeftMinAlpha;

@property (nonatomic) CGFloat menuOpacityViewLeftMaxAlpha;

@property (nonatomic) CGFloat menuOpacityViewRightMinAlpha;

@property (nonatomic) CGFloat menuOpacityViewRightMaxAlpha;

- (instancetype)initWithContentViewController:(UIViewController *)contentViewController
                       leftMenuViewController:(UIViewController *)leftMenuViewController
                      rightMenuViewController:(UIViewController *)rightMenuViewController;

- (void)presentLeftViewController;
- (void)presentRightViewController;
- (void)hideMenuViewController;

@end

@protocol XTSideMenuDelegate <NSObject>

@optional

- (void)sideMenu:(XTSideMenu *)sideMenu didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer;

- (void)sideMenu:(XTSideMenu *)sideMenu willShowLeftMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(XTSideMenu *)sideMenu didShowLeftMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(XTSideMenu *)sideMenu willHideLeftMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(XTSideMenu *)sideMenu didHideLeftMenuViewController:(UIViewController *)menuViewController;

- (void)sideMenu:(XTSideMenu *)sideMenu willShowRightMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(XTSideMenu *)sideMenu didShowRightMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(XTSideMenu *)sideMenu willHideRightMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(XTSideMenu *)sideMenu didHideRightMenuViewController:(UIViewController *)menuViewController;

@end