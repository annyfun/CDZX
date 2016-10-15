//
//  User.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "User.h"
#import "DBConnection.h"
#import "TCUser.h"

#define kThinkChatUserForeignKeyDefault @"_DefaultUserForeignKey"

#define kThinkChatUserInfoVersionKey    @"kThinkChatUserInfoVersionKey"
#define kThinkChatUserInfoVersionValue  @"1.0"

@implementation User

@synthesize ID;
@synthesize phone;
@synthesize passWord;
@synthesize sort;
@synthesize nickName;
@synthesize headImgUrlS;
@synthesize headImgUrlL;
@synthesize email;
@synthesize sign;
@synthesize gender;
@synthesize isFriend;
@synthesize timeCreate;

@synthesize genderString;

+ (id)objectWithTCUser:(TCUser *)tmpU {
    User* itemU = [[User alloc] init];
    
    itemU.ID = tmpU.ID;
    itemU.nickName = tmpU.name;
    itemU.headImgUrlS = tmpU.head;
    
    return itemU;
}

- (BOOL)isChangeUserInfo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* version = [defaults objectForKey:kThinkChatUserInfoVersionKey];
    if (version != nil && [version isEqualToString:kThinkChatUserInfoVersionValue]) {
        return NO;
    }
    return YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        if (![self isChangeUserInfo]) {
            self.ID = [aDecoder decodeObjectForKey:@"ID"];
            self.phone = [aDecoder decodeObjectForKey:@"phone"];
            self.passWord = [aDecoder decodeObjectForKey:@"passWord"];
            self.sort = [aDecoder decodeObjectForKey:@"sort"];
            self.nickName = [aDecoder decodeObjectForKey:@"nickName"];
            self.headImgUrlS = [aDecoder decodeObjectForKey:@"headImgUrlS"];
            self.headImgUrlL = [aDecoder decodeObjectForKey:@"headImgUrlL"];
            self.email = [aDecoder decodeObjectForKey:@"email"];
            self.sign = [aDecoder decodeObjectForKey:@"sign"];
            self.gender = [aDecoder decodeIntForKey:@"gender"];
            self.isFriend = [aDecoder decodeBoolForKey:@"isFriend"];
            self.timeCreate = [aDecoder decodeDoubleForKey:@"timeCreate"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:kThinkChatUserInfoVersionValue forKey:kThinkChatUserInfoVersionKey];
	[defaults synchronize];
    
    [aCoder encodeObject:ID forKey:@"ID"];
    [aCoder encodeObject:phone forKey:@"phone"];
    [aCoder encodeObject:passWord forKey:@"passWord"];
    [aCoder encodeObject:sort forKey:@"sort"];
    [aCoder encodeObject:nickName forKey:@"nickName"];
    [aCoder encodeObject:headImgUrlS forKey:@"headImgUrlS"];
    [aCoder encodeObject:headImgUrlL forKey:@"headImgUrlL"];
    [aCoder encodeObject:email forKey:@"email"];
    [aCoder encodeObject:sign forKey:@"sign"];
    [aCoder encodeInt:gender forKey:@"gender"];
    [aCoder encodeBool:isFriend forKey:@"isFriend"];
    [aCoder encodeDouble:timeCreate forKey:@"timeCreate"];
}

- (void)updateWithJsonDic:(NSDictionary *)dic {
    [super updateWithJsonDic:dic];
    if (isInitSuccuss) {
        self.ID = [dic getStringValueForKey:@"id" defaultValue:nil];
        self.type = [dic getStringValueForKey:@"type" defaultValue:nil];
        self.phone = [dic getStringValueForKey:@"phone" defaultValue:nil];
        self.nickName = [dic getStringValueForKey:@"nickname" defaultValue:nil];
        self.sex = [dic getStringValueForKey:@"sex" defaultValue:nil];
        self.company = [dic getStringValueForKey:@"company" defaultValue:nil];
        self.position = [dic getStringValueForKey:@"position" defaultValue:nil];
        self.city = [dic getStringValueForKey:@"city" defaultValue:nil];
        self.money = [dic getStringValueForKey:@"money" defaultValue:nil];
        self.active = [dic getStringValueForKey:@"active" defaultValue:nil];
        self.sign = [dic getStringValueForKey:@"sign" defaultValue:nil];
        self.sort = [dic getStringValueForKey:@"sort" defaultValue:nil];
        self.headImgUrlS = [dic getStringValueForKey:@"headsmall" defaultValue:nil];
        self.headImgUrlL = [dic getStringValueForKey:@"headlarge" defaultValue:nil];
        self.province = [dic getStringValueForKey:@"province" defaultValue:nil];
        self.forbidden = [dic getBoolValueForKey:@"forbidden" defaultValue:NO];
        self.uid = [dic getStringValueForKey:@"uid" defaultValue:nil];
        self.gid = [dic getStringValueForKey:@"gid" defaultValue:nil];
        self.sgid = [dic getStringValueForKey:@"sgid" defaultValue:nil];
        self.isFriend = [dic getIntValueForKey:@"isfriend" defaultValue:0] == 1;
        self.passWord = [dic getStringValueForKey:@"pw" defaultValue:nil];
        self.createtime = [dic getStringValueForKey:@"createtime" defaultValue:nil];
        
        self.timeCreate = [dic getDoubleValueForKey:@"createtime" defaultValue:0.0];
        self.email = [dic getStringValueForKey:@"email" defaultValue:nil];
        self.gender = [dic getIntValueForKey:@"gender" defaultValue:genderNo];
        
        if (sign == nil || sign.length == 0) {
            self.sign = @"这家伙很懒,什么也没留下";
        }
    }
}

- (NSString*)genderString {
    if (genderString == nil) {
        if (gender == male) {
            genderString = @"男";
        } else if (gender == female) {
            genderString = @"女";
        } else if (gender == genderNo) {
            genderString = @"保密";
        }
    }
    return genderString;
}

#pragma mark - DB

+ (void)createTableIfNotExists {
	Statement *stmt = [DBConnection statementWithQuery:"CREATE TABLE IF NOT EXISTS tb_user (ID, phone, passWord, sort, nickName, headImgUrlS, headImgUrlL, email, sign, gender, isFriend, timeCreate, foreignKey, currentUser, primary key(ID, foreignKey, currentUser))"];
    int step = [stmt step];
	if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

+ (id)objectWithID:(NSString *)wID foreignKey:(NSString *)fKey {
    
    if (fKey == nil) {
        fKey = kThinkChatUserForeignKeyDefault;
    }
    
    User* result = nil;
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"SELECT * FROM tb_user WHERE ID = ? and foreignKey = ? and currentUser = ?"];
    }
    
    int i = 1;
    [stmt bindString:wID forIndex:i++];
    [stmt bindString:fKey forIndex:i++];
    [stmt bindString:[BaseEngine currentBaseEngine].user.ID forIndex:i++];
    
    int ret = [stmt step];
    if (ret == SQLITE_ROW) {
        result = [[User alloc] initWithStatement:stmt];
    }
    [stmt reset];
    
    return result;
}

- (id)initWithStatement:(Statement *)stmt {
	if (self = [super init]) {
        int i = 0;
        self.ID = [stmt getString:i++];
        self.phone = [stmt getString:i++];
        self.passWord = [stmt getString:i++];
        self.sort = [stmt getString:i++];
        self.nickName = [stmt getString:i++];
        self.headImgUrlS = [stmt getString:i++];
        self.headImgUrlL = [stmt getString:i++];
        self.email = [stmt getString:i++];
        self.sign = [stmt getString:i++];
        self.gender = [stmt getInt32:i++];
        self.isFriend = [stmt getInt32:i++] == 1;
        self.timeCreate = [stmt getDouble:i++];
    }
	return self;
}

- (void)insertDBWithForeignKey:(NSString *)fKey {
    
    if (fKey == nil) {
        fKey = kThinkChatUserForeignKeyDefault;
    }
    
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"REPLACE INTO tb_user VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"];
    }
    
    int i = 1;
    [stmt bindString:ID forIndex:i++];
    [stmt bindString:phone forIndex:i++];
    [stmt bindString:passWord forIndex:i++];
    [stmt bindString:sort forIndex:i++];
    [stmt bindString:nickName forIndex:i++];
    [stmt bindString:headImgUrlS forIndex:i++];
    [stmt bindString:headImgUrlL forIndex:i++];
    [stmt bindString:email forIndex:i++];
    [stmt bindString:sign forIndex:i++];
    [stmt bindInt32: gender forIndex:i++];
    [stmt bindInt32: isFriend?1:0 forIndex:i++];
    [stmt bindDouble:timeCreate forIndex:i++];
    [stmt bindString:fKey forIndex:i++];
    [stmt bindString:[BaseEngine currentBaseEngine].user.ID	forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

- (void)deleteFromDBWithForeignKey:(NSString *)fKey {
    
    if (fKey == nil) {
        fKey = kThinkChatUserForeignKeyDefault;
    }
    
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"delete from tb_user where ID = ? and foreignKey = ? and currentUser = ?"];
    }
    
    int i = 1;
    [stmt bindString:ID	forIndex:i++];
    [stmt bindString:fKey forIndex:i++];
    [stmt bindString:[BaseEngine currentBaseEngine].user.ID	forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

@end
