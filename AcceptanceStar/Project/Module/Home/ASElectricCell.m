//
//  ASElectricCell.m
//  AcceptanceStar
//
//  Created by Jinjin on 2016/11/22.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "ASElectricCell.h"

@implementation ASElectricCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
