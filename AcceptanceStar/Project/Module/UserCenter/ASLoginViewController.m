//
//  ASLoginViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/26.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASLoginViewController.h"
#import "AppDelegate.h"

@interface ASLoginViewController () <LoginObserverDelegate>

@property (nonatomic, weak) IBOutlet UIView *backContainerView;

@property (nonatomic, weak) IBOutlet UIView *inputContainerView;
@property (nonatomic, weak) IBOutlet UITextField *phoneTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;

@property (nonatomic, weak) IBOutlet UILabel *registerLabel;
@property (nonatomic, weak) IBOutlet UILabel *forgetPasswordLabel;

@end

@implementation ASLoginViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.phoneTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kCachedUserName];
    self.passwordTextField.text = nil;
    WeakSelfType blockSelf = self;
    
    self.registerLabel.userInteractionEnabled = YES;
    [self.registerLabel bk_whenTapped:^{
        [blockSelf pushViewController:@"ASRegisterViewController"];
    }];
    self.forgetPasswordLabel.userInteractionEnabled = YES;
    [self.forgetPasswordLabel bk_whenTapped:^{
        [blockSelf pushViewController:@"ASResetPasswordViewController"];
    }];
    
    [self.backContainerView bk_whenTapped:^{
        [blockSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [UIView makeRoundForView:self.inputContainerView withRadius:5];
    [UIView makeBorderForView:self.inputContainerView withColor:kDefaultBorderColor borderWidth:1];
    self.phoneTextField.maxLength = 15;
    self.passwordTextField.maxLength = 20;
    [UIView makeRoundForView:self.loginButton withRadius:5];
//    self.loginButton.backgroundColor = [UIColor clearColor];
//    [self.loginButton setBackgroundImage:[YSCImageUtils stretchImage:[UIImage imageNamed:@"btn_normal"] withPoint:CGPointMake(5, 5)]
//                                forState:UIControlStateNormal];
//    [self.loginButton setBackgroundImage:[YSCImageUtils stretchImage:[UIImage imageNamed:@"btn_selected"] withPoint:CGPointMake(5, 5)]
//                                forState:UIControlStateSelected];
    
    
}

- (IBAction)loginButtonClicked:(id)sender {
    NSString *phoneNumber = Trim(self.phoneTextField.text);
    NSString *password = Trim(self.passwordTextField.text);
    CheckStringEmpty(phoneNumber, @"登陆账号不能为空");
    CheckStringEmpty(password, @"登陆密码不能为空");
    [self.view endEditing:YES];
    [UIView showHUDLoadingOnWindow:@"正在登陆"];
    [[Login sharedInstance] loginWithParams:@{kParamPhone : phoneNumber,
                                              @"pw" : password}
                                andObserver:self];
}


#pragma mark - LoginObserverDelegate

- (void)loginSucceededWithUserId:(NSString *)phone session:(NSString *)theSession {
    NSString *username = Trim(self.phoneTextField.text);
    if ([NSString isNotEmpty:username]) {
        [[NSUserDefaults standardUserDefaults] setValue:username forKey:kCachedUserName];
    }
    [[AppDelegate instance] loginWithUser:[USER createUser] passWord:self.passwordTextField.text];
    [UIView hideHUDLoadingOnWindow];
    
    WeakSelfType blockSelf = self;
    if (isEmpty(USER.nickname)) {
        [self bk_performBlock:^(id obj) {
            [blockSelf pushViewController:@"ASImproveInformationViewController" withParams:@{kParamTitle : @"完善资料"}];
        } afterDelay:1];
    }
    else {
        [self bk_performBlock:^(id obj) {
            [blockSelf dismissViewControllerAnimated:YES completion:nil];
        } afterDelay:1];
    }
}
- (void)loginFailedWithError:(NSString *)theError {
    [UIView showResultThenHideOnWindow:theError];
}
- (void)loggedOut {
    [UIView hideHUDLoadingOnWindow];
}
@end

