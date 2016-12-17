//
//  ASReceivedTieXianShenQingTableViewCell.m
//  AcceptanceStar
//
//  Created by lcyu on 2016/11/24.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "ASReceivedTieXianShenQingTableViewCell.h"
@interface ASReceivedTieXianShenQingTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLB;
@property (weak, nonatomic) IBOutlet UILabel *phoneLB;
@property (weak, nonatomic) IBOutlet UILabel *priceLB;
@property (weak, nonatomic) IBOutlet UILabel *dateLB;
@property (weak, nonatomic) IBOutlet UIImageView *headerIV;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;

@end
@implementation ASReceivedTieXianShenQingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setTieXianModel:(TieXianModel *)tieXianModel
{
    _tieXianModel = tieXianModel;
    self.nameLB.text = _tieXianModel.name;
    self.phoneLB.text = _tieXianModel.phone;
    self.priceLB.text = _tieXianModel.price;
    self.dateLB.text = _tieXianModel.date;
    [self.headerIV setImageWithURLString:_tieXianModel.headpic placeholderImage:DefaultAvatarImage];
    
    UIColor *textColor = [UIColor lightGrayColor];
    UIImage *statusImage = nil;
    UIColor *imageColor = [UIColor clearColor];
    
    if (tieXianModel.rstatus==ASElectricStautsReject){
        statusImage = [UIImage imageNamed:@"img_e_reject"];
        imageColor = [UIColor redColor];
    }else if(tieXianModel.rstatus==ASElectricStautsWan){
        statusImage = [UIImage imageNamed:@"img_e_pass"];
        imageColor = [UIColor greenColor];
    }else{
        textColor = [UIColor blackColor];
    }
    self.nameLB.textColor = textColor;
    self.phoneLB.textColor = textColor;
    self.priceLB.textColor = textColor;
    self.dateLB.textColor = textColor;
    
    self.statusImageView.image = statusImage;
    self.statusImageView.backgroundColor = imageColor;
    
}

@end
