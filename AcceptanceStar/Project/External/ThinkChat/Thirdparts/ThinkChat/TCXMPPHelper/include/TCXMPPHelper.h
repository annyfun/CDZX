//
//  TCXMPPHelper.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-15.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    forHelperConnectState_Connecting,   // 正在连接
    forHelperConnectState_Success,      // 连接成功
    forHelperConnectState_Failure,      // 连接失败
    forHelperConnectState_Disconnect,   // 断开连接
    forHelperConnectState_NoDisconnect, // 未断开连接
    forHelperConnectState_TimeOut,      // 连接超时
}HelperConnectState;

typedef enum {
    forHelperLoginState_Wrong,      // 用户名或密码错误
    forHelperLoginState_Success,    // 登录成功
    forHelperLoginState_Failure,    // 登录失败
    forHelperLoginState_Conflict,   // 异地登录
}HelperLoginState;

@protocol TCXMPPHelperDelegate <NSObject>

- (void)helper:(id)sender changeConnectState:(HelperConnectState)state;
- (void)helper:(id)sender changeLoginState:(HelperLoginState)state;
- (void)helper:(id)sender didReceiveMessageDic:(NSDictionary*)dic;
- (void)helper:(id)sender didReceiveNotifyDic:(NSDictionary *)dic;

- (void)helper:(id)sender didReceiveError:(id)err;

@end

@interface TCXMPPHelper : NSObject

+ (TCXMPPHelper*)instance;

- (void)configWithDomain:(NSString*)strDomain server:(NSString*)strServer port:(UInt16)uintPort;

- (void)loginWithUserName:(NSString*)name passWord:(NSString*)pass delegate:(id <TCXMPPHelperDelegate>)del;

- (void)signOut;

- (BOOL)connect;
- (void)disconnect;

- (void)setDebugMode:(BOOL)value;

@end
