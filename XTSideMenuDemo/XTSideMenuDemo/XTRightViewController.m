//
//  XTRightViewController.m
//  XTSideMenuDemo
//
//  Created by XT on 14-8-14.
//  Copyright (c) 2014年 XT. All rights reserved.
//

#import "XTRightViewController.h"
#import "XTSideMenu.h"
#import "UIViewController+XTSideMenu.h"

@interface XTRightViewController ()

@end

@implementation XTRightViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
#warning Hi,notice here.You'd better to set self.view.backgroundColor = [UIColor clearColor],then you will see the oparity view.
    self.view.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)closeRightMenu:(id)sender {
    [self.sideMenuViewController hideMenuViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
