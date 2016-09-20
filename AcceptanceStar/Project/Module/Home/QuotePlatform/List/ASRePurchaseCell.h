//
//  ASBuybackInformationCell.h
//  AcceptanceStar
//
//  Created by yangshengchao on 15/6/2.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASRePurchaseCell : YSCBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;
@property (weak, nonatomic) IBOutlet UILabel *kindLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *daysLabel;
@end
