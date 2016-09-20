//
//  AppDelegate.h
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/22.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThinkChat.h"

@class User;
@class ViewController;
@class ThinkChat;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, ThinkChatDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) NSArray *provinceArray;

@property (assign, nonatomic) NSInteger messageCount;

+ (AppDelegate*)instance;
- (void)getNewMessageCount;
- (void)refreshCities;//下载城市列表
- (void)loginWithUser:(User*)itemU passWord:(NSString*)pwd;
- (void)signOut;

- (void)sendMessage:(TCMessage*)msg;
- (void)resetUnreadCount;

- (void)clearSessionID:(NSString*)sid typeChat:(ChatType)typeChat;
- (void)hasReadSessionID:(NSString*)sid typeChat:(ChatType)typeChat;

- (void)hasReadNotify:(TCNotify*)itemN;
- (void)joinGroup:(TCGroup*)itemG;
- (void)quitGroup:(TCGroup*)itemG;
- (void)editGroup:(TCGroup*)itemG;
- (void)addGroupMember:(TCNotify*)itemT;
- (void)deleteGroupMember:(TCNotify*)itemT;
- (void)addFriend:(User*)itemU;
- (void)deleteFriend:(User*)itemU;

- (BOOL)isPureNumandCharacters:(NSString *)string;

@end
