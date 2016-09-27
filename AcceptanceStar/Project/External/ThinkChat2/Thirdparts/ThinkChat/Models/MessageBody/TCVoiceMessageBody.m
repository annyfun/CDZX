//
//  TCVoiceMessageBody.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-8.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCVoiceMessageBody.h"

@implementation TCVoiceMessageBody

@synthesize voiceUrl;
@synthesize voiceTime;

- (void)dealloc {
    self.voiceUrl = nil;
}

- (void)updateWithJsonDic:(NSDictionary *)dic {
    [super updateWithJsonDic:dic];
    if (isInitSuccuss) {
        self.voiceUrl   = [dic getStringValueForKey:@"url"  defaultValue:nil];
        self.voiceTime  = [dic getIntValueForKey:   @"time" defaultValue:0];
    }
}

@end
