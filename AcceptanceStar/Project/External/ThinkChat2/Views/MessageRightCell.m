//
//  MessageRightCell.m
//  DaMi
//
//  Created by keen on 14-5-12.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "MessageRightCell.h"
#import "TCMessage.h"

@implementation MessageRightCell

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect frame = btnContent.frame;
    CGFloat width = [ContentRight widthWithItem:self.message];
    CGFloat height = [ContentRight heightWithItem:self.message];
    frame.origin.x += frame.size.width - width;
    frame.size.width = width;
    frame.size.height = height;
    btnContent.frame = frame;
    
    frame = btnFail.frame;
    CGPoint contentOrigin = btnContent.frame.origin;
    CGFloat pointX = contentOrigin.x - 8 - frame.size.width;
    CGFloat pointY = contentOrigin.y + (btnContent.frame.size.height - frame.size.height)/2;
    frame.origin = CGPointMake(pointX, pointY);
    btnFail.frame = frame;
    
    self.contentFrame =  CGRectMake(btnContent.frame.origin.x + btnContent.frameContent.origin.x,
                                    btnContent.frame.origin.y + btnContent.frameContent.origin.y,
                                    btnContent.frameContent.size.width,
                                    btnContent.frameContent.size.height);
    actView.center = btnContent.center;
}

@end
