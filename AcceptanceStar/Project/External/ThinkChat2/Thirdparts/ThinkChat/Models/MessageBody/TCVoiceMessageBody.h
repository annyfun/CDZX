//
//  TCVoiceMessageBody.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-8.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCMessageBody.h"

@interface TCVoiceMessageBody : TCMessageBody

@property (nonatomic, strong) NSString* voiceUrl;       // 音频
@property (nonatomic, assign) float     voiceTime;      // 音频时长 (秒)

@end
