//
//  MessageLeftCell.m
//  DaMi
//
//  Created by keen on 14-5-12.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "MessageLeftCell.h"
#import "TCMessage.h"

@implementation MessageLeftCell

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = btnContent.frame;
    CGFloat width = [ContentLeft widthWithItem:self.message];
    CGFloat height = [ContentLeft heightWithItem:self.message];
    frame.size.width = width;
    frame.size.height = height;
    btnContent.frame = frame;
    
    self.contentFrame =  CGRectMake(btnContent.frame.origin.x + btnContent.frameContent.origin.x,
                                    btnContent.frame.origin.y + btnContent.frameContent.origin.y,
                                    btnContent.frameContent.size.width,
                                    btnContent.frameContent.size.height);
    actView.center = btnContent.center;
}

@end
