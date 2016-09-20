//
//  ASLawyerOnlineCell.h
//  AcceptanceStar
//
//  Created by yangshengchao on 15/12/31.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASLawyerOnlineCell : YSCBaseTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *cityNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView  *cityImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIView *phoneView;
@property (nonatomic, weak) IBOutlet UIView *chatView;

@end
