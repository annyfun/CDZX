//
//  ASShiBorTableViewCell.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/30.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASShiBorTableViewCell.h"

@implementation ASShiBorTableViewCell

+ (CGFloat)HeightOfCell {
    return AUTOLAYOUT_LENGTH(90);
}

- (void)layoutObject:(ShiBorModel *)model {
    self.onLabel.text = model.name;
    self.pointLabel.text = model.data;
    self.percentLabel.text = model.bp;
    if ([@"up" isEqualToString:model.type]) {
        self.arrowImageView.image = [UIImage imageNamed:@"icon_up"];
    }
    else {
        self.arrowImageView.image = [UIImage imageNamed:@"icon_down"];
    }
}

@end
