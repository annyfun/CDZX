//
//  ASBankPriceQuotationViewController.m
//  AcceptanceStar
//
//  Created by benson on 11/20/16.
//  Copyright © 2016 Builder. All rights reserved.
//

#import "ASBankPriceQuotationViewController.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface ASBankPriceQuotationViewController ()

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextField *expireDayTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstRateTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondRateTextField;
@property (weak, nonatomic) IBOutlet UITextField *thirdRateTextField;
@property (weak, nonatomic) IBOutlet UITextField *forthRateTextField;
@property (weak, nonatomic) IBOutlet UITextField *companyTextField;
@property (weak, nonatomic) IBOutlet UITextField *publisherTextField;
@property (weak, nonatomic) IBOutlet UITextField *mainPhoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondaryPhoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

// 弹框
@property (weak, nonatomic) IBOutlet UIView *alertView;

@end

@implementation ASBankPriceQuotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"发布本行报价";
    [self.sendButton makeRoundWithRadius:5];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scrollView flashScrollIndicators];
}

#pragma mark - User Action

- (IBAction)submitData:(id)sender {
    // 验证用户输入合法性
    CheckStringEmpty(self.priceTextField.text, @"单张票面不能为空");
    CheckStringEmpty(self.expireDayTextField.text, @"期限不能为空");
    CheckStringEmpty(self.firstRateTextField.text, @"一类行年利率不能为空");
    CheckStringEmpty(self.secondRateTextField.text, @"二类行年利率不能为空");
    CheckStringEmpty(self.thirdRateTextField.text, @"三类行年利率不能为空");
    CheckStringEmpty(self.forthRateTextField.text, @"四类行年利率不能为空");
    CheckStringEmpty(self.publisherTextField.text, @"发布人不能为空");
    CheckStringMatchRegex(RegexMobilePhone, self.mainPhoneTextField.text, @"输入的手机号不合法");
    
    [self.view endEditing:YES];
    [UIView showHUDLoadingOnWindow:@"正在发送请求"];
    [AFNManager postDataWithAPI:kResPathAppBondElectricAdd andDictParam:[self userInputParameters] modelName:nil requestSuccessed:^(id responseObject) {
        [UIView hideHUDLoadingOnWindow];
        self.alertView.hidden = NO;
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [UIView showResultThenHideOnWindow:errorMessage afterDelay:1.5];
    }];
}

/// 点击"完成"按钮
- (IBAction)finish:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/// 点击"再发一条"按钮
- (IBAction)reSubmitData:(id)sender {
    self.alertView.hidden = YES;
    [self.scrollView setContentOffset:CGPointMake(0, -64) animated:YES];
}

#pragma mark - Private Method

- (NSDictionary *)userInputParameters {
    return @{
             @"price"     : self.priceTextField.text,
             @"days"      : self.expireDayTextField.text,
             @"rt_1"      : self.firstRateTextField.text,
             @"rt_2"      : self.secondRateTextField.text,
             @"rt_3"      : self.thirdRateTextField.text,
             @"rt_4"      : self.forthRateTextField.text,
             @"company"   : self.publisherTextField.text,
             @"phone"     : self.mainPhoneTextField.text,
             @"comment"   : self.commentTextField.text,
             };
}

@end
