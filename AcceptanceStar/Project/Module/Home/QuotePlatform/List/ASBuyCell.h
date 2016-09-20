//
//  ASBuyInformationCell.h
//  AcceptanceStar
//
//  Created by yangshengchao on 15/6/1.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASBuyCell : YSCBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *attrImageView;//票据属性
@property (weak, nonatomic) IBOutlet UILabel *classLabel;//承兑行类型
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;//买入金额
@property (weak, nonatomic) IBOutlet UILabel *daysLabel;//剩余天数
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;//报价利率
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;//兑换城市

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactsLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end
