//
//  TCEngine.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-8.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCEngine.h"

#define kThinkChatCurrentUserID         @"ThinkChatCurrentUserID"
#define kThinkChatCurrentPassword		@"ThinkChatCurrentPassword"

static TCEngine* _currentTCEngine;

@implementation TCEngine

@synthesize userID;
@synthesize passWord;
@synthesize deviceIDAPNS;

+ (TCEngine*)currentEngine {
    if (_currentTCEngine == nil) {
        _currentTCEngine = [[TCEngine alloc] init];
    }
    return _currentTCEngine;
}

- (id)init {
    if (self = [super init]) {
        [self readAuthorizeData];
    }
    return self;
}

- (void)dealloc {
    self.userID = nil;
    self.passWord = nil;
    self.deviceIDAPNS = nil;
}

- (void)saveAuthorizeData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (userID) {
        [defaults setObject:userID forKey:kThinkChatCurrentUserID];
    }
    if (passWord) {
        [defaults setObject:passWord forKey:kThinkChatCurrentPassword];
    }
    
	[defaults synchronize];
}

- (void)readAuthorizeData {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.userID   = [defaults objectForKey:kThinkChatCurrentUserID];
    self.passWord = [defaults objectForKey:kThinkChatCurrentPassword];
}

- (void)deleteAuthorizeData {
    self.userID = nil;
    self.passWord = nil;
    self.deviceIDAPNS = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:kThinkChatCurrentUserID];
    [defaults removeObjectForKey:kThinkChatCurrentPassword];
    
	[defaults synchronize];
}

- (void)setCurrentUserID:(NSString *)strID password:(NSString *)pwd {
    self.userID = strID;
    self.passWord = pwd;
    
    [self saveAuthorizeData];
}

- (BOOL)isLoggedIn
{
    return self.userID && self.userID.length > 0;
}

- (void)logOut {
    [self deleteAuthorizeData];
}

@end
