//
//  TCGroup.m
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCGroup.h"
#import "TCEngine.h"
#import "TCDBConnection.h"
#import "TCUser.h"

#define kThinkChatGroupForeignKeyDefault @"_DefaultGroupForeignKey"

@implementation TCGroup

@synthesize ID;
@synthesize name;
@synthesize headImgUrlS;
@synthesize headImgUrlL;
@synthesize description;
@synthesize uid;
@synthesize creator;
@synthesize count;
@synthesize isJoin;
@synthesize isAdmin;
@synthesize isGetMessage;
@synthesize timeCreate;
@synthesize type;
@synthesize memberIDs;
@synthesize userList;

- (void)dealloc {
    self.ID = nil;
    self.name = nil;
    self.headImgUrlS = nil;
    self.headImgUrlL = nil;
    self.description = nil;
    self.creator = nil;
    self.memberIDs = nil;
    self.userList = nil;
}

- (void)updateWithJsonDic:(NSDictionary *)dic {
    [super updateWithJsonDic:dic];
    if (isInitSuccuss) {
        self.ID = [dic getStringValueForKey:@"id" defaultValue:nil];
        self.name = [dic getStringValueForKey:@"name" defaultValue:nil];
        self.headImgUrlS = [dic getStringValueForKey:@"logosmall" defaultValue:nil];
        self.headImgUrlL = [dic getStringValueForKey:@"logolarge" defaultValue:nil];
        self.description = [dic getStringValueForKey:@"description" defaultValue:nil];
        self.uid = [dic getStringValueForKey:@"uid" defaultValue:nil];
        self.creator = [dic getStringValueForKey:@"creator" defaultValue:nil];
        
        self.count = [dic getIntValueForKey:@"count" defaultValue:0];
        self.isJoin = [dic getIntValueForKey:@"isjoin" defaultValue:0] == 1;
        self.isAdmin = [dic getIntValueForKey:@"role" defaultValue:0] == 1;
        self.isGetMessage = [dic getIntValueForKey:@"getmsg" defaultValue:0] == 1;
        
        self.timeCreate = [dic getDoubleValueForKey:@"createtime" defaultValue:0.0];
        
        [self updateExtendWithDic:[dic getDictionaryForKey:@"extend" defaultValue:nil]];

        if (memberIDs == nil) {
            self.memberIDs = [NSMutableArray array];
        }
        NSString* strIDs = [dic getStringValueForKey:@"uids" defaultValue:nil];
        [memberIDs addObjectsFromArray:[strIDs componentsSeparatedByString:@","]];
        
        if (userList == nil) {
            self.userList = [NSMutableArray array];
        }
        NSArray* tmpList = [dic getArrayForKey:@"list" defaultValue:nil];
        if (tmpList != nil) {
            for (NSDictionary* dicU in tmpList) {
                TCUser* itemU = [TCUser objWithJsonDic:dicU];
                if (itemU) {
                    [userList addObject:itemU];
                }
            }
        }
        
        if (headImgUrlS == nil || headImgUrlS.length == 0) {
            NSMutableArray* tmpHeadArr = [NSMutableArray array];
            for (int i = 0; i < 4 && i < userList.count; i++) {
                TCUser* itemU = [userList objectAtIndex:i];
                [tmpHeadArr addObject:itemU.head];
            }
            self.headImgUrlS = [tmpHeadArr componentsJoinedByString:@","];
        }
    }
}

#pragma mark - DB

+ (void)createTableIfNotExists {
	TCStatement *stmt = [TCDBConnection statementWithQuery:"CREATE TABLE IF NOT EXISTS tb_tc_group (ID, name, headImgUrlS, headImgUrlL, description, uid, creator, count, isJoin, isAdmin, isGetMessage, timeCreate, extend, foreignKey, currentUser, primary key(ID, foreignKey, currentUser))"];
    int step = [stmt step];
	if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}

+ (id)objectWithID:(NSString *)wID foreignKey:(NSString *)fKey {
    
    if (fKey == nil) {
        fKey = kThinkChatGroupForeignKeyDefault;
    }
    
    TCGroup* result = nil;
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"SELECT * FROM tb_tc_group WHERE ID = ? and foreignKey = ? and currentUser = ?"];
    }
    
    int i = 1;
    [stmt bindString:wID forIndex:i++];
    [stmt bindString:fKey forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    
    int ret = [stmt step];
    if (ret == SQLITE_ROW) {
        result = [[TCGroup alloc] initWithStatement:stmt];
    }
    [stmt reset];
    
    return result;
}

- (id)initWithStatement:(TCStatement *)stmt {
	if (self = [super init]) {
        int i = 0;
        self.ID = [stmt getString:i++];
        self.name = [stmt getString:i++];
        self.headImgUrlS = [stmt getString:i++];
        self.headImgUrlL = [stmt getString:i++];
        self.description = [stmt getString:i++];
        self.uid = [stmt getString:i++];
        self.creator = [stmt getString:i++];
        self.count = [stmt getInt32:i++];
        self.isJoin = [stmt getInt32:i++] == 1;
        self.isAdmin = [stmt getInt32:i++] == 1;
        self.isGetMessage = [stmt getInt32:i++] == 1;
        self.timeCreate = [stmt getDouble:i++];
        [self updateExtendWithString:[stmt getString:i++]];
    }
	return self;
}

- (void)insertDBWithForeignKey:(NSString *)fKey {
    
    if (fKey == nil) {
        fKey = kThinkChatGroupForeignKeyDefault;
    }
    
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"REPLACE INTO tb_tc_group VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"];
    }
    
    int i = 1;
    [stmt bindString:ID forIndex:i++];
    [stmt bindString:name forIndex:i++];
    [stmt bindString:headImgUrlS forIndex:i++];
    [stmt bindString:headImgUrlL forIndex:i++];
    [stmt bindString:description forIndex:i++];
    [stmt bindString:uid forIndex:i++];
    [stmt bindString:creator forIndex:i++];
    [stmt bindInt32: count forIndex:i++];
    [stmt bindInt32: isJoin?1:0 forIndex:i++];
    [stmt bindInt32: isAdmin?1:0 forIndex:i++];
    [stmt bindInt32: isGetMessage?1:0 forIndex:i++];
    [stmt bindDouble:timeCreate forIndex:i++];
    [stmt bindString:[self getExtendJsonString] forIndex:i++];
    [stmt bindString:fKey forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID	forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}

- (void)deleteFromDBWithForeignKey:(NSString *)fKey {
    
    if (fKey == nil) {
        fKey = kThinkChatGroupForeignKeyDefault;
    }
    
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"delete from tb_tc_group where ID = ? and foreignKey = ? and currentUser = ?"];
    }
    
    int i = 1;
    [stmt bindString:ID	forIndex:i++];
    [stmt bindString:fKey forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID	forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}

@end
