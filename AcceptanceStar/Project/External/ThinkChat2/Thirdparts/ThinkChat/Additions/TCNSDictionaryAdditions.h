//
//  TCNSDictionaryAdditions.h
//  ThinkChat
//
//  Created by keen on 14-8-21.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (TCAdditions)

- (BOOL)getBoolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue;
- (int)getIntValueForKey:(NSString *)key defaultValue:(int)defaultValue;
- (NSInteger)getIntegerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue;
- (float)getFloatValueForKey:(NSString*)key defaultValue:(float)defaultValue;
- (double)getDoubleValueForKey:(NSString *)key defaultValue:(double)defaultValue;
- (time_t)getTimeValueForKey:(NSString *)key defaultValue:(time_t)defaultValue;
- (long long)getLongLongValueValueForKey:(NSString *)key defaultValue:(long long)defaultValue;
- (NSString *)getStringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue;
- (NSArray*)getArrayForKey:(NSString *)key defaultValue:(NSArray *)defaultValue;
- (NSDictionary*)getDictionaryForKey:(NSString *)key defaultValue:(NSDictionary *)defaultValue;

@end

@interface NSMutableDictionary (TCAdditions)

- (void)setObjectCanNil:(id)anObject forKey:(id <NSCopying>)aKey;

@end