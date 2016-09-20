//
//  TCMessage.h
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCBaseObject.h"
#import "TCUser.h"
#import "TCTextMessageBody.h"
#import "TCImageMessageBody.h"
#import "TCVoiceMessageBody.h"
#import "TCLocationMessageBody.h"

@interface TCMessage : TCBaseObject

@property (nonatomic, strong) NSString*         ID;             // ID(唯一)   服务器指定
@property (nonatomic, strong) NSString*         tag;            // 标志(唯一)  客户端指定

@property (nonatomic, assign) ChatType          typeChat;       // 消息类型 (100单聊,200群聊)
@property (nonatomic, assign) FileType          typeFile;       // 文件类型 (1文字,2图片,3语音,4位置)

@property (nonatomic, strong) TCUser*           from;
@property (nonatomic, strong) TCUser*           to;

@property (nonatomic, assign) NSTimeInterval    time;           // 时间 (毫秒)

@property (nonatomic, strong) TCMessageBody*    body;           // 消息体

// 增加属性

@property (nonatomic, strong) NSString*         contentFormat;  // 格式化后的显示内容
@property (nonatomic, strong) NSString*         withID;         // 单聊为对方的ID,群聊为部落ID或会议ID
@property (nonatomic, assign) MessageState      state;          // 消息状态
@property (nonatomic, assign) BOOL              isRead;         // 是否已读
@property (nonatomic, assign) BOOL              isSendByMe;     // 是否为自己发送的消息
@property (nonatomic, assign) int               rowID;          // sqlite 自增 ID,只用作数据库查询

// get 属性
@property (nonatomic, assign, readonly) int     imgWidthHalf;   // 图片半宽
@property (nonatomic, assign, readonly) int     imgHeightHalf;  // 图片半高

@property (nonatomic, readonly) TCTextMessageBody*      bodyText;
@property (nonatomic, readonly) TCImageMessageBody*     bodyImage;
@property (nonatomic, readonly) TCVoiceMessageBody*     bodyVoice;
@property (nonatomic, readonly) TCLocationMessageBody*  bodyLocation;

+ (TCMessage*)newMessage;

#pragma DB

+ (void)createTableIfNotExists;

+ (NSArray*)getMessageListTimeLineWithID:(NSString *)withID
                                typeChat:(ChatType)typeChat
                              sinceRowID:(int)sinceRowID
                                maxRowID:(int)maxRowID
                                   count:(int)count
                                    page:(int)page;

+ (NSArray*)getMessageListUnreadWithID:(NSString *)withID
                              typeChat:(ChatType)typeChat
                                 count:(int)count;

+ (TCMessage*)getLatestMessageWithID:(NSString*)wID typeChat:(ChatType)typeChat;

+ (void)cleanMessageWithID:(NSString*)wID typeChat:(ChatType)typeChat;
+ (void)hasReadMessageWithID:(NSString*)wID typeChat:(ChatType)typeChat;

+ (TCMessage*)objectWithID:(NSString*)wID foreignKey:(NSString*)fKey;

- (void)insertDBWithForeignKey:(NSString*)fKey;
- (void)deleteFromDBWithForeignKey:(NSString*)fKey;

@end
