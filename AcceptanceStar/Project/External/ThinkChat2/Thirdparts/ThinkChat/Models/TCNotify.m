//
//  TCNotify.m
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCNotify.h"
#import "TCDBConnection.h"
#import "TCEngine.h"
#import "TCUser.h"
#import "TCGroup.h"
#import "TCMessage.h"
#import "TCSession.h"
#import "TCNSStringAdditions.h"

@implementation TCNotify

@synthesize ID;
@synthesize type;
@synthesize content;
@synthesize time;
@synthesize user;
@synthesize message;
@synthesize group;
@synthesize isRead;
@synthesize isDone;

- (void)dealloc {
    self.ID = nil;
    self.content = nil;
    self.user = nil;
    self.message = nil;
    self.group = nil;
}

- (void)updateWithJsonDic:(NSDictionary*)dic {
    [super updateWithJsonDic:dic];
    if (isInitSuccuss) {
        
        self.type = [dic getIntValueForKey:@"type" defaultValue:0];
        self.content = [dic getStringValueForKey:@"content" defaultValue:nil];
        self.time = [dic getDoubleValueForKey:@"time" defaultValue:0.0];
        [self updateExtendWithDic:[dic getDictionaryForKey:@"extend" defaultValue:nil]];

        NSDictionary* dicU = [dic objectForKey:@"user"];
        if (dicU != nil && [dicU isKindOfClass:[NSDictionary class]]) {
            if (user) {
                [user updateWithJsonDic:dicU];
            } else {
                self.user = [TCUser objWithJsonDic:dicU];
            }
        }
        NSDictionary* dicR = [dic objectForKey:@"room"];
        if (dicR != nil && [dicR isKindOfClass:[NSDictionary class]]) {
            if (group) {
                [group updateWithJsonDic:dicR];
            } else {
                self.group = [TCGroup objWithJsonDic:dicR];
            }
        }
        NSDictionary* dicM = [dic objectForKey:@"message"];
        if (dicM != nil && [dicM isKindOfClass:[NSDictionary class]]) {
            if (message) {
                [message updateWithJsonDic:dicM];
            } else {
                self.message = [TCMessage objWithJsonDic:dicM];
            }
        }
        if (ID == nil) {
            self.ID = [NSString GUIDString];
        }
    }
}

- (BOOL)dealNotify {
    // 处理通知
    
    TCSession* itemS = nil;
    
    BOOL result = YES;
    switch (type) {
        case forNotifyType_System:
            // 1   系统通知
            
            break;
        case forNotifyType_ConversationQuit:
            // 300 用户退出 会话
            group.type = forTCGroupType_Temp;
            
            break;
        case forNotifyType_ConversationRemove:
            // 301 管理员删除 会话用户
            group.type = forTCGroupType_Temp;
            
            break;
        case forNotifyType_ConversationEdit:
            // 302 管理员编辑 会话名称
            group.type = forTCGroupType_Temp;
            itemS = [TCSession getSessionFromDBWithID:group.ID typeChat:forChatTypeRoom];
            if (itemS) {
                itemS.name = group.name;
                [itemS insertDB];
            }
            
            break;
        case forNotifyType_ConversationDele:
            // 303 管理员删除 会话
            group.type = forTCGroupType_Temp;
            [TCSession clearSessionID:group.ID typeChat:forChatTypeRoom];
            
            break;
        case forNotifyType_ConversationKick:
            // 304 自己被踢出 会话
            group.type = forTCGroupType_Temp;
            [TCSession clearSessionID:group.ID typeChat:forChatTypeRoom];
            
            break;
        case forNotifyType_GroupJoinApply:
            // 202 申请加 群
            group.type = forTCGroupType_Group;
            
            break;
        case forNotifyType_GroupJoinAgree:
            // 203 同意申请入 群
            group.type = forTCGroupType_Group;

            break;
        case forNotifyType_GroupJoinRefuse:
            // 204 不同意申请入 群
            group.type = forTCGroupType_Group;

            break;
        case forNotifyType_GroupInviteApply:
            // 205 邀请入 群
            group.type = forTCGroupType_Group;

            break;
        case forNotifyType_GroupInviteAgree:
            // 206 同意邀请入 群
            group.type = forTCGroupType_Group;

            break;
        case forNotifyType_GroupInviteRefuse:
            // 207 不同意邀请入 群
            group.type = forTCGroupType_Group;

            break;
        case forNotifyType_GroupKick:
            // 208 自己被踢出 群
            group.type = forTCGroupType_Group;
            [TCSession clearSessionID:group.ID typeChat:forChatTypeGroup];
            
            break;
        case forNotifyType_GroupQuit:
            // 209 成员退出 群
            group.type = forTCGroupType_Group;

            break;
        case forNotifyType_GroupDele:
            // 210 管理员删除 群
            group.type = forTCGroupType_Group;
            [TCSession clearSessionID:group.ID typeChat:forChatTypeGroup];

            break;
        case forNotifyType_GroupRemove:
            // 211 管理员删除 群成员
            group.type = forTCGroupType_Group;

            break;
        default:
            // 扩展通知
            
            break;
    }
    
    [self insertDB];

    return result;
}

#pragma DB

+ (void)createTableIfNotExists
{
    // NSLogFunc
	TCStatement *stmt = [TCDBConnection statementWithQuery:"CREATE TABLE IF NOT EXISTS tb_tc_notify (ID, type, content, time, user, message, room, isRead, isDone, extend, currentUser, primary key(ID, type, currentUser))"];
    int step = [stmt step];
	if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}

+ (TCNotify*)getLatestNotify {
    TCNotify* result = nil;
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"SELECT * FROM tb_tc_notify WHERE currentUser = ? order by time desc limit 0,1"];
    }
    
    int i = 1;
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    
    int ret = [stmt step];
    if (ret == SQLITE_ROW) {
        result = [[TCNotify alloc] initWithStatement:stmt];
    }
    [stmt reset];
    
    return result;
}

+ (NSArray*)getNotifyListTimeLineWithFinalNotify:(TCNotify *)itemN {
    if (itemN == nil) {
        return [self getNotifyListTimeLine];
    } else {
        NSMutableArray* list = [NSMutableArray array];
        static TCStatement *stmt = nil;
        if (stmt == nil) {
            stmt = [TCDBConnection statementWithQuery:"SELECT * FROM tb_tc_notify WHERE content <> '' and content not null and currentUser = ? and time < ? order by time desc limit 0,?"];
        }
        
        int i = 1;
        [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
        [stmt bindDouble:itemN.time forIndex:i++];
        [stmt bindInt32:defaultSizeInt forIndex:i++];
        
        int ret = [stmt step];
        
        while (ret == SQLITE_ROW) {
            TCNotify* item = [[TCNotify alloc] initWithStatement:stmt];
            if (item) {
                [list addObject:item];
            }
            ret = [stmt step];
        }
        
        [stmt reset];
        return list;
    }
}

+ (NSArray*)getNotifyListTimeLine {
    NSMutableArray* list = [NSMutableArray array];
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"SELECT * FROM tb_tc_notify WHERE content <> '' and content not null and currentUser = ? order by time desc limit 0,?"];
    }
    
    int i = 1;
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    [stmt bindInt32:defaultSizeInt forIndex:i++];
    
    int ret = [stmt step];
    
    while (ret == SQLITE_ROW) {
        TCNotify* item = [[TCNotify alloc] initWithStatement:stmt];
        if (item) {
            [list addObject:item];
        }
        ret = [stmt step];
    }
    
    [stmt reset];
	return list;
}

+ (int)getUnReadCount {
    int count = 0;
    
    // 统计未读数
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"SELECT count(ID) FROM tb_tc_notify WHERE content <> '' and content not null and isRead = 0 and currentUser = ?"];
    }
    
    int i = 1;
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    
    int ret = [stmt step];
    
    if (ret == SQLITE_ROW) {
        count = [stmt getInt32:0];
    }
    [stmt reset];
    
    return count;
}

// 设置通知为已读
+ (void)hasReadNotify:(TCNotify*)itemN {
    [itemN hasRead];
}

- (void)hasRead {
    self.isRead = YES;
    
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"UPDATE tb_tc_notify set isRead = 1 where ID = ? and type = ? and currentUser = ?"];
    }
    
    int i = 1;
    [stmt bindString:ID forIndex:i++];
    [stmt bindInt32:type forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}

// 设置通知为已处理
+ (void)hasDoneNotify:(TCNotify*)itemN {
    [itemN hasDone];
}

- (void)hasDone {
    self.isDone = YES;
    
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"UPDATE tb_tc_notify set isDone = 1 where ID = ? and type = ? and currentUser = ?"];
    }
    
    int i = 1;
    [stmt bindString:ID forIndex:i++];
    [stmt bindInt32:type forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}

// 删除通知
+ (void)hasDeleteNotify:(TCNotify*)itemN {
    [itemN hasDelete];
}

- (void)hasDelete {
    [self deleteFromDB];
}

// 更新通知内容
+ (void)hasUpdateNotify:(TCNotify *)itemN newContent:(NSString *)newContent {
    [itemN hasUpdateNewContent:newContent];
}

- (void)hasUpdateNewContent:(NSString *)newContent {
    self.content = newContent;
    
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"UPDATE tb_tc_notify set content = ? where ID = ? and type = ? and currentUser = ?"];
    }
    
    int i = 1;
    [stmt bindString:content forIndex:i++];
    [stmt bindString:ID forIndex:i++];
    [stmt bindInt32:type forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}


- (NSString*)foreignKey {
    return [NSString stringWithFormat:@"TCNotifyFK_%@",ID];
}

- (id)initWithStatement:(TCStatement *)stmt {
    // NSLogFunc
	if (self = [super init]) {
        NSString* strUser = nil;
        NSString* strMessage = nil;
        NSString* strRoom = nil;
        
        int i = 0;
        self.ID = [stmt getString:i++];
        self.type = [stmt getInt32:i++];
        self.content = [stmt getString:i++];
        self.time = [stmt getDouble:i++];
        
        strUser = [stmt getString:i++];
        strMessage = [stmt getString:i++];
        strRoom = [stmt getString:i++];
        
        self.isRead = [stmt getInt32:i++] == 1;
        self.isDone = [stmt getInt32:i++] == 1;
        [self updateExtendWithString:[stmt getString:i++]];
        
        if (strUser) {
            self.user = [TCUser objectWithID:strUser foreignKey:[self foreignKey]];
        }
        if (strMessage) {
            self.message = [TCMessage objectWithID:strMessage foreignKey:[self foreignKey]];
        }
        if (strRoom) {
            self.group = [TCGroup objectWithID:strRoom foreignKey:[self foreignKey]];
        }
    }
	return self;
}

- (void)insertDB
{
    // NSLogFunc
    if (user) {
        [user insertDBWithForeignKey:[self foreignKey]];
    }
    if (message) {
        [message insertDBWithForeignKey:[self foreignKey]];
    }
    if (group) {
        [group insertDBWithForeignKey:[self foreignKey]];
    }
    
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"REPLACE INTO tb_tc_notify VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"];
    }
    
    int i = 1;
    [stmt bindString:   ID          forIndex:i++];
    [stmt bindInt32:    type        forIndex:i++];
    [stmt bindString:   content     forIndex:i++];
    [stmt bindDouble:   time        forIndex:i++];
    [stmt bindString:   user.ID     forIndex:i++];
    [stmt bindString:   message.tag forIndex:i++];
    [stmt bindString:   group.ID     forIndex:i++];
    [stmt bindInt32:    isRead      forIndex:i++];
    [stmt bindInt32:    isDone      forIndex:i++];
    [stmt bindString:[self getExtendJsonString] forIndex:i++];
    [stmt bindString:   [TCEngine currentEngine].userID	forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}

- (void)deleteFromDB {
    // NSLogFunc
    if (user) {
        [user deleteFromDBWithForeignKey:[self foreignKey]];
    }
    if (message) {
        [message deleteFromDBWithForeignKey:[self foreignKey]];
    }
    if (group) {
        [group deleteFromDBWithForeignKey:[self foreignKey]];
    }
    
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"delete from tb_tc_notify where ID = ? and type = ? and currentUser = ?"];
    }
    int i = 1;
    [stmt bindString:ID forIndex:i++];
    [stmt bindInt32:type forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}

@end
