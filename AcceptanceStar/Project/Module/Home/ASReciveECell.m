//
//  ASReciveECell.m
//  AcceptanceStar
//
//  Created by Jinjin on 2016/11/29.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "ASReciveECell.h"

@implementation ASReciveECell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    self.selectionStyle = UITableViewCellSelectionStyleGray;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
