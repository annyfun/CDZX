//
//  ASConfigViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/27.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASConfigViewController.h"
#import "AppDelegate.h"

@interface ASConfigViewController () <LoginObserverDelegate>
@property (weak, nonatomic) IBOutlet UIView *generalView;
@property (weak, nonatomic) IBOutlet UIView *changePasswordView;
@property (weak, nonatomic) IBOutlet UIView *shieldView;
@property (weak, nonatomic) IBOutlet UIView *aboutUsView;

@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@end

@implementation ASConfigViewController
- (void)viewWillDisappear:(BOOL)animated {
    [LOGIN unregisterLoginObserver:self];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    [UIView makeRoundForView:self.actionButton withRadius:5];
    WeakSelfType blockSelf = self;
    [self.generalView bk_whenTapped:^{
        [blockSelf pushViewController:@"ASGeneralViewController"];
    }];
    [self.changePasswordView bk_whenTapped:^{
        [blockSelf pushViewController:@"ASChangePasswordViewController"];
    }];
    [self.shieldView bk_whenTapped:^{
        [blockSelf pushViewController:@"ASShieldUsersViewController"];
    }];
    [self.aboutUsView bk_whenTapped:^{
        [blockSelf pushViewController:@"ASAboutUsViewController"];
    }];
    
    if (ISLOGGED) {
        [self.actionButton setTitle:@"退出登录" forState:UIControlStateNormal];
    }
    else {
        self.actionButton.hidden = YES;
    }
}

- (IBAction)actionButtonClicked:(id)sender {
    if (ISLOGGED) {
        [LOGIN registerLoginObserver:self];
        UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"提示" message:@"确定要注销登录？"];
        [alertView bk_addButtonWithTitle:@"注销" handler:^{
            [LOGIN logout];
            [[AppDelegate instance] signOut];
        }];
        [alertView bk_setCancelButtonWithTitle:@"按错了" handler:nil];
        [alertView show];
    }
    else {

    }
}

- (void)loginSucceededWithPassword:(NSString *)password {}
- (void)loginFailedWithError:(NSString *)errorMessage {}
- (void)loggedOut {
    [self backViewController];
    postNWithInfo(kNotificationHandleTabbar, @{kParamSelectedIndex : @(0)});
}

@end
