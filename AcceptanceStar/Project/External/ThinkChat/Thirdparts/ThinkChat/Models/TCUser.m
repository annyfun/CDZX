//
//  TCUser.m
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCUser.h"
#import "TCEngine.h"
#import "TCDBConnection.h"

@implementation TCUser

@synthesize ID;
@synthesize name;
@synthesize head;
@synthesize headsmall;
@synthesize sign;

#define kThinkChatUserForeignKeyDefault @"_DefaultUserForeignKey"

#define kThinkChatUserInfoVersionKey    @"kThinkChatUserInfoVersionKey"
#define kThinkChatUserInfoVersionValue  @"1.1"

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
            self.name = [aDecoder decodeObjectForKey:@"name"];
            self.head = [aDecoder decodeObjectForKey:@"head"];
            self.headsmall = [aDecoder decodeObjectForKey:@"headsmall"];
            self.sign = [aDecoder decodeObjectForKey:@"sign"];
            [self updateExtendWithString:[aDecoder decodeObjectForKey:@"extend"]];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:kThinkChatUserInfoVersionValue forKey:kThinkChatUserInfoVersionKey];
	[defaults synchronize];
    
    [aCoder encodeObject:ID forKey:@"ID"];
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:head forKey:@"head"];
    [aCoder encodeObject:headsmall forKey:@"headsmall"];
    [aCoder encodeObject:sign forKey:@"sign"];
    [aCoder encodeObject:[self getExtendJsonString] forKey:@"extend"];
}

- (void)dealloc {
    self.ID = nil;
    self.name = nil;
    self.head = nil;
}

- (void)updateWithJsonDic:(NSDictionary *)dic {
    [super updateWithJsonDic:dic];
    if (isInitSuccuss) {
        self.ID = [dic getStringValueForKey:@"uid" defaultValue:nil];
        self.name = [dic getStringValueForKey:@"name" defaultValue:nil];
        self.head = [dic getStringValueForKey:@"head" defaultValue:nil];
        self.headsmall = [dic getStringValueForKey:@"headsmall" defaultValue:nil];
        self.sign = [dic getStringValueForKey:@"sign" defaultValue:nil];
        [self updateExtendWithDic:[dic getDictionaryForKey:@"extend" defaultValue:nil]];
    }
}


#pragma mark - DB

+ (void)createTableIfNotExists {
	TCStatement *stmt = [TCDBConnection statementWithQuery:"CREATE TABLE IF NOT EXISTS tb_tc_user (ID, name, head, extend, foreignKey, currentUser, primary key(ID, foreignKey, currentUser))"];
    int step = [stmt step];
	if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}

+ (id)objectWithID:(NSString *)wID foreignKey:(NSString *)fKey {
    
    if (fKey == nil) {
        fKey = kThinkChatUserForeignKeyDefault;
    }
    
    TCUser* result = nil;
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"SELECT * FROM tb_tc_user WHERE ID = ? and foreignKey = ? and currentUser = ?"];
    }
    
    int i = 1;
    [stmt bindString:wID forIndex:i++];
    [stmt bindString:fKey forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    
    int ret = [stmt step];
    if (ret == SQLITE_ROW) {
        result = [[TCUser alloc] initWithStatement:stmt];
    }
    [stmt reset];
    
    return result;
}

- (id)initWithStatement:(TCStatement *)stmt {
	if (self = [super init]) {
        int i = 0;
        self.ID = [stmt getString:i++];
        self.name = [stmt getString:i++];
        self.head = [stmt getString:i++];
        [self updateExtendWithString:[stmt getString:i++]];
    }
	return self;
}

- (void)insertDBWithForeignKey:(NSString *)fKey {
    
    if (fKey == nil) {
        fKey = kThinkChatUserForeignKeyDefault;
    }

    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"REPLACE INTO tb_tc_user VALUES(?, ?, ?, ?, ?, ?)"];
    }
    
    int i = 1;
    [stmt bindString:ID forIndex:i++];
    [stmt bindString:name forIndex:i++];
    [stmt bindString:head forIndex:i++];
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
        fKey = kThinkChatUserForeignKeyDefault;
    }

    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"delete from tb_tc_user where ID = ? and foreignKey = ? and currentUser = ?"];
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
