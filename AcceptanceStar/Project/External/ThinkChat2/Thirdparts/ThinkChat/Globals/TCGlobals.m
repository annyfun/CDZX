//
//  TCGlobals.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-11.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCGlobals.h"
#import "TCUser.h"
#import "TCGroup.h"
#import "TCMessage.h"
#import "TCSession.h"
#import "TCNotify.h"

#import "TCDBConnection.h"

@implementation TCGlobals

+ (void)createTableIfNotExists {
    [TCDBConnection getSharedDatabase];
    
    [TCUser createTableIfNotExists];
    [TCGroup createTableIfNotExists];
    [TCMessage createTableIfNotExists];
    [TCSession createTableIfNotExists];
    [TCNotify createTableIfNotExists];
}

#define kThinkChatIfCloseAPNS                @"ThinkChatIfCloseAPNS"

+ (BOOL)isNotify {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return ![defaults boolForKey:kThinkChatIfCloseAPNS];
}

+ (void)setIsNotify:(BOOL)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:!value forKey:kThinkChatIfCloseAPNS];
    [defaults synchronize];
}

@end
