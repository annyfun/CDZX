//
//  ASTieXianShenQingTableViewCell.m
//  AcceptanceStar
//
//  Created by lcyu on 2016/11/24.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "ASTieXianShenQingTableViewCell.h" 
#import <UIView+FDCollapsibleConstraints.h>

@interface ASTieXianShenQingTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *bankNameLB;
@property (weak, nonatomic) IBOutlet UILabel *expLB;
@property (weak, nonatomic) IBOutlet UILabel *priceLB;
@property (weak, nonatomic) IBOutlet UILabel *phoneLB;
@property (weak, nonatomic) IBOutlet UILabel *priceLeftLB;
@property (weak, nonatomic) IBOutlet UILabel *allowPriceLeftLB;
@property (weak, nonatomic) IBOutlet UILabel *allowPriceLB;

@end
@implementation ASTieXianShenQingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setTieXianModel:(TieXianModel *)tieXianModel
{
    _tieXianModel = tieXianModel;
    if (_tieXianModel.reject) {
        UIColor *color = RGB(137, 137, 137);
        self.priceLB.textColor = color;
        self.priceLeftLB.textColor = color;
        self.allowPriceLB.textColor = color;
        self.allowPriceLeftLB.textColor = color;
        self.bankNameLB.textColor = color;
        self.phoneLB.fd_collapsed = YES;
    }
    else{
        self.bankNameLB.textColor = RGB(19, 19, 19);
        self.priceLB.textColor = RGB(52, 106, 174);
        self.priceLeftLB.textColor = RGB(19, 19, 19);
        self.allowPriceLB.textColor = RGB(104,174,52);
        self.allowPriceLeftLB.textColor = RGB(19, 19, 19);
        self.phoneLB.fd_collapsed = NO;
    }
    self.bankNameLB.text = _tieXianModel.bankName;
    self.expLB.text = _tieXianModel.date;
    self.priceLB.text = _tieXianModel.price;
    self.phoneLB.text = _tieXianModel.phone;
    self.allowPriceLB.text = @"填什么";
}
@end
