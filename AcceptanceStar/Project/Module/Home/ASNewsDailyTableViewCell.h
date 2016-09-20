//
//  ASNewsDailyTableViewCell.h
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/30.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASNewsDailyTableViewCell : YSCBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconNewImageView;
@end
