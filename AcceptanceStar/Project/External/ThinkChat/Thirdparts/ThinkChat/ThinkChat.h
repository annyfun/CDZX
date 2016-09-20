//
//  ThinkChat.h
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TCConfig.h"

typedef enum {
    forTCConnectState_Connecting,   // 正在连接
    forTCConnectState_Success,      // 连接成功
    forTCConnectState_Failure,      // 连接失败
    forTCConnectState_Disconnect,   // 断开连接
    forTCConnectState_NoDisconnect, // 未断开连接
    forTCConnectState_TimeOut,      // 连接超时
}TCConnectState;

typedef enum {
    forTCLoginState_Wrong,      // 用户名或密码错误
    forTCLoginState_Success,    // 登录成功
    forTCLoginState_Failure,    // 登录失败
    forTCLoginState_Conflict,   // 异地登录
}TCLoginState;

// 无具体返回值回调
@protocol TCResultNoneDelegate <NSObject>

- (void)tcResultNoneError:(TCError*)itemE;

@end

// 单个用户返回回调
@protocol TCResultUserDelegate <NSObject>

- (void)tcResultUser:(TCUser*)itemU error:(TCError*)itemE;

@end

// 用户列表返回回调
@protocol TCResultUserListDelegate <NSObject>

- (void)tcResultUserList:(NSArray*)arr pageInfo:(TCPageInfo*)itemP error:(TCError*)itemE;

@end

// 单个群组或临时会话返回回调
@protocol TCResultGroupDelegate <NSObject>

- (void)tcResultGroup:(TCGroup*)itemG error:(TCError*)itemE;

@end

// 群组或临时会话列表返回回调
@protocol TCResultGroupListDelegate <NSObject>

- (void)tcResultGroupList:(NSArray*)arr pageInfo:(TCPageInfo*)itemP error:(TCError*)itemE;

@end

@protocol ThinkChatDelegate <NSObject>

@optional

// 连接状态变化: 连接中,连接成功,连接失败,连接冲突(异地登陆)

- (void)thinkChat:(id)sender connectState:(TCConnectState)tcState;

// 登陆授权状态变化: 登陆中,登陆成功,登陆失败

- (void)thinkChat:(id)sender loginState:(TCLoginState)tcState;

// 收到消息
- (void)thinkChat:(id)sender receiveMessage:(TCMessage*)tcMessage;

// 收到通知
- (void)thinkChat:(id)sender receiveNotify:(TCNotify*)tcNotify;

@end

@interface ThinkChat : NSObject

@property (nonatomic, readonly) NSString*   serverDomain;

@property (nonatomic, assign) id    delegate;

+ (ThinkChat*)instance;

#pragma mark - TCApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)pToken;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

#pragma mark - APNS

- (NSString*)setupApnsWithDelegate:(id <TCResultNoneDelegate>)aDelegate;
- (NSString*)cancelApnsWithDelegate:(id <TCResultNoneDelegate>)aDelegate;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	初始化聊天环境
 *
 *	@param 	serverUrl 	服务器地址(接口地址前部分,包含端口)
 *	@param 	imServerUrl 	聊天服务器地址
 *	@param 	imServerName 	聊天服务器名称
 *	@param 	imServerPort 	聊天服务器端口
 */
- (void)initWithServerUrl:(NSString*)serverUrl
              IMServerUrl:(NSString*)imServerUrl
             IMServerName:(NSString*)imServerName
             IMServerPort:(UInt16)imServerPort;



/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	连接服务器并登录
 *
 *	@param 	ID          用户对应聊天服务器的ID
 *	@param 	passWord 	密码
 *	@param 	del         处理连接状态以及登录状态
 */
- (void)loginWithID:(NSString*)ID
           passWord:(NSString*)passWord
           delegate:(id <ThinkChatDelegate>)del;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	退出登录
 */
- (void)logOut;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置调试模式
 *
 *	@param 	value          是否开启调试模式
 */
- (void)setDebugMode:(BOOL)value;

#pragma mark - API for Local

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取单个会话
 *
 *	@param 	sid 	会话ID
 *	@param 	typeChat 	会话类型
 *
 *	@return	会话
 */
- (TCSession*)getSessionWithID:(NSString*)sid typeChat:(ChatType)typeChat;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取当前登录用户所有消息未读数
 *
 *	@return	消息未读数
 */
- (int)getUnReadMessageCount;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取当前登录用户的所有会话列表
 *
 *	@return	会话列表
 */
- (NSArray*)getSessionListTimeLine;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	清空单个会话聊天记录
 *
 *	@param 	sid 	会话ID
 *	@param 	typeChat 	会话类型
 */
- (void)clearSessionID:(NSString*)sid typeChat:(ChatType)typeChat;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	标记单个会话所有聊天记录为已读
 *
 *	@param 	sid 	会话ID
 *	@param 	typeChat 	会话类型
 */
- (void)hasReadSessionID:(NSString *)sid typeChat:(ChatType)typeChat;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取会话的消息列表
 *
 *	@param 	withID 	会话ID
 *	@param 	typeChat 	会话类型
 *	@param 	sinceRowID 	若指定此参数，则返回rowID比sinceRowID大的消息（即比sinceRowID时间晚的消息），默认为0。与参数count配合使用
 *	@param 	maxRowID 	若指定此参数，则返回rowID小于maxRowID的消息，默认为0。与参数count配合使用
 *	@param 	count 	单页返回的记录条数，最大不超过100，默认为20。
 *	@param 	page 	返回结果的页码，默认为1。与参数count配合使用
 *
 *	@return	消息列表
 */
- (NSArray*)getMessageListTimeLineWithID:(NSString*)withID
                                typeChat:(ChatType)typeChat
                              sinceRowID:(int)sinceRowID
                                maxRowID:(int)maxRowID
                                   count:(int)count
                                    page:(int)page;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取会话的指定数量的最新未读消息记录
 *
 *	@param 	withID 	会话ID
 *	@param 	typeChat 	会话类型
 *	@param 	count 	单页返回的记录条数，最大不超过100，默认为20。
 *
 *	@return	消息列表
 */
- (NSArray*)getMessageListUnreadWithID:(NSString*)withID
                              typeChat:(ChatType)typeChat
                                 count:(int)count;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取当前登录用户的最新的一条通知
 *
 *	@return	通知
 */
- (TCNotify*)getLatestNotify;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取当前登录用户的所有未读通知数
 *
 *	@return	未读通知数
 */
- (int)getUnReadNotifyCount;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取当前登录用户的通知列表
 *
 *	@param 	itemN 	最后一条通知,默认为空时,返回最新的通知列表
 *
 *	@return	通知列表
 */
- (NSArray*)getNotifyListTimeLineWithFinalNotify:(TCNotify*)itemN;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置通知为已读
 *
 *	@param 	itemN 	待设置通知
 */
- (void)hasReadNotify:(TCNotify*)itemN;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置通知为已处理
 *
 *	@param 	itemN 	待设置通知
 */
- (void)hasDoneNotify:(TCNotify*)itemN;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	删除通知
 *
 *	@param 	itemN 	待删除通知
 */
- (void)hasDeleteNotify:(TCNotify*)itemN;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	更新通知内容
 *
 *	@param 	itemN 	待更新通知
 *	@param 	newContent 	新通知内容
 */
- (void)hasUpdateNotify:(TCNotify*)itemN newContent:(NSString*)newContent;



/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	取消网络接口访问
 *
 *	@param 	aTag 	接口访问标记
 */
- (void)cancelRequestTag:(NSString*)aTag;

#pragma mark - API for Server

/****************
 * 消息
 ****************/

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	发送消息
 *
 *	@param 	msg 	待发送消息体
 *	@param 	attach 	待发送附件
 *
 *	@return	接口访问标记
 */
- (NSString*)sendMessage:(TCMessage *)msg
                  attach:(NSData*)attach;


/**************
 * 会话
 **************/

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	创建临时会话并添加用户到该新会话
 *
 *	@param 	name 	待创建的会话名称
 *	@param 	userArr 	待添加的用户ID组
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)createConversationName:(NSString *)name
                           userList:(NSArray *)userArr
                           delegate:(id <TCResultGroupDelegate>)aDelegate;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	管理员添加用户到临时会话
 *
 *	@param 	userArr 	待添加的用户ID组
 *	@param 	cid 	临时会话ID
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)addUserList:(NSArray*)userArr
          toConversation:(NSString*)cid
                delegate:(id <TCResultNoneDelegate>)aDelegate;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取临时会话详细
 *
 *	@param 	cid 	临时会话ID
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)getConversationDetail:(NSString*)cid
                          delegate:(id <TCResultGroupDelegate>)aDelegate;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	管理员删除临时会话成员
 *
 *	@param 	uid 	待删除用户ID
 *	@param 	cid 	临时会话ID
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)deleteUser:(NSString*)uid
       fromConversation:(NSString*)cid
               delegate:(id <TCResultNoneDelegate>)aDelegate;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	成员退出临时会话
 *
 *	@param 	cid 	临时会话ID
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)quitConversation:(NSString*)cid
                     delegate:(id <TCResultNoneDelegate>)aDelegate;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	管理员编辑临时会话
 *
 *	@param 	cid 	临时会话ID
 *	@param 	name 	名称
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)modifyConversation:(NSString*)cid
                        newName:(NSString*)name
                       delegate:(id <TCResultGroupDelegate>)aDelegate;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置临时会话是否接收消息
 *
 *	@param 	cid 	临时会话ID
 *	@param 	isGet 	是否接受消息
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)setConversation:(NSString*)cid
                isGetMessage:(BOOL)isGet
                    delegate:(id <TCResultNoneDelegate>)aDelegate;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	管理员删除临时会话
 *
 *	@param 	cid 	临时会话ID
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)deleteConversation:(NSString*)cid
                       delegate:(id <TCResultNoneDelegate>)aDelegate;


/*******************
 *  群聊
 *******************/

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取群组详细
 *
 *	@param 	gid 	群组ID
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)getGroupDetail:(NSString*)gid
                   delegate:(id <TCResultGroupDelegate>)aDelegate;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	创建群组
 *
 *	@param 	name 	群名称
 *	@param 	img 	群头像
 *	@param 	description 	群描述
 *  @param  extend  扩展属性
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)createGroupName:(NSString *)name
                   headImage:(UIImage *)img
                 description:(NSString *)description
                      extend:(TCExtend*)extend
                    delegate:(id <TCResultGroupDelegate>)aDelegate;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	搜索群组
 *
 *	@param 	key 	搜索关键字
 *  @param  count   单页返回的记录条数，最大不超过100，超过100以100处理，默认为20。
 *  @param  page    返回结果的页码，默认为1。
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)searchGroup:(NSString*)key
                   count:(int)count
                    page:(int)page
                delegate:(id <TCResultGroupListDelegate>)aDelegate;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取当前登录用户所在群组列表
 *
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)getGroupListDelegate:(id <TCResultGroupListDelegate>)aDelegate;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	获取群组的成员列表
 *
 *	@param 	gid 	群组ID
 *  @param  count   单页返回的记录条数，最大不超过100，超过100以100处理，默认为20。
 *  @param  page    返回结果的页码，默认为1。
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)getUserListInGroup:(NSString*)gid
                          count:(int)count
                           page:(int)page
                       delegate:(id<TCResultUserListDelegate>)aDelegate;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	申请加入群组
 *
 *	@param 	gid 	群组ID
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)applyJoinGroup:(NSString*)gid
                   delegate:(id <TCResultNoneDelegate>)aDelegate;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	管理员同意用户加入群组
 *
 *	@param 	gid 	群组ID
 *	@param 	uid 	申请人ID
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)agreeApplyJoinGroup:(NSString*)gid
                            user:(NSString*)uid
                        delegate:(id <TCResultNoneDelegate>)aDelegate;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	管理员不同意用户加入群组
 *
 *	@param 	gid 	群组ID
 *	@param 	uid 	申请人ID
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)refuseApplyJoinGroup:(NSString*)gid
                             user:(NSString*)uid
                         delegate:(id <TCResultNoneDelegate>)aDelegate;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	管理员邀请用户加入群组
 *
 *	@param 	gid 	群组ID
 *	@param 	uid 	被邀请用户ID
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)inviteJoinGroup:(NSString*)gid
                        user:(NSString*)uid
                    delegate:(id <TCResultNoneDelegate>)aDelegate;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	用户同意邀请加入群组
 *
 *	@param 	gid 	群组ID
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)agreeInviteJoinGroup:(NSString*)gid
                         delegate:(id <TCResultNoneDelegate>)aDelegate;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	用户不同意邀请加入群组
 *
 *	@param 	gid 	群组ID
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)refuseInviteJoinGroup:(NSString*)gid
                          delegate:(id <TCResultNoneDelegate>)aDelegate;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	管理员删除群组成员
 *
 *	@param 	uid 	待删除的成员ID
 *	@param 	gid 	群组ID
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)deleteUser:(NSString*)uid
              fromGroup:(NSString*)gid
               delegate:(id <TCResultNoneDelegate>)aDelegate;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	成员退出群组
 *
 *	@param 	gid 	群组ID
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)quitGroup:(NSString*)gid
              delegate:(id <TCResultNoneDelegate>)aDelegate;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	管理员删除群组
 *
 *	@param 	gid 	群组ID
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)deleteGroup:(NSString*)gid
                delegate:(id <TCResultNoneDelegate>)aDelegate;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	管理员编辑群组资料
 *
 *	@param 	gid 	群组ID
 *	@param 	name 	群名称
 *	@param 	img 	群头像
 *	@param 	description 	群描述
 *  @param  extend  扩展属性
 *	@param 	aDelegate 	回调delegate
 *
 *	@return	接口访问标记
 */
- (NSString*)modifyGroup:(NSString*)gid
                    name:(NSString*)name
               headImage:(UIImage*)img
             description:(NSString*)description
                  extend:(TCExtend*)extend
                delegate:(id <TCResultNoneDelegate>)aDelegate;


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	设置群组是否接收消息
 *
 *	@param 	gid 	群组ID
 *	@param 	isGet 	是否接受消息
 *	@param 	aDelegate 	回调delegate
 *
 *	@return 接口访问标记
 */
- (NSString*)setGroup:(NSString*)gid
         isGetMessage:(BOOL)isGet
             delegate:(id <TCResultNoneDelegate>)aDelegate;


@end
