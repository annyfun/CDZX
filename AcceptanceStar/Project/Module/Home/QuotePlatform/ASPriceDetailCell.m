//
//  ASPriceDetailCell.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/6/3.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASPriceDetailCell.h"

@implementation ASPriceDetailCell

+ (CGFloat)HeightOfCellByObject:(CommonItemModel *)model {
    CGFloat height1 = [NSString HeightOfNormalString:model.rightTitle1 maxWidth:AUTOLAYOUT_LENGTH(380) withFont:AUTOLAYOUT_FONT(28)];
    return MAX(height1 + AUTOLAYOUT_LENGTH(60), AUTOLAYOUT_LENGTH(90));
}

- (void)layoutObject:(CommonItemModel *)model {
    self.leftImageView.image = [UIImage imageNamed:model.icon];
    self.leftTitleLabel.text = model.title;
    self.right1TitleLabel.text = model.rightTitle1;
    self.right2TitleLabel.text = model.rightTitle2;
}

@end
