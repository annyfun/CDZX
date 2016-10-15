//
//  SimpleHeadCell.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-11.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "SimpleHeadCell.h"

@implementation SimpleHeadCell

@synthesize title;
@synthesize number;
@synthesize detail;

+ (CGFloat)heightWithItem:(id)item {
    return 60;
}

- (void)dealloc {
    title = nil;
    number = nil;
    detail = nil;
    labTitle = nil;
    labDetail = nil;
    labNumber = nil;
}

- (void)setTitle:(NSString *)str {
    title = str;
    labTitle.text = title;
    [labTitle sizeToFit];
    labNumber.left = CGRectGetMaxX(labTitle.frame) + 5;
}
- (void)setNumber:(NSString *)str {
    labNumber.hidden = isEmpty(str);
    number = str;
    labNumber.text = number;
    [labNumber sizeToFit];
}
- (void)setDetail:(NSString *)str {
    detail = str;
    if (isNotEmpty(str)) {
        labDetail.text = detail;
    }
    else {
        labDetail.text = @"TA很懒，什么都没留下";
    }
    [labDetail sizeToFit];
}

@end
