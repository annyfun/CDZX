//
//  ASPriceDetailCell.h
//  AcceptanceStar
//
//  Created by yangshengchao on 15/6/3.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASPriceDetailCell : YSCBaseTableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *leftImageView;
@property (nonatomic, weak) IBOutlet UILabel *leftTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *right1TitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *right2TitleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *rightImageView;
@end
