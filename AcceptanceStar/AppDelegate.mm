//
//  AppDelegate.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/22.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "AppDelegate.h"
#import "MLBlackTransition.h"
#import "JSCustomBadge.h"
#import <AlipaySDK/AlipaySDK.h>
#import <AudioToolbox/AudioToolbox.h>
#import "BaseNavigationController.h"
#import "LoginController.h"
#import "WTStatusBar.h"
#import "TCNotify.h"
#import "TCUser.h"
#import "BMapKit.h"
#import <AVOSCloud/AVOSCloud.h>
#import "Masonry.h"
#import "UMMobClick/MobClick.h"
#import <AFOnceKit/AFOnce.h>

#define kMaxSendCount 1 // 同时发送最大数

static SystemSoundID soundDidRecMsg;
static SystemSoundID soundDidSendMsg;
static SystemSoundID soundDidRecNotify;

@interface AppDelegate () <BMKGeneralDelegate> {
    BMKMapManager * _mapManager;
    NSMutableArray* prepSendList;       //发送消息的队列
    int             countSend;          //正在发送的消息数
    NSTimeInterval  timeNotice;
    
    BOOL first;
}
@end

@implementation AppDelegate

+ (AppDelegate*)instance {
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    [self configureLaunchingWithOptions:launchOptions application:application];
    
    //设置程序启动入口界面
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = kDefaultNaviBarColor;
    self.window.rootViewController = [self rootViewController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)configureLaunchingWithOptions:(NSDictionary *)launchOptions application:(UIApplication *)application
{
    [AVOSCloud setApplicationId:@"ecmJqvnW8dpbCEMxQ9YmGXAR"
                      clientKey:@"6QJxIkXBg6TqrVsJj2cD9S7F"];
    
    [self initAppDefaultUI:nil];

    [MLBlackTransition validatePanPackWithMLBlackTransitionGestureRecognizerType:MLBlackTransitionGestureRecognizerTypeScreenEdgePan];
    
    dispatch_async(dispatch_queue_create("WPAppManagerConfigureLaunching", NULL), ^{
       
        
        
        [YSCCommonUtils configUmeng];
        
    
        
        #pragma mark - Init ThinkChat
        [[ThinkChat instance] application:application didFinishLaunchingWithOptions:launchOptions];
        [[ThinkChat instance] setDebugMode:NO];
        prepSendList = [[NSMutableArray alloc] init];
        countSend = 0;
        [self initializeAudios];
        [Globals initializeGlobals];
        [[ThinkChat instance] initWithServerUrl:kBaseSDKAPIDomain
                                    IMServerUrl:kBaseSDKAPIDomainXMPP
                                   IMServerName:kBaseSDKAPIDomainXMPPServer
                                   IMServerPort:kBaseSDKAPIDomainXMPPPort];
        
        
        
        [self refreshCities];
        
        
        // Setup Baidu Map
        _mapManager = [[BMKMapManager alloc] init];
        BOOL ret = [_mapManager start:@"PwEDDlWfBQTQin5dXGCbV0vg" generalDelegate:self];
        if (!ret) {
            TCDemoLog(@"manager start failed!");
        }
       
        
        [self downLoadDays];
        
        first = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            User* itemU = [BaseEngine currentBaseEngine].user;
            if (itemU) {
                [[ThinkChat instance] loginWithID:itemU.ID passWord:[BaseEngine currentBaseEngine].passWord delegate:self];
            }
            [self getNewMessageCount];
        });
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetMessageCount) name:@"ASMomentsViewControllerIn" object:nil];
        [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(getNewMessageCount) userInfo:nil repeats:YES];
        
        
    });
}


//-----------------------------------
//
// 业务逻辑相关代码
//
//-----------------------------------
#pragma mark - 业务逻辑相关代码
//初始化App默认样式
- (void)initAppDefaultUI:(NSString *)navibarImageName {
    //将状态栏字体改为白色（前提是要设置[View controller-based status bar appearance]为NO）
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //改变Navibar的颜色和背景图片
    [[UINavigationBar appearance] setBarTintColor:kDefaultNaviBarColor];
    if ([NSString isNotEmpty:navibarImageName]) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:navibarImageName]
                                           forBarMetrics:UIBarMetricsDefault];
    }
    //控制返回箭头按钮的颜色
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //设置Title为白色,Title大小为18
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                                            NSFontAttributeName : [UIFont boldSystemFontOfSize:20] }];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
}
//初始化root view controller
- (UIViewController *)rootViewController {
//    return [UIResponder createBaseViewController:@"ASCreateMomentViewController"];
    //top class of tabbar
    NSArray *tabClassArray = @[@"ASHomeViewController",         //主页
                               @"SessionListController",        //消息
                               @"GroupListController",          //群聊
                               @"ASContactsViewController",         //通讯录
                               @"ASUserCenterViewController"];  //个人中心
    //normal tabbar icon
    NSArray *tabNormalImageArray = @[@"icon_tabbar_home_normal",
                                     @"icon_tabbar_message_normal",
                                     @"icon_tabbar_groupchart_normal",
                                     @"icon_tabbar_contacts_normal",
                                     @"icon_tabbar_usercenter_normal"];
    //selected tabbar icon
    NSArray *tabSeletedImageArray = @[@"icon_tabbar_home_selected",
                                      @"icon_tabbar_message_selected",
                                      @"icon_tabbar_groupchart_selected",
                                      @"icon_tabbar_contacts_selected",
                                      @"icon_tabbar_usercenter_selected"];
    NSArray *tabItemNamesArray = @[@"首页", @"消息", @"群聊", @"通讯录", @"我"];
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (NSUInteger i = 0; i < [tabClassArray count]; i++) {
        UIViewController *tabbarRootViewController = [UIResponder createBaseViewController:tabClassArray[i]];
        
        tabbarRootViewController.hidesBottomBarWhenPushed = NO;//NOTE:一级页面的tabbar不能隐藏
        tabbarRootViewController.navigationItem.title = tabItemNamesArray[i];
        UITabBarItem *tabbaritem = [[UITabBarItem alloc] initWithTitle:tabItemNamesArray[i]
                                                                 image:[UIImage imageNamed:tabNormalImageArray[i]]
                                                         selectedImage:[UIImage imageNamed:tabSeletedImageArray[i]]];
        //修改未选中时的image,否则会是灰色的
        @try {
            [tabbaritem setValue:[UIImage imageNamed:tabNormalImageArray[i]] forKey:@"unselectedImage"];
            [tabbaritem setValue:[UIImage imageNamed:tabSeletedImageArray[i]] forKey:@"selectedImage"];
        }
        @catch (NSException *exception)
        {
        }
        @finally
        {
        }
        //以下两行代码是调整image和label的位置
        tabbaritem.imageInsets = UIEdgeInsetsMake(-1, 0, 1, 0);
        [tabbaritem setTitlePositionAdjustment:UIOffsetMake(0, -2)];
        
        //创建navigationController
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tabbarRootViewController];
        navigationController.customNavigationDelegate = [[ADNavigationControllerDelegate alloc] init];
        navigationController.navigationController.navigationBar.translucent = YES;
        navigationController.tabBarItem = tabbaritem;
        [viewControllers addObject:navigationController];
    }
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.delegate = self;
    tabBarController.viewControllers = viewControllers;
    tabBarController.tabBar.barStyle = UIBarStyleDefault;
    tabBarController.tabBar.backgroundColor = RGB(247, 247, 247);
    tabBarController.tabBar.tintColor = RGB(34, 108, 232);//设置选中后的图片颜色（这个必须有，否则会默认是蓝色）
    
    //修改未选中和选中时，tabbar的title颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : RGB(148, 148, 148) ,
                                                         NSFontAttributeName : AUTOLAYOUT_FONT(20)}
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : RGB(34, 108, 232),
                                                         NSFontAttributeName : AUTOLAYOUT_FONT(20)}
                                             forState:UIControlStateSelected];
    addNObserver(@selector(handleTabbarNotification:), kNotificationHandleTabbar);
    
    return tabBarController;
}
//发通知修改tabbar的选择状态
- (void)handleTabbarNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo[kParamSelectedIndex]) {
        NSInteger selectedIndex = [userInfo[kParamSelectedIndex] integerValue];
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
        [tabBarController setSelectedIndex:selectedIndex];
    }
    if (userInfo[kParamNotificationName]) {
        NSString *notificationName = Trim(userInfo[kParamNotificationName]);
        postN(notificationName);
    }
}
//下载城市列表
- (void)refreshCities {
    if (isEmpty(self.provinceArray)) {
        [AFNManager getDataWithAPI:kResPathAppCityIndex
                      andDictParam:@{}
                         modelName:ClassOfObject(ASProvinceModel)
                  requestSuccessed:^(id responseObject) {
                      NSArray *tempArray = responseObject;
                      if ([tempArray isKindOfClass:[NSArray class]]) {
                          [[StorageManager sharedInstance] setConfigValue:tempArray forKey:kLocalCityList];
                      }
                  }
                    requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                        NSLog(@"error=%@", errorMessage);
                    }];
    }
}
- (NSArray *)provinceArray {
    if (isEmpty(_provinceArray)) {
        NSArray *tempArray = [[StorageManager sharedInstance] configValueForKey:kLocalCityList];
        _provinceArray = [[NSArray alloc] initWithArray:tempArray];
    }
    return _provinceArray;
}

//-----------------------------------
//
// tabBarViewControllerDelegate
//
//-----------------------------------
#pragma mark - tabBarViewControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSString *controllerName = NSStringFromClass(ClassOfObject(((UINavigationController *)viewController).topViewController));
    UINavigationController *navigationController = (UINavigationController *)tabBarController.selectedViewController;
    [navigationController popToRootViewControllerAnimated:NO];
    
    //刷新当前要显示的页面(通过发通知的方式)
    if ([@"KQHomeViewController" isEqualToString:controllerName]) {
        //        postN(kNotificationRefreshHome);
    }
}
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    NSString *controllerName = NSStringFromClass(ClassOfObject(((UINavigationController *)viewController).topViewController));
    //判断是否需要进入选择的界面
    if ([@"SessionListController" isEqualToString:controllerName] ||
        [@"GroupListController" isEqualToString:controllerName] ||
        [@"ASContactsViewController" isEqualToString:controllerName] ||
        [@"ASUserCenterViewController" isEqualToString:controllerName]) {
        if ( NO == ISLOGGED) {
            [self userNotLogin];
            return NO;//未登录就弹登录界面
        }
    }
    return YES;
}


//-----------------------------------
//
// AppDelegate相关回调方法
//
//-----------------------------------
#pragma mark - AppDelegate相关回调方法
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[ThinkChat instance] applicationWillResignActive:application];
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[ThinkChat instance] applicationDidEnterBackground:application];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[ThinkChat instance] applicationWillEnterForeground:application];
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[ThinkChat instance] applicationDidBecomeActive:application];
}    
    
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[ThinkChat instance] applicationWillTerminate:application];
}
//从其它客户端打开本app
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    NSString *host = [url host];
    
    [OpenShare handleOpenURL:url];
     
    if ([@"safepay" isEqualToString:host]) {//支付宝回调
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
        }];
    }
    return [UMSocialSnsService handleOpenURL:url];
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [UMSocialSnsService handleOpenURL:url];
}

- (void)resetMessageCount{
    self.messageCount = 0;
    
}

- (void)setMessageCount:(NSInteger)messageCount{
    _messageCount = messageCount;
    UITabBarController *c = (id)self.window.rootViewController;
    UIViewController *sc = [c.viewControllers lastObject];
    sc.tabBarItem.badgeValue = _messageCount?[NSString stringWithFormat:@"%zd",_messageCount]:nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AFGetNewMessageCount" object:nil];
}

- (BOOL)isPureNumandCharacters:(NSString *)string
{
    NSString* string2 = [string stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(string2.length > 0)
    {
        return NO;
    }
    return YES;
}


- (void)getNewMessageCount{
    if (!isEmpty(TOKEN)) {
        [AFNManager getDataWithAPI:kResPathAppMessageCount
                      andDictParam:@{}
                         modelName:nil
                  requestSuccessed:^(id responseObject) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          NSString* strMsgCount = responseObject;
                          if ([strMsgCount isKindOfClass:[NSString class]]) {
                          
                              if ([strMsgCount isEqualToString:@"0"]) {
                                  return;
                              }
                              
                          NSInteger newCount = [strMsgCount intValue];
                              if (newCount!=self.messageCount) {
                                  self.messageCount = newCount;
                              }
                              NSLog(@"消息数量更新 %zd",self.messageCount);
                          }
                      });
                  }
                    requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                        NSLog(@"error=%@", errorMessage);
                    }];
    }
}

//-----------------------------------
//
// 处理远程消息推送
//
//-----------------------------------
#pragma mark - 处理远程消息推送
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)pToken {
    [[ThinkChat instance] application:application didRegisterForRemoteNotificationsWithDeviceToken:pToken];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[ThinkChat instance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[ThinkChat instance] application:application didReceiveRemoteNotification:userInfo];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"settings=%@", notificationSettings);
}
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void(^)())completionHandler {
    NSLog(@"identifier = %@, userInfo = %@", identifier, userInfo);
    if (completionHandler) {
        completionHandler();
    }
}
#endif


//-----------------------------------
//
// 消息处理
//
//-----------------------------------
#pragma mark - 消息处理
- (void)loginWithUser:(User*)itemU passWord:(NSString*)pwd {
    [[BaseEngine currentBaseEngine] setCurrentUser:itemU password:pwd];
    [self userDidLogin];
}
- (void)signOut {
    [[ThinkChat instance] logOut];
    [[BaseEngine currentBaseEngine] logOut];
    //[LOGIN logout];
    //TODO:switch to home
    //TODO:present login view controller
}
- (void)userDidLogin {
    User* itemU = [BaseEngine currentBaseEngine].user;
    [[ThinkChat instance] loginWithID:itemU.ID passWord:[BaseEngine currentBaseEngine].passWord delegate:self];
}
- (void)userNotLogin {
    YSCBaseViewController *loginViewController = (YSCBaseViewController *)[UIResponder createBaseViewController:@"ASLoginViewController"];
    //创建navigationController
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    navigationController.customNavigationDelegate = [[ADNavigationControllerDelegate alloc] init];
    navigationController.navigationController.navigationBar.translucent = YES;
    [self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
}
- (void)receivedMessage:(TCMessage*)item {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyReceivedMessage object:item];
    [self resetUnreadCount];
}
- (void)sendMessage:(TCMessage*)msg {
    msg.state = forMessageStateHavent;
    [prepSendList addObject:msg];
    [self doSendMessage];
}
- (void)doSendMessage {
    if (countSend >= kMaxSendCount) {
        return;
    }
    
    if (prepSendList.count > 0) {
        
        countSend += 1;
        
        BOOL isSuccess = NO;
        TCMessage* msg = [prepSendList firstObject];
        id  attach = nil;
        
        if (msg.typeFile == forFileVoice) {
            NSData* data = [NSData dataWithContentsOfFile:msg.bodyVoice.voiceUrl];
            if (data) {
                isSuccess = YES;
                attach = data;
            }
        } else if (msg.typeFile == forFileImage) {
            NSData* data = [NSData dataWithContentsOfFile:msg.bodyImage.imgUrlL];
            if (data) {
                isSuccess = YES;
                attach = data;
            }
        } else if (msg.typeFile == forFileText || msg.typeFile == forFileLocation) {
            isSuccess = YES;
        }
        
        if (isSuccess) {
            [[ThinkChat instance] sendMessage:msg attach:attach];
        } else {
            msg.state = forMessageStateError;
            [self receivedMessage:msg];
            
            [prepSendList removeObjectAtIndex:0];
            countSend -= 1;
            [self doSendMessage];
        }
    }
}



//-----------------------------------
//
// ThinkChatDelegate
//
//-----------------------------------
#pragma mark - ThinkChatDelegate
- (void)thinkChat:(id)sender connectState:(TCConnectState)tcState {
    TCDemoLogFunc;
    TCDemoLog(@"%d",tcState);
    switch (tcState) {
        case forTCConnectState_Connecting:
            [WTStatusBar setStatusText:@"正在连接聊天服务器..." animated:YES];
            break;
        case forTCConnectState_Success:
            [WTStatusBar setStatusText:@"连接成功！" timeout:1.5 animated:YES];
            break;
        case forTCConnectState_Failure:
            [WTStatusBar setStatusText:@"连接失败！" timeout:1.5 animated:YES];
            break;
        case forTCConnectState_Disconnect:
            [WTStatusBar setStatusText:@"断开连接" timeout:1.5 animated:YES];
            break;
        case forTCConnectState_NoDisconnect:
            [WTStatusBar setStatusText:@"未断开连接" timeout:1.5 animated:YES];
            break;
        case forTCConnectState_TimeOut:
            [WTStatusBar setStatusText:@"连接超时" timeout:1.5 animated:YES];
            break;
    }
}
- (void)thinkChat:(id)sender loginState:(TCLoginState)tcState {
    TCDemoLogFunc;
    TCDemoLog(@"%d",tcState);
    switch (tcState) {
        case forTCLoginState_Wrong:
            [WTStatusBar setStatusText:@"用户名或密码错误" timeout:1.5 animated:YES];
            break;
        case forTCLoginState_Success:
            //TODO:dismiss login
            [self resetUnreadCount];
            break;
        case forTCLoginState_Failure:
            [WTStatusBar setStatusText:@"登录失败,请重新登录" timeout:1.5 animated:YES];
            break;
        case forTCLoginState_Conflict:
            [WTStatusBar setStatusText:@"账号在其他地方已登录" timeout:1.5 animated:YES];

            [LOGIN logout];
            [[AppDelegate instance] signOut];

            

            //[self signOut];
            
            
            break;
    }
    if (self.window.rootViewController == nil) {
        [self userNotLogin];
    }
}
- (void)thinkChat:(id)sender receiveMessage:(TCMessage *)oMessage {
    TCDemoLogFunc;
    if (oMessage.isSendByMe) {
        TCMessage* sMessage = nil;
        for (TCMessage* item in prepSendList) {
            if ([item.tag isEqualToString:oMessage.tag]) {
                sMessage = item;
                break;
            }
        }
        if (sMessage) {
            NSFileManager* fm = [NSFileManager defaultManager];
            NSError* err = nil;
            
            NSString* sName = nil;  // 原文件名
            NSString* oName = nil;  // 目标文件名
            
            if (oMessage.state == forMessageStateNormal) {
                if (oMessage.typeFile == forFileImage) {
                    sName = sMessage.bodyImage.imgUrlL;
                    oName = [NSString stringWithFormat:@"%@/Library/Cache/Images/%@.dat",NSHomeDirectory(),[oMessage.bodyImage.imgUrlL md5Hex]];
                    [fm moveItemAtPath:sName toPath:oName error:&err];
                    if (err == nil) {
                        sName = sMessage.bodyImage.imgUrlS;
                        oName = [NSString stringWithFormat:@"%@/Library/Cache/Images/%@.dat",NSHomeDirectory(),[oMessage.bodyImage.imgUrlS md5Hex]];
                        [fm moveItemAtPath:sName toPath:oName error:&err];
                    }
                } else if (oMessage.typeFile == forFileVoice) {
                    sName = sMessage.bodyVoice.voiceUrl;
                    oName = [NSString stringWithFormat:@"%@/Library/Cache/Audios/%@.pcm",NSHomeDirectory(),[oMessage.bodyVoice.voiceUrl md5Hex]];
                    [fm moveItemAtPath:sName toPath:oName error:&err];
                }
            }
            
            if (err) {
                // 文件移动失败
                oMessage.state = forMessageStateError;
            }
            [self receivedMessage:oMessage];
            
            [prepSendList removeObject:sMessage];
            countSend -= 1;
            [self doSendMessage];
        }
    } else {
        [self audioPlayRecMsg];
        [self receivedMessage:oMessage];
    }
}
- (void)thinkChat:(id)sender receiveNotify:(TCNotify*)aNotify {
    TCDemoLogFunc;
    
    if (aNotify) {
        TCDemoLog(@"收到一条新的通知 : %@",aNotify.content);
        BOOL    isPlayRecNotify = YES;
        User* itemU = nil;
        
        switch (aNotify.type) {
            case forNotifyType_System:
                // 1   系统通知
                break;
            case forNotifyType_ConversationQuit:
                // 300 用户退出 会话
                isPlayRecNotify = NO;
                [self deleteGroupMember:aNotify];
                break;
            case forNotifyType_ConversationRemove:
                // 301 管理员删除 会话用户
                isPlayRecNotify = NO;
                [self deleteGroupMember:aNotify];
                break;
            case forNotifyType_ConversationEdit:
                // 302 管理员编辑 会话名称
                isPlayRecNotify = NO;
                
                break;
            case forNotifyType_ConversationDele:
                // 303 管理员删除 会话
                isPlayRecNotify = NO;
                [self quitGroup:aNotify.group];
                break;
            case forNotifyType_ConversationKick:
                // 304 自己被踢出 会话
                [self quitGroup:aNotify.group];
                break;
            case forNotifyType_GroupJoinApply:
                // 202 申请加 群
                break;
            case forNotifyType_GroupJoinAgree:
                // 203 同意申请入 群
                [self joinGroup:aNotify.group];
                break;
            case forNotifyType_GroupJoinRefuse:
                // 204 不同意申请入 群
                break;
            case forNotifyType_GroupInviteApply:
                // 205 邀请入 群
                break;
            case forNotifyType_GroupInviteAgree:
                // 206 同意邀请入 群
                [self addGroupMember:aNotify];
                break;
            case forNotifyType_GroupInviteRefuse:
                // 207 不同意邀请入 群
                break;
            case forNotifyType_GroupKick:
                // 208 自己被踢出 群
                [self quitGroup:aNotify.group];
                break;
            case forNotifyType_GroupQuit:
                // 209 成员退出 群
                isPlayRecNotify = NO;
                [self deleteGroupMember:aNotify];
                break;
            case forNotifyType_GroupDele:
                // 210 管理员删除 群
                isPlayRecNotify = NO;
                [self quitGroup:aNotify.group];
                break;
            case forNotifyType_GroupRemove:
                // 211 管理员删除 群成员
                isPlayRecNotify = NO;
                [self deleteGroupMember:aNotify];
                break;
            default:
                // 扩展通知
                if (aNotify.type == forNotifyType_FriendApply) {
                    // 申请加好友
                    [aNotify hasUpdateNewContent:[NSString stringWithFormat:@"%@申请加你为好友",aNotify.user.name]];
                } else if (aNotify.type == forNotifyType_FriendAgree) {
                    // 同意加好友
                    [aNotify hasUpdateNewContent:[NSString stringWithFormat:@"%@已经同意添加你为好友",aNotify.user.name]];
                    itemU = [User objectWithTCUser:aNotify.user];
                    [self addFriend:itemU];
                } else if (aNotify.type == forNotifyType_FriendRefuse) {
                    // 拒绝加好友
                    [aNotify hasUpdateNewContent:[NSString stringWithFormat:@"%@已经拒绝添加你为好友",aNotify.user.name]];
                } else if (aNotify.type == forNotifyType_FriendDelete) {
                    // 解除好友关系
                    [aNotify hasUpdateNewContent:[NSString stringWithFormat:@"%@已经解除了好友关系",aNotify.user.name]];
                    itemU = [User objectWithTCUser:aNotify.user];
                    [self deleteFriend:itemU];
                }
                break;
        }
        
        if (isPlayRecNotify) {
            [self audioPlayRecNotify];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyReceiveNotify object:aNotify];
        
        [self resetUnreadCount];
    }
}
- (void)joinGroup:(TCGroup*)itemG {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyJoinGroup object:itemG];
}
- (void)quitGroup:(TCGroup*)itemG {
    ChatType typeChat = forChatTypeUser;
    if (itemG.type == forTCGroupType_Group) {
        typeChat = forChatTypeGroup;
    } else if (itemG.type == forTCGroupType_Temp) {
        typeChat = forChatTypeRoom;
    }
    [self clearSessionID:itemG.ID typeChat:typeChat];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyQuitGroup object:itemG];
}
- (void)editGroup:(TCGroup*)itemG {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyEditGroup object:itemG];
}
- (void)addGroupMember:(TCNotify*)itemT {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyAddGroupMember object:itemT];
}
- (void)deleteGroupMember:(TCNotify*)itemT {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyDeleteGroupMember object:itemT];
}
- (void)addFriend:(User*)itemU {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyAddFriend object:itemU];
}
- (void)deleteFriend:(User*)itemU {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyDeleteFriend object:itemU];
}


//-----------------------------------
//
// BMKGeneralDelegate
//
//-----------------------------------
#pragma mark - BMKGeneralDelegate
/**
 *返回网络错误
 *@param iError 错误号
 */
- (void)onGetNetworkState:(int)iError {
    if (iError != 0) {
        TCDemoLog(@"百度地图 - 网络错误 : %s : %d",__func__,iError);
    }
}
/**
 *返回授权验证错误
 *@param iError 错误号 : BMKErrorPermissionCheckFailure 验证失败
 */
- (void)onGetPermissionState:(int)iError {
    if (iError != 0) {
        TCDemoLog(@"百度地图 - 授权验证错误 : %s : %d",__func__,iError);
    }
}


//-----------------------------------
//
// Audios Play
//
//-----------------------------------
#pragma mark - Audios Play
- (void)initializeAudios {
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"audio_msg_rec" ofType:@"caf"]], &soundDidRecMsg);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"audio_msg_send" ofType:@"caf"]], &soundDidSendMsg);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"audio_notify_rec" ofType:@"wav"]], &soundDidRecNotify);
}
- (void)audioPlayRecMsg {
    if ([Globals isAudioNotify]) {
        NSTimeInterval theTime = [[NSDate date] timeIntervalSince1970];
        if (theTime > timeNotice + kTimeNoticeOffset) {
            timeNotice = theTime;
            AudioServicesPlaySystemSound(soundDidRecMsg);
        }
    }
}
- (void)audioPlaySendMsg {
    if ([Globals isAudioNotify]) {
        NSTimeInterval theTime = [[NSDate date] timeIntervalSince1970];
        if (theTime > timeNotice + kTimeNoticeOffset) {
            timeNotice = theTime;
            AudioServicesPlaySystemSound(soundDidSendMsg);
        }
    }
}
- (void)audioPlayRecNotify {
    if ([Globals isAudioNotify]) {
        NSTimeInterval theTime = [[NSDate date] timeIntervalSince1970];
        if (theTime > timeNotice + kTimeNoticeOffset) {
            timeNotice = theTime;
            AudioServicesPlaySystemSound(soundDidRecNotify);
        }
    }
}
- (void)resetUnreadCount {
    //[self.viewController resetUnreadCount];
    
    UITabBarController *c = (id)self.window.rootViewController;
    UIViewController *sc = [c.viewControllers objectAtIndex:1];
    NSString* strBadgeValue = nil;
    NSInteger totalUnread = 0;
    
    NSArray *contentArr = [TCSession getSessionListTimeLine];
    for (TCSession *session in contentArr) {
        totalUnread += session.unreadCount;
    }
    totalUnread += [TCNotify getUnReadCount];
    if (totalUnread > 99) {
        strBadgeValue = @"99+";
    } else if (totalUnread > 0) {
        strBadgeValue = [NSString stringWithFormat:@"%ld", (long)totalUnread];
    }
    sc.tabBarItem.badgeValue = strBadgeValue;
    
}
- (void)clearSessionID:(NSString *)sid typeChat:(ChatType)typeChat {
    [[ThinkChat instance] clearSessionID:sid typeChat:typeChat];
    
    TCSession* itemS = [[TCSession alloc] init];
    itemS.ID = sid;
    itemS.typeChat = typeChat;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyClearSession object:itemS];
    
    [self resetUnreadCount];
}
- (void)hasReadSessionID:(NSString *)sid typeChat:(ChatType)typeChat {
    [[ThinkChat instance] hasReadSessionID:sid typeChat:typeChat];
    
    TCSession* itemS = [[TCSession alloc] init];
    itemS.ID = sid;
    itemS.typeChat = typeChat;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyHasReadSession object:itemS];
    
    [self resetUnreadCount];
}
- (void)hasReadNotify:(TCNotify*)itemN {
    [[ThinkChat instance] hasReadNotify:itemN];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyHasReadNotify object:itemN];
    
    [self resetUnreadCount];
}

- (void)downLoadDays{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://yhcd.net/date.txt"] options:NSDataReadingMappedAlways error:NULL];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
       
        if (str.length) {
            [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"hehehe"];
        }
    });
}


@end
