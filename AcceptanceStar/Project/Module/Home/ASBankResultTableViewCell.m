//
//  ASBankResultTableViewCell.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/30.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASBankResultTableViewCell.h"

@implementation ASBankResultTableViewCell

+ (CGFloat)HeightOfCell {
    return AUTOLAYOUT_LENGTH(260);
}

- (void)layoutDataModel:(BankIndexModel *)dataModel {
    self.bankNameLabel.text = Trim(dataModel.bank);
    self.bankNumLabel.text = [NSString stringWithFormat:@"支付联行号：%@", dataModel.CNAPS];
    self.addressLabel.text = [NSString stringWithFormat:@"地址：%@", Trim(dataModel.address)];
    self.phoneNumberLabel.text = Trim(dataModel.phone);
    
    //拨打电话
    self.phoneNumberLabel.userInteractionEnabled = YES;
    [self.phoneNumberLabel removeAllGestureRecognizers];
    [self.phoneNumberLabel bk_whenTapped:^{
        [YSCCommonUtils MakeCall:dataModel.phone];
    }];
}

@end
