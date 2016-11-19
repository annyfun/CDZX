//
//  ASRegisterViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/26.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASRegisterViewController.h"

@interface ASRegisterViewController ()

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *typeCollectionArray;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *typeImageViewArray;
@property (assign, nonatomic) NSInteger selectedTypeIndex;
@property (assign, nonatomic) NSInteger selectedCityId;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *textFieldViewArray;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifyTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordRepeatTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UIView *agreementView;
@property (weak, nonatomic) IBOutlet UIImageView *agreeImageView;
@property (assign, nonatomic) BOOL isAgreed;

@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (nonatomic, assign) NSInteger countDownSeconds;//倒计时的最大秒数
@property (nonatomic, weak) IBOutlet UILabel *agreementLabel;

@end

@implementation ASRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册";
    WeakSelfType blockSelf = self;
    self.phoneTextField.maxLength = 15;
    self.verifyTextField.maxLength = 10;
    self.passwordTextField.maxLength = 20;
    self.passwordRepeatTextField.maxLength = 20;
    [UIView makeRoundForView:self.registerButton withRadius:5];
    [self.verifyButton makeBorderWithColor:RGB(247, 89, 89) borderWidth:1];
    [self.verifyButton makeRoundWithRadius:3];
    
    [self.agreementView bk_whenTapped:^{
        blockSelf.isAgreed = ! blockSelf.isAgreed;
    }];
    self.isAgreed = NO;
    for (int i = 0; i < [self.typeCollectionArray count]; i++) {
        UIView *typeView = self.typeCollectionArray[i];
        [typeView bk_whenTapped:^{
            blockSelf.selectedTypeIndex = i;
        }];
    }
    self.selectedTypeIndex = -1;
    
    for (UIView *textFieldView in self.textFieldViewArray) {
        [UIView makeRoundForView:textFieldView withRadius:5];
        [UIView makeBorderForView:textFieldView withColor:kDefaultBorderColor borderWidth:1];
    }
    
    //业务所在地选择
    [((UIView *)self.textFieldViewArray[4]) bk_whenTapped:^{
        YSCObjectResultBlock block = ^(NSObject *object, NSError *error) {
            ASCityModel *city = (ASCityModel *)object;
            blockSelf.selectedCityId = city.id;
            blockSelf.cityTextField.text = city.city;
        };
        [blockSelf pushViewController:@"ASCitySelectionViewController"
                           withParams:@{kParamBlock : block,
                                        kParamIndex : @(blockSelf.selectedCityId)}];
    }];
    //同意注册协议
    self.agreementLabel.userInteractionEnabled = YES;
    [self.agreementLabel bk_whenTapped:^{
        [blockSelf pushViewController:@"ASWebViewViewController"
                           withParams:@{kParamTitle : @"服务协议",
                                        kParamUrl : @"http://www.yhcd.net/index/agreement"}];
    }];
}
- (void)setSelectedTypeIndex:(NSInteger)selectedTypeIndex {
    _selectedTypeIndex = selectedTypeIndex;
    for (int i = 0; i < [self.typeCollectionArray count]; i++) {
        UIImageView *imageView = self.typeImageViewArray[i];
        if (i == self.selectedTypeIndex) {
            imageView.image = [UIImage imageNamed:@"radio_selected"];
        }
        else {
            imageView.image = [UIImage imageNamed:@"radio_unselected"];
        }
    }
}
- (void)setIsAgreed:(BOOL)isAgreed {
    _isAgreed = isAgreed;
    if (isAgreed) {
        self.agreeImageView.image = [UIImage imageNamed:@"mark_agreed"];
    }
    else {
        self.agreeImageView.image = [UIImage imageNamed:@"mark_unagreed"];
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
                  andDictParam:@{kParamPhone : phone,
                                 kParamToken : TOKEN}
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
    if (NO == self.isAgreed) {
        [UIView showResultThenHideOnWindow:@"您未同意服务协议"];
        return;
    }
    
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
    CheckStringEmpty(self.cityTextField.text, @"请选择业务所在地区");
    
    WeakSelfType blockSelf = self;
    [UIView showHUDLoadingOnWindow:@"正在注册"];
    [AFNManager postDataWithAPI:kResPathAppUserRegister
                   andDictParam:@{kParamType : @(self.selectedTypeIndex),
                                  kParamPhone : phone,
                                  @"pw" : password,
                                  @"repw" : passwordRepeat,
                                  kParamVerify : verifyCode,
                                  kParamCity : @(self.selectedCityId)} // TODO-tsw: 业务地区参数待确定
                      modelName:ClassOfObject(UserModel)
               requestSuccessed:^(id responseObject) {
                   UserModel *user = (UserModel *)responseObject;
                   if ([user isKindOfClass:[UserModel class]]) {
                       [user setPw:password];
                       [LOGIN resetUser:user];
                       [UIView showResultThenHideOnWindow:@"注册成功"];
                   }
                   else {
                       [UIView showResultThenHideOnWindow:@"注册失败"];
                   }
               }
                 requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     [UIView showResultThenHideOnWindow:errorMessage];
                 }];
}
@end
