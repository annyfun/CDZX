//
//  TCSession.m
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCSession.h"
#import "TCDBConnection.h"
#import "TCEngine.h"
#import "TCMessage.h"
#import "TCUser.h"
#import "TCGroup.h"

@implementation TCSession

@synthesize ID;
@synthesize typeChat;

@synthesize name;
@synthesize head;
@synthesize content;
@synthesize time;
@synthesize unreadCount;

@synthesize message;
@synthesize user;
@synthesize group;

+ (id)sessionWithMessage:(TCMessage *)item {
    TCSession* session = [TCSession getSessionFromDBWithID:item.withID typeChat:item.typeChat];
    if (session == nil) {
        session = [[TCSession alloc] init];
    }
    
    session.message = item;
    
    session.ID = item.withID;
    session.time = item.time;
    if (!item.isRead) {
        session.unreadCount += 1;
    }
    session.typeChat = item.typeChat;
    session.content = item.contentFormat;
    
    if (session.typeChat == forChatTypeUser) {
        if (item.isSendByMe) {
            session.name = item.to.name;
            session.head = item.to.head;
            [session copyExtendFrom:item.to];
        } else {
            session.name = item.from.name;
            session.head = item.from.head;
            [session copyExtendFrom:item.from];
        }
    } else {
        session.name = item.to.name;
        session.head = item.to.head;
        [session copyExtendFrom:item.to];
    }
    
    return session;
}

+ (id)sessionWithUser:(TCUser *)item {
    TCSession* session = [[TCSession alloc] init];
    
    session.user = item;
    
    session.ID = item.ID;
    session.name = item.name;
    session.head = item.head;
    [session copyExtendFrom:item];
    
    session.typeChat = forChatTypeUser;
    
    return session;
}

+ (id)sessionWithGroup:(TCGroup *)item {
    TCSession* session = [[TCSession alloc] init];
    
    session.group = item;
    
    session.ID = item.ID;
    session.name = item.name;
    session.head = item.headImgUrlS;
    session.time = item.timeCreate;
    if (item.type == forTCGroupType_Group) {
        session.typeChat = forChatTypeGroup;
    } else if (item.type == forTCGroupType_Temp) {
        session.typeChat = forChatTypeRoom;
    }
    [session copyExtendFrom:item];

    return session;
}


+ (void)updateWithMessage:(TCMessage *)item {
    [item insertDBWithForeignKey:nil];
    TCSession* itemS = [TCSession sessionWithMessage:item];
    [itemS insertDB];
}

- (void)dealloc {
    self.ID = nil;
    self.name = nil;
    self.head = nil;
    self.content = nil;
    self.message = nil;
    self.user = nil;
    self.group = nil;
}

- (void)updateWithMessage:(TCMessage*)msg {
    if ([ID isEqualToString:msg.withID] && typeChat == msg.typeChat) {
        self.message = msg;
        
        self.time = msg.time;
        if (!msg.isRead) {
            self.unreadCount = unreadCount + 1;
        }
        if (typeChat == forChatTypeUser) {
            if (msg.isSendByMe) {
                self.name = msg.to.name;
                self.head = msg.to.head;
                [self copyExtendFrom:msg.to];
            } else {
                self.name = msg.from.name;
                self.head = msg.from.head;
                [self copyExtendFrom:msg.from];
            }
        } else {
            self.name = msg.to.name;
            self.head = msg.to.head;
            [self copyExtendFrom:msg.to];
        }
    }
}

- (TCUser*)user {
    if (user == nil && typeChat == forChatTypeUser) {
        self.user = [[TCUser alloc] init];
        user.ID = ID;
        user.name = name;
        user.head = head;
        [user copyExtendFrom:self];
    }
    return user;
}

- (TCGroup*)group {
    if (group == nil && (typeChat == forChatTypeGroup || typeChat == forChatTypeRoom)) {
        self.group = [[TCGroup alloc] init];
        group.ID = ID;
        group.name = name;
        group.headImgUrlS = head;
        
        if (typeChat == forChatTypeGroup) {
            group.type = forTCGroupType_Group;
        } else if (typeChat == forChatTypeRoom) {
            group.type = forTCGroupType_Temp;
        }
        
        [group copyExtendFrom:self];
    }
    return group;
}

#pragma DB

+ (void)createTableIfNotExists
{
	TCStatement *stmt = [TCDBConnection statementWithQuery:"CREATE TABLE IF NOT EXISTS tb_tc_session (ID, typeChat, extend, name, head, content, time, unreadCount, currentUser, primary key(ID, typeChat, currentUser))"];
    int step = [stmt step];
	if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}

+ (TCSession*)getSessionFromDBWithID:(NSString*)wID typeChat:(ChatType)typeChat {
    TCSession* result = nil;
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"SELECT * FROM tb_tc_session WHERE ID = ? and typeChat = ? and currentUser = ?"];
    }
    
    int i = 1;
    [stmt bindString:wID forIndex:i++];
    [stmt bindInt32:typeChat forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    
    int ret = [stmt step];
    if (ret == SQLITE_ROW) {
        result = [[TCSession alloc] initWithStatement:stmt];
    }
    [stmt reset];
    
    return result;
}

+ (NSArray*)getSessionListTimeLine
{
    NSMutableArray* list = [NSMutableArray array];
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"SELECT * FROM tb_tc_session WHERE currentUser = ? order by time desc"];
    }
    
    int i = 1;
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    
    int ret = [stmt step];
    
    while (ret == SQLITE_ROW) {
        TCSession * item = [[TCSession alloc] initWithStatement:stmt];
        if (item) {
            [list addObject:item];
        }
        ret = [stmt step];
    }
    
    [stmt reset];
	return list;
}

- (id)initWithStatement:(TCStatement *)stmt {
	if (self = [super init]) {
        int i = 0;
        self.ID             = [stmt getString:i++];
        self.typeChat       = [stmt getInt32:i++];
        [self updateExtendWithString:[stmt getString:i++]];
        self.name           = [stmt getString:i++];
        self.head           = [stmt getString:i++];
        self.content        = [stmt getString:i++];
        self.time           = [stmt getDouble:i++];
        self.unreadCount    = [stmt getInt32:i++];
	}
	return self;
}

- (void)insertDB
{
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"REPLACE INTO tb_tc_session VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)"];
    }
    int i = 1;
    
    [stmt bindString:ID             forIndex:i++];
    [stmt bindInt32: typeChat       forIndex:i++];
    [stmt bindString:[self getExtendJsonString] forIndex:i++];
    [stmt bindString:name           forIndex:i++];
    [stmt bindString:head           forIndex:i++];
    [stmt bindString:content        forIndex:i++];
    [stmt bindDouble:time           forIndex:i++];
    [stmt bindInt32: unreadCount    forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID	forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}

+ (int)getUnReadMessageCount {
    int unRead = 0;
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"SELECT sum(unreadCount) FROM tb_tc_session WHERE currentUser = ?"];
    }
    
    int i = 1;
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    
    int ret = [stmt step];
    
    if (ret == SQLITE_ROW) {
        unRead = [stmt getInt32:0];
    }
    [stmt reset];
    
    return unRead;
}

+ (void)clearSessionID:(NSString *)sid typeChat:(ChatType)typeChat {
    [TCMessage cleanMessageWithID:sid typeChat:typeChat];
    
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"delete from tb_tc_session where ID = ? and typeChat = ? and currentUser = ?"];
    }
    int i = 1;
    [stmt bindString:sid                                forIndex:i++];
    [stmt bindInt32: typeChat                               forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID	forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}

+ (void)hasReadSessionID:(NSString *)sid typeChat:(ChatType)typeChat {
    [TCMessage hasReadMessageWithID:sid typeChat:typeChat];

    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"update tb_tc_session set unreadCount = 0 WHERE ID = ? and typeChat = ? and currentUser = ?"];
    }
    
    int i = 1;
    [stmt bindString:sid forIndex:i++];
    [stmt bindInt32:typeChat forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}

+ (TCSession*)sessionWithID:(NSString *)sid typeChat:(ChatType)typeChat {
    TCSession* result = [TCSession getSessionFromDBWithID:sid typeChat:typeChat];
    
    if (result == nil) {
        result = [[TCSession alloc] init];
        result.ID = sid;
        result.typeChat = typeChat;
    }
    
    return result;
}

@end
