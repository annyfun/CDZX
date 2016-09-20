//
//  BaseClient.m
//  Base
//
//  Created by keen on 13-10-25.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import "BaseClient.h"
#import "BaseEngine.h"
#import "BaseRequest.h"
#import "AppDelegate.h"
//#import "Message.h"

@interface BaseClient () <BaseRequestDelegate> {
    id      delegate;
    SEL     action;
    BOOL    needUID;
    BOOL    cancelled;
}

@property (nonatomic, strong) BaseRequest*    request;
@property (nonatomic, strong) BaseEngine*     engine;

@end

@implementation BaseClient

@synthesize request;
@synthesize engine;
@synthesize errorCode;
@synthesize errorMessage;
@synthesize hasError;

- (id)initWithDelegate:(id)del action:(SEL)act
{
    self = [super init];
    if (self) {
        delegate = del;
        action = act;
        
        needUID = NO;
        self.hasError = NO;
        self.engine = [BaseEngine currentBaseEngine];
    }
    return self;
}

- (void)dealloc
{
    self.request = nil;
    self.engine = nil;
    self.errorMessage = nil;
}

- (void) cancel
{
    if (!cancelled) {
        [request disconnect];
        cancelled = YES;
        delegate = nil;
    }
}

- (void) showAlert
{
    NSString* alertMsg = nil;
    if ([errorMessage isKindOfClass:[NSString class]] && errorMessage.length > 0) {
        alertMsg = errorMessage;
    } else {
        alertMsg = @"出错了";
    }
    [Globals showAlertTitle:nil msg:alertMsg];
}



- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSMutableDictionary *)params
                     postDataType:(BaseRequestPostDataType)postDataType
{
    [request disconnect];
    
    NSMutableDictionary* mutParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutParams setObject:kBaseDemoAPPKey forKey:@"appkey"];
    
    if (needUID) {
        if ([engine isLoggedIn]) {
            [mutParams setObject:engine.user.ID forKey:@"uid"];
        } else {
            //            self.saveMethodName = methodName;
            //            self.saveHttpMethod = httpMethod;
            //            self.saveParams = params;
            //            self.savePostDataType = postDataType;
            //            self.saveHttpHeaderFields = httpHeaderFields;
            //
            //            [self loginViewCanceled];
            //            LoginViewController* con = [[[LoginViewController alloc] initWithDelegate:self] autorelease];
            //            [(BaseViewController*)delegate pushViewController:con];
            self.hasError = YES;
            self.errorMessage = @"请登陆";
            SuppressPerformSelectorLeakWarning(
                                               [delegate performSelector:action withObject:self withObject:nil];
                                               );
            return;
        }
    }
    
    self.request = [BaseRequest requestWithURL:[NSString stringWithFormat:@"%@%@",kBaseDemoAPIDomain,methodName]
                                    httpMethod:httpMethod
                                        params:mutParams
                                  postDataType:postDataType
                              httpHeaderFields:nil
                                      delegate:self];
    
	[self.request connect];
}

#pragma mark - BaseRequestDelegate Methods

- (void)request:(BaseRequest*)sender didFailWithError:(NSError *)error {
    self.hasError = YES;
    if (!cancelled) {
        NSString * errorStr = [[error userInfo] objectForKey:@"error"];
        if (errorStr == nil || errorStr.length <= 0) {
            errorStr = [NSString stringWithFormat:@"%@", [error localizedDescription]];
        } else {
            errorStr = [NSString stringWithFormat:@"%@", [[error userInfo] objectForKey:@"error"]];
        }
        self.errorMessage = errorStr;
        SuppressPerformSelectorLeakWarning(
                                           [delegate performSelector:action withObject:self withObject:error];
                                           );
    }
}

- (void)request:(BaseRequest*)sender didFinishLoadingWithResult:(NSDictionary*)result {
    if (!cancelled) {
        self.hasError = YES;
        self.errorCode = -1;
        if (result != nil && [result isKindOfClass:[NSDictionary class]]) {
            NSDictionary* state = [result objectForKey:@"state"];
            if (state != nil && [state isKindOfClass:[NSDictionary class]]) {
                self.errorCode = [state getIntValueForKey:@"code" defaultValue:errorCode];
                if (errorCode == 0) {
                    self.hasError = NO;
                } else if (errorCode == 2) {
                    self.errorMessage = @"登陆凭证已过期,请重新登陆.";
                    if (delegate && [delegate respondsToSelector:action]) {
                        SuppressPerformSelectorLeakWarning(
                                                           [delegate performSelector:action withObject:self withObject:result];
                                                           );
                    }
                    [[AppDelegate instance] signOut];
                    return;
                }
                self.errorMessage = [state getStringValueForKey:@"msg" defaultValue:nil];
            }
        }
        
        if (errorCode != 0 && self.errorMessage == nil) {
            self.errorMessage = @"默认的错误提示信息,还没提供哈..";
        }
        
        if (delegate && [delegate respondsToSelector:action]) {
            SuppressPerformSelectorLeakWarning(
                                               [delegate performSelector:action withObject:self withObject:result];
                                               );
        }
    }
}

// 添加APNS
/*
 添加ios消息推送  只适合iphone
 接口：
 api/other/action
 参数	必填	类型	说明
 appkey	yes	string	appkey
 action	yes	string	addNoticeHostForIphone
 uid	yes	string	当前登录用户的唯一id
 udid	yes	string	当前设备的deviceToken
 bnotice	yes	string	是否通知，1-通知 0-不通知
 */
- (void)setupAPNSDevice {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    if (engine && engine.user && engine.user.ID) {
        [params setObject:engine.user.ID forKey:@"uid"];
    } else {
        return;
    }
    if (engine.deviceIDAPNS.length > 0) {
        [params setObject:engine.deviceIDAPNS forKey:@"udid"];
    } else {
        self.errorMessage = @"请确认已同意推送通知";
        if (delegate && [delegate respondsToSelector:action]) {
            SuppressPerformSelectorLeakWarning(
                                               [delegate performSelector:action withObject:self withObject:nil];
                                               );
        }
        return;
    }
    [params setObject:@"1" forKey:@"bnotice"];
    [params setObject:@"addNoticeHostForIphone" forKey:@"action"];
    
    [self loadRequestWithMethodName:@"api/other/action"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kBaseRequestPostDataTypeNormal];
}

// 取消APNS
/*
 取消ios消息推送  只适合iphone
 接口：
 api/other/action
 参数	必填	类型	说明
 appkey	yes	string	appkey
 action	yes	string	removeNoticeHostForIphone
 uid	yes	string	当前登录用户的唯一id
 udid	yes	string	当前设备的deviceToken
 */
- (void)cancelAPNSDevice {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    if (engine && engine.user && engine.user.ID) {
        [params setObject:engine.user.ID forKey:@"uid"];
    } else {
        return;
    }
    if (engine.deviceIDAPNS.length > 0) {
        [params setObject:engine.deviceIDAPNS forKey:@"udid"];
    } else {
        self.errorMessage = @"请确认已同意推送通知";
        if (delegate && [delegate respondsToSelector:action]) {
            SuppressPerformSelectorLeakWarning(
                                               [delegate performSelector:action withObject:self withObject:nil];
                                               );
        }
        return;
    }
    [params setObject:@"removeNoticeHostForIphone" forKey:@"action"];
    
    [self loadRequestWithMethodName:@"api/other/action"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kBaseRequestPostDataTypeNormal];
}

/***************
 *  好友
 ***************/

/*
 注册(/user/regist)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 FALSE
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 phone	true	string	用户帐号或者手机
 password	true	string	密码
 nickname	true	string	昵称
 */
- (void)registerWithPhoneNumber:(NSString *)phoneNumber nickName:(NSString *)nickName passWord:(NSString *)passWord {
    needUID = NO;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:phoneNumber forKey:@"phone"];
    [params setObject:nickName forKey:@"nickname"];
    [params setObject:passWord forKey:@"password"];
    
    [self loadRequestWithMethodName:@"/user/regist"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kBaseRequestPostDataTypeNormal];
}

/*
 登陆(/user/login)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 FALSE
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 phone	true	string	用户帐号或者手机
 password	true	string	密码
 */
- (void)loginWithPhoneNumber:(NSString *)phoneNumber passWord:(NSString *)passWord {
    needUID = NO;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:phoneNumber forKey:@"phone"];
    [params setObject:passWord forKey:@"password"];
    
    [self loadRequestWithMethodName:@"/user/login"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kBaseRequestPostDataTypeNormal];
}

/*
 搜索用户(/user/search)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 TRUE
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 search	true	string	用户昵称和手机
 */

- (void)searchUser:(NSString*)key {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:key forKey:@"search"];
    
    [self loadRequestWithMethodName:@"/user/search"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kBaseRequestPostDataTypeNormal];
}

/*
 用户申请加好友(/user/applyAddFriend)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 TRUE
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 fuid	true	string|int	被加人
 */

- (void)applyFriend:(NSString*)uid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:uid forKey:@"fuid"];
    
    [self loadRequestWithMethodName:@"/user/applyAddFriend"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kBaseRequestPostDataTypeNormal];
}

/*
 同意申请加好友(/user/agreeAddFriend)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 TRUE
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 fuid	true	string|int	申请人
 */

- (void)agreeFriend:(NSString*)uid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:uid forKey:@"fuid"];
    
    [self loadRequestWithMethodName:@"/user/agreeAddFriend"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kBaseRequestPostDataTypeNormal];
}

/*
 拒绝申请加好友(/user/refuseAddFriend)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 TRUE
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 fuid	true	string|int	申请人
 */

- (void)refuseFriend:(NSString*)uid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:uid forKey:@"fuid"];
    
    [self loadRequestWithMethodName:@"/user/refuseAddFriend"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kBaseRequestPostDataTypeNormal];
}

/*
 7.	好友列表(/user/friendList)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 TRUE
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 */

- (void)getFriendList {
    needUID = YES;
    
    [self loadRequestWithMethodName:@"/user/friendList"
                         httpMethod:@"POST"
                             params:nil
                       postDataType:kBaseRequestPostDataTypeNormal];
}

/*
 8.	删除好友(/user/deleteFriend)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 TRUE
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 fuid	true	int	要删除的好友
 */

- (void)deleteFriend:(NSString*)uid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:uid forKey:@"fuid"];
    
    [self loadRequestWithMethodName:@"/user/deleteFriend"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kBaseRequestPostDataTypeNormal];
}

/*******************
 *  我
 *******************/

/*
 用户详细(/user/detail)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 fuid	false	int	用户id
 */

- (void)getUserDetail:(NSString*)uid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    if (uid) {
        [params setObject:uid forKey:@"fuid"];
    }
    
    [self loadRequestWithMethodName:@"/user/detail"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kBaseRequestPostDataTypeNormal];
}

/*
 2.  编辑用户资料(/user/edit)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数  必选  类型  说明
 picture false   string  上传头像
 nickname    true    string  昵称
 gender  true    int 0-男 1-女 2-未填写
 sign    false   string  用户签名
 */

- (void)modifyUserHead:(UIImage*)img
              nickName:(NSString*)name
                gender:(Gender)gender
                  sign:(NSString*)sign {
    needUID = YES;
    
    BaseRequestPostDataType postType = kBaseRequestPostDataTypeNormal;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    if (img) {
        [params setObject:img forKey:@"pic"];
        postType = kBaseRequestPostDataTypeMultipart;
    }

    if (name) {
        [params setObject:name forKey:@"nickname"];
    }
    
    if (gender != [BaseEngine currentBaseEngine].user.gender) {
        [params setObject:[NSString stringWithFormat:@"%d",gender] forKey:@"gender"];
    }
    
    if (sign) {
        [params setObject:sign forKey:@"sign"];
    }
    
    [self loadRequestWithMethodName:@"/user/edit"
                         httpMethod:@"POST"
                             params:params
                       postDataType:postType];
}

/*
 3.	修改密码(/user/editPassword)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 oldpassword	true	string	旧密码
 newpassword	true	string	新密码
 */

- (void)editPasswordOld:(NSString*)pwdOld new:(NSString*)pwdNew {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:pwdOld forKey:@"oldpassword"];
    [params setObject:pwdNew forKey:@"newpassword"];
    
    [self loadRequestWithMethodName:@"/user/editPassword"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kBaseRequestPostDataTypeNormal];
}

/*
 4.	反馈意见(/user/feedback)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 content	true	string	反馈意见
 */

- (void)feedback:(NSString*)content {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:content forKey:@"content"];
    
    [self loadRequestWithMethodName:@"/user/feedback"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kBaseRequestPostDataTypeNormal];
}

/*
 5.	举报(/user/jubao)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 content	false	string	举报内容
 fuid	true	string	被举报人
 */

- (void)reportUser:(NSString*)uid reason:(NSString*)reason {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:uid forKey:@"fuid"];
    [params setObject:reason forKey:@"content"];
    
    [self loadRequestWithMethodName:@"/user/jubao"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kBaseRequestPostDataTypeNormal];
}

/*******************
 *  设置
 *******************/

/*
 版本更新(/version/api/update)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 False
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 os	true	string	ios, android
 version	true	string	版本号
 ID	false	string	当为ios时为必传
 */

- (void)checkUpdate {
    needUID = NO;
    
    NSString * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:@"ios" forKey:@"os"];
    [params setObject:version forKey:@"version"];
    [params setObject:[NSString stringWithFormat:@"%@",APPID] forKey:@"ID"];
    
    [self loadRequestWithMethodName:@"/version/api/update"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kBaseRequestPostDataTypeNormal];
}

@end
