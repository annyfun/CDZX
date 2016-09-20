//
//  TCGlobals.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-11.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCGlobals : NSObject

#define kTCSDKErrorDomain           @"SDKErrorDomain"
#define kTCSDKErrorCodeKey          @"SDKErrorCodeKey"


+ (void)createTableIfNotExists;

+ (BOOL)isNotify;
+ (void)setIsNotify:(BOOL)value;

@end
