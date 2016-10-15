//
//  TCExtend.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-15.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCExtend.h"

@implementation TCExtend

@synthesize extDic;

- (id)init {
    self = [super init];
    if (self) {
        extDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setExtendValue:(NSString *)value forKey:(NSString *)key {
    if (value == nil) {
        value = @"";
    }
    [extDic setValue:value forKey:key];
}

- (NSString*)getExtendValueForKey:(NSString *)key {
    return [extDic objectForKey:key];
}

- (NSString*)getExtendJsonString {
    NSMutableString* json = [[NSMutableString alloc] init];
    [json appendString:@"{"];
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    NSArray* keys = [extDic allKeys];
    for (NSString* key in keys) {
        NSString* value = [extDic objectForKey:key];
        [arr addObject:[NSString stringWithFormat:@"\"%@\":\"%@\"",key,value]];
    }
    [json appendString:[arr componentsJoinedByString:@","]];
    [json appendString:@"}"];
    return json;
}

- (void)copyExtendFrom:(TCExtend *)item {
    [extDic setDictionary:item.extDic];
}

- (void)updateExtendWithString:(NSString *)str {
    if (str != nil && [str isKindOfClass:[NSString class]] && str.length > 0) {
        NSError *parseError = nil;
        NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
        if (parseError == nil) {
            [extDic setDictionary:result];
        }
    }
}

- (void)updateExtendWithDic:(NSDictionary *)dic {
    [extDic setDictionary:dic];
}

@end
