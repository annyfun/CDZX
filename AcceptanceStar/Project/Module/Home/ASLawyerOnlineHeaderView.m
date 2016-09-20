//
//  ASLawyerOnlineHeaderView.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/12/31.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "ASLawyerOnlineHeaderView.h"
 

@implementation ASLawyerOnlineHeaderView

+ (CGFloat)HeightOfViewByObject:(NSObject *)object {
    return AUTOLAYOUT_LENGTH(50);
}

- (void)layoutObject:(CaiShuiModel *)model {
    self.nameLabel.text = Trim(model.sectionKey);
}

@end
