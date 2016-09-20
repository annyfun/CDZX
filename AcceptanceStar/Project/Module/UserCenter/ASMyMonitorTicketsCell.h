//
//  ASMyMonitorTicketsCell.h
//  AcceptanceStar
//
//  Created by yangshengchao on 15/10/15.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASMyMonitorTicketsCell : YSCBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *ticketNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end
