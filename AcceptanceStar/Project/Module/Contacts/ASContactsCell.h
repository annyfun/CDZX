//
//  ASContactsCell.h
//  AcceptanceStar
//
//  Created by yangshengchao on 15/9/4.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASContactsCell : YSCBaseTableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *nickNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UILabel *signLabel;
@property (nonatomic, weak) IBOutlet UIView *markView;
@property (nonatomic, weak) IBOutlet UIImageView *markImageView;

@end
