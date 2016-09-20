//
//  ASContactsHeader.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/9/4.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASContactsHeader.h"

@implementation ASContactsHeader

+ (CGFloat)HeightOfViewByObject:(NSObject *)object {
    return AUTOLAYOUT_LENGTH(80);
}
- (void)layoutObject:(UserModel *)user {
    if (user.isOpen) {
        self.arrowImageView.image = [UIImage imageNamed:@"icon_down1"];
    }
    else {
        self.arrowImageView.image = [UIImage imageNamed:@"icon_right"];
    }
    [self resetSelected:user.isSelected];
}

- (void)resetSelected:(BOOL)selected {
    if (selected) {
        self.markImageView.image = [UIImage imageNamed:@"mark_selected"];
    }
    else {
        self.markImageView.image = [UIImage imageNamed:@"mark_unselected"];
    }
}

@end
