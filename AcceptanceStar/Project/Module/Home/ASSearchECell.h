//
//  ASSearchECell.h
//  AcceptanceStar
//
//  Created by Jinjin on 2016/11/24.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASSearchECell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UIView *inputView;

@property (copy, nonatomic) void(^textChange)(NSString *string);
@end
