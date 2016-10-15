//
//  TCMessage.m
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCMessage.h"
#import "TCEngine.h"
#import "TCDBConnection.h"
#import "TCNSStringAdditions.h"

#define kThinkChatMessageForeignKeyDefault @"_DefaultMessageForeignKey"

@implementation TCMessage

@synthesize ID;
@synthesize tag;
@synthesize typeChat;
@synthesize typeFile;
@synthesize from;
@synthesize to;
@synthesize time;

@synthesize body;

@synthesize contentFormat;
@synthesize withID;
@synthesize state;
@synthesize isRead;
@synthesize isSendByMe;
@synthesize rowID;

@synthesize imgWidthHalf;
@synthesize imgHeightHalf;

@synthesize bodyText;
@synthesize bodyImage;
@synthesize bodyVoice;
@synthesize bodyLocation;

+ (id)newMessage {
    TCMessage* itemM = [[TCMessage alloc] init];
    
    itemM.from.ID = [TCEngine currentEngine].userID;
    itemM.time = [[NSDate date] timeIntervalSince1970]*1000;
    itemM.tag = [NSString GUIDString];
    itemM.state = forMessageStateHavent;
    itemM.isSendByMe = YES;
    itemM.isRead = YES;

    return itemM;
}


- (id)init {
    self = [super init];
    if (self) {
        self.from = [[TCUser alloc] init];
        self.to = [[TCUser alloc] init];
    }
    return self;
}

- (void) dealloc {
    self.ID = nil;
    self.tag = nil;
    self.from = nil;
    self.to = nil;
    self.body = nil;
    self.contentFormat = nil;
    self.withID = nil;
}

- (NSString*)contentFormat {
    if (contentFormat == nil) {
        NSString* str = nil;
        switch (typeFile) {
            case forFileText:
                str = ((TCTextMessageBody*)body).content;
                if (str != nil && str.length > 0) {
//                    str = [EmotionInputView decodeMessageEmoji:str];
                } else {
                    str = @"[文字]";
                }
                break;
            case forFileImage:
                str = @"[图片]";
                break;
            case forFileVoice:
                str = @"[声音]";
                break;
            case forFileLocation:
                str = @"[位置]";
                break;
            default:
                str = @"[消息]";
                break;
        }
        self.contentFormat = str;
    }
    return contentFormat;
}

- (NSString*)withID {
    if (withID == nil) {
        if (typeChat != forChatTypeUser) {
            self.withID = to.ID;
        } else {
            if ([from.ID isEqualToString:[TCEngine currentEngine].userID]) {
                self.withID = to.ID;
            } else {
                self.withID = from.ID;
            }
        }
    }
    return withID;
}

- (TCTextMessageBody*)bodyText {
    if (typeFile == forFileText) {
        return (TCTextMessageBody*)body;
    }
    return nil;
}

- (TCImageMessageBody*)bodyImage {
    if (typeFile == forFileImage) {
        return (TCImageMessageBody*)body;
    }
    return nil;
}

- (TCVoiceMessageBody*)bodyVoice {
    if (typeFile == forFileVoice) {
        return (TCVoiceMessageBody*)body;
    }
    return nil;
}

- (TCLocationMessageBody*)bodyLocation {
    if (typeFile == forFileLocation) {
        return (TCLocationMessageBody*)body;
    }
    return nil;
}

- (int)imgWidthHalf {
    if (typeFile == forFileLocation) {
        return 78;
    } else if (typeFile == forFileImage) {
        return ceilf(self.bodyImage.imgWidth/2.0);
    }
    return 0.0;
}

- (int)imgHeightHalf {
    if (typeFile == forFileLocation) {
        return 78;
    } else if (typeFile == forFileImage) {
        return ceilf(self.bodyImage.imgHeight/2.0);
    }
    return 0.0;
}

- (void)updateWithJsonDic:(NSDictionary*)dic {
    isInitSuccuss = NO;
    if (dic != nil && [dic isKindOfClass:[NSDictionary class]]) {
        
        self.ID       = [dic getStringValueForKey:@"id"       defaultValue:nil];
        self.tag      = [dic getStringValueForKey:@"tag"      defaultValue:nil];
        self.time     = [dic getDoubleValueForKey:@"time"     defaultValue:0.0];
        self.typeChat = [dic getIntValueForKey:   @"typechat" defaultValue:forChatTypeUser];
        self.typeFile = [dic getIntValueForKey:   @"typefile" defaultValue:forFileText];
        
        self.from.ID  = [dic getStringValueForKey:@"fromid" defaultValue:nil];
        self.from.name = [dic getStringValueForKey:@"fromname" defaultValue:nil];
        self.from.head = [dic getStringValueForKey:@"fromhead" defaultValue:nil];
        
        self.to.ID    = [dic getStringValueForKey:@"toid" defaultValue:nil];
        self.to.name  = [dic getStringValueForKey:@"toname" defaultValue:nil];
        self.to.head  = [dic getStringValueForKey:@"tohead" defaultValue:nil];

        NSDictionary* extFrom = [dic getDictionaryForKey:@"fromextend" defaultValue:nil];
        NSDictionary* extTo   = [dic getDictionaryForKey:@"toextend" defaultValue:nil];

        if (extFrom) {
            [self.from updateExtendWithDic:extFrom];
        }
        if (extTo) {
            [self.to updateExtendWithDic:extTo];
        }
        
        if (typeFile == forFileText) {
            self.body = [[TCTextMessageBody alloc] initWithJsonDic:dic];
        } else if (typeFile == forFileImage) {
            NSDictionary* subDic = [dic getDictionaryForKey:@"image" defaultValue:nil];
            self.body = [[TCImageMessageBody alloc] initWithJsonDic:subDic];
        } else if (typeFile == forFileVoice) {
            NSDictionary* subDic = [dic getDictionaryForKey:@"voice" defaultValue:nil];
            self.body = [[TCVoiceMessageBody alloc] initWithJsonDic:subDic];
        } else if (typeFile == forFileLocation) {
            NSDictionary* subDic = [dic getDictionaryForKey:@"location" defaultValue:nil];
            self.body = [[TCLocationMessageBody alloc] initWithJsonDic:subDic];
        }
        
        NSDictionary* extMsg = [dic getDictionaryForKey:@"extend" defaultValue:nil];
        NSDictionary* extBody   = [dic getDictionaryForKey:@"bodyextend" defaultValue:nil];

        if (extMsg) {
            [self updateExtendWithDic:extMsg];
        }
        if (extBody) {
            [self.body updateExtendWithDic:extBody];
        }
        
        self.state = forMessageStateNormal;
        if ([from.ID isEqualToString:[TCEngine currentEngine].userID]) {
            self.isSendByMe = YES;
            self.isRead = YES;
        } else {
            self.isSendByMe = NO;
        }
        isInitSuccuss = YES;
    }
}

#pragma DB

+ (void)createTableIfNotExists {
	TCStatement *stmt = [TCDBConnection statementWithQuery:"CREATE TABLE IF NOT EXISTS tb_tc_message (ID, tag, typeChat, typeFile, extend, fromID, fromName, fromHead, fromExtend, toID, toName, toHead, toExtend, time, content, imgUrlS, imgUrlL, imgWidth, imgHeight, voiceUrl, voiceTime, address, lat, lng, bodyExtend, withID, state, isRead, isSendByMe, foreignKey, currentUser, primary key(tag, foreignKey, currentUser))"];
    int step = [stmt step];
	if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}

+ (id)objectWithID:(NSString *)wID foreignKey:(NSString *)fKey {

    if (fKey == nil) {
        fKey = kThinkChatMessageForeignKeyDefault;
    }

    TCMessage* result = nil;
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"SELECT rowid,* FROM tb_tc_message WHERE tag = ? and foreignKey = ? and currentUser = ?"];
    }
    
    int i = 1;
    [stmt bindString:wID forIndex:i++];
    [stmt bindString:fKey forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    
    int ret = [stmt step];
    if (ret == SQLITE_ROW) {
        result = [[TCMessage alloc] initWithStatement:stmt];
    }
    [stmt reset];
    
    return result;
}

+ (NSArray*)getMessageListTimeLineWithID:(NSString *)wID
                                typeChat:(ChatType)typeChat
                              sinceRowID:(int)sinceRowID
                                maxRowID:(int)maxRowID
                                   count:(int)count
                                    page:(int)page {
    if (count < 1) {
        count = defaultSizeInt;
    } else if (count > 100) {
        count = 100;
    }
    if (page < 1) {
        page = 1;
    }
    
    if (sinceRowID > 0) {
        return [self getMessageListTimeLineWithID:wID typeChat:typeChat sinceRowID:sinceRowID count:count];
    } else if (maxRowID > 0) {
        return [self getMessageListTimeLineWithID:wID typeChat:typeChat maxRowID:maxRowID count:count];
    } else {
        return [self getMessageListTimeLineWithID:wID typeChat:typeChat count:count page:page];
    }
}

+ (NSArray*)getMessageListTimeLineWithID:(NSString *)wID
                                typeChat:(ChatType)typeChat
                              sinceRowID:(int)sinceRowID
                                   count:(int)count {
    NSMutableArray* list = [NSMutableArray array];
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"SELECT rowid,* FROM tb_tc_message WHERE foreignKey = ? and withID = ? and typeChat = ? and rowid > ? and currentUser = ? order by rowid asc limit 0,?"];
    }
    
    int i = 1;
    [stmt bindString:kThinkChatMessageForeignKeyDefault forIndex:i++];
    [stmt bindString:wID forIndex:i++];
    [stmt bindInt32: typeChat forIndex:i++];
    [stmt bindInt64: sinceRowID forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    [stmt bindInt32:count forIndex:i++];
    
    int ret = [stmt step];
    
    while (ret == SQLITE_ROW) {
        TCMessage* item = [[TCMessage alloc] initWithStatement:stmt];
        if (item) {
            [list addObject:item];
        }
        ret = [stmt step];
    }
    
    [stmt reset];
    return list;
}

+ (NSArray*)getMessageListTimeLineWithID:(NSString *)wID
                                typeChat:(ChatType)typeChat
                                maxRowID:(int)maxRowID
                                   count:(int)count {
    NSMutableArray* list = [NSMutableArray array];
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"SELECT rowid,* FROM tb_tc_message WHERE foreignKey = ? and withID = ? and typeChat = ? and rowid < ? and currentUser = ? order by rowid desc limit 0,?"];
    }
    
    int i = 1;
    [stmt bindString:kThinkChatMessageForeignKeyDefault forIndex:i++];
    [stmt bindString:wID forIndex:i++];
    [stmt bindInt32: typeChat forIndex:i++];
    [stmt bindInt64: maxRowID forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    [stmt bindInt32:count forIndex:i++];
    
    int ret = [stmt step];
    
    while (ret == SQLITE_ROW) {
        TCMessage* item = [[TCMessage alloc] initWithStatement:stmt];
        if (item) {
            [list insertObject:item atIndex:0];
        }
        ret = [stmt step];
    }
    
    [stmt reset];
    return list;
}

+ (NSArray*)getMessageListTimeLineWithID:(NSString *)wID
                                typeChat:(ChatType)typeChat
                                   count:(int)count
                                    page:(int)page {
    NSMutableArray* list = [NSMutableArray array];
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"SELECT rowid,* FROM tb_tc_message WHERE foreignKey = ? and withID = ? and typeChat = ? and currentUser = ? order by rowid desc limit ?,?"];
    }
    
    int i = 1;
    [stmt bindString:kThinkChatMessageForeignKeyDefault forIndex:i++];
    [stmt bindString:wID forIndex:i++];
    [stmt bindInt32: typeChat forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    [stmt bindInt32:(page-1)*count forIndex:i++];
    [stmt bindInt32:count forIndex:i++];
    
    int ret = [stmt step];
    
    while (ret == SQLITE_ROW) {
        TCMessage* item = [[TCMessage alloc] initWithStatement:stmt];
        if (item) {
            [list insertObject:item atIndex:0];
        }
        ret = [stmt step];
    }
    
    [stmt reset];
    return list;
}

+ (NSArray*)getMessageListUnreadWithID:(NSString *)wID
                              typeChat:(ChatType)typeChat
                                 count:(int)count {
    if (count < 1) {
        count = defaultSizeInt;
    } else if (count > 100) {
        count = 100;
    }

    NSMutableArray* list = [NSMutableArray array];
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"SELECT rowid,* FROM tb_tc_message WHERE isRead = 0 and foreignKey = ? and withID = ? and typeChat = ? and currentUser = ? order by rowid desc limit 0,?"];
    }
    
    int i = 1;
    [stmt bindString:kThinkChatMessageForeignKeyDefault forIndex:i++];
    [stmt bindString:wID forIndex:i++];
    [stmt bindInt32: typeChat forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    [stmt bindInt32:count forIndex:i++];
    
    int ret = [stmt step];
    
    while (ret == SQLITE_ROW) {
        TCMessage* item = [[TCMessage alloc] initWithStatement:stmt];
        if (item) {
            [list insertObject:item atIndex:0];
        }
        ret = [stmt step];
    }
    
    [stmt reset];
    return list;
}

+ (id)getLatestMessageWithID:(NSString *)wID typeChat:(ChatType)typeChat {
    TCMessage* result = nil;
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"SELECT rowid,* FROM tb_tc_message WHERE withID = ? and typeChat = ? and foreignKey = ? and currentUser = ? order by rowid desc limit 0,1"];
    }
    
    int i = 1;
    [stmt bindString:wID forIndex:i++];
    [stmt bindInt32: typeChat forIndex:i++];
    [stmt bindString:kThinkChatMessageForeignKeyDefault forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    
    int ret = [stmt step];
    if (ret == SQLITE_ROW) {
        result = [[TCMessage alloc] initWithStatement:stmt];
    }
    [stmt reset];
    
    return result;
}

+ (void)cleanMessageWithID:(NSString *)wID typeChat:(ChatType)typeChat {
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"delete from tb_tc_message where foreignKey = ? and withID = ? and typeChat = ? and currentUser = ?"];
    }
    int i = 1;
    [stmt bindString:kThinkChatMessageForeignKeyDefault forIndex:i++];
    [stmt bindString:wID forIndex:i++];
    [stmt bindInt32:typeChat forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}

+ (int)getUnReadCount {
    int unRead = 0;
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"SELECT count(isRead) FROM tb_tc_message WHERE foreignKey = ? and isRead = 0 and currentUser = ?"];
    }
    
    int i = 1;
    [stmt bindString:kThinkChatMessageForeignKeyDefault forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    
    int ret = [stmt step];
    
    if (ret == SQLITE_ROW) {
        unRead = [stmt getInt32:0];
    }
    [stmt reset];
    
    return unRead;
}

+ (void)hasReadMessageWithID:(NSString *)wID typeChat:(ChatType)typeChat {
    // NSLogFunc
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"update tb_tc_message set isRead = 1 WHERE foreignKey = ? and withID = ? and typeChat = ? and currentUser = ?"];
    }
    
    int i = 1;
    [stmt bindString:kThinkChatMessageForeignKeyDefault forIndex:i++];
    [stmt bindString:wID forIndex:i++];
    [stmt bindInt32:typeChat forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}

- (id)initWithStatement:(TCStatement *)stmt {
	if (self = [self init]) {
        int i = 0;
        self.rowID      = [stmt getInt32:i++];
        self.ID         = [stmt getString:i++];
        self.tag        = [stmt getString:i++];
        self.typeChat   = [stmt getInt32:i++];
        self.typeFile   = [stmt getInt32:i++];
        [self updateExtendWithString:[stmt getString:i++]];
        self.from.ID     = [stmt getString:i++];
        self.from.name   = [stmt getString:i++];
        self.from.head   = [stmt getString:i++];
        [self.from updateExtendWithString:[stmt getString:i++]];
        self.to.ID       = [stmt getString:i++];
        self.to.name     = [stmt getString:i++];
        self.to.head     = [stmt getString:i++];
        [self.to updateExtendWithString:[stmt getString:i++]];
        self.time       = [stmt getDouble:i++];
        
        if (typeFile == forFileText) {
            self.body = [[TCTextMessageBody alloc] init];
            ((TCTextMessageBody*)body).content = [stmt getString:i++];
        } else {
            i = i + 1;
        }
        
        if (typeFile == forFileImage) {
            self.body = [[TCImageMessageBody alloc] init];
            ((TCImageMessageBody*)body).imgUrlS    = [stmt getString:i++];
            ((TCImageMessageBody*)body).imgUrlL    = [stmt getString:i++];
            ((TCImageMessageBody*)body).imgWidth   = [stmt getInt32:i++];
            ((TCImageMessageBody*)body).imgHeight  = [stmt getInt32:i++];
        } else {
            i = i + 4;
        }

        if (typeFile == forFileVoice) {
            self.body = [[TCVoiceMessageBody alloc] init];
            ((TCVoiceMessageBody*)body).voiceUrl   = [stmt getString:i++];
            ((TCVoiceMessageBody*)body).voiceTime  = [stmt getInt32:i++];
        } else {
            i = i + 2;
        }

        if (typeFile == forFileLocation) {
            self.body = [[TCLocationMessageBody alloc] init];
            ((TCLocationMessageBody*)body).address    = [stmt getString:i++];
            ((TCLocationMessageBody*)body).lat        = [stmt getDouble:i++];
            ((TCLocationMessageBody*)body).lng        = [stmt getDouble:i++];
        } else {
            i = i + 3;
        }
        
        [self.body updateExtendWithString:[stmt getString:i++]];
        self.withID     = [stmt getString:i++];
        self.state      = [stmt getInt32:i++];
        self.isRead     = [stmt getInt32:i++] == 1;
        self.isSendByMe = [stmt getInt32:i++] == 1;
        
        if (state == forMessageStateHavent) {
            self.state = forMessageStateError;
        }
	}
	return self;
}

- (void)insertDBWithForeignKey:(NSString *)fKey {
    
    if (fKey == nil) {
        fKey = kThinkChatMessageForeignKeyDefault;
    }

    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"REPLACE INTO tb_tc_message VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"];
    }
    int i = 1;
    [stmt bindString: ID                forIndex:i++];
    [stmt bindString: tag               forIndex:i++];
    [stmt bindInt32:  typeChat          forIndex:i++];
    [stmt bindInt32:  typeFile          forIndex:i++];
    [stmt bindString:[self getExtendJsonString] forIndex:i++];
    [stmt bindString: from.ID            forIndex:i++];
    [stmt bindString: from.name          forIndex:i++];
    [stmt bindString: from.head          forIndex:i++];
    [stmt bindString: [from getExtendJsonString]          forIndex:i++];
    [stmt bindString: to.ID              forIndex:i++];
    [stmt bindString: to.name            forIndex:i++];
    [stmt bindString: to.head            forIndex:i++];
    [stmt bindString: [to getExtendJsonString]            forIndex:i++];
    [stmt bindDouble: time              forIndex:i++];
    
    if (typeFile == forFileText) {
        [stmt bindString:self.bodyText.content           forIndex:i++];
    } else {
        i = i + 1;
    }
    
    if (typeFile == forFileImage) {
        [stmt bindString: self.bodyImage.imgUrlS           forIndex:i++];
        [stmt bindString: self.bodyImage.imgUrlL           forIndex:i++];
        [stmt bindInt32:  self.bodyImage.imgWidth          forIndex:i++];
        [stmt bindInt32:  self.bodyImage.imgHeight         forIndex:i++];
    } else {
        i = i + 4;
    }
    
    if (typeFile == forFileVoice) {
        [stmt bindString: self.bodyVoice.voiceUrl          forIndex:i++];
        [stmt bindInt32:  self.bodyVoice.voiceTime         forIndex:i++];
    } else {
        i = i + 2;
    }
    
    if (typeFile == forFileLocation) {
        [stmt bindString: self.bodyLocation.address           forIndex:i++];
        [stmt bindDouble: self.bodyLocation.lat               forIndex:i++];
        [stmt bindDouble: self.bodyLocation.lng               forIndex:i++];
    } else {
        i = i + 3;
    }
    
    [stmt bindString:[body getExtendJsonString] forIndex:i++];
    [stmt bindString: self.withID       forIndex:i++];
    [stmt bindInt32:  state             forIndex:i++];
    [stmt bindInt32:  isRead?1:0        forIndex:i++];
    [stmt bindInt32:  isSendByMe?1:0    forIndex:i++];
    [stmt bindString: fKey               forIndex:i++];
    [stmt bindString: [TCEngine currentEngine].userID	forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}

- (void)deleteFromDBWithForeignKey:(NSString *)fKey {

    if (fKey == nil) {
        fKey = kThinkChatMessageForeignKeyDefault;
    }
    
    static TCStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TCDBConnection statementWithQuery:"delete from tb_tc_message where tag = ? and foreignKey = ? and currentUser = ?"];
    }
    
    int i = 1;
    [stmt bindString:tag	forIndex:i++];
    [stmt bindString:fKey forIndex:i++];
    [stmt bindString:[TCEngine currentEngine].userID	forIndex:i++];
    
	int step = [stmt step];
    if (step != SQLITE_DONE) {
        [TCDBConnection alert];
    }
    [stmt reset];
}

@end
