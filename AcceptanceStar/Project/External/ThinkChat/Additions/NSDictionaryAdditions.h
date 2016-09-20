//
//  NSDictionaryAdditions.h
//  WeiboPad
//
//  Created by junmin liu on 10-10-6.
//  Copyright 2010 Openlab. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (Additions)

- (BOOL)getBoolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue;
- (int)getIntValueForKey:(NSString *)key defaultValue:(int)defaultValue;
- (float)getFloatValueForKey:(NSString*)key defaultValue:(float)defaultValue;
- (double)getDoubleValueForKey:(NSString *)key defaultValue:(double)defaultValue;
- (time_t)getTimeValueForKey:(NSString *)key defaultValue:(time_t)defaultValue;
- (long long)getLongLongValueValueForKey:(NSString *)key defaultValue:(long long)defaultValue;
- (NSString *)getStringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue;
- (NSArray*)getArrayForKey:(NSString *)key defaultValue:(NSArray *)defaultValue;
- (NSDictionary*)getDictionaryForKey:(NSString *)key defaultValue:(NSDictionary *)defaultValue;

@end

@interface NSMutableDictionary (Additions)

- (void)setObjectCanNil:(id)anObject forKey:(id <NSCopying>)aKey;

@end