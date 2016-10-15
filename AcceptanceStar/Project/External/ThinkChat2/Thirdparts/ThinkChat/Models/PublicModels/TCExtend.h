//
//  TCExtend.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-15.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCExtend : NSObject

@property (nonatomic, readonly) NSMutableDictionary*    extDic;

- (NSString*)getExtendJsonString;

- (void)setExtendValue:(NSString*)value forKey:(NSString*)key;

- (NSString*)getExtendValueForKey:(NSString*)key;

- (void)copyExtendFrom:(TCExtend*)item;

- (void)updateExtendWithString:(NSString*)str;

- (void)updateExtendWithDic:(NSDictionary*)dic;

@end
