//
//  Constants.h
//  YSCKit
//
//  Created by  YangShengchao on 14-2-13.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//  FORMATED!
//

#ifndef YSCKit_Constants_h
#define YSCKit_Constants_h

typedef void (^CallBackBlock)();
typedef void (^CallBackWithResponseBlock)(id response);

#import "Masonry.h"
#import "YSCKit.h"

//ThinkChat 入口
#import "Config.h"

/**
 *  第三方登录、分享平台key定义
 */
#pragma mark - 第三方平台key控制

#define AppRedirectUrlOfWeibo   @"http://xizue.com"

//手机QQ和QQ空间(配置在UMeng后端) urlscheme 添加：QQ05FEBF7D(手机QQ回调要用) 和 tencent100581245(QQ空间回调要用)
//(3303384205@qq.com jxj123456)
#define AppKeyQQ                @"1104794251"
#define AppSecretQQ             @"xNmOlhALscCJ5nmY"

//腾讯微博(配置在UMeng后端) urlscheme 添加：wb801548274
#define AppKeyTencentWeibo      @""
#define AppSecretTencentWeibo   @""

//新浪微博(配置在UMeng后端)
#define AppKeySinaWeibo         @""
#define AppSecretSinaWeibo      @""

//微信(3303384205@qq.com jxj123456)
#define AppKeyWeiXin            @"wx02be3a6564b7a50d"
#define AppSecretWeiXin         @"2be4f68f1f7801cf1cee413b34256324"

/**
 *  判断设备的相关参数
 */
#pragma mark - Device

#define IOS_VERSION             ([[[UIDevice currentDevice] systemVersion] floatValue])
#define IOS7_OR_LATER           __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
#define IOS8_OR_LATER           (IOS_VERSION >= 8.0f)
#define IOS7_OR_EARLIER         (IOS_VERSION < 8.0f)
#define SCREEN_WIDTH            ([UIScreen mainScreen].bounds.size.width) //屏幕的宽度(point)
#define SCREEN_HEIGHT           ([UIScreen mainScreen].bounds.size.height)//屏幕的高度(point)
#define STATUSBAR_HEIGHT        20.0f
#define NAVIGATIONBAR_HEIGHT    44.0f
#define TITLEBAR_HEIGHT         64.0f       //等于STATUSBAR_HEIGHT + NAVIGATIONBAR_HEIGHT
#define TABBAR_HEIGHT           49.0f
#define KEYBOARD_HEIGHT         216.0f      //默认键盘高度
#define XIB_WIDTH               640.0f      //xib布局时的宽度(point)，主要用于计算缩放比例


/**
 *  颜色及相关默认值定义
 */
#pragma mark - Color defines

#define kDefaultViewColor               RGB(240, 240, 240)      //self.view的默认背景颜色
#define kDefaultTitleBarColor           RGB(234, 106, 84)       //导航栏的默认颜色
#define kDefaultStatusBarColor          RGB(234, 106, 84)       //状态栏默认颜色
#define kDefaultNaviBarColor            RGBA(25, 30, 39, 1)  //设置navigationBar默认颜色(包括了StatusBar)
#define kDefaultTextColor               RGB(5, 5, 5)      //设置文字默认颜色
#define kDefaultTextColor1              RGB(122, 122, 122)
#define kDefaultEmptyTextColor          RGB(122, 122, 122)      //列表为空时的提醒文字颜色
#define kDefaultSeperatorLineColor      RGB(215, 215, 215)      //设置间隔线的默认颜色
#define kDefaultRedButtonColor          RGB(234, 4, 8)          //按钮默认可用颜色
#define kDefaultGrayButtonColor         RGB(110, 110, 110)      //按钮默认不可用颜色
#define kDefaultImageBackColor          RGB(243, 243, 243)      //默认图片的背景色
//#define kDefaultBorderColor             RGB(200, 200, 200)
#define kDefaultBorderColor             RGB(204, 204, 204)      //设置边线、间隔线的默认颜色
#define kDefaultPlaceholderColor        RGB(180, 180, 180)      //列表为空时的提醒文字颜色


/**
 * 代码段简写
 */
#pragma mark - define images

#define StretchImageOfTopicReply        [ImageUtils stretchImage:[UIImage imageNamed:@"bg_balloon_white"] withPoint:CGPointMake(20, 20)]
#define DefaultAvatarImage              [UIImage imageNamed:@"default_avatar"]
#define DefaultProductImage             [UIImage imageNamed:@"default_product"]
#define DefaultImage                    [UIImage imageNamed:@"default_image"]
#define GenderMaleImage                 [UIImage imageNamed:@"icon_gender_male"]
#define GenderFemaleImage               [UIImage imageNamed:@"icon_gender_female"]
#define DefaultNaviBarArrowBackImage    [UIImage imageNamed:@"arrow_left_white"]                  //BaseViewController里设置push和present出来的返回按钮图片
#define PresentNaviBarImage             [UIImage imageNamed:@"bg_navigationbar"]    //BaseViewController里设置prsent出来的navibar背景图片
#define PresentNaviBackColor            [UIColor whiteColor]            //定义BaseViewController里设置prsent出来的navibar返回箭头颜色
#define PresentNaviTitleColor           [UIColor whiteColor]            //定义BaseViewController里设置prsent出来的navibar标题文字颜色
#define ReturnWhenObjectIsEmpty(object)             if ([NSObject isEmpty:object]) { return ;    }
#define ReturnNilWhenObjectIsEmpty(object)          if ([NSObject isEmpty:object]) { return nil; }
#define ReturnEmptyWhenObjectIsEmpty(object)        if ([NSObject isEmpty:object]) { return @""; }
#define ReturnYESWhenObjectIsEmpty(object)          if ([NSObject isEmpty:object]) { return YES; }
#define ReturnNOWhenObjectIsEmpty(object)           if ([NSObject isEmpty:object]) { return NO;  }
#define ReturnZeroWhenObjectIsEmpty(object)         if ([NSObject isEmpty:object]) { return 0;  }
#define CheckStringEmpty(string,errmsg)                 if ([NSString isEmptyConsiderWhitespace:(string)]) {[UIView showResultThenHideOnWindow:(errmsg)];return;}
#define CheckStringMatchRegex(regex,string,errmsg)      if (NO == [NSString isMatchRegex:(regex) withString:(string)]) {[UIView showResultThenHideOnWindow:(errmsg)];return;}
#define CheckStringNotMatchRegex(regex,string,errmsg)      if ([NSString isMatchRegex:(regex) withString:(string)]) {[UIView showResultThenHideOnWindow:(errmsg)];return;}
#define Trim(x)                         [NSString trimString:x]
#define ClassOfObject(x)                [x class]
#define RandomInt(from,to)              ((int)((from) + arc4random() % ((to)-(from) + 1)))  //随机数 [from,to] 之间
#define DBRealPath                      [[YSCFileUtils DirectoryPathOfDocuments] stringByAppendingPathComponent:@"Cache.sqlite"]      //数据库在沙盒中的路径
#define LOGIN                           [Login sharedInstance]
#define FormatFloatValue(x)             [YSCCommonUtils formatFloatValue:x]
#define FormatNumberValue(x)            [YSCCommonUtils formatNumberValue:x]
#define CreateNSError(errMsg)                       [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey : Trim(errMsg)}]
#define CreateNSErrorCode(code,errMsg)                   [NSError errorWithDomain:@"" code:Code userInfo:@{NSLocalizedDescriptionKey : Trim(errMsg)}]
#define GetNSErrorMsg(error)                        ((NSError *)error).userInfo[NSLocalizedDescriptionKey]  //=error.localizedDescription


/**
 *  定义常量
 */
#pragma mark - define constants

#define kDefaultDuration                0.3f                    //默认动画时间
#define kDefaultPageStartIndex          1
#define kDefaultPageSize                20
#define IsNeedSignParams                0                       //网络请求参数是否签名
#define IsNeedEncryptHTTPHeader         0                       //HTTPHeadertoken参数是否加密
#define IsStatusBarChanged              0                       //在present vc 的时候是否需要修改状态栏颜色
#define IsJsonKeyFirstLetterUpper       0                       //json的key第一个字母是否大写
#define kDefaultAFNTimeOut              10.0f                   //网络访问超时(s)
#define kBadgeScaleFactor               (AUTOLAYOUT_SCALE * 1.6)//设置JSCustomBadge.badgeScaleFactor默认值
#define ScaleOfResponseTime             1000                    //返回的服务器时间：1000-毫秒  1-秒
#define kAppScheme                      @"CDZXAppScheme"
#define kCachedUserModel                @"UserModel"
#define kCachedUserName                 @"UserName"
#define kCachedPassword                 @"Password"
#define kCachedUserToken                @"UserToken"
#define kCellIdentifier                 @"Cell"
#define kFooterIdentifier               @"Footer"
#define kHeaderIdentifier               @"Header"
#define kItemCellIdentifier             @"ItemCell"             //UICollectionView要用的
#define kProductCollectionHeaderView    @"CollectionHeaderView" //UICollectionView要用的
#define kProductCollectionFooterView    @"CollectionFooterView" //UICollectionView要用的
#define kAppChannelAppStore             @"AppStore"             //定义渠道为AppStore
#define kAppChannelOfficialWebsite      @"OfficialWebsite"      //定义渠道为官网
#define kAppChannelDebug                @"Debug"                //定义渠道为测试环境
#define kDefaultTipText                 @"没有相关信息"
#define kLocalCityList                  @"LocalCityList"

//常量
#ifndef kDefaultTipsEmptyText
#define kDefaultTipsEmptyText       @"暂无数据"
#endif
#ifndef kDefaultTipsEmptyIcon
#define kDefaultTipsEmptyIcon       @"icon_empty"//列表为空时的默认icon名称
#endif
#ifndef kDefaultTipsFailedIcon
#define kDefaultTipsFailedIcon      @"icon_failed"//列表加载失败时的默认icon名称
#endif
#ifndef kDefaultTipsButtonTitle
#define kDefaultTipsButtonTitle     @"重新加载"//列表加载失败、为空时的按钮名称
#endif

/**
 *  定义通知名称
 */
#pragma mark - Notification Name

#define kNotificationHandleTabbar           @"kNotificationHandleTabbar"
#define kNotificationRefreshHome            @"kNotificationRefreshHome"
#define kNotificationRefreshMessage         @"kNotificationRefreshMessage"
#define kNotificationRefreshGroupChat       @"kNotificationRefreshGroupChat"
#define kNotificationRefreshContacts        @"kNotificationRefreshContacts"
#define kNotificationRefreshUserCenter      @"kNotificationRefreshUserCenter"

#define kNotificationRefreshBuyList         @"kNotificationRefreshBuyList"
#define kNotificationRefreshSellList        @"kNotificationRefreshSellList"
#define kNotificationRefreshQuotePriceList  @"kNotificationRefreshQuotePriceList"
#define kNotificationRefreshReSaleList      @"kNotificationRefreshReSaleList"
#define kNotificationRefreshRePurchaseList  @"kNotificationRefreshRePurchaseList"

#endif
