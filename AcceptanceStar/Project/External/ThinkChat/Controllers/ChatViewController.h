//
//  ChatViewController.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-8.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "BaseListController.h"

@class TCSession;
@class TCGroup;
@class User;

@interface ChatViewController : BaseListController

- (id)initWithSession:(TCSession*)item;
- (id)initWithGroup:(TCGroup*)item;
- (id)initWithUser:(User*)item;

@end
