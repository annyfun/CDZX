//
//  ASContactsCell.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/9/4.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASContactsCell.h"

@implementation ASContactsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.statusLabel.hidden = YES;
}

+ (CGFloat)HeightOfCellByObject:(NSObject *)object {
    return AUTOLAYOUT_LENGTH(120);
}

- (void)layoutObject:(UserModel *)user {
    [self.avatarImageView setImageWithURLString:user.headsmall placeholderImageName:@"default_head_user" withFadeIn:NO];
    self.nickNameLabel.text = user.nickname;
    if (isEmpty(user.sign)) {
        self.signLabel.text = @"TA很懒，什么都没留下";
    }
    else {
        self.signLabel.text = Trim(user.sign);
    }
    
    WEAKSELF
    [self.markView removeAllGestureRecognizers];
    [self.markView bk_whenTapped:^{
        user.isSelected = !user.isSelected;
        [blockSelf resetSelected:user.isSelected];
    }];
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
