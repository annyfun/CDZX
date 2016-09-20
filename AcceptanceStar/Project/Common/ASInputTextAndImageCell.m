//
//  ASInputTextAndImageCell.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/6/8.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASInputTextAndImageCell.h"

@implementation ASInputTextAndImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [UIView makeRoundForView:self.valueTextField withRadius:5];
    [UIView makeBorderForView:self.valueTextField withColor:RGB(142, 142, 142) borderWidth:1];
}

@end
