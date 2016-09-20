//
//  ASQuotePriceCell.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/6/1.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASQuotePriceCell.h"

@implementation ASQuotePriceCell

+ (CGFloat)HeightOfCell {
    return AUTOLAYOUT_LENGTH(165);
}

- (void)layoutDataModel:(QuotePriceModel *)dataModel {
    NSString *iconName = @"";
    if (dataModel.iattr == 0) {//纸银
        iconName = @"icon_attr_zy";
    }
    else if (dataModel.iattr == 1) {//电银
        iconName = @"icon_attr_dy";
    }
    else if (dataModel.iattr == 2) {//纸商
        iconName = @"icon_attr_zs";
    }
    else {
        iconName = @"icon_attr_ds";
    }
    self.attrImageView.image = [UIImage imageNamed:iconName];
    
    self.companyNameLabel.text = dataModel.companyName;
    self.gg_rLabel.text = [NSString stringWithFormat:@"%@‰", dataModel.gg_r];
    self.ds_rLabel.text = [NSString stringWithFormat:@"%@‰", dataModel.ds_r];
    self.xs_rLabel.text = [NSString stringWithFormat:@"%@‰", dataModel.xs_r];
    self.qt_rLabel.text = [NSString stringWithFormat:@"%@‰", dataModel.qt_r];
    
    self.dateLabel.text = [NSString stringWithFormat:@"%@上传",[YSCCommonUtils TimePassed2:dataModel.date]];
    self.priceLabel.text = [NSString stringWithFormat:@"单张票面%@万起", Trim(dataModel.price)];
    self.daysLabel.text = [NSString stringWithFormat:@"期限%ld天起", dataModel.days];
}

@end
