//
//  Config.h
//  ALHomeland
//
//  Created by kiwi on 8/7/13.
//  Copyright (c) 2013 xizue. All rights reserved.
//

#import "ColorHelper.h"
#import "Declare.h"
#import "Globals.h"
#import "BaseEngine.h"

#import "ThinkChat.h"

#import "UIViewAdditions.h"
#import "UIImageAddtions.h"
#import "NSDictionaryAdditions.h"
#import "NSStringAdditions.h"

#import "WCAlertView.h"
#import "KAlertView.h"

#ifndef Custom_Config_h
#define Custom_Config_h

#define ShouldLogAfterRequest 1

// Demo 服务器 (app接口地址)
//#define kBaseDemoAPIHost              @"http://www.yhcd.net"
#define kResPathAppBaseUrl             @"http://test.yhcd.net"
#define kBaseDemoAPIDomain            @"/index.php"
#define kBaseDemoAPPKey               @"0e93f53b5b02e29ca3eb6f37da3b05b9"

// SDK 服务器 (openfire服务器设置)
#define kBaseSDKAPIHost               @"http://www.yhcd.net"
#define kBaseSDKAPIDomain             kBaseSDKAPIHost@"/tc_sdk/index.php"
#define kBaseSDKAPIDomainXMPP         @"yhcd.net"
#define kBaseSDKAPIDomainXMPPPort     5222
#define kBaseSDKAPIDomainXMPPServer   @"ay130624211425z"

#define DB_Version @"1.0.12"
#define defaultSizeInt 20
#define defaultSizeStr @"20"

#define kBaseSDKErrorDomain           @"SDKErrorDomain"
#define kBaseSDKErrorCodeKey          @"SDKErrorCodeKey"


#define kBaseIfCloseAPNS                @"baseIfCloseAPNS"
#define kBaseIfCloseVoice               @"baseIfCloseVoice"

#define APPID @"838106901"

#define kCornerRadiusNormal 8
#define kCornerRadiusSmall  6
#define kCornerRadiusLarge  12

#define kCornerRadiusHead   0
#define kCornerRadiusInput  kCornerRadiusSmall
#define kCornerRadiusButton kCornerRadiusSmall

#define kTimeNoticeOffset           5   // 提醒时间间隔

#define kImageDefaultHeadUser   [UIImage imageNamed:@"default_head_user"]
#define kImageDefaultHeadGroup  [UIImage imageNamed:@"default_head_group"]
#define kImageDefaultImageNone  [UIImage imageNamed:@"default_image_none"]

#endif
