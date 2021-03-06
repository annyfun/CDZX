//
//  AppDelegate.m
//  AFCal
//
//  Created by Jinjin on 2016/9/27.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "AppDelegate.h"
#import "ASDiscountCalculatorViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [YSCCommonUtils configUmeng];
    
    //将状态栏字体改为白色（前提是要设置[View controller-based status bar appearance]为NO）
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //改变Navibar的颜色和背景图片
    [[UINavigationBar appearance] setBarTintColor:kDefaultNaviBarColor];
    //控制返回箭头按钮的颜色
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //设置Title为白色,Title大小为18
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                                            NSFontAttributeName : [UIFont boldSystemFontOfSize:20] }];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    
    ASDiscountCalculatorViewController *cal = [[ASDiscountCalculatorViewController alloc] initWithNibName:@"ASCalViewController" bundle:nil];
    
    [(UINavigationController *)self.window.rootViewController pushViewController:cal animated:NO];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    NSString *host = [url host];
//    [OpenShare handleOpenURL:url];
    return [UMSocialSnsService handleOpenURL:url];
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [UMSocialSnsService handleOpenURL:url];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self downLoadDays];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
