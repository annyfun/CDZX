//
//  BaseEngine.h
//  Base
//
//  Created by keen on 13-10-25.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface BaseEngine : NSObject

@property (nonatomic, strong)   User*       user;
@property (nonatomic, strong)   NSString*   passWord;
@property (nonatomic, strong)   NSString*   deviceIDAPNS;

+ (BaseEngine *) currentBaseEngine;

- (void)saveAuthorizeData;

- (void)setCurrentUser:(User*)item password:(NSString*)pwd;

- (BOOL)isLoggedIn;

- (void)logOut;

@end
