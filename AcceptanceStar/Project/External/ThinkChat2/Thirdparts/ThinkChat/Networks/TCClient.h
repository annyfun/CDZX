//
//  TCClient.h
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class TCExtend;
@class TCMessage;
@class TCClient;
@class TCError;
@class TCPageInfo;

typedef enum {
    forTCResultObjectType_None = 0,
    forTCResultObjectType_User,
    forTCResultObjectType_UserList,
    forTCResultObjectType_Group,
    forTCResultObjectType_GroupList,
    forTCResultObjectType_Conversation,
    forTCResultObjectType_ConversationList,
    forTCResultObjectType_Message,
}TCResultObjectType;

@protocol TCClientDelegate <NSObject>

- (void)tcClient:(id)sender result:(NSObject*)result;

@end

@interface TCClient : NSObject

@property (nonatomic, strong) TCError*              error;
@property (nonatomic, strong) NSString*             tagRequest;
@property (nonatomic, assign) id                    actionDelegate;
@property (nonatomic, assign) TCResultObjectType    typeResult;

- (id)initWithDelegate:(id <TCClientDelegate>)aDelegate actionDelegate:(id)anActionDelegate;

- (void) cancel;

// 添加APNS
- (void)setupAPNSDevice;

// 取消APNS
- (void)cancelAPNSDevice;

- (void)sendMessage:(TCMessage*)msg attach:(id)data;

/**************
 * 会话
 **************/

// 1.	创建临时会话并添加用户(/session/api/add)
- (void)createConversationName:(NSString*)name
                      userList:(NSArray*)userArr;

// 2.	添加用户到一个会话(/session/api/addUserToSession)
- (void)addUserList:(NSArray*)userArr
     toConversation:(NSString*)cid;

// 4.	会话详细(/session/api/detail)
- (void)getConversationDetail:(NSString*)cid;

// 5.	删除用户(/session/api/remove)
- (void)deleteUser:(NSString*)uid
  fromConversation:(NSString*)cid;

// 6.	退出会话(/session/api/quit)
- (void)quitConversation:(NSString*)cid;

// 7.	编辑会话(/session/api/edit)
- (void)modifyConversation:(NSString*)cid
                   newName:(NSString*)name;

// 8.	设置是否接收消息(/session/api/getmsg)
- (void)setConversation:(NSString*)cid
           isGetMessage:(BOOL)isGet;

// 9.	删除会话(/session/api/delete)
- (void)deleteConversation:(NSString*)cid;

/*******************
 *  群聊
 *******************/

// 1.   群详细(/group/api/detail)
- (void)getGroupDetail:(NSString*)gid;

// 2.   创建群(/group/api/add)
- (void)createGroupName:(NSString*)name
              headImage:(UIImage*)img
            description:(NSString*)description
                 extend:(TCExtend*)extend;

// 3.   搜索群(/group/api/search)
- (void)searchGroup:(NSString*)key
              count:(int)count
               page:(int)page;

// 4.   用户群列表(/group/api/groupList)
- (void)getGroupList;

// 5.	群的用户列表(/group/api/groupUserList)
- (void)getUserListInGroup:(NSString*)gid
                     count:(int)count
                      page:(int)page;


// 7.	申请加入群(/group/api/apply)
- (void)applyJoinGroup:(NSString*)gid;

// 8.	同意申请加入群(/group/api/agreeApply)
- (void)agreeApplyJoinGroup:(NSString*)gid
                       user:(NSString*)uid;

// 9.	不同意申请加入群(/group/api/disagreeApply)
- (void)refuseApplyJoinGroup:(NSString*)gid
                        user:(NSString*)uid;

// 10.	邀请加入群(/group/api/invite)
- (void)inviteJoinGroup:(NSString*)gid
                   user:(NSString*)uid;

// 11.	同意邀请加入群(/group/api/agreeInvite)
- (void)agreeInviteJoinGroup:(NSString*)gid;

// 12.	不同意邀请加入群(/group/api/disagreeInvite)
- (void)refuseInviteJoinGroup:(NSString*)gid;

// 13.	管理员删除成员(/group/api/remove)
- (void)deleteUser:(NSString*)uid
         fromGroup:(NSString*)gid;

// 14.	退出群(/group/api/quit)
- (void)quitGroup:(NSString*)gid;

// 15.	管理员删除群(/group/api/delete)
- (void)deleteGroup:(NSString*)gid;

// 16.	编辑群资料(/group/api/edit)
- (void)modifyGroup:(NSString*)gid
               name:(NSString*)name
          headImage:(UIImage*)img
        description:(NSString*)description
             extend:(TCExtend*)extend;

// 17.	设置是否接收群消息(/group/api/getmsg)
- (void)setGroup:(NSString*)gid
    isGetMessage:(BOOL)isGet;


@end
