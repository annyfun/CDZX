//
//  HeadCheckCell.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-19.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "HeadCheckCell.h"

@interface HeadCheckCell () {
    IBOutlet UILabel* labTitle;
    IBOutlet UILabel* labDetail;
    IBOutlet UIImageView*   imgViewCheck;
}

@end

@implementation HeadCheckCell

@synthesize title;
@synthesize content;
@synthesize isCheck;

+ (CGFloat)heightWithItem:(id)item {
    return 60;
}

- (void)dealloc {
    title = nil;
    content = nil;
    labTitle = nil;
    labDetail = nil;
}

- (void)setTitle:(NSString *)str {
    title = str;
    labTitle.text = title;
}

- (void)setContent:(NSString *)str {
    content = str;
    labDetail.text = content;
}

- (void)setIsCheck:(BOOL)value {
    isCheck = value;
    if (isCheck) {
        imgViewCheck.image = [UIImage imageNamed:@"cell_check_d"];
    } else {
        imgViewCheck.image = [UIImage imageNamed:@"cell_check_n"];
    }
}

@end
