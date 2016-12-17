//
//  ASInfoTableViewCell.m
//  AcceptanceStar
//
//  Created by lcyu on 2016/11/22.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "ASInfoTableViewCell.h"
@interface ASInfoTableViewCell()
@property (weak, nonatomic) IBOutlet UITextField *totalPriceTF;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *companyTF;
@property (weak, nonatomic) IBOutlet UITextField *remarkTF;
@end
@implementation ASInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.companyTF addTarget:self action:@selector(tFDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    
    [self.remarkTF addTarget:self action:@selector(rFDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)tFDidChange:(UITextField *) sender {
    self.tieXianModel.company = sender.text;
}

- (void)rFDidChange:(UITextField *) sender {
    self.tieXianModel.remark = sender.text;
}


-(void)setTieXianModel:(TieXianModel *)tieXianModel
{
    _tieXianModel = tieXianModel;
    self.totalPriceTF.text = tieXianModel.totalPrice == 0? nil : [NSString stringWithFormat:@"%ld", tieXianModel.totalPrice];
    self.nameTF.text = tieXianModel.name;
    self.phoneTF.text = tieXianModel.phone;
    self.companyTF.text = self.tieXianModel.company;
    self.remarkTF.text = self.tieXianModel.remark;
}
@end
