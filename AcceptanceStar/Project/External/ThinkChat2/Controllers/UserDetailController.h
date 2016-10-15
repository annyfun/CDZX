//
//  UserDetailController.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-11.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "BaseListController.h"

@class User;

typedef enum {
    forUserDetailRequestType_ApplyFriend,
    forUserDetailRequestType_DeleteFriend,
}UserDetailRequestType;

@interface UserDetailController : BaseListController

- (id)initWithUser:(User*)item;

@end
