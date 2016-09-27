//
//  TCClient.m
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCClient.h"
#import "ThinkChat.h"
#import "TCEngine.h"
#import "TCRequest.h"
#import "TCMessage.h"
#import "TCNSStringAdditions.h"

@interface TCClient () <TCRequestDelegate> {
    BOOL    needUID;
    BOOL    cancelled;
}

@property (nonatomic, strong) TCRequest*            request;
@property (nonatomic, strong) TCEngine*             engine;
@property (nonatomic, assign) id <TCClientDelegate> delegate;

@end

@implementation TCClient

@synthesize request;
@synthesize engine;
@synthesize delegate;
@synthesize error;
@synthesize tagRequest;
@synthesize actionDelegate;
@synthesize typeResult;

- (id)initWithDelegate:(id <TCClientDelegate>)aDelegate actionDelegate:(id)anActionDelegate {
    self = [super init];
    if (self) {
        self.delegate = aDelegate;
        self.actionDelegate = anActionDelegate;
        self.tagRequest = [NSString GUIDString];
        
        needUID = NO;
        self.engine = [TCEngine currentEngine];
    }
    return self;
}

- (void)dealloc
{
    self.request = nil;
    self.engine = nil;
    self.delegate = nil;
    self.error = nil;
    self.actionDelegate = nil;
}

- (void) cancel
{
    if (!cancelled) {
        [request disconnect];
        cancelled = YES;
        self.request = nil;
        self.engine = nil;
        self.delegate = nil;
        self.error = nil;
        self.actionDelegate = nil;
    }
}


- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSMutableDictionary *)params
                     postDataType:(TCRequestPostDataType)postDataType
{
    [request disconnect];
    
    NSMutableDictionary* mutParams = [NSMutableDictionary dictionaryWithDictionary:params];
    
    if (needUID) {
        if ([engine isLoggedIn]) {
            [mutParams setObject:engine.userID forKey:@"uid"];
        } else {
            self.error = [TCError errorWithCode:-1 message:@"请登录"];
            [delegate tcClient:self result:nil];
            return;
        }
    }
    
    [mutParams setObject:@"iphone" forKey:@"device"];
    
    self.request = [TCRequest requestWithURL:[NSString stringWithFormat:@"%@%@",[ThinkChat instance].serverDomain,methodName]
                                  httpMethod:httpMethod
                                      params:mutParams
                                postDataType:postDataType
                            httpHeaderFields:nil
                                    delegate:self];
    
	[request connect];
}

#pragma mark - TCRequestDelegate Methods

- (void)request:(TCRequest*)sender didFailWithError:(NSError *)err {
    self.request = nil;
    if (!cancelled) {
        NSString * errorStr = [[err userInfo] objectForKey:@"error"];
        if (errorStr == nil || errorStr.length <= 0) {
            errorStr = [NSString stringWithFormat:@"%@", [err localizedDescription]];
        } else {
            errorStr = [NSString stringWithFormat:@"%@", [[err userInfo] objectForKey:@"error"]];
        }
        self.error = [TCError errorWithCode:1 message:errorStr];
        [delegate tcClient:self result:nil];
    }
}

- (void)request:(TCRequest*)sender didFinishLoadingWithResult:(NSDictionary*)result {
    self.request = nil;
    if (!cancelled) {
        BOOL        hasError = YES;
        NSInteger   errorCode = -1;
        NSString*   errorMessage = nil;
        
        if (result != nil && [result isKindOfClass:[NSDictionary class]]) {
            NSDictionary* state = [result objectForKey:@"state"];
            if (state != nil && [state isKindOfClass:[NSDictionary class]]) {
                errorCode = [state getIntegerValueForKey:@"code" defaultValue:errorCode];
                if (errorCode == 0) {
                    hasError = NO;
                } else if (errorCode == 2) {
                    self.error = [TCError errorWithCode:errorCode message:@"登陆凭证已过期,请重新登陆."];
                    [delegate tcClient:self result:result];
                    [[ThinkChat instance] logOut];
                    return;
                }
                errorMessage = [state getStringValueForKey:@"msg" defaultValue:nil];
            }
        }
        
        if (errorCode != 0 && errorMessage == nil) {
            errorMessage = @"默认的错误提示信息,还没提供哈..";
        }
        
        if (hasError) {
            self.error = [TCError errorWithCode:errorCode message:errorMessage];
        }
        [delegate tcClient:self result:result];
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
    if (engine && engine.userID) {
        [params setObject:engine.userID forKey:@"uid"];
    } else {
        return;
    }
    if (engine.deviceIDAPNS.length > 0) {
        [params setObject:engine.deviceIDAPNS forKey:@"udid"];
    } else {
        return;
    }
    [params setObject:@"1" forKey:@"bnotice"];
    
    [self loadRequestWithMethodName:@"/user/api/addNoticeHostForIphone"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
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
    if (engine && engine.userID) {
        [params setObject:engine.userID forKey:@"uid"];
    } else {
        return;
    }
    if (engine.deviceIDAPNS.length > 0) {
        [params setObject:engine.deviceIDAPNS forKey:@"udid"];
    } else {
        return;
    }
    
    [self loadRequestWithMethodName:@"/user/api/removeNoticeHostForIphone"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

- (void)sendMessage:(TCMessage*)msg attach:(id)data {
    needUID = YES;
    
    TCRequestPostDataType tmpPostType = kTCRequestPostDataTypeNormal;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (data) {
        [params setObject:data forKey:@"file_upload"];
        tmpPostType = kTCRequestPostDataTypeMultipart;
    }
    
    [params setObject:msg.tag forKey:@"tag"];
    [params setObject:[NSString stringWithFormat:@"%d",msg.typeChat] forKey:@"typechat"];
    [params setObject:[NSString stringWithFormat:@"%d",msg.typeFile] forKey:@"typefile"];
    
    if (msg.from.name) {
        [params setObject:msg.from.name forKey:@"fromname"];
    }
    if (msg.from.head) {
        [params setObject:msg.from.head forKey:@"fromhead"];
    }
    
    [params setObject:msg.to.ID forKey:@"toid"];
    if (msg.to.name) {
        [params setObject:msg.to.name forKey:@"toname"];
    }
    if (msg.to.head) {
        [params setObject:msg.to.head forKey:@"tohead"];
    }

    [params setObject:[msg getExtendJsonString] forKey:@"extend"];
    [params setObject:[msg.from getExtendJsonString] forKey:@"fromextend"];
    [params setObject:[msg.to getExtendJsonString] forKey:@"toextend"];
    [params setObject:[msg.body getExtendJsonString] forKey:@"bodyextend"];
    
    if (msg.typeFile == forFileText) {
        TCTextMessageBody* body = (TCTextMessageBody*)msg.body;
        [params setObject:body.content forKey:@"content"];
    }
    
    if (msg.typeFile == forFileVoice) {
        TCVoiceMessageBody* body = (TCVoiceMessageBody*)msg.body;
        [params setObject:[NSString stringWithFormat:@"%.0f",body.voiceTime] forKey:@"voicetime"];
    } else if (msg.typeFile == forFileLocation) {
        TCLocationMessageBody* body = (TCLocationMessageBody*)msg.body;
        [params setObject:body.address forKey:@"address"];
        [params setObject:[NSString stringWithFormat:@"%.6f",body.lat] forKey:@"lat"];
        [params setObject:[NSString stringWithFormat:@"%.6f",body.lng] forKey:@"lng"];
    }
    
    [self loadRequestWithMethodName:@"/message/api/sendMessage"
                         httpMethod:@"POST"
                             params:params
                       postDataType:tmpPostType];
}


/**************
 * 会话
 **************/

/*
 1.	创建临时会话并添加用户(/session/api/add)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 TRUE
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 name	true	string	会话名称
 uids	true	string	格式：id1,id2,id3,id4
 */

- (void)createConversationName:(NSString*)name userList:(NSArray*)userArr {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:name forKey:@"name"];
    [params setObject:[userArr componentsJoinedByString:@","] forKey:@"uids"];
    
    [self loadRequestWithMethodName:@"/session/api/add"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 2.	添加用户到一个会话(/session/api/addUserToSession)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 TRUE
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 sessionid	true	int	临时会话id
 uids	true	string	格式：id1,id2,id3,id4
 */

- (void)addUserList:(NSArray*)userArr toConversation:(NSString*)cid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:cid forKey:@"sessionid"];
    [params setObject:[userArr componentsJoinedByString:@","] forKey:@"uids"];
    
    [self loadRequestWithMethodName:@"/session/api/addUserToSession"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 4.	会话详细(/session/api/detail)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 TRUE
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 sessionid	true	int	临时会话id
 */

- (void)getConversationDetail:(NSString*)cid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:cid forKey:@"sessionid"];
    
    [self loadRequestWithMethodName:@"/session/api/detail"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 5.	删除用户(/session/api/remove)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 TRUE
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 sessionid	true	int	临时会话id
 fuid	true	int	要删除的用户
 */

- (void)deleteUser:(NSString*)uid fromConversation:(NSString*)cid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:cid forKey:@"sessionid"];
    [params setObject:uid forKey:@"fuid"];
    
    [self loadRequestWithMethodName:@"/session/api/remove"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 6.	退出会话(/session/api/quit)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 TRUE
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 sessionid	true	int	临时会话id
 */

- (void)quitConversation:(NSString*)cid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:cid forKey:@"sessionid"];
    
    [self loadRequestWithMethodName:@"/session/api/quit"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 7.	编辑会话(/session/api/edit)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 TRUE
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 sessionid	true	int	临时会话id
 name	true	string	会话名称
 */

- (void)modifyConversation:(NSString*)cid newName:(NSString*)name {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:cid forKey:@"sessionid"];
    [params setObject:name forKey:@"name"];
    
    [self loadRequestWithMethodName:@"/session/api/edit"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 8.	设置是否接收消息(/session/api/getmsg)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 TRUE
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 sessionid	true	int	临时会话id
 */

- (void)setConversation:(NSString*)cid isGetMessage:(BOOL)isGet {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:cid forKey:@"sessionid"];
    [params setObject:isGet?@"1":@"0" forKey:@"getmsg"];
    
    [self loadRequestWithMethodName:@"/session/api/getmsg"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 9.	删除会话(/session/api/delete)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 TRUE
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 sessionid	true	int	临时会话id
 */

- (void)deleteConversation:(NSString*)cid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:cid forKey:@"sessionid"];
    
    [self loadRequestWithMethodName:@"/session/api/delete"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*******************
 *  群聊
 *******************/

/*
 群详细(/group/api/detail)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 groupid	true	int	群id
 */

- (void)getGroupDetail:(NSString*)gid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:gid forKey:@"groupid"];
    
    [self loadRequestWithMethodName:@"/group/api/detail"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 创建群(/group/api/add)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 name	true	string	群名称
 pic			上传图片
 description	true	string	描述
 */

- (void)createGroupName:(NSString*)name
              headImage:(UIImage*)img
            description:(NSString*)description
                 extend:(TCExtend *)extend {
    needUID = YES;
    
    TCRequestPostDataType postType = kTCRequestPostDataTypeNormal;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:name forKey:@"name"];
    
    if (img) {
        [params setObject:img forKey:@"pic"];
        postType = kTCRequestPostDataTypeMultipart;
    }
    
    [params setObject:description forKey:@"description"];
    
    if (extend) {
        [params setObject:[extend getExtendJsonString] forKey:@"extend"];
    }
    
    [self loadRequestWithMethodName:@"/group/api/add"
                         httpMethod:@"POST"
                             params:params
                       postDataType:postType];
}

/*
 搜索群(/group/api/search)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 search	true	string	搜索群名称
 */

- (void)searchGroup:(NSString*)key
              count:(int)count
               page:(int)page {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:key forKey:@"search"];
    
    if (count > 0) {
        if (count > 100) {
            count = 100;
        }
        [params setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
    }
    
    if (page > 1) {
        [params setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
    }
    
    [self loadRequestWithMethodName:@"/group/api/search"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 用户群列表(/group/api/groupList)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 */

- (void)getGroupList {
    needUID = YES;
    
    [self loadRequestWithMethodName:@"/group/api/groupList"
                         httpMethod:@"POST"
                             params:nil
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 5.	群的用户列表(/group/api/groupUserList)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 groupid	true	int	群id
 */

- (void)getUserListInGroup:(NSString*)gid
                     count:(int)count
                      page:(int)page {
    needUID = YES;
    NSString *url = [NSString stringWithFormat:@"%@/group/groupUserList/ss_uid/%@/groupid/%@", kBaseSDKAPIHost,Trim(engine.userID),gid];
    [request disconnect];
    if (needUID) {
        if ([engine isLoggedIn]) {
            //
        } else {
            self.error = [TCError errorWithCode:-1 message:@"请登录"];
            [delegate tcClient:self result:nil];
            return;
        }
    }
    self.request = [TCRequest requestWithURL:url
                                  httpMethod:@"POST"
                                      params:nil
                                postDataType:kTCRequestPostDataTypeNormal
                            httpHeaderFields:nil
                                    delegate:self];
    
    [request connect];
}

/*
 7.	申请加入群(/group/api/apply)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 groupid	true	int	群id
 */

- (void)applyJoinGroup:(NSString*)gid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:gid forKey:@"groupid"];
    
    [self loadRequestWithMethodName:@"/group/api/apply"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 8.	同意申请加入群(/group/api/agreeApply)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 groupid	true	int	群id
 fuid	true	int	申请者
 */

- (void)agreeApplyJoinGroup:(NSString*)gid user:(NSString*)uid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:gid forKey:@"groupid"];
    [params setObject:uid forKey:@"fuid"];
    
    [self loadRequestWithMethodName:@"/group/api/agreeApply"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 9.	不同意申请加入群(/group/api/disagreeApply)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 groupid	true	int	群id
 fuid	true	int	申请者
 */

- (void)refuseApplyJoinGroup:(NSString*)gid user:(NSString*)uid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:gid forKey:@"groupid"];
    [params setObject:uid forKey:@"fuid"];
    
    [self loadRequestWithMethodName:@"/group/api/disagreeApply"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 10.	邀请加入群(/group/api/invite)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 groupid	true	int	群id
 fuid	true	int	邀请者
 */

- (void)inviteJoinGroup:(NSString*)gid user:(NSString*)uid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:gid forKey:@"groupid"];
    [params setObject:uid forKey:@"fuid"];
    
    [self loadRequestWithMethodName:@"/group/api/invite"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 11.	同意邀请加入群(/group/api/agreeInvite)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 groupid	true	int	群id
 */

- (void)agreeInviteJoinGroup:(NSString*)gid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:gid forKey:@"groupid"];
    
    [self loadRequestWithMethodName:@"/group/api/agreeInvite"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 12.	不同意邀请加入群(/group/api/disagreeInvite)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 groupid	true	int	群id
 */

- (void)refuseInviteJoinGroup:(NSString*)gid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:gid forKey:@"groupid"];
    
    [self loadRequestWithMethodName:@"/group/api/disagreeInvite"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 13.	管理员删除成员(/group/api/remove)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 groupid	true	int	群id
 fuid	true	int	删除者
 */

- (void)deleteUser:(NSString*)uid fromGroup:(NSString*)gid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:gid forKey:@"groupid"];
    [params setObject:uid forKey:@"fuid"];
    
    [self loadRequestWithMethodName:@"/group/api/remove"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 14.	退出群(/group/api/quit)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 groupid	true	int	群id
 */

- (void)quitGroup:(NSString*)gid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:gid forKey:@"groupid"];
    
    [self loadRequestWithMethodName:@"/group/api/quit"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 15.	管理员删除群(/group/api/delete)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 groupid	true	int	群id
 */

- (void)deleteGroup:(NSString*)gid {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:gid forKey:@"groupid"];
    
    [self loadRequestWithMethodName:@"/group/api/delete"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

/*
 16.	编辑群资料(/group/api/edit)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 groupid	true	int	群id
 pic	false		上传图片
 name	false	string	群名称
 description	false	string	描述
 */

- (void)modifyGroup:(NSString*)gid
               name:(NSString*)name
          headImage:(UIImage*)img
        description:(NSString*)description
             extend:(TCExtend *)extend {
    needUID = YES;
    
    TCRequestPostDataType postType = kTCRequestPostDataTypeNormal;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:gid forKey:@"groupid"];
    
    if (name) {
        [params setObject:name forKey:@"name"];
    }
    
    if (img) {
        [params setObject:img forKey:@"pic"];
        postType = kTCRequestPostDataTypeMultipart;
    }
    
    if (description) {
        [params setObject:description forKey:@"description"];
    }
    
    if (extend) {
        [params setObject:[extend getExtendJsonString] forKey:@"extend"];
    }
    
    [self loadRequestWithMethodName:@"/group/api/edit"
                         httpMethod:@"POST"
                             params:params
                       postDataType:postType];
}

/*
 17.	设置是否接收群消息(/group/api/getmsg)
 1、HTTP请求方式
 GET/POST
 2、是否需要登录
 True
 3、支持格式
 JSON
 4、请求参数
 参数	必选	类型	说明
 groupid	true	int	群id
 getmsg	true	int	0-不接收 1-接收
 */

- (void)setGroup:(NSString*)gid isGetMessage:(BOOL)isGet {
    needUID = YES;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:gid forKey:@"groupid"];
    [params setObject:isGet?@"1":@"0" forKey:@"getmsg"];
    
    [self loadRequestWithMethodName:@"/group/api/getmsg"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kTCRequestPostDataTypeNormal];
}

@end
