//
//  BaseClient.h
//  Base
//
//  Created by keen on 13-10-25.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface BaseClient : NSObject

@property (nonatomic, assign) int           errorCode;
@property (nonatomic, strong) NSString*     errorMessage;
@property (nonatomic, assign) BOOL          hasError;

- (id)initWithDelegate:(id)del action:(SEL)act;

- (void) showAlert;

- (void) cancel;

// 添加APNS
- (void)setupAPNSDevice;

// 取消APNS
- (void)cancelAPNSDevice;

/***************
 *  好友
 ***************/

// 1.   注册(/user/api/regist)
- (void)registerWithPhoneNumber:(NSString *)phoneNumber
                       nickName:(NSString *)nickName
                       passWord:(NSString *)passWord;

// 2.   登陆(/user/api/login)
- (void)loginWithPhoneNumber:(NSString *)phoneNumber
                    passWord:(NSString *)passWord;

// 3.   搜索用户(/user/api/search)
- (void)searchUser:(NSString*)key;

// 4.   用户申请加好友(/user/api/applyAddFriend)
- (void)applyFriend:(NSString*)uid;

// 5.   同意申请加好友(/user/api/agreeAddFriend)
- (void)agreeFriend:(NSString*)uid;

// 6.   拒绝申请加好友(/user/api/refuseAddFriend)
- (void)refuseFriend:(NSString*)uid;

// 7.	好友列表(/user/api/friendList)
- (void)getFriendList;

// 8.	删除好友(/user/api/deleteFriend)
- (void)deleteFriend:(NSString*)uid;

/*******************
 *  我
 *******************/

// 1.   用户详细(/user/api/detail)
- (void)getUserDetail:(NSString*)uid;

// 2.  编辑用户资料(/user/api/edit)
- (void)modifyUserHead:(UIImage*)img
              nickName:(NSString*)name
                gender:(Gender)gender
                  sign:(NSString*)sign;

// 3.	修改密码(/user/api/editPassword)
- (void)editPasswordOld:(NSString*)pwdOld new:(NSString*)pwdNew;

// 4.	反馈意见(/user/api/feedback)
- (void)feedback:(NSString*)content;

// 5.	举报(/user/api/jubao)
- (void)reportUser:(NSString*)uid reason:(NSString*)reason;

/*******************
 *  设置
 *******************/

// 1.   版本更新(/version/api/update)
- (void)checkUpdate;

@end
