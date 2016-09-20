//
//  TCNotify.h
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCBaseObject.h"

typedef enum {
    forProcessUntreated = 0,
    forProcessAccepted = 1,
    forProcessRefuse = 2,
}ProcessType;

@class TCUser;
@class TCMessage;
@class TCGroup;

@interface TCNotify : TCBaseObject

@property (nonatomic, strong) NSString*         ID;

@property (nonatomic, assign) NotifyType        type;
@property (nonatomic, strong) NSString*         content;
@property (nonatomic, assign) NSTimeInterval    time;

@property (nonatomic, strong) TCUser*           user;
@property (nonatomic, strong) TCMessage*        message;
@property (nonatomic, strong) TCGroup*          group;

@property (nonatomic, assign) BOOL              isRead;
@property (nonatomic, assign) BOOL              isDone;

- (BOOL)dealNotify;

#pragma DB

+ (void)createTableIfNotExists;

+ (TCNotify*)getLatestNotify;
+ (NSArray*)getNotifyListTimeLineWithFinalNotify:(TCNotify*)itemN;
+ (int)getUnReadCount;

// 设置通知为已读
+ (void)hasReadNotify:(TCNotify*)itemN;
- (void)hasRead;

// 设置通知为已处理
+ (void)hasDoneNotify:(TCNotify*)itemN;
- (void)hasDone;

// 删除通知
+ (void)hasDeleteNotify:(TCNotify*)itemN;
- (void)hasDelete;

// 更新通知内容
+ (void)hasUpdateNotify:(TCNotify *)itemN newContent:(NSString *)newContent;
- (void)hasUpdateNewContent:(NSString *)newContent;

@end
