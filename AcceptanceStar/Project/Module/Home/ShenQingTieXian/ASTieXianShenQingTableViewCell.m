//
//  ASTieXianShenQingTableViewCell.m
//  AcceptanceStar
//
//  Created by lcyu on 2016/11/24.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "ASTieXianShenQingTableViewCell.h"
@interface ASTieXianShenQingTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *bankNameLB;
@property (weak, nonatomic) IBOutlet UILabel *expLB;
@property (weak, nonatomic) IBOutlet UILabel *priceLB;
@property (weak, nonatomic) IBOutlet UILabel *phoneLB;

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
//    self.bankNameLB.text = _tieXianModel.ban
}
@end
