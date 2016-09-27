//
//  TCSession.h
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCBaseObject.h"

@class TCUser;
@class TCGroup;
@class TCMessage;

@interface TCSession : TCBaseObject

@property (nonatomic, strong) NSString*      ID;            // 同 Message.withID
@property (nonatomic, assign) ChatType       typeChat;      // 消息类型

@property (nonatomic, strong) NSString*      name;
@property (nonatomic, strong) NSString*      head;
@property (nonatomic, strong) NSString*      content;       // 内容
@property (nonatomic, assign) NSTimeInterval time;          // 更新时间
@property (nonatomic, assign) int            unreadCount;   // 未读数

@property (nonatomic, strong) TCMessage*     message;       // 最新的一条消息
@property (nonatomic, strong) TCUser*        user;
@property (nonatomic, strong) TCGroup*       group;

+ (void)createTableIfNotExists;

+ (NSArray*)getSessionListTimeLine;
+ (TCSession*)sessionWithMessage:(TCMessage*)item;
+ (TCSession*)sessionWithUser:(TCUser *)item;
+ (TCSession*)sessionWithGroup:(TCGroup *)item;
+ (void)updateWithMessage:(TCMessage*)item;

- (void)updateWithMessage:(TCMessage*)item;

+ (int)getUnReadMessageCount;

- (void)insertDB;

+ (void)clearSessionID:(NSString*)sid typeChat:(ChatType)typeChat;
+ (void)hasReadSessionID:(NSString *)sid typeChat:(ChatType)typeChat;

+ (TCSession*)sessionWithID:(NSString*)sid typeChat:(ChatType)typeChat;
+ (TCSession*)getSessionFromDBWithID:(NSString*)wID typeChat:(ChatType)typeChat;

@end
