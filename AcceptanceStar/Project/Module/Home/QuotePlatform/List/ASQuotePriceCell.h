//
//  ASQuotePriceCell.h
//  AcceptanceStar
//
//  Created by yangshengchao on 15/6/1.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASQuotePriceCell : YSCBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *attrImageView;//票据属性
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;//机构名称
@property (weak, nonatomic) IBOutlet UILabel *gg_rLabel;//
@property (weak, nonatomic) IBOutlet UILabel *ds_rLabel;//
@property (weak, nonatomic) IBOutlet UILabel *xs_rLabel;//
@property (weak, nonatomic) IBOutlet UILabel *qt_rLabel;//

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *daysLabel;
@end
