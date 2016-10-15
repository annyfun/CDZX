//
//  ButtonHeadCell.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-25.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "ButtonHeadCell.h"

@implementation ButtonHeadCell

@synthesize titleButton;
@synthesize bkgImage;

- (void)dealloc {
    self.titleButton = nil;
    self.bkgImage = nil;
}

- (void)initialiseCell {
    [super initialiseCell];
    
    btnInCell.titleLabel.font = [UIFont systemFontOfSize:16];
    [btnInCell setTitleColor:kColorWhite forState:UIControlStateNormal];
    [btnInCell setTitleColor:kColorWhite forState:UIControlStateHighlighted];
    [btnInCell setBackgroundImage:[UIImage imageWithColor:kColorBtnBkgGreen] forState:UIControlStateNormal];
    btnInCell.layer.cornerRadius = kCornerRadiusButton;
    btnInCell.clipsToBounds = YES;
}

- (IBAction)btnPressed:(id)sender {
    if (sender == btnInCell) {
        if ([self.delegate respondsToSelector:@selector(ButtonHeadCellDidPressedButton:)]) {
            [self.delegate ButtonHeadCellDidPressedButton:self];
        }
    }
}

- (void)setTitleButton:(NSString *)str {
    titleButton = str;

    [btnInCell setTitle:titleButton forState:UIControlStateNormal];

    if (titleButton) {
        btnInCell.hidden = NO;
    } else {
        btnInCell.hidden = YES;
    }
}

- (void)setBkgImage:(UIImage *)img {
    bkgImage = img;
    [btnInCell setBackgroundImage:bkgImage forState:UIControlStateNormal];
}

@end
