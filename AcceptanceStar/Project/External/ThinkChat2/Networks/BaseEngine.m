//
//  BaseEngine.m
//  Base
//
//  Created by keen on 13-10-25.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import "BaseEngine.h"

#define kBaseCurrentUserInfo		@"BaseUserInfo"
#define kBaseCurrentPassword		@"BasePassWord"

static BaseEngine * _currentBaseEngine;

@implementation BaseEngine

@synthesize user;
@synthesize passWord;
@synthesize deviceIDAPNS;

+ (BaseEngine *) currentBaseEngine
{
    if (_currentBaseEngine == nil) {
        _currentBaseEngine = [[BaseEngine alloc] init];
    }
	return _currentBaseEngine;
}

- (id)init {
    if (self = [super init]) {
        [self readAuthorizeData];
    }
    return self;
}

- (void)dealloc {
    self.user = nil;
    self.passWord = nil;
    self.deviceIDAPNS = nil;
}

- (void)saveAuthorizeData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:user];
    if (data) {
        [defaults setObject:data forKey:kBaseCurrentUserInfo];
    }
    if (passWord) {
        [defaults setObject:passWord forKey:kBaseCurrentPassword];
    }
    
	[defaults synchronize];
}

- (void)readAuthorizeData {
    
    self.user = nil;
    self.passWord = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData* data = [defaults objectForKey:kBaseCurrentUserInfo];
    NSString* pwd = [defaults objectForKey:kBaseCurrentPassword];
    if (data) {
        self.user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    if (pwd) {
        self.passWord = pwd;
    }
}

- (void)deleteAuthorizeData {
    self.user = nil;
    self.passWord = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:kBaseCurrentUserInfo];
    [defaults removeObjectForKey:kBaseCurrentPassword];

	[defaults synchronize];
}

- (void)setCurrentUser:(User *)item password:(NSString *)pwd {
    self.user = item;
    self.passWord = pwd;
    [self saveAuthorizeData];
}

- (BOOL)isLoggedIn
{
    return self.user && self.user.ID.length > 0;
}

- (void)logOut {
    [self deleteAuthorizeData];
}


@end
