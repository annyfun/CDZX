//
//  ASCreditBankCell.m
//  AcceptanceStar
//
//  Created by benson on 11/21/16.
//  Copyright © 2016 Builder. All rights reserved.
//

#import "ASCreditBankCell.h"

@implementation ASCreditBankCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setSeparatorMargin];
}

- (void)setSeparatorMargin {
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [self setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set your cell's layout margins
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end
