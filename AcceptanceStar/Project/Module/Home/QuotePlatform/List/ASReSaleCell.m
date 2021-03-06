//
//  ASRepostInformationCell.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/6/1.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASReSaleCell.h"

@implementation ASReSaleCell

+ (CGFloat)HeightOfCell {
    return AUTOLAYOUT_LENGTH(88);
}

- (void)layoutDataModel:(BondReSaleModel *)dataModel {
    self.actionLabel.text = dataModel.action;
    if (0 == dataModel.iaction) {
        self.actionLabel.textColor = RGB(234, 4, 8);
    }
    else {
        self.actionLabel.textColor = RGB(4, 234, 8);
    }
    self.kindLabel.text = dataModel.kind;
    self.rateLabel.text = dataModel.rate;
    self.priceLabel.text = [NSString stringWithFormat:@"%@", dataModel.price];
    self.daysLabel.text = [NSString stringWithFormat:@"%ld", dataModel.days];}

@end
