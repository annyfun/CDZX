//
//  TCGroup.h
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCBaseObject.h"

typedef enum {
    forTCGroupType_Temp,    // 临时会话
    forTCGroupType_Group,   // 群组
}TCGroupType;

@interface TCGroup : TCBaseObject

@property (nonatomic, strong) NSString*         ID;
@property (nonatomic, strong) NSString*         name;
@property (nonatomic, strong) NSString*         headImgUrlS;
@property (nonatomic, strong) NSString*         headImgUrlL;
@property (nonatomic, strong) NSString*         description;
@property (nonatomic, strong) NSString*         uid;
@property (nonatomic, strong) NSString*         creator;
@property (nonatomic, assign) int               count;
@property (nonatomic, assign) BOOL              isJoin;
@property (nonatomic, assign) BOOL              isAdmin;
@property (nonatomic, assign) BOOL              isGetMessage;
@property (nonatomic, assign) NSTimeInterval    timeCreate;

@property (nonatomic, assign) TCGroupType       type;

@property (nonatomic, strong) NSMutableArray*   memberIDs;

@property (nonatomic, strong) NSMutableArray*   userList;

@property (nonatomic, assign) BOOL              isLeave; // 是否主动离开

#pragma DB

+ (void)createTableIfNotExists;

+ (id)objectWithID:(NSString*)wID foreignKey:(NSString*)fKey;

- (void)insertDBWithForeignKey:(NSString*)fKey;
- (void)deleteFromDBWithForeignKey:(NSString*)fKey;

@end
