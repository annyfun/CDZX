//
//  TCEngine.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-8.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCEngine : NSObject

@property (nonatomic, strong) NSString* userID;
@property (nonatomic, strong) NSString* passWord;
@property (nonatomic, strong) NSString* deviceIDAPNS;

+ (TCEngine*)currentEngine;

- (void)saveAuthorizeData;

- (void)setCurrentUserID:(NSString*)strID password:(NSString*)pwd;

- (BOOL)isLoggedIn;

- (void)logOut;


@end
