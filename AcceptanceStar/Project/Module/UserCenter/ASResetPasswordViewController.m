//
//  ASResetPasswordViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/26.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASResetPasswordViewController.h"

@interface ASResetPasswordViewController ()
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *textFieldViewArray;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifyTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordRepeatTextField;

@property (weak, nonatomic) IBOutlet UIButton *verifyButton;//获取验证码
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (assign, nonatomic) NSInteger countDownSeconds;
@end

@implementation ASResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"忘记密码";
    self.phoneTextField.maxLength = 15;
    self.verifyTextField.maxLength = 10;
    self.passwordTextField.maxLength = 20;
    self.passwordRepeatTextField.maxLength = 20;
    [UIView makeRoundForView:self.registerButton withRadius:5];
    [self.verifyButton makeRoundWithRadius:3];
    [self.verifyButton makeBorderWithColor:RGB(247, 89, 89) borderWidth:1];
    
    for (UIView *textFieldView in self.textFieldViewArray) {
        [UIView makeRoundForView:textFieldView withRadius:5];
        [UIView makeBorderForView:textFieldView withColor:kDefaultBorderColor borderWidth:1];
    }
}

//启动倒计时
- (void)startCounting {
    self.countDownSeconds = 60;
    [self.verifyButton setTitle:[NSString stringWithFormat:@"%ld" , (long)self.countDownSeconds]
                            forState:UIControlStateNormal];
    self.verifyButton.enabled = NO;
    
    WeakSelfType blockSelf = self;
    [NSTimer bk_scheduledTimerWithTimeInterval:1 block:^(NSTimer * timer) {
        blockSelf.countDownSeconds--;
        [blockSelf.verifyButton setTitle:[NSString stringWithFormat:@"还剩%ld秒" , (long)self.countDownSeconds]
                                     forState:UIControlStateNormal];
        if (blockSelf.countDownSeconds <= 0) {
            [timer invalidate];
            blockSelf.verifyButton.enabled = YES;
            [blockSelf.verifyButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        }
    } repeats:YES];
}
#pragma mark - 按钮事件
- (IBAction)verifyButtonClicked:(id)sender {
    NSString *phone = Trim(self.phoneTextField.text);
    CheckStringEmpty(phone, @"手机号不能为空");
    CheckStringMatchRegex(RegexMobilePhone, phone, @"输入的手机号不合法");
    
    WEAKSELF
    [UIView showHUDLoadingOnWindow:@"正在发送验证码"];
    [AFNManager getDataWithAPI:kResPathAppToolPhoneVerify
                  andDictParam:@{kParamPhone : phone}
                     modelName:nil
              requestSuccessed:^(id responseObject) {
                  [UIView hideHUDLoadingOnWindow];
                  [UIView showAlertVieWithMessage:@"验证码发送成功，请查收您的手机短信"];
                  [blockSelf startCounting];
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    [UIView showResultThenHideOnWindow:errorMessage];
                }];
}
- (IBAction)registerButtonClicked:(id)sender {
    NSString *phone = Trim(self.phoneTextField.text);
    NSString *verifyCode = Trim(self.verifyTextField.text);
    NSString *password = Trim(self.passwordTextField.text);
    NSString *passwordRepeat = Trim(self.passwordRepeatTextField.text);
    CheckStringEmpty(phone, @"手机号不能为空");
    CheckStringEmpty(verifyCode, @"验证码不能为空");
    CheckStringEmpty(password, @"请输入密码");
    CheckStringEmpty(passwordRepeat, @"请再输入一次密码");
    CheckStringMatchRegex(RegexMobilePhone, phone, @"输入的手机号不合法");
    if (NO == [password isEqualToString:passwordRepeat]) {
        [UIView showResultThenHideOnWindow:@"两次输入的密码不一致"];
        return;
    }
    
    WeakSelfType blockSelf = self;
    [UIView showHUDLoadingOnWindow:@"正在重置密码"];
    [AFNManager postDataWithAPI:kResPathAppUserResetPassword
                   andDictParam:@{kParamPhone : phone,
                                  @"newpwd" : password,
                                  @"conpwd" : passwordRepeat,
                                  @"verifycode" : verifyCode}
                      modelName:nil
               requestSuccessed:^(id responseObject) {
                   [UIView showResultThenHideOnWindow:@"重置成功"];
                   [blockSelf bk_performBlock:^(id obj) {
                       [blockSelf backViewController];
                   } afterDelay:1];
               }
                 requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     [UIView showResultThenHideOnWindow:errorMessage];
                 }];
}

@end
