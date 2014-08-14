Purpose
--------------

A side menu style design by 网易.I just to practice.


Supported SDK Versions
-----------------------------

* Supported build target - iOS 7.1(Xcode 5.1, Apple LLVM compiler 5.1)
* Earliest supported deployment target - iOS 6.0
* Earliest compatible deployment target - iOS 5.0

NOTE: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this OS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.


ARC Compatibility
------------------

ARC required.


Installation
--------------

Just drag the XTSideMenu class files into your project.


Explain
--------------

All effects are based on the original app, and then add some customization.


Properties
--------------

The XTSideMenu has the following properties:

	@property (nonatomic, strong) UIViewController *contentViewController;

The Center ViewController.

	@property (nonatomic, strong) UIViewController *leftMenuViewController;
    
The Left ViewController.

    @property (nonatomic, strong) UIViewController *rightMenuViewController;
    
The right ViewController.

    @property (nonatomic, weak) id <XTSideMenuDelegate> delegate;

The delegate ,you can listen to some methods

    @property (nonatomic) BOOL contentBlur;
    
The switch that you can open or close the contentView shade weather has blur effect.Default is YES.

    @property (nonatomic) BOOL panGestureEnabled;
    
The switch that you can control weather sideMenu can open by panGesture.Default is YES.

    @property (nonatomic) NSTimeInterval animationDuration;
    
The menu open or close animator duration.Default is 0.35;

    @property (nonatomic, strong) UIColor *contentBlurViewTintColor;
    
When contentView shade has blur effect,this color is blur fix color.

    @property (nonatomic) CGFloat contentBlurViewMinAlpha

    @property (nonatomic) CGFloat contentBlurViewMaxAlpha

When transitioning,The contentView shade view will change it's alpha.These is min or max aplha value.Default is 0 and 1.0.

    @property (nonatomic) CGFloat leftMenuViewVisibleWidth;

The left menu visiable width.Default is 240.

    @property (nonatomic) CGFloat rightMenuViewVisibleWidth;

The right menu visiable width.Default is 320.

    @property (nonatomic, strong) UIColor *menuOpacityViewLeftBackgroundColor;
    
The left menu opacity view's background color.Default is R:223/255.0 G:48/255.0 B:49/255.0;

    @property (nonatomic, strong) UIColor *menuOpacityViewRightBackgroundColor;

The right menu opacity view's background color.Default is R:223/255.0 G:48/255.0 B:49/255.0;

    @property (nonatomic) CGFloat menuOpacityViewLeftMinAlpha;

    @property (nonatomic) CGFloat menuOpacityViewLeftMaxAlpha;

    @property (nonatomic) CGFloat menuOpacityViewRightMinAlpha;

    @property (nonatomic) CGFloat menuOpacityViewRightMaxAlpha;

When menu is showing,the menu view will change the opacity view's alpha. Default is 0.75,0.8,0.75,0.9.


Methods
--------------

The XTSide class has the following methods:

    - (instancetype)initWithContentViewController:(UIViewController *)contentViewController
                       leftMenuViewController:(UIViewController *)leftMenuViewController
                      rightMenuViewController:(UIViewController *)rightMenuViewController;

This is the init method.The contentViewController is required,the leftMenuViewController and the rightMenuViewController is optional.

    - (void)presentLeftViewController;
    
Open the left menu.

    - (void)presentRightViewController;
    
Open the right menu.

    - (void)hideMenuViewController;
    
Close menu.


Protocols
---------------

    - (void)sideMenu:(XTSideMenu *)sideMenu didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer;

    - (void)sideMenu:(XTSideMenu *)sideMenu willShowLeftMenuViewController:(UIViewController *)menuViewController;

    - (void)sideMenu:(XTSideMenu *)sideMenu didShowLeftMenuViewController:(UIViewController *)menuViewController;

    - (void)sideMenu:(XTSideMenu *)sideMenu willHideLeftMenuViewController:(UIViewController *)menuViewController;

    - (void)sideMenu:(XTSideMenu *)sideMenu didHideLeftMenuViewController:(UIViewController *)menuViewController;

    - (void)sideMenu:(XTSideMenu *)sideMenu willShowRightMenuViewController:(UIViewController *)menuViewController;

    - (void)sideMenu:(XTSideMenu *)sideMenu didShowRightMenuViewController:(UIViewController *)menuViewController;

    - (void)sideMenu:(XTSideMenu *)sideMenu willHideRightMenuViewController:(UIViewController *)menuViewController;

    - (void)sideMenu:(XTSideMenu *)sideMenu didHideRightMenuViewController:(UIViewController *)menuViewController;

It's easy to understander their usages.


Release Notes
----------------

Version 1.0

- Initial release.