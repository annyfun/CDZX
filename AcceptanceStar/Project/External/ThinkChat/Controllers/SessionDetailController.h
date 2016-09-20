//
//  SessionDetailController.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-25.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "BaseListController.h"

@class TCSession;

typedef enum {
    forSessionDetailRequest_Quit = 0,   // 退出
    forSessionDetailRequest_Delete,     // 删除
    forSessionDetailRequest_Kick,       // 踢人
    forSessionDetailRequest_IsGetMsg,   // 是否接受新消息
}SessionDetailRequestType;

@interface SessionDetailController : BaseListController

- (id)initWithSession:(TCSession*)item;

@end
