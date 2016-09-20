//
//  NotifyCell.m
//  DaMi
//
//  Created by keen on 14-4-4.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "NotifyCell.h"
#import "TCNotify.h"

@interface NotifyCell () {
    IBOutlet UILabel*   labContent;
    IBOutlet UILabel*   labState;
    IBOutlet UILabel*   labTime;
}

@end

@implementation NotifyCell

@synthesize notify;

+ (CGFloat)heightWithItem:(TCNotify*)item {
    CGFloat offSetX = 10;
    if (systemVersionFloatValue < 7.0) {
        offSetX += 11;
    } else {
        offSetX += 15;
    }
    UIFont* font = [UIFont systemFontOfSize:16];
    CGSize size = [item.content sizeWithFont:font maxWidth:320 - offSetX*2 maxNumberLines:0];
    
    return size.height + 46;
}


- (void)dealloc {
    notify = nil;
    labContent = nil;
    labState = nil;
    labTime = nil;
}

- (void)initialiseCell {
    [super initialiseCell];
    
    labTime.textColor = kColorTitleLightGray;
    labState.textColor = kColorTitleGray;
    labState.text = @"已处理";
}

- (void)setNotify:(TCNotify *)item {
    notify = item;
    
    labContent.text = notify.content;
    labTime.text = [Globals timeStringWith:notify.time];

    if (notify.isRead) {
        labContent.textColor = kColorTitleGray;
    } else {
        labContent.textColor = kColorTitleBlack;
    }

    labState.hidden = !notify.isDone;
}

@end
