//
//  User.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "BaseObject.h"

@class TCUser;

@interface User : BaseObject

@property (nonatomic, strong) NSString*         ID;
@property (nonatomic, strong) NSString*         type;
@property (nonatomic, strong) NSString*         phone;
@property (nonatomic, strong) NSString*         nickName;
@property (nonatomic, strong) NSString*         sex;
@property (nonatomic, strong) NSString*         age;
@property (nonatomic, strong) NSString*         company;
@property (nonatomic, strong) NSString*         position;
@property (nonatomic, strong) NSString*         city;
@property (nonatomic, strong) NSString*         money;
@property (nonatomic, strong) NSString*         active;
@property (nonatomic, strong) NSString*         sign;
@property (nonatomic, strong) NSString*         sort;
@property (nonatomic, strong) NSString*         headImgUrlS;
@property (nonatomic, strong) NSString*         headImgUrlL;
@property (nonatomic, strong) NSString*         province;
@property (nonatomic, assign) BOOL              forbidden;
@property (nonatomic, strong) NSString*         uid;
@property (nonatomic, strong) NSString*         gid;
@property (nonatomic, strong) NSString*         sgid;
@property (nonatomic, assign) BOOL              isFriend;
@property (nonatomic, strong) NSString*         passWord;
@property (nonatomic, strong) NSString*         createtime;//yyyy-MM-dd HH:mm:ss

@property (nonatomic, assign) NSTimeInterval    timeCreate;
@property (nonatomic, strong) NSString*         email;
@property (nonatomic, assign) Gender            gender;

@property (nonatomic, readonly) NSString*       genderString;

+ (id)objectWithTCUser:(TCUser*)item;

#pragma DB

+ (void)createTableIfNotExists;

+ (id)objectWithID:(NSString*)wID foreignKey:(NSString*)fKey;

- (void)insertDBWithForeignKey:(NSString*)fKey;
- (void)deleteFromDBWithForeignKey:(NSString*)fKey;

@end
