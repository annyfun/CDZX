//
//  ASChangePhoneViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/30.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASChangePhoneViewController.h"

@interface ASChangePhoneViewController ()
@property (nonatomic, weak) IBOutlet UITextField *phoneTextField;
@property (nonatomic, weak) IBOutlet UITextField *captchaTextField;

@property (nonatomic, weak) IBOutlet UIButton *sendCaptchaButton;
@property (nonatomic, weak) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) NSString *sendPhone;

@property (nonatomic, assign) NSInteger countDownSeconds;
@end

@implementation ASChangePhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sendPhone = @"";
    [UIView makeRoundForView:self.sendCaptchaButton withRadius:3];
    [self.sendCaptchaButton makeBorderWithColor:RGB(247, 89, 89) borderWidth:1];
    [UIView makeRoundForView:self.submitButton withRadius:5];
}

//启动倒计时
- (void)startCounting {
    self.countDownSeconds = 60;
    [self.sendCaptchaButton setTitle:[NSString stringWithFormat:@"%ld" , (long)self.countDownSeconds]
                       forState:UIControlStateNormal];
    self.sendCaptchaButton.enabled = NO;
    
    WeakSelfType blockSelf = self;
    [NSTimer bk_scheduledTimerWithTimeInterval:1 block:^(NSTimer * timer) {
        blockSelf.countDownSeconds--;
        [blockSelf.sendCaptchaButton setTitle:[NSString stringWithFormat:@"还剩%ld秒" , (long)self.countDownSeconds]
                                forState:UIControlStateNormal];
        if (blockSelf.countDownSeconds <= 0) {
            [timer invalidate];
            blockSelf.sendCaptchaButton.enabled = YES;
            [blockSelf.sendCaptchaButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        }
    } repeats:YES];
}
- (IBAction)sendCaptchaButtonClicked:(id)sender {
    NSString *phone = Trim(self.phoneTextField.text);
    CheckStringEmpty(phone, @"手机号不能为空");
    CheckStringMatchRegex(RegexMobilePhone, phone, @"手机号不合法");
    WEAKSELF
    [self showHUDLoading:@"正在发送验证码"];
    [AFNManager postDataWithAPI:kResPathAppToolPhoneVerify
                   andDictParam:@{@"phone" : phone}
                      modelName:nil
               requestSuccessed:^(id responseObject) {
                   [blockSelf hideHUDLoading];
                   blockSelf.sendPhone = phone;
                   [UIView showAlertVieWithMessage:@"验证码发送成功，请注意查收您的手机短信"];
                   [blockSelf startCounting];
               }
                 requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     [blockSelf hideHUDLoading];
                     [UIView showAlertVieWithMessage:errorMessage];
                 }];
}

- (IBAction)submitButtonClicked:(id)sender {
    CheckStringEmpty(self.sendPhone, @"请先获取验证码");
    NSString *phone = Trim(self.phoneTextField.text);
    NSString *verify = Trim(self.captchaTextField.text);
    CheckStringEmpty(phone, @"手机号不能为空");
    CheckStringEmpty(verify, @"验证码不能为空");
    CheckStringMatchRegex(RegexMobilePhone, phone, @"手机号不合法");
    if (NO == [self.sendPhone isEqual:phone]) {
        [self showAlertVieWithMessage:@"验证码对应的手机号错误"];
        return;
    }
    
    WEAKSELF
    [self showHUDLoading:@"正在修改您的手机号"];
    [AFNManager postDataWithAPI:kResPathAppUserChangePhone
                   andDictParam:@{@"phone" : phone,
                                  @"phone_verify" : verify}
                      modelName:nil
               requestSuccessed:^(id responseObject) {
                   [blockSelf showResultThenBack:@"修改成功"];
               }
                 requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     [blockSelf hideHUDLoading];
                     [UIView showAlertVieWithMessage:errorMessage];
                 }];
}

@end
