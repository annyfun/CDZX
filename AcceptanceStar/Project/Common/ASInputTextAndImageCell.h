//
//  ASInputTextAndImageCell.h
//  AcceptanceStar
//
//  Created by yangshengchao on 15/6/8.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASInputTextAndImageCell : YSCBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@property (weak, nonatomic) IBOutlet UIImageView *valueImageView;

@end
