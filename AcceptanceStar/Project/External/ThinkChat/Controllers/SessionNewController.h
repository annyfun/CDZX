//
//  SessionNewController.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-19.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "BaseListController.h"

@class TCSession;


@protocol SessionNewDelegate <NSObject>

- (void)sessionNew:(id)sender addUserList:(NSArray*)arr;

@end

@interface SessionNewController : BaseListController

- (id)initWithSession:(TCSession*)itemS userList:(NSArray*)arr delegate:(id <SessionNewDelegate>)del;

@end
