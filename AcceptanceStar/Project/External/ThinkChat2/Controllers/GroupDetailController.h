//
//  GroupDetailController.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-11.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "BaseListController.h"

@class TCGroup;

typedef enum {
    forGroupDetailRequestType_ApplyJoin,
    forGroupDetailRequestType_Quit,
    forGroupDetailRequestType_Delete,
    forGroupDetailRequestType_IsGetMessage,
}GroupDetailRequestType;

@interface GroupDetailController : BaseListController

- (id)initWithGroup:(TCGroup*)item;

@end
