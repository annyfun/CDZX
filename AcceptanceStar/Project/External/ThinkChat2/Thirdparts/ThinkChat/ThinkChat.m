//
//  ThinkChat.m
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "ThinkChat.h"

#import "TCXMPPHelper.h"

#import "TCEngine.h"
#import "TCClient.h"

#import "TCGlobals.h"

//#ifdef DEBUG
//#define TCSDKLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
//#else
//#define TCSDKLog(...)
//#endif

#define TCSDKLogFunc // TCSDKLog(@"%s",__func__)


@interface ThinkChat () <TCXMPPHelperDelegate, TCClientDelegate> {
    NSMutableDictionary* clientDic;
    NSMutableDictionary* prepSendDic;
}

@property (nonatomic, strong) NSString* userID;
@property (nonatomic, strong) NSString* passWord;

@end

@implementation ThinkChat

@synthesize serverDomain;
@synthesize delegate;

@synthesize userID;
@synthesize passWord;


static ThinkChat* tcMod = nil;

+ (ThinkChat*)instance {
    if (tcMod == nil) {
        tcMod = [[ThinkChat alloc] init];
    }
    return tcMod;
}

- (void)cancelRequestTag:(NSString *)aTag {
    if (aTag != nil && aTag.length > 0) {
        TCClient* client = [clientDic objectForKey:aTag];
        if (client) {
            [client cancel];
            client = nil;
            [clientDic removeObjectForKey:aTag];
            [prepSendDic removeObjectForKey:aTag];
        }
    }
}

- (void)initWithServerUrl:(NSString *)serverUrl IMServerUrl:(NSString *)imServerUrl IMServerName:(NSString *)imServerName IMServerPort:(UInt16)imServerPort {
    
    clientDic = [[NSMutableDictionary alloc] init];
    prepSendDic = [[NSMutableDictionary alloc] init];
    
    serverDomain = serverUrl;
    
    [[TCXMPPHelper instance] configWithDomain:imServerUrl server:imServerName port:imServerPort];
    
    [TCGlobals createTableIfNotExists];
}

- (void)loginWithID:(NSString *)strID passWord:(NSString *)strPassWord delegate:(id)del {

    self.userID   = strID;
    self.passWord = strPassWord;
    self.delegate = del;
    
    [[TCXMPPHelper instance] loginWithUserName:strID passWord:strPassWord delegate:self];
}

- (void)logOut {
    [self cancelAPNS];
    [[TCEngine currentEngine] logOut];
    [[TCXMPPHelper instance] signOut];
}

- (void)setDebugMode:(BOOL)value {
    // 设置调试模式
    [[TCXMPPHelper instance] setDebugMode:value];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self setupAPNS];
    if ([TCEngine currentEngine].isLoggedIn) {
        [[TCXMPPHelper instance] disconnect];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if ([TCEngine currentEngine].isLoggedIn) {
        [[TCXMPPHelper instance] connect];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType types = (UIRemoteNotificationTypeBadge |
                                        UIRemoteNotificationTypeSound |
                                        UIRemoteNotificationTypeAlert);
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        UIUserNotificationSettings * registerSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:registerSettings];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                                               UIUserNotificationTypeSound |
                                                                               UIUserNotificationTypeAlert)];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)pToken {
    
    NSString * uid = [NSString stringWithFormat:@"%@", pToken];
    uid = [uid stringByReplacingOccurrencesOfString:@"<" withString:@""];
    uid = [uid stringByReplacingOccurrencesOfString:@">" withString:@""];
    uid = [uid stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [TCEngine currentEngine].deviceIDAPNS = uid;
    if ([TCEngine currentEngine].isLoggedIn) {
        [self setupAPNS];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // TCSDKLog(@"didFailToRegisterForRemoteNotificationsWithError : %@",[error localizedDescription]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // TCSDKLog(@"didReceiveRemoteNotification : %@", userInfo);
}

- (void)setupAPNS {
    if ([self isRegisteredForRemoteNotifications]) {
        TCClient * clt = [self cliendWithTypeResult:forTCResultObjectType_None delegate:nil];
        if ([TCGlobals isNotify]) {
            [clt setupAPNSDevice];
        } else {
            [clt cancelAPNSDevice];
        }
    }
}

- (void)cancelAPNS {
    [self setupApnsWithDelegate:nil];
}

- (NSString*)setupApnsWithDelegate:(id <TCResultNoneDelegate>)aDelegate {
    if ([self isRegisteredForRemoteNotifications]) {
        TCClient * clt = [self cliendWithTypeResult:forTCResultObjectType_None delegate:aDelegate];
        [clt setupAPNSDevice];
        return clt.tagRequest;
    }
    return nil;
}

- (NSString*)cancelApnsWithDelegate:(id <TCResultNoneDelegate>)aDelegate {
    if ([self isRegisteredForRemoteNotifications]) {
        TCClient * clt = [self cliendWithTypeResult:forTCResultObjectType_None delegate:aDelegate];
        [clt cancelAPNSDevice];
        return clt.tagRequest;
    }
    return nil;
}

- (BOOL)isRegisteredForRemoteNotifications {
    BOOL result = NO;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        result = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    } else {
        UIRemoteNotificationType enabledTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        result = enabledTypes > 0;
    }
    return result;
}

#pragma mark - TCXMPPHelperDelegate

- (void)helper:(id)sender changeConnectState:(HelperConnectState)state {
    if ([delegate respondsToSelector:@selector(thinkChat:connectState:)]) {
        [delegate thinkChat:self connectState:(TCConnectState)state];
    }
}

- (void)helper:(id)sender changeLoginState:(HelperLoginState)state {
    if (state == forHelperLoginState_Success) {
        [[TCEngine currentEngine] setCurrentUserID:userID password:passWord];
        [self setupAPNS];
    }
    if ([delegate respondsToSelector:@selector(thinkChat:loginState:)]) {
        [delegate thinkChat:self loginState:(TCLoginState)state];
    }
}

- (void)helper:(id)sender didReceiveMessageDic:(NSDictionary *)dic {
    TCMessage* itemM = [TCMessage objWithJsonDic:dic];
    if (itemM) {
        [self receivedMessage:itemM];
    }
}

- (void)helper:(id)sender didReceiveNotifyDic:(NSDictionary *)dic {
    TCNotify* itemN = [TCNotify objWithJsonDic:dic];
    if (itemN) {
        [itemN dealNotify];
        if ([delegate respondsToSelector:@selector(thinkChat:receiveNotify:)]) {
            [delegate thinkChat:self receiveNotify:itemN];
        }
    }
}

- (void)helper:(id)sender didReceiveError:(id)err {
    
}

#pragma mark - Message Get

- (void)receivedMessage:(TCMessage*)msg {
    [TCSession updateWithMessage:msg];
    if ([delegate respondsToSelector:@selector(thinkChat:receiveMessage:)]) {
        [delegate thinkChat:self receiveMessage:msg];
    }
}

#pragma mark - API for Local

// 获取单个会话
- (TCSession*)getSessionWithID:(NSString*)sid typeChat:(ChatType)typeChat {
    return [TCSession sessionWithID:sid typeChat:typeChat];
}

// 获取所有消息未读数
- (int)getUnReadMessageCount {
    return [TCSession getUnReadMessageCount];
}

// 获取会话列表
- (NSArray*)getSessionListTimeLine {
    return [TCSession getSessionListTimeLine];
}

// 清空单个会话聊天记录
- (void)clearSessionID:(NSString *)sid typeChat:(ChatType)typeChat {
    [TCSession clearSessionID:sid typeChat:typeChat];
}

// 标记单个会话聊天记录为已读
- (void)hasReadSessionID:(NSString *)sid typeChat:(ChatType)typeChat {
    [TCSession hasReadSessionID:sid typeChat:typeChat];
}

// 获取会话的分页消息列表

- (NSArray*)getMessageListTimeLineWithID:(NSString *)withID
                                typeChat:(ChatType)typeChat
                              sinceRowID:(int)sinceRowID
                                maxRowID:(int)maxRowID
                                   count:(int)count
                                    page:(int)page {
    return [TCMessage getMessageListTimeLineWithID:withID typeChat:typeChat sinceRowID:sinceRowID maxRowID:maxRowID count:count page:page];
}

// 获取会话的指定数量的最新未读消息记录
- (NSArray*)getMessageListUnreadWithID:(NSString *)withID
                              typeChat:(ChatType)typeChat
                                 count:(int)count {
    return [TCMessage getMessageListUnreadWithID:withID typeChat:typeChat count:count];
}

// 获取当前登录用户的最新的一条通知

- (TCNotify*)getLatestNotify {
    return [TCNotify getLatestNotify];
}

// 获取当前登录用户的所有未读通知数

- (int)getUnReadNotifyCount {
    return [TCNotify getUnReadCount];
}

// 获取当前登录用户的分页通知列表

- (NSArray*)getNotifyListTimeLineWithFinalNotify:(TCNotify*)itemN {
    return [TCNotify getNotifyListTimeLineWithFinalNotify:itemN];
}

// 设置通知为已读

- (void)hasReadNotify:(TCNotify*)itemN {
    [TCNotify hasReadNotify:itemN];
}

// 设置通知为已处理

- (void)hasDoneNotify:(TCNotify*)itemN {
    [TCNotify hasDoneNotify:itemN];
}

// 删除通知

- (void)hasDeleteNotify:(TCNotify *)itemN {
    [TCNotify hasDeleteNotify:itemN];
}

// 更新通知内容
- (void)hasUpdateNotify:(TCNotify *)itemN newContent:(NSString *)newContent {
    [TCNotify hasUpdateNotify:itemN newContent:newContent];
}

#pragma mark - TCClientDelegate

- (void)tcClient:(TCClient*)sender result:(NSObject *)result {
    [clientDic removeObjectForKey:sender.tagRequest];
    
    NSObject* gotResult = nil;
    TCPageInfo* pageInfo = nil;
    
    if (sender.error == nil) {
        NSDictionary* dicPage = [(NSDictionary*)result objectForKey:@"pageInfo"];
        pageInfo = [TCPageInfo objWithJsonDic:dicPage];
        result = [(NSDictionary*)result objectForKey:@"data"];
        if (sender.typeResult == forTCResultObjectType_None) {
            
        } else if (sender.typeResult == forTCResultObjectType_User) {
            NSDictionary* dic = (NSDictionary*)result;
            TCUser* itemU = [TCUser objWithJsonDic:dic];
            if (itemU) {
                gotResult = itemU;
            }
        } else if (sender.typeResult == forTCResultObjectType_UserList) {
            gotResult = (NSArray*)result;
        } else if (sender.typeResult == forTCResultObjectType_Group) {
            NSDictionary* dic = (NSDictionary*)result;
            TCGroup* itemG = [TCGroup objWithJsonDic:dic];
            if (itemG) {
                itemG.type = forTCGroupType_Group;
                
                TCSession* itemS = [TCSession getSessionFromDBWithID:itemG.ID typeChat:forChatTypeGroup];
                if (itemS) {
                    itemS.name = itemG.name;
                    itemS.head = itemG.headImgUrlS;
                    [itemS insertDB];
                }
                
                gotResult = itemG;
            }
        } else if (sender.typeResult == forTCResultObjectType_GroupList) {
            NSMutableArray* gotArr = [[NSMutableArray alloc] init];
            NSArray* arr = (NSArray*)result;
            for (NSDictionary* dic in arr) {
                TCGroup* itemG = [TCGroup objWithJsonDic:dic];
                if (itemG) {
                    itemG.type = forTCGroupType_Group;
                    [gotArr addObject:itemG];
                }
            }
            if (gotArr.count > 0) {
                gotResult = gotArr;
            }
        } else if (sender.typeResult == forTCResultObjectType_Conversation) {
            NSDictionary* dic = (NSDictionary*)result;
            TCGroup* itemG = [TCGroup objWithJsonDic:dic];
            if (itemG) {
                itemG.type = forTCGroupType_Temp;
                gotResult = itemG;
            }
        } else if (sender.typeResult == forTCResultObjectType_ConversationList) {
            NSMutableArray* gotArr = [[NSMutableArray alloc] init];
            NSArray* arr = (NSArray*)result;
            for (NSDictionary* dic in arr) {
                TCGroup* itemG = [TCGroup objWithJsonDic:dic];
                if (itemG) {
                    itemG.type = forTCGroupType_Temp;
                    TCSession* itemS = [TCSession sessionWithGroup:itemG];
                    itemS.name = itemG.name;
                    [itemS insertDB];
                    [gotArr addObject:itemG];
                }
            }
            if (gotArr.count > 0) {
                gotResult = gotArr;
            }
        } else if (sender.typeResult == forTCResultObjectType_Message) {
            [prepSendDic removeObjectForKey:sender.tagRequest];
            
            NSDictionary* dic = (NSDictionary*)result;
            TCMessage* itemM = [TCMessage objWithJsonDic:dic];
            if (itemM) {
                gotResult = itemM;
                [self receivedMessage:itemM];
            }
        }
    } else {
        if (sender.typeResult == forTCResultObjectType_Message) {
            TCMessage* itemM = [prepSendDic objectForKey:sender.tagRequest];
            itemM.state = forMessageStateError;
            [self receivedMessage:itemM];
            [prepSendDic removeObjectForKey:sender.tagRequest];
        }
    }
    
    if (sender.typeResult == forTCResultObjectType_None) {
        [sender.actionDelegate tcResultNoneError:sender.error];
    } else if (sender.typeResult == forTCResultObjectType_User) {
        [sender.actionDelegate tcResultUser:(TCUser*)gotResult error:sender.error];
    } else if (sender.typeResult == forTCResultObjectType_UserList) {
        [sender.actionDelegate tcResultUserList:(NSArray*)gotResult pageInfo:pageInfo error:sender.error];
    } else if (sender.typeResult == forTCResultObjectType_Group ||
               sender.typeResult == forTCResultObjectType_Conversation) {
        [sender.actionDelegate tcResultGroup:(TCGroup*)gotResult error:sender.error];
    } else if (sender.typeResult == forTCResultObjectType_GroupList ||
               sender.typeResult == forTCResultObjectType_ConversationList) {
        [sender.actionDelegate tcResultGroupList:(NSArray*)gotResult pageInfo:pageInfo error:sender.error];
    }
}

- (TCClient*)cliendWithTypeResult:(TCResultObjectType)aType delegate:(id)aDelegate {
    TCClient* client = [[TCClient alloc] initWithDelegate:self actionDelegate:aDelegate];
    client.typeResult = aType;
    [clientDic setObject:client forKey:client.tagRequest];
    return client;
}

#pragma mark - API for Server

/****************
 * 消息
 ****************/

- (NSString*)sendMessage:(TCMessage *)msg
                  attach:(id)attach {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_Message delegate:nil];
    [prepSendDic setObject:msg forKey:client.tagRequest];
    [client sendMessage:msg attach:attach];
    return client.tagRequest;
}

/**************
 * 会话
 **************/

// 1. 创建临时会话并添加用户(/session/api/add)
- (NSString*)createConversationName:(NSString *)name
                           userList:(NSArray *)userArr
                           delegate:(id<TCResultGroupDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_Conversation delegate:aDelegate];
    [client createConversationName:name userList:userArr];
    return client.tagRequest;
}

// 2. 添加用户到一个会话(/session/api/addUserToSession)
- (NSString*)addUserList:(NSArray*)userArr
          toConversation:(NSString*)cid
                delegate:(id <TCResultNoneDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_None delegate:aDelegate];
    [client addUserList:userArr toConversation:cid];
    return client.tagRequest;
}

// 4. 会话详细(/session/api/detail)
- (NSString*)getConversationDetail:(NSString*)cid
                          delegate:(id<TCResultGroupDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_Conversation delegate:aDelegate];
    [client getConversationDetail:cid];
    return client.tagRequest;
}

// 5. 删除用户(/session/api/remove)
- (NSString*)deleteUser:(NSString*)uid
       fromConversation:(NSString*)cid
               delegate:(id <TCResultNoneDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_None delegate:aDelegate];
    [client deleteUser:uid fromConversation:cid];
    return client.tagRequest;
}

// 6. 退出会话(/session/api/quit)
- (NSString*)quitConversation:(NSString*)cid
                     delegate:(id <TCResultNoneDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_None delegate:aDelegate];
    [client quitConversation:cid];
    return client.tagRequest;
}

// 7. 编辑会话(/session/api/edit)
- (NSString*)modifyConversation:(NSString*)cid
                        newName:(NSString*)name
                       delegate:(id<TCResultGroupDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_Conversation delegate:aDelegate];
    [client modifyConversation:cid newName:name];
    return client.tagRequest;
}

// 8. 设置是否接收消息(/session/api/getmsg)
- (NSString*)setConversation:(NSString*)cid
                isGetMessage:(BOOL)isGet
                    delegate:(id <TCResultNoneDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_None delegate:aDelegate];
    [client setConversation:cid isGetMessage:isGet];
    return client.tagRequest;
}

// 9. 删除会话(/session/api/delete)
- (NSString*)deleteConversation:(NSString*)cid
                       delegate:(id <TCResultNoneDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_None delegate:aDelegate];
    [client deleteConversation:cid];
    return client.tagRequest;
}

/*******************
 *  群聊
 *******************/

// 1.   群详细(/group/api/detail)
- (NSString*)getGroupDetail:(NSString*)gid
                   delegate:(id<TCResultGroupDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_Group delegate:aDelegate];
    [client getGroupDetail:gid];
    return client.tagRequest;
}

// 2.   创建群(/group/api/add)
- (NSString*)createGroupName:(NSString *)name
                   headImage:(UIImage *)img
                 description:(NSString *)description
                      extend:(TCExtend *)extend
                    delegate:(id<TCResultGroupDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_Group delegate:aDelegate];
    [client createGroupName:name headImage:img description:description extend:extend];
    return client.tagRequest;
}

// 3.   搜索群(/group/api/search)
- (NSString*)searchGroup:(NSString*)key
                   count:(int)count
                    page:(int)page
                delegate:(id<TCResultGroupListDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_GroupList delegate:aDelegate];
    [client searchGroup:key count:count page:page];
    return client.tagRequest;
}

// 4.   用户群列表(/group/api/groupList)
- (NSString*)getGroupListDelegate:(id<TCResultGroupListDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_GroupList delegate:aDelegate];
    [client getGroupList];
    return client.tagRequest;
}

// 5. 群的用户列表(/group/api/groupUserList)
- (NSString*)getUserListInGroup:(NSString*)gid
                          count:(int)count
                           page:(int)page
                       delegate:(id<TCResultUserListDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_UserList delegate:aDelegate];
    [client getUserListInGroup:gid count:count page:page];
    return client.tagRequest;
}

// 7. 申请加入群(/group/api/apply)
- (NSString*)applyJoinGroup:(NSString*)gid
                   delegate:(id <TCResultNoneDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_None delegate:aDelegate];
    [client applyJoinGroup:gid];
    return client.tagRequest;
}

// 8. 同意申请加入群(/group/api/agreeApply)
- (NSString*)agreeApplyJoinGroup:(NSString*)gid
                            user:(NSString*)uid
                        delegate:(id <TCResultNoneDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_None delegate:aDelegate];
    [client agreeApplyJoinGroup:gid user:uid];
    return client.tagRequest;
}

// 9. 不同意申请加入群(/group/api/disagreeApply)
- (NSString*)refuseApplyJoinGroup:(NSString*)gid
                             user:(NSString*)uid
                         delegate:(id <TCResultNoneDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_None delegate:aDelegate];
    [client refuseApplyJoinGroup:gid user:uid];
    return client.tagRequest;
}

// 10.  邀请加入群(/group/api/invite)
- (NSString*)inviteJoinGroup:(NSString*)gid
                        user:(NSString*)uid
                    delegate:(id <TCResultNoneDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_None delegate:aDelegate];
    [client inviteJoinGroup:gid user:uid];
    return client.tagRequest;
}

// 11.  同意邀请加入群(/group/api/agreeInvite)
- (NSString*)agreeInviteJoinGroup:(NSString*)gid
                         delegate:(id <TCResultNoneDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_None delegate:aDelegate];
    [client agreeInviteJoinGroup:gid];
    return client.tagRequest;
}

// 12.  不同意邀请加入群(/group/api/disagreeInvite)
- (NSString*)refuseInviteJoinGroup:(NSString*)gid
                          delegate:(id <TCResultNoneDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_None delegate:aDelegate];
    [client refuseInviteJoinGroup:gid];
    return client.tagRequest;
}

// 13.  管理员删除成员(/group/api/remove)
- (NSString*)deleteUser:(NSString*)uid
              fromGroup:(NSString*)gid
               delegate:(id <TCResultNoneDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_None delegate:aDelegate];
    [client deleteUser:uid fromGroup:gid];
    return client.tagRequest;
}

// 14.  退出群(/group/api/quit)
- (NSString*)quitGroup:(NSString*)gid
              delegate:(id <TCResultNoneDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_None delegate:aDelegate];
    [client quitGroup:gid];
    return client.tagRequest;
}

// 15.  管理员删除群(/group/api/delete)
- (NSString*)deleteGroup:(NSString*)gid
                delegate:(id <TCResultNoneDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_None delegate:aDelegate];
    [client deleteGroup:gid];
    return client.tagRequest;
}

// 16.  编辑群资料(/group/api/edit)
- (NSString*)modifyGroup:(NSString*)gid
                    name:(NSString*)name
               headImage:(UIImage*)img
             description:(NSString*)description
                  extend:(TCExtend *)extend
                delegate:(id <TCResultNoneDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_None delegate:aDelegate];
    [client modifyGroup:gid name:name headImage:img description:description extend:extend];
    return client.tagRequest;
}

// 17.  设置是否接收群消息(/group/api/getmsg)
- (NSString*)setGroup:(NSString*)gid
         isGetMessage:(BOOL)isGet
             delegate:(id <TCResultNoneDelegate>)aDelegate {
    TCClient* client = [self cliendWithTypeResult:forTCResultObjectType_None delegate:aDelegate];
    [client setGroup:gid isGetMessage:isGet];
    return client.tagRequest;
}

@end
