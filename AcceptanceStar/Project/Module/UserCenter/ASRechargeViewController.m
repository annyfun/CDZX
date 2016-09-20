//
//  ASRechargeViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/30.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASRechargeViewController.h"
#import "YSCTextField.h"
#import <AlipaySDK/AlipaySDK.h>

@interface ASRechargeViewController ()
@property (weak, nonatomic) IBOutlet YSCTextField *amountTextField;
@property (weak, nonatomic) IBOutlet UIButton *rechargeButton;
@end

@implementation ASRechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"充值";
    [self.rechargeButton makeRoundWithRadius:5];
    self.amountTextField.textType = YSCTextTypeDecimal;
}

- (IBAction)rechargeButtonClicked:(id)sender {
    CheckStringEmpty(Trim(self.amountTextField.text), @"充值金额不能为空");
    CGFloat amount = [self.amountTextField.text floatValue];
    if (amount <= 0) {
        [self showResultThenHide:@"请输入正确的金额"];
        return;
    }
    [self createOrderByMoney:Trim(self.amountTextField.text)];
}

- (void)createOrderByMoney:(NSString *)money {
    [self showResultThenHide:@"正在充值" afterDelay:5 onView:self.view];
    WEAKSELF
    [AFNManager getDataWithAPI:kResPathAppPayIndex
                   andDictParam:@{@"title" : @"承兑之星充值业务", @"price" : money}
                      modelName:[CreateOrderModel class]
               requestSuccessed:^(id responseObject) {
                   CreateOrderModel *model = (CreateOrderModel *)responseObject;
                   if ([model isKindOfClass:[CreateOrderModel class]] && isNotEmpty(model.url)) {
                       [[AlipaySDK defaultService] payOrder:model.url fromScheme:kAppScheme callback:^(NSDictionary *resultDic) {
                           if (9000 == [resultDic[@"resultStatus"] integerValue]) {
                               USER.money = @(USER.money.floatValue + money.floatValue);
                               LOGIN.isUserChanged = YES;
                               [blockSelf showResultThenBack:@"充值成功"];
                           }
                           else {
                               [blockSelf showResultThenHide:@"充值失败"];
                           }
                       }];
                   }
                   else {
                       [blockSelf showResultThenHide:@"返回数据有误"];
                   }
               }
                 requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     [blockSelf hideHUDLoading];
                     [blockSelf showAlertVieWithMessage:errorMessage];
                 }];
}

@end
