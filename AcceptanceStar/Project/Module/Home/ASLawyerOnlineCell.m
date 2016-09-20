//
//  ASLawyerOnlineCell.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/12/31.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "ASLawyerOnlineCell.h"

@implementation ASLawyerOnlineCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

+ (CGFloat)HeightOfCellByObject:(NSObject *)object {
    return AUTOLAYOUT_LENGTH(90);
}

- (void)layoutObject:(CaiShuiModel *)model {
    self.cityNameLabel.text = Trim(model.cityname);
    [self.cityImageView setImageWithURLString:model.img];
    self.nameLabel.text = Trim(model.name);
    [self.phoneView removeAllGestureRecognizers];
    [self.phoneView bk_whenTapped:^{
        [YSCCommonUtils MakeCall:model.phone];
    }];
}

@end
