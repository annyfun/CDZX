//
//  UserListController.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-12.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "BaseListController.h"

typedef enum {
    forUserListType_GroupMember,
    forUserListType_GroupInvite,
    forUserListType_ConversationAdd,
}UserListType;

@class TCGroup;

@interface UserListController : BaseListController

- (id)initWithGroup:(TCGroup*)item type:(UserListType)theType;

@end
