//
//  XTSideMenu.m
//  NewXTNews
//
//  Created by XT on 14-8-9.
//  Copyright (c) 2014年 XT. All rights reserved.
//

#import "XTSideMenu.h"

typedef NS_ENUM(NSUInteger, XTSideMenuVisibleType) {
    XTSideMenuVisibleTypeContent = 0,
    XTSideMenuVisibleTypeLeft = 1,
    XTSideMenuVisibleTypeRight = 2,
    XTSideMenuVisibleTypeMoving = 3,
};

typedef NS_ENUM(NSUInteger, XTSideMenuShowType) {
    XTSideMenuShowTypeNone = 0,
    XTSideMenuShowTypeLeft = 1,
    XTSideMenuShowTypeRight = 2,
};

typedef NS_ENUM(NSUInteger, XTSideMenuDelegateType) {
    XTSideMenuDelegateTypeDidRecognizePanGesture,
    
    XTSideMenuDelegateTypeWillShowLeftMenuViewController,
    XTSideMenuDelegateTypeDidShowLeftMenuViewController,
    XTSideMenuDelegateTypeWillHideLeftMenuViewController,
    XTSideMenuDelegateTypeDidHideLeftMenuViewController,
    
    
    XTSideMenuDelegateTypeWillShowRightMenuViewController,
    XTSideMenuDelegateTypeDidShowRightMenuViewController,
    XTSideMenuDelegateTypeWillHideRightMenuViewController,
    XTSideMenuDelegateTypeDidHideRightMenuViewController,
};



@interface XTSideMenu ()<UIGestureRecognizerDelegate>

@property (nonatomic) XTSideMenuVisibleType visibleType;

@property (nonatomic) XTSideMenuShowType showType;

@property (nonatomic) CGPoint originalPoint;

@property (nonatomic, strong) UIView *menuViewContainer;

@property (nonatomic, strong) UIButton *menuButton;

@property (nonatomic, strong) UIView *menuOpacityView;

@property (nonatomic, strong) UIView *contentViewContainer;

@property (nonatomic, strong) XTBlurView *contentBlurView;

@end

@implementation XTSideMenu

- (id)init
{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _visibleType = XTSideMenuVisibleTypeContent;
    
    _menuViewContainer = [[UIView alloc] init];
    
    _contentViewContainer = [[UIView alloc] init];
    
    _contentBlurViewTintColor = [UIColor colorWithWhite:0.7 alpha:0.73];
    
    _contentBlurViewMinAlpha = 0;
    
    _contentBlurViewMaxAlpha = 1.0;
    
    _leftMenuViewVisibleWidth = 240;
    
    _rightMenuViewVisibleWidth = 320;
    
    _animationDuration = 0.35;
    
    _panGestureEnabled = YES;
    
    _contentBlur = NO;
    
    _menuOpacityViewLeftMinAlpha = 0.75;
    
    _menuOpacityViewLeftMaxAlpha = 0.8;
    
    _menuOpacityViewRightMinAlpha = 0.75;
    
    _menuOpacityViewRightMaxAlpha = 0.9;
    
    _menuOpacityViewLeftBackgroundColor = [UIColor colorWithRed:223 / 255.0 green:48 / 255.0 blue:49 / 255.0 alpha:1.0];
    
    _menuOpacityViewRightBackgroundColor = [UIColor blackColor];//[UIColor colorWithRed:223 / 255.0 green:48 / 255.0 blue:49 / 255.0 alpha:1.0];
}

- (instancetype)initWithContentViewController:(UIViewController *)contentViewController leftMenuViewController:(UIViewController *)leftMenuViewController rightMenuViewController:(UIViewController *)rightMenuViewController
{
    if (self = [self init]) {
        _contentViewController = contentViewController;
        _leftMenuViewController = leftMenuViewController;
        _rightMenuViewController = rightMenuViewController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.menuViewContainer];
    [self.view addSubview:self.contentViewContainer];
    
    self.menuViewContainer.frame = self.view.bounds;
    self.menuViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (self.leftMenuViewController) {
        [self addChildViewController:self.leftMenuViewController];
        self.leftMenuViewController.view.frame = CGRectMake(0, 0, self.leftMenuViewVisibleWidth, CGRectGetHeight(self.view.bounds));
        self.leftMenuViewController.view.center = [self leftMenuViewCenter:XTSideMenuShowTypeNone];
        [self.menuViewContainer addSubview:self.leftMenuViewController.view];
        [self.leftMenuViewController didMoveToParentViewController:self];
        self.leftMenuViewController.view.hidden = YES;
    }
    
    if (self.rightMenuViewController) {
        [self addChildViewController:self.rightMenuViewController];
        self.rightMenuViewController.view.frame = CGRectMake(0, 0, self.rightMenuViewVisibleWidth, CGRectGetHeight(self.view.bounds));
        self.rightMenuViewController.view.center = [self rightMenuViewCenter:XTSideMenuShowTypeNone];
        [self.menuViewContainer addSubview:self.rightMenuViewController.view];
        [self.rightMenuViewController didMoveToParentViewController:self];
        self.rightMenuViewController.view.hidden = YES;
    }
    
    self.contentViewContainer.frame = self.view.bounds;
    self.contentViewContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = self.view.bounds;
    [self.contentViewContainer addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    self.menuViewContainer.alpha = 0;
    
    self.view.multipleTouchEnabled = NO;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    panGestureRecognizer.delegate = self;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    [self addCenterKVO];
    
    
    self.menuButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectNull;
        [button addTarget:self action:@selector(hideMenuViewController) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    self.menuOpacityView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectNull];
        view;
    });
    
    self.contentBlurView = ({
        XTBlurView *imageView = [[XTBlurView alloc] initWithFrame:CGRectNull];
        [self updateContentBlurViewImage];
        imageView;
    });
}

#pragma mark -
#pragma mark KVO Method

- (void)addCenterKVO
{
    [self.leftMenuViewController.view addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
    [self.rightMenuViewController.view addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"center"])
    {
        UIView *view = object;
        if (view == self.leftMenuViewController.view)
        {
            if (CGRectGetMinX(view.frame) > 0)
            {
                view.left = 0;
            }
        }
        else if (view == self.rightMenuViewController.view)
        {
            if (CGRectGetMaxX(view.frame) < CGRectGetWidth(self.view.bounds))
            {
                view.right = CGRectGetWidth(self.view.bounds);
            }
        }
    }
}

#pragma mark -
#pragma mark - PublicMethod

/*!
 *  显示leftMenu
 */

- (void)presentLeftViewController
{
    if (self.leftMenuViewController)
    {
        [self dealDelegateWithType:XTSideMenuDelegateTypeWillShowLeftMenuViewController object:self.leftMenuViewController];
        
        [self _presentLeftViewController];
    }
    else
    {
         NSAssert(false,@"NONE LEFTMENU!");
    }
}

/*!
 *  显示rightMenu
 */

- (void)presentRightViewController
{
    if (self.rightMenuViewController)
    {
        [self dealDelegateWithType:XTSideMenuDelegateTypeWillShowRightMenuViewController object:self.leftMenuViewController];

        [self _presentRightViewController];
    }
    else
    {
        NSAssert(false,@"NONE RIGHTMENU!");
    }
}

/*!
 *  隐藏menu
 */

- (void)hideMenuViewController
{
    if (self.visibleType == XTSideMenuVisibleTypeLeft) {
        [self dealDelegateWithType:XTSideMenuDelegateTypeWillHideLeftMenuViewController object:self.leftMenuViewController];
    }else if (self.visibleType == XTSideMenuVisibleTypeRight) {
        [self dealDelegateWithType:XTSideMenuDelegateTypeWillHideRightMenuViewController object:self.rightMenuViewController];
    }
    
    XTSideMenuVisibleType type = self.visibleType;
    [self.menuButton removeFromSuperview];
    self.visibleType = XTSideMenuVisibleTypeMoving;
    
    switch (type)
    {
        case XTSideMenuVisibleTypeLeft:
        {
            CGPoint center = self.leftMenuViewController.view.center;
            CGPoint endCenter = CGPointMake(center.x - CGRectGetWidth(self.leftMenuViewController.view.bounds), center.y);
            [UIView animateWithDuration:self.animationDuration
                             animations:^{
                                 self.leftMenuViewController.view.center = endCenter;
                                 self.menuOpacityView.center = endCenter;
                                 self.menuOpacityView.alpha = self.menuOpacityViewLeftMinAlpha;
                                 self.contentBlurView.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 self.menuViewContainer.alpha = 0;
                                 self.leftMenuViewController.view.center = center;
                                 self.leftMenuViewController.view.hidden = YES;
                                 self.visibleType = XTSideMenuVisibleTypeContent;
                                 [self.contentBlurView removeFromSuperview];
                                 [self dealDelegateWithType:XTSideMenuDelegateTypeDidHideLeftMenuViewController object:self.leftMenuViewController];
                             }];
            break;
        }
        case XTSideMenuVisibleTypeRight:
        {
            CGPoint center = self.rightMenuViewController.view.center;
            CGPoint endCenter = CGPointMake(center.x + CGRectGetWidth(self.rightMenuViewController.view.bounds), center.y);
            [UIView animateWithDuration:self.animationDuration
                             animations:^{
                                 self.rightMenuViewController.view.center = endCenter;
                                 self.menuOpacityView.center = endCenter;
                                 self.menuOpacityView.alpha = self.menuOpacityViewRightMinAlpha;
                                 self.contentBlurView.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 self.menuViewContainer.alpha = 0;
                                 self.rightMenuViewController.view.center = center;
                                 self.rightMenuViewController.view.hidden = YES;
                                 self.visibleType = XTSideMenuVisibleTypeContent;
                                 [self.contentBlurView removeFromSuperview];
                                 [self dealDelegateWithType:XTSideMenuDelegateTypeDidHideRightMenuViewController object:self.rightMenuViewController];
                             }];
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark - Private Method

- (CGPoint)leftMenuViewCenter:(XTSideMenuShowType)type
{
    switch (type)
    {
        case XTSideMenuShowTypeNone:
        case XTSideMenuShowTypeRight:
            return CGPointMake(-1 * self.leftMenuViewVisibleWidth / 2.0, CGRectGetHeight(self.leftMenuViewController.view.bounds) / 2.0);
            break;
        case XTSideMenuShowTypeLeft:
            return CGPointMake(self.leftMenuViewVisibleWidth / 2.0, CGRectGetHeight(self.leftMenuViewController.view.bounds) / 2.0);
            break;
        default:
            break;
    }
}

- (CGPoint)rightMenuViewCenter:(XTSideMenuShowType)type
{
    switch (type) {
        case XTSideMenuShowTypeNone:
        case XTSideMenuShowTypeLeft:
            return CGPointMake(self.rightMenuViewVisibleWidth / 2.0 + CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.rightMenuViewController.view.bounds) / 2.0);
            break;
        case XTSideMenuShowTypeRight:
            return CGPointMake(CGRectGetWidth(self.view.bounds) - self.rightMenuViewVisibleWidth / 2.0, CGRectGetHeight(self.rightMenuViewController.view.bounds) / 2.0);
        default:
            break;
    }
}

- (void)prepareForPresentMenuViewController
{
    [self.view bringSubviewToFront:self.menuViewContainer];

    [self.view.window endEditing:YES];
    
    [self addContentBlurView];
    
    [self addMenuButton];
    
    self.menuButton.enabled = NO;
    
    self.menuViewContainer.alpha = 1;
    
    self.contentBlurView.alpha = self.contentBlurViewMinAlpha;
}

- (void)prepareForPresentLeftViewController
{
    [self prepareForPresentMenuViewController];
    
    self.menuOpacityView.alpha = self.menuOpacityViewLeftMinAlpha;
    
    [self addMenuOpacityView:XTSideMenuShowTypeLeft];
    
    [self updateMenuOperateViewBackgroundColor:XTSideMenuShowTypeLeft];
    
    self.leftMenuViewController.view.hidden = NO;
    
    self.leftMenuViewController.view.center = [self leftMenuViewCenter:XTSideMenuShowTypeNone];
    
    self.menuOpacityView.center = self.leftMenuViewController.view.center;
}

- (void)prepareForPresentRightViewController
{
    [self prepareForPresentMenuViewController];
    
    self.menuOpacityView.alpha = self.menuOpacityViewRightMinAlpha;
    
    [self addMenuOpacityView:XTSideMenuShowTypeRight];
    
    [self updateMenuOperateViewBackgroundColor:XTSideMenuShowTypeRight];
    
    self.rightMenuViewController.view.hidden = NO;
    
    self.rightMenuViewController.view.center = [self rightMenuViewCenter:XTSideMenuShowTypeNone];
    
    self.menuOpacityView.center = self.rightMenuViewController.view.center;
}

- (void)_presentLeftViewController
{
    if (!_leftMenuViewController) {
        return;
    }
    
    [self prepareForPresentLeftViewController];
    
    [self userInteractionEnabled:NO];
    
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.leftMenuViewController.view.center = [self leftMenuViewCenter:XTSideMenuShowTypeLeft];
                         self.menuOpacityView.center = [self leftMenuViewCenter:XTSideMenuShowTypeLeft];
                         self.menuOpacityView.alpha = self.menuOpacityViewLeftMaxAlpha;
                         self.contentBlurView.alpha = self.contentBlurViewMaxAlpha;
                     }
                     completion:^(BOOL finished) {
                         [self userInteractionEnabled:YES];
                         self.visibleType = XTSideMenuVisibleTypeLeft;
                         self.menuButton.enabled = YES;
                         [self dealDelegateWithType:XTSideMenuDelegateTypeDidShowLeftMenuViewController object:self.leftMenuViewController];
                     }];
}

- (void)_presentRightViewController
{
    if (!_rightMenuViewController) {
        return;
    }

    [self prepareForPresentRightViewController];
    
    [self userInteractionEnabled:NO];
    
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.rightMenuViewController.view.center = [self rightMenuViewCenter:XTSideMenuShowTypeRight];
                         self.menuOpacityView.center = [self rightMenuViewCenter:XTSideMenuShowTypeRight];
                         self.menuOpacityView.alpha = self.menuOpacityViewRightMaxAlpha;
                         self.contentBlurView.alpha = self.contentBlurViewMaxAlpha;
                     }
                     completion:^(BOOL finished) {
                         [self userInteractionEnabled:YES];
                         self.visibleType = XTSideMenuVisibleTypeRight;
                         self.menuButton.enabled = YES;
                         [self dealDelegateWithType:XTSideMenuDelegateTypeDidShowRightMenuViewController object:self.rightMenuViewController];
                     }];
}

#pragma mark -
#pragma mark UIGestureRecognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (!self.panGestureEnabled)
    {
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark PanGestureAction

- (void)prepareForPanPresentLeftViewController
{
    [self prepareForPresentLeftViewController];
    
    self.showType = XTSideMenuShowTypeLeft;
}

- (void)prepareForPanPresentRightViewController
{
    [self prepareForPresentRightViewController];
    
    self.showType = XTSideMenuShowTypeRight;
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)sender
{
    [self dealDelegateWithType:XTSideMenuDelegateTypeDidRecognizePanGesture object:sender];
    
    if (self.visibleType == XTSideMenuVisibleTypeContent)
    {
        CGPoint point = [sender locationInView:self.view];
        
        switch (sender.state) {
            case UIGestureRecognizerStateBegan:
            {
                CGPoint dirPoint = [sender translationInView:self.view];
                
                self.originalPoint = point;
                
                if (dirPoint.x > 0 && self.leftMenuViewController)
                {
                    [self dealDelegateWithType:XTSideMenuDelegateTypeWillShowLeftMenuViewController object:self.leftMenuViewController];
                    
                    [self prepareForPanPresentLeftViewController];
                }
                else if (dirPoint.x < 0 && self.rightMenuViewController)
                {
                    [self dealDelegateWithType:XTSideMenuDelegateTypeWillShowRightMenuViewController object:self.rightMenuViewController];
                    
                    [self prepareForPanPresentRightViewController];
                }
                else
                {
                    self.showType = XTSideMenuShowTypeNone;
                }
                break;
            }
            case UIGestureRecognizerStateChanged:
            {
                if (self.showType == XTSideMenuShowTypeLeft)
                {
                    CGRect rect = self.leftMenuViewController.view.frame;
                    CGFloat maxX = CGRectGetMaxX(rect);
                    CGFloat progress = maxX / self.leftMenuViewVisibleWidth;
                    self.menuOpacityView.alpha = progress * (self.menuOpacityViewLeftMaxAlpha - self.menuOpacityViewLeftMinAlpha) + self.menuOpacityViewLeftMinAlpha;
                    self.contentBlurView.alpha = self.contentBlurViewMinAlpha + progress * (self.contentBlurViewMaxAlpha - self.contentBlurViewMinAlpha);
                    
                    CGPoint center = self.leftMenuViewController.view.center;
                    self.leftMenuViewController.view.center = CGPointMake(center.x + point.x - self.originalPoint.x, center.y);
                    self.menuOpacityView.center = self.leftMenuViewController.view.center;
                    self.originalPoint = point;
                }
                else if (self.showType == XTSideMenuShowTypeRight)
                {
                    CGRect rect = self.rightMenuViewController.view.frame;
                    CGFloat minX = CGRectGetMinX(rect);
                    CGFloat progress = (CGRectGetWidth(self.view.bounds) - minX) / self.rightMenuViewVisibleWidth;
                    self.menuOpacityView.alpha = progress * (self.menuOpacityViewRightMaxAlpha - self.menuOpacityViewRightMinAlpha) + self.menuOpacityViewRightMinAlpha;
                    self.contentBlurView.alpha = self.contentBlurViewMinAlpha + progress * (self.contentBlurViewMaxAlpha - self.contentBlurViewMinAlpha);
                    
                    CGPoint center = self.rightMenuViewController.view.center;
                    self.rightMenuViewController.view.center = CGPointMake(center.x + point.x - self.originalPoint.x, center.y);
                    self.menuOpacityView.center = self.rightMenuViewController.view.center;
                    self.originalPoint = point;
                }
                break;
            }
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            {
                if (self.showType == XTSideMenuShowTypeLeft)
                {
                    CGRect rect = self.leftMenuViewController.view.frame;
                    CGFloat maxX = CGRectGetMaxX(rect);
                    CGFloat deltaX = [sender velocityInView:self.view].x;
                    if (maxX == self.leftMenuViewVisibleWidth)
                    {
                        self.menuButton.enabled = YES;
                        self.visibleType = XTSideMenuVisibleTypeLeft;
                        
                        [self dealDelegateWithType:XTSideMenuDelegateTypeDidShowLeftMenuViewController object:self.leftMenuViewController];
                    }
                    else if ((maxX < self.leftMenuViewVisibleWidth && maxX >= self.leftMenuViewVisibleWidth / 2.0) || deltaX > 400)
                    {
                        [self userInteractionEnabled:NO];
                        [UIView animateWithDuration:self.animationDuration
                                         animations:^{
                                             self.leftMenuViewController.view.center = CGPointMake(self.leftMenuViewVisibleWidth / 2.0, CGRectGetMidY(rect));
                                             self.menuOpacityView.center = CGPointMake(self.leftMenuViewVisibleWidth / 2.0, CGRectGetMidY(rect));
                                             self.menuOpacityView.alpha = self.menuOpacityViewLeftMaxAlpha;
                                             self.contentBlurView.alpha = self.contentBlurViewMaxAlpha;
                                         }
                                         completion:^(BOOL finished) {
                                             [self userInteractionEnabled:YES];
                                             self.menuButton.enabled = YES;
                                             self.visibleType = XTSideMenuVisibleTypeLeft;
                                             [self dealDelegateWithType:XTSideMenuDelegateTypeDidShowLeftMenuViewController object:self.leftMenuViewController];
                                         }];
                    }
                    else
                    {
                        [self userInteractionEnabled:NO];
                        [self.menuButton removeFromSuperview];
                        CGPoint endCenter = CGPointMake(-1 * self.leftMenuViewVisibleWidth / 2.0, CGRectGetMidY(rect));
                        CGPoint origionCenter = CGPointMake(self.leftMenuViewVisibleWidth / 2.0, CGRectGetMidY(rect));
                        [UIView animateWithDuration:self.animationDuration
                                         animations:^{
                                             self.leftMenuViewController.view.center = endCenter;
                                             self.menuOpacityView.center = endCenter;
                                             self.menuOpacityView.alpha = self.menuOpacityViewLeftMinAlpha;
                                             self.contentBlurView.alpha = self.contentBlurViewMinAlpha;
                                         }
                                         completion:^(BOOL finished) {
                                             [self userInteractionEnabled:YES];
                                             self.menuViewContainer.alpha = 0;
                                             self.leftMenuViewController.view.center = origionCenter;
                                             self.leftMenuViewController.view.hidden = YES;
                                             self.visibleType = XTSideMenuVisibleTypeContent;
                                             [self.contentBlurView removeFromSuperview];
                                         }];
                    }
                }
                else if (self.showType == XTSideMenuShowTypeRight)
                {
                    CGFloat parMinX = CGRectGetWidth(self.view.bounds) - self.rightMenuViewVisibleWidth;
                    CGRect rect = self.rightMenuViewController.view.frame;
                    CGFloat minX = CGRectGetMinX(rect);
                    CGFloat deltaX = [sender velocityInView:self.view].x;

                    if (minX == parMinX)
                    {
                        self.menuButton.enabled = YES;
                        self.visibleType = XTSideMenuVisibleTypeRight;
                        [self dealDelegateWithType:XTSideMenuDelegateTypeDidShowRightMenuViewController object:self.rightMenuViewController];
                    }
                    else if ((minX > parMinX && minX <= (parMinX + self.rightMenuViewVisibleWidth / 2.0)) || deltaX < -400)
                    {
                        [self userInteractionEnabled:NO];
                        CGPoint center = CGPointMake(CGRectGetWidth(self.view.bounds) - self.rightMenuViewVisibleWidth / 2.0, CGRectGetMidY(rect));
                        [UIView animateWithDuration:self.animationDuration
                                         animations:^{
                                             self.rightMenuViewController.view.center = center;
                                             self.menuViewContainer.alpha = 1.0f;
                                             self.menuOpacityView.center = center;
                                             self.menuOpacityView.alpha = self.menuOpacityViewRightMaxAlpha;
                                             self.contentBlurView.alpha = self.contentBlurViewMaxAlpha;
                                         }
                                         completion:^(BOOL finished) {
                                             [self userInteractionEnabled:YES];
                                             self.visibleType = XTSideMenuVisibleTypeRight;
                                             self.menuButton.enabled = YES;
                                             [self dealDelegateWithType:XTSideMenuDelegateTypeDidShowRightMenuViewController object:self.rightMenuViewController];
                                         }];
                    }
                    else
                    {
                        [self userInteractionEnabled:NO];
                        CGPoint endCenter = CGPointMake(CGRectGetWidth(self.view.bounds) + CGRectGetWidth(rect) / 2.0, CGRectGetMidY(rect));
                        CGPoint origionCenter = CGPointMake(CGRectGetWidth(rect) / 2.0, CGRectGetMidY(rect));
                        [UIView animateWithDuration:self.animationDuration
                                         animations:^{
                                             self.rightMenuViewController.view.center = endCenter;
                                             self.menuOpacityView.center = endCenter;
                                             self.menuOpacityView.alpha = self.menuOpacityViewRightMinAlpha;
                                             self.contentBlurView.alpha = self.contentBlurViewMinAlpha;
                                         }
                                         completion:^(BOOL finished) {
                                             [self userInteractionEnabled:YES];
                                             self.menuViewContainer.alpha = 0;
                                             self.rightMenuViewController.view.center = origionCenter;
                                             self.rightMenuViewController.view.hidden = YES;
                                             self.visibleType = XTSideMenuVisibleTypeContent;
                                             [self.contentBlurView removeFromSuperview];
                                         }];
                    }
                }
                break;
            }
            default:
                break;
        }
    }
    else if (self.visibleType == XTSideMenuVisibleTypeLeft)
    {
        CGPoint point = [sender locationInView:self.view];
        switch (sender.state) {
            case UIGestureRecognizerStateBegan:
            {
                self.originalPoint = point;
                [self dealDelegateWithType:XTSideMenuDelegateTypeWillHideLeftMenuViewController object:self.leftMenuViewController];
                break;
            }
            case UIGestureRecognizerStateChanged:
            {
                CGRect rect = self.leftMenuViewController.view.frame;
                CGFloat maxX = CGRectGetMaxX(rect);
                CGFloat progress = maxX / self.leftMenuViewVisibleWidth;
                self.menuOpacityView.alpha = progress * (self.menuOpacityViewLeftMaxAlpha - self.menuOpacityViewLeftMinAlpha) + self.menuOpacityViewLeftMinAlpha;
                self.contentBlurView.alpha = self.contentBlurViewMinAlpha + progress * (self.contentBlurViewMaxAlpha - self.contentBlurViewMinAlpha);
                CGPoint center = self.leftMenuViewController.view.center;
                self.leftMenuViewController.view.center = CGPointMake(center.x + point.x - self.originalPoint.x, center.y);
                self.menuOpacityView.center = self.leftMenuViewController.view.center;
                self.originalPoint = point;
                break;
            }
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateEnded:
            {
                CGRect rect = self.leftMenuViewController.view.frame;
                CGFloat maxX = CGRectGetMaxX(rect);
                CGFloat delta = [sender velocityInView:self.view].x;
                if (delta < -400 || maxX < self.leftMenuViewVisibleWidth / 2.0)
                {
                    [self userInteractionEnabled:NO];
                    [UIView animateWithDuration:self.animationDuration
                                     animations:^{
                                         self.leftMenuViewController.view.center = [self leftMenuViewCenter:XTSideMenuShowTypeNone];
                                         self.menuOpacityView.center = [self leftMenuViewCenter:XTSideMenuShowTypeNone];
                                         self.menuOpacityView.alpha = self.menuOpacityViewLeftMinAlpha;
                                         self.contentBlurView.alpha = self.contentBlurViewMinAlpha;
                                     }
                                     completion:^(BOOL finished) {
                                         [self.menuButton removeFromSuperview];
                                         self.menuViewContainer.alpha = 0;
                                         self.leftMenuViewController.view.center = [self leftMenuViewCenter:XTSideMenuShowTypeLeft];
                                         self.leftMenuViewController.view.hidden = YES;
                                         self.visibleType = XTSideMenuVisibleTypeContent;
                                         [self.contentBlurView removeFromSuperview];
                                         [self userInteractionEnabled:YES];
                                         [self dealDelegateWithType:XTSideMenuDelegateTypeDidHideLeftMenuViewController object:self.leftMenuViewController];
                                     }];
                }
                else
                {
                    [self userInteractionEnabled:NO];
                    [UIView animateWithDuration:self.animationDuration
                                     animations:^{
                                         self.leftMenuViewController.view.center = CGPointMake(self.leftMenuViewVisibleWidth / 2.0, CGRectGetMidY(rect));
                                         self.menuOpacityView.center = CGPointMake(self.leftMenuViewVisibleWidth / 2.0, CGRectGetMidY(rect));
                                         self.menuOpacityView.alpha = self.menuOpacityViewLeftMaxAlpha;
                                         self.contentBlurView.alpha = self.contentBlurViewMaxAlpha;
                                     }
                                     completion:^(BOOL finished) {
                                         [self userInteractionEnabled:YES];
                                         self.menuButton.enabled = YES;
                                         self.visibleType = XTSideMenuVisibleTypeLeft;
                                     }];
                }
                break;
            }
            default:
                break;
        }
        
    }
    else if (self.visibleType == XTSideMenuVisibleTypeRight)
    {
        CGPoint point = [sender locationInView:self.view];
        switch (sender.state) {
            case UIGestureRecognizerStateBegan:
            {
                self.originalPoint = point;
                [self dealDelegateWithType:XTSideMenuDelegateTypeWillHideRightMenuViewController object:self.rightMenuViewController];
                break;
            }
            case UIGestureRecognizerStateChanged:
            {
                CGRect rect = self.rightMenuViewController.view.frame;
                CGFloat minX = CGRectGetMinX(rect);
                CGFloat progress = (CGRectGetWidth(self.view.bounds) - minX) / self.rightMenuViewVisibleWidth;
                self.menuOpacityView.alpha = progress * (self.menuOpacityViewRightMaxAlpha - self.menuOpacityViewRightMinAlpha) + self.menuOpacityViewRightMinAlpha;
                self.contentBlurView.alpha = self.contentBlurViewMinAlpha + progress * (self.contentBlurViewMaxAlpha - self.contentBlurViewMinAlpha);
                CGPoint center = self.rightMenuViewController.view.center;
                self.rightMenuViewController.view.center = CGPointMake(center.x + point.x - self.originalPoint.x, center.y);
                self.menuOpacityView.center = self.rightMenuViewController.view.center;
                self.originalPoint = point;
                break;
            }
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateEnded:
            {
                CGRect rect = self.rightMenuViewController.view.frame;
                CGFloat minX = CGRectGetMinX(rect);
                CGFloat delta = [sender velocityInView:self.view].x;
                if (delta > 400 || minX >= (CGRectGetWidth(self.view.bounds) - self.rightMenuViewVisibleWidth / 2.0))
                {
                    [self userInteractionEnabled:NO];
                    CGPoint endCenter = CGPointMake(CGRectGetWidth(self.view.bounds) + CGRectGetWidth(rect) / 2.0, CGRectGetMidY(rect));
                    CGPoint origionCenter = CGPointMake(CGRectGetWidth(rect) / 2.0, CGRectGetMidY(rect));
                    [UIView animateWithDuration:self.animationDuration
                                     animations:^{
                                         self.rightMenuViewController.view.center = endCenter;
                                         self.menuOpacityView.center = endCenter;
                                         self.menuOpacityView.alpha = self.menuOpacityViewRightMinAlpha;
                                         self.contentBlurView.alpha = self.contentBlurViewMinAlpha;
                                     }
                                     completion:^(BOOL finished) {
                                         [self userInteractionEnabled:YES];
                                         self.menuViewContainer.alpha = 0;
                                         self.rightMenuViewController.view.center = origionCenter;
                                         self.rightMenuViewController.view.hidden = YES;
                                         self.visibleType = XTSideMenuVisibleTypeContent;
                                         [self.contentBlurView removeFromSuperview];
                                         [self dealDelegateWithType:XTSideMenuDelegateTypeDidHideRightMenuViewController object:self.rightMenuViewController];
                                     }];
                }
                else
                {
                    [self userInteractionEnabled:NO];
                    CGPoint center = CGPointMake(CGRectGetWidth(self.view.bounds) - self.rightMenuViewVisibleWidth / 2.0, CGRectGetMidY(rect));
                    [UIView animateWithDuration:self.animationDuration
                                     animations:^{
                                         self.rightMenuViewController.view.center = center;
                                         self.menuViewContainer.alpha = 1.0f;
                                         self.menuOpacityView.center = center;
                                         self.menuOpacityView.alpha = self.menuOpacityViewRightMaxAlpha;
                                         self.contentBlurView.alpha = self.contentBlurViewMaxAlpha;
                                     }
                                     completion:^(BOOL finished) {
                                         [self userInteractionEnabled:YES];
                                         self.visibleType = XTSideMenuVisibleTypeRight;
                                         self.menuButton.enabled = YES;
                                     }];
                }
                break;
            }
            default:
                break;
        }

    }
}

- (void)addMenuButton
{
    if (self.menuButton.superview)
    {
        return;
    }
    self.menuButton.autoresizingMask = UIViewAutoresizingNone;
    self.menuButton.frame = self.menuViewContainer.bounds;
    self.menuButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.menuViewContainer insertSubview:self.menuButton atIndex:0];
}

- (void)addMenuOpacityView:(XTSideMenuShowType)type
{
    if (self.menuOpacityView.superview)
    {
        if (type == XTSideMenuShowTypeLeft) {
            self.menuOpacityView.frame = self.leftMenuViewController.view.bounds;
        }else if (type == XTSideMenuShowTypeRight){
            self.menuOpacityView.frame = self.rightMenuViewController.view.bounds;
        }
        return;
    }
    self.menuOpacityView.autoresizingMask = UIViewAutoresizingNone;
    if (type == XTSideMenuShowTypeLeft) {
        self.menuOpacityView.frame = self.leftMenuViewController.view.bounds;
    }else if (type == XTSideMenuShowTypeRight){
        self.menuOpacityView.frame = self.rightMenuViewController.view.bounds;
    }    self.menuOpacityView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.menuViewContainer insertSubview:self.menuOpacityView aboveSubview:self.menuButton];
}

- (void)addContentBlurView
{
    if (self.contentBlurView.superview)
    {
        return;
    }
    self.contentBlurView.autoresizesSubviews = UIViewAutoresizingNone;
    self.contentBlurView.frame = self.contentViewContainer.bounds;
    self.contentBlurView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentBlurView.viewToBlur = self.contentViewController.view;
    [self.contentViewContainer insertSubview:self.contentBlurView aboveSubview:self.contentViewController.view];
}

- (void)updateContentBlurViewImage
{
    if (self.contentBlur)
    {
        self.contentBlurView.blur = YES;
        self.contentBlurView.tintColor = self.contentBlurViewTintColor;
    }
    else
    {
        self.contentBlurView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    }
}

- (void)updateMenuOperateViewBackgroundColor:(XTSideMenuShowType)type
{
    if (type == XTSideMenuShowTypeLeft) {
        self.menuOpacityView.backgroundColor = self.menuOpacityViewLeftBackgroundColor;
    }else if (type == XTSideMenuShowTypeRight) {
        self.menuOpacityView.backgroundColor = self.menuOpacityViewRightBackgroundColor;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.contentBlurView updateBlur];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Status Bar Appearance Management

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIStatusBarStyle statusBarStyle = UIStatusBarStyleLightContent;
    return statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    BOOL statusBarHidden = NO;
    return statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    UIStatusBarAnimation statusBarAnimation = UIStatusBarAnimationNone;
    return statusBarAnimation;
}

#pragma mark -
#pragma mark UserInteractionEnabled

- (void)userInteractionEnabled:(BOOL)enable
{
    self.view.userInteractionEnabled = enable;
}

#pragma mark -
#pragma mark DelegateMethod


#define XTSuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

- (void)dealDelegateWithType:(XTSideMenuDelegateType)type object:(id)object
{
    if (_delegate) {
        SEL action;
        switch (type) {
            case XTSideMenuDelegateTypeDidRecognizePanGesture:
                action = @selector(sideMenu:didRecognizePanGesture:);
                break;
            case XTSideMenuDelegateTypeWillShowLeftMenuViewController:
                action = @selector(sideMenu:willShowLeftMenuViewController:);
                break;
            case XTSideMenuDelegateTypeDidShowLeftMenuViewController:
                action = @selector(sideMenu:didShowLeftMenuViewController:);
                break;
            case XTSideMenuDelegateTypeWillHideLeftMenuViewController:
                action = @selector(sideMenu:willHideLeftMenuViewController:);
                break;
            case XTSideMenuDelegateTypeDidHideLeftMenuViewController:
                action = @selector(sideMenu:didHideLeftMenuViewController:);
                break;
            case XTSideMenuDelegateTypeWillShowRightMenuViewController:
                action = @selector(sideMenu:willShowRightMenuViewController:);
                break;
            case XTSideMenuDelegateTypeDidShowRightMenuViewController:
                action = @selector(sideMenu:didShowRightMenuViewController:);
                break;
            case XTSideMenuDelegateTypeWillHideRightMenuViewController:
                action = @selector(sideMenu:willHideRightMenuViewController:);
                break;
            case XTSideMenuDelegateTypeDidHideRightMenuViewController:
                action = @selector(sideMenu:didHideRightMenuViewController:);
                break;
            default:
                break;
        }
        if (action && [_delegate respondsToSelector:action] && object) {
            XTSuppressPerformSelectorLeakWarning([_delegate performSelector:action withObject:self withObject:object]);
        }
    }
}


@end
