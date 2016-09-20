//
//  ASBuyInformationCell.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/6/1.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASBuyCell.h"

@implementation ASBuyCell

+ (CGFloat)HeightOfCell {
    return AUTOLAYOUT_LENGTH(165);
}

- (void)layoutDataModel:(BondBuyModel *)dataModel {
    NSString *iconName = @"";
    if (dataModel.iattr == 0) {//纸银
        iconName = (dataModel.istatus == 1) ? @"icon_attr_zy" : @"icon_attr_zy1";
    }
    else if (dataModel.iattr == 1) {//电银
        iconName = (dataModel.istatus == 1) ? @"icon_attr_dy" : @"icon_attr_dy1";
    }
    else if (dataModel.iattr == 2) {//纸商
        iconName = (dataModel.istatus == 1) ? @"icon_attr_zs" : @"icon_attr_zs1";
    }
    else {
        iconName = (dataModel.istatus == 1) ? @"icon_attr_ds" : @"icon_attr_ds1";
    }
    self.attrImageView.image = [UIImage imageNamed:iconName];
    
    self.classLabel.text = dataModel.jsonClass;
    self.priceLabel.text = [NSString stringWithFormat:@"%@万元", FormatNumberValue(dataModel.price)];
    self.daysLabel.text = [NSString stringWithFormat:@"%ld天", dataModel.days];
    self.rateLabel.text = [NSString stringWithFormat:@"报价利率：%@%%", dataModel.rate];
    self.cityLabel.text = [NSString stringWithFormat:@"兑换城市：%@", dataModel.city];
    self.dateLabel.text = [NSString stringWithFormat:@"%@上传",[YSCCommonUtils TimePassed2:dataModel.date]];
    self.contactsLabel.text = [NSString stringWithFormat:@"已有%ld人联系", dataModel.contacts];
    if (dataModel.istatus == 1) {
        self.statusLabel.text = @"买家报价中";
        self.statusLabel.textColor = RGB(247, 89, 89);
    }
    else if (dataModel.istatus == 2) {
        self.statusLabel.text = @"已交易";
        self.statusLabel.textColor = RGB(147, 147, 147);
    }
}

@end
