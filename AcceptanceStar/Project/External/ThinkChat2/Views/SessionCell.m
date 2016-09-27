//
//  SessionCell.m
//  HomeBridge
//
//  Created by keen on 14-6-24.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "SessionCell.h"
#import "TCSession.h"
#import "JSBadgeView.h"
#import "EmotionInputView.h"

@interface SessionCell () {
    IBOutlet UIImageView* imgViewHeadBkg;
    IBOutlet UIImageView* imgViewHead1;
    IBOutlet UIImageView* imgViewHead2;
    IBOutlet UIImageView* imgViewHead3;
    IBOutlet UIImageView* imgViewHead4;
    IBOutlet UILabel*     labName;
    IBOutlet UILabel*     labTime;
    IBOutlet UILabel*     labContent;

    JSBadgeView*    badgeView;
}

@end

@implementation SessionCell

@synthesize session;

+ (CGFloat)heightWithItem:(id)item {
    return 70;
}

- (void)dealloc {
    // data
    self.session = nil;
    
    // view
    imgViewHeadBkg = nil;
    imgViewHead1 = nil;
    imgViewHead2 = nil;
    imgViewHead3 = nil;
    imgViewHead4 = nil;
    labName = nil;
    labTime = nil;
    labContent = nil;
    
    badgeView = nil;
}

- (void)setSession:(TCSession *)item {
    session = item;
    
    labName.text = session.name;
    labTime.text = [Globals timeStringWith:session.time];
    labContent.text = [EmotionInputView decodeMessageEmoji:session.content];
    
    int unReadCount = session.unreadCount;
    NSString* strBadgeValue = nil;
    if (unReadCount > 99) {
        strBadgeValue = @"99+";
    } else if (unReadCount > 0) {
        strBadgeValue = [NSString stringWithFormat:@"%d",unReadCount];
    }

    self.badgeValue = strBadgeValue;
}

- (void)setBadgeValue:(NSString *)value {
    if (badgeView == nil) {
        badgeView = [[JSBadgeView alloc] initWithParentView:imgViewHeadBkg alignment:JSBadgeViewAlignmentTopRight];
        imgViewHeadBkg.clipsToBounds = NO;
    }
    badgeView.badgeText = value;
}

- (void)setImageHead:(UIImage *)imgHead tag:(NSInteger)tag {
    UIImageView* imgViewHead = nil;
    if (tag == 0) {
        imgViewHead = imgViewHead1;
    } else if (tag == 1) {
        imgViewHead = imgViewHead2;
    } else if (tag == 2) {
        imgViewHead = imgViewHead3;
    } else if (tag == 3) {
        imgViewHead = imgViewHead4;
    }
    if (imgViewHead) {
        imgViewHead.image = imgHead;
    }
}

@end
