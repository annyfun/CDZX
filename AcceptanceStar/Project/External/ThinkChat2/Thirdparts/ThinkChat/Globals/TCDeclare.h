//
//  TCDeclare.h
//  ThinkChat
//
//  Created by keen on 14-8-21.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#ifndef ThinkChat_TCDeclare_h
#define ThinkChat_TCDeclare_h

typedef enum {
	kTCErrorCodeInterface	= 100,
	kTCErrorCodeSDK         = 101,
}TCErrorCode;

typedef enum {
	kTCSDKErrorCodeParseError       = 200,
	kTCSDKErrorCodeRequestError     = 201,
}TCSDKErrorCode;


// 消息类型
typedef enum {
    forChatTypeUser = 100,
    forChatTypeGroup = 200,
    forChatTypeRoom = 300,
}ChatType;

// 文件类型
typedef enum {
    forFileText = 1,    // 文字
    forFileImage = 2,   // 图片
    forFileVoice = 3,   // 声音
    forFileLocation = 4,// 位置
}FileType;

// 消息状态
typedef enum {
    forMessageStateNormal = 0,  // 收到的消息，发送成功的消息
    forMessageStateError = 1,   // 发送失败
    forMessageStateHavent = 2,  // 未发送
}MessageState;

/*
 通知类型
 1   系统通知
 
 101 申请加好友
 102 同意加好友
 103 不同意加好友
 
 300 用户退出会议
 301 管理员删除用户
 302 管理员编辑会话名称
 303 管理员删除会话
 
 202 申请加群
 203 同意申请入群
 204 不同意申请入群
 
 205 邀请入群
 206 同意邀请入群
 207 不同意邀请入群
 
 208 管理员删除成员
 209 退出部落
 210 删除群
 */

typedef enum {
    forNotifyType_System = 1,    // 1   系统通知
    
    forNotifyType_ConversationQuit = 300,    // 300 用户退出会议
    forNotifyType_ConversationRemove = 301,  // 301 管理员删除用户
    forNotifyType_ConversationEdit = 302,    // 302 管理员编辑会话名称
    forNotifyType_ConversationDele = 303,    // 303 管理员删除会话
    forNotifyType_ConversationKick = 304,    // 304 被踢出会话

    forNotifyType_GroupJoinApply = 202,    // 202 申请加群
    forNotifyType_GroupJoinAgree = 203,    // 203 同意申请入群
    forNotifyType_GroupJoinRefuse = 204,   // 204 不同意申请入群
    
    forNotifyType_GroupInviteApply = 205,    // 205 邀请入群
    forNotifyType_GroupInviteAgree = 206,    // 206 同意邀请入群
    forNotifyType_GroupInviteRefuse = 207,   // 207 不同意邀请入群
    
    forNotifyType_GroupKick = 208,    // 208 被踢出群
    forNotifyType_GroupQuit = 209,    // 209 退出部落
    forNotifyType_GroupDele = 210,    // 210 删除群
    forNotifyType_GroupRemove = 211,  // 211 管理员删除成员

    forNotifyType_Extend = 10000,   // 10000 扩展通知起始点
}NotifyType;

#define TC_DB_Version @"1.0.10"

#define defaultSizeInt 20
#define defaultSizeStr @"20"

#endif
