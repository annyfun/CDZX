//
//  BaseNavigationController.m
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initializeView];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        // Custom initialization
        [self initializeView];
    }
    return self;
}

- (void)initializeView {
    if ([self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:)]) {
        [self.navigationBar setBackgroundImage:[UIImage imageWithColor:kColorNavBkg] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    } else if ([self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self.navigationBar setBackgroundImage:[UIImage imageWithColor:kColorNavBkg] forBarMetrics:UIBarMetricsDefault];
    }
    [self.navigationBar setTitleTextAttributes:@{UITextAttributeTextColor:kColorNavTitle,UITextAttributeTextShadowOffset:[NSNumber numberWithFloat:0.0]}];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

@end
