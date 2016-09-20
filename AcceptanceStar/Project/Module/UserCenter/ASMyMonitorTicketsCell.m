//
//  ASMyMonitorTicketsCell.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/10/15.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "ASMyMonitorTicketsCell.h"

@implementation ASMyMonitorTicketsCell

+ (CGFloat)HeightOfCellByObject:(NSObject *)object {
    return AUTOLAYOUT_LENGTH(90);
}
- (void)layoutObject:(CourtMyModel *)model {
    if (model.iStatus) {
        self.statusImageView.image = [UIImage imageNamed:@"circle_red"];
        self.statusLabel.text = @"警告";
        self.statusLabel.textColor = RGB(234, 4, 8);
    }
    else {
        self.statusImageView.image = [UIImage imageNamed:@"circle_green"];
        self.statusLabel.text = @"监控中";
        self.statusLabel.textColor = kDefaultTextColor;
    }
    self.ticketNumberLabel.text = Trim(model.tno);
    self.timeLabel.text = [NSDate StringFromTimeStamp:model.posttime withFormat:@"yyyy-MM-dd HH:mm"];
}

@end
