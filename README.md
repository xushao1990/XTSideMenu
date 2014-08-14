Purpose
--------------

A side menu style design by 网易.I just to practice.

网易设计的一款侧滑方式，我仅仅练习而已


Supported SDK Versions
-----------------------------

* Supported build target - iOS 7.1(Xcode 5.1, Apple LLVM compiler 5.1)
* Earliest supported deployment target - iOS 6.0
* Earliest compatible deployment target - iOS 5.0

NOTE: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this OS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.

xcode 5.1，SDK iOS 7.1下开发，测试过iOS6的兼容性，iOS5没有测试，理论上支持


ARC Compatibility
------------------

XTSideMenu need ARC

ARC，必须


Installation
--------------

Just drag the XTSideMenu class files into your project.

把相关类拖入工程即可


Explain
--------------

All the effect is based on the original, and then add some customization.

所有的效果都是分析网易客户端取得，并在开放了一些定制的接口


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



Methods
--------------

The iCarousel class has the following methods (note: for Mac OS, substitute NSView for UIView in method arguments):

	- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;

This will center the carousel on the specified item, either immediately or with a smooth animation. For wrapped carousels, the carousel will automatically determine the shortest (direct or wraparound) distance to scroll. If you need to control the scroll direction, or want to scroll by more than one revolution, use the scrollByNumberOfItems method instead.




Protocols
---------------




Release Notes
----------------

Version 1.0

- Initial release.