//
//  Declare.h
//  BusinessMate
//
//  Created by keen on 13-6-7.
//  Copyright (c) 2013年 xizue. All rights reserved.
//

#ifndef BusinessMate_Declare_h
#define BusinessMate_Declare_h

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#define systemVersionFloatValue [UIDevice currentDevice].systemVersion.floatValue

#ifdef DEBUG
#define TCDemoLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define TCDemoLog(...)
#endif

#define TCDemoLogFunc TCDemoLog(@"%s",__func__)

typedef enum {
	kBaseErrorCodeInterface	= 100,
	kBaseErrorCodeSDK         = 101,
}DLErrorCode;

typedef enum {
	kBaseSDKErrorCodeParseError       = 200,
	kBaseSDKErrorCodeRequestError     = 201,
}DLSDKErrorCode;

//1-分组 2-组织 3-群
typedef enum {
    forGrouping = 1,
    forGroupOrganize = 2,
    forGroupRoom = 3,
}GroupType;

// 性别 gender 0-男 1-女 2-未填写
typedef enum {
    male = 0,       // 男
    female = 1,     // 女
    genderNo = 2,   // 未知
}Gender;

// 滑动方向
typedef enum {
    forDirectionOriginal = 0,   // 初始
    forDirectionRight = 1,      // 向右,页面增加
    forDirectionLeft = -1,      // 向左,页面减少
}DirectionType;

typedef struct {
    double lat;
    double lng;
}Location;

Location LocationMake(double la, double ln);

#define kNotifyReceivedMessage      @"receivedMessage"
#define kNotifyReceiveNotify        @"receiveNotify"

#define kNotifyClearSession         @"clearSession"
#define kNotifyHasReadSession       @"hasReadSession"

#define kNotifyHasReadNotify        @"hasReadNotify"

#define kNotifyJoinGroup            @"joinGroup"
#define kNotifyQuitGroup            @"quitGroup"
#define kNotifyEditGroup            @"editGroup"

#define kNotifyAddGroupMember       @"addGroupMember"
#define kNotifyDeleteGroupMember    @"deleteGroupMember"

#define kNotifyAddFriend            @"addFriend"
#define kNotifyDeleteFriend         @"deleteFriend"

// 通知扩展
#define forNotifyType_FriendApply   forNotifyType_Extend + 1    // 申请加好友
#define forNotifyType_FriendAgree   forNotifyType_Extend + 2    // 同意加好友
#define forNotifyType_FriendRefuse  forNotifyType_Extend + 3    // 拒绝加好友
#define forNotifyType_FriendDelete  forNotifyType_Extend + 4    // 删除好友

#endif
