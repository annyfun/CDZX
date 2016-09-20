//
//  TCUser.h
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCBaseObject.h"

@interface TCUser : TCBaseObject

@property (nonatomic, strong) NSString* ID;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* head;
@property (nonatomic, strong) NSString* headsmall;
@property (nonatomic, strong) NSString* sign;

#pragma DB

+ (void)createTableIfNotExists;

+ (id)objectWithID:(NSString*)wID foreignKey:(NSString*)fKey;

- (void)insertDBWithForeignKey:(NSString*)fKey;
- (void)deleteFromDBWithForeignKey:(NSString*)fKey;

@end
