//
//  NSDictionaryAdditions.m
//  WeiboPad
//
//  Created by junmin liu on 10-10-6.
//  Copyright 2010 Openlab. All rights reserved.
//

#import "NSDictionaryAdditions.h"


@implementation NSDictionary (Additions)

- (BOOL)getBoolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    id tmpValue = [self objectForKey:key];
    
    if (tmpValue == nil || tmpValue == [NSNull null]) {
        return defaultValue;
    }
    
    if ([tmpValue isKindOfClass:[NSNumber class]]) {
        return [tmpValue boolValue];
    } else {
        @try {
            return [tmpValue boolValue];
        }
        @catch (NSException *exception) {
            TCDemoLog(@"getBoolValueForKey : %@",key);
            TCDemoLog(@"tmpValue : %@",tmpValue);
            return defaultValue;
        }
    }
}

- (int)getIntValueForKey:(NSString *)key defaultValue:(int)defaultValue {
    id tmpValue = [self objectForKey:key];
    
    if (tmpValue == nil || tmpValue == [NSNull null]) {
        return defaultValue;
    }
    
    if ([tmpValue isKindOfClass:[NSNumber class]]) {
        return [tmpValue intValue];
    } else {
        @try {
            return [tmpValue intValue];
        }
        @catch (NSException *exception) {
            TCDemoLog(@"getIntValueForKey : %@",key);
            TCDemoLog(@"tmpValue : %@",tmpValue);
            return defaultValue;
        }
    }
}

- (float)getFloatValueForKey:(NSString *)key defaultValue:(float)defaultValue {
    id tmpValue = [self objectForKey:key];
    
    if (tmpValue == nil || tmpValue == [NSNull null]) {
        return defaultValue;
    }
    
    if ([tmpValue isKindOfClass:[NSNumber class]]) {
        return [tmpValue floatValue];
    } else {
        @try {
            return [tmpValue floatValue];
        }
        @catch (NSException *exception) {
            TCDemoLog(@"getFloatValueForKey : %@",key);
            TCDemoLog(@"tmpValue : %@",tmpValue);
            return defaultValue;
        }
    }
}

- (double)getDoubleValueForKey:(NSString *)key defaultValue:(double)defaultValue {
    id tmpValue = [self objectForKey:key];
    
    if (tmpValue == nil || tmpValue == [NSNull null]) {
        return defaultValue;
    }
    
    if ([tmpValue isKindOfClass:[NSNumber class]]) {
        return [tmpValue doubleValue];
    } else {
        @try {
            return [tmpValue doubleValue];
        }
        @catch (NSException *exception) {
            TCDemoLog(@"getDoubleValueForKey : %@",key);
            TCDemoLog(@"tmpValue : %@",tmpValue);
            return defaultValue;
        }
    }
}

- (time_t)getTimeValueForKey:(NSString *)key defaultValue:(time_t)defaultValue {
	NSString *stringTime   = [self objectForKey:key];
    if ((id)stringTime == [NSNull null]) {
        stringTime = @"";
    }
	struct tm created;
    time_t now;
    time(&now);
    
	if (stringTime) {
		if (strptime([stringTime UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL) {
			strptime([stringTime UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
		}
		return mktime(&created);
	}
	return defaultValue;
}

- (long long)getLongLongValueValueForKey:(NSString *)key defaultValue:(long long)defaultValue {
    id tmpValue = [self objectForKey:key];
    
    if (tmpValue == nil || tmpValue == [NSNull null]) {
        return defaultValue;
    }
    
    if ([tmpValue isKindOfClass:[NSNumber class]]) {
        return [tmpValue longLongValue];
    } else {
        @try {
            return [tmpValue longLongValue];
        }
        @catch (NSException *exception) {
            TCDemoLog(@"getLongLongValueValueForKey : %@",key);
            TCDemoLog(@"tmpValue : %@",tmpValue);
            return defaultValue;
        }
    }
}

- (NSString *)getStringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    id tmpValue = [self objectForKey:key];
    
    if (tmpValue == nil || tmpValue == [NSNull null]) {
        return defaultValue;
    }
    
    if ([tmpValue isKindOfClass:[NSString class]]) {
        return [NSString stringWithString:tmpValue];
    } else {
        @try {
            return [NSString stringWithFormat:@"%@",tmpValue];
        }
        @catch (NSException *exception) {
            TCDemoLog(@"getStringValueForKey : %@",key);
            TCDemoLog(@"tmpValue : %@",tmpValue);
            return defaultValue;
        }
    }
}

- (NSArray*)getArrayForKey:(NSString *)key defaultValue:(NSArray *)defaultValue {
    if (![self isKindOfClass:[NSDictionary class]]) {
        return defaultValue;
    }
    
    id tmpValue = [self objectForKey:key];
    if (tmpValue == nil || tmpValue == [NSNull null]) {
        return defaultValue;
    }
    
    if ([tmpValue isKindOfClass:[NSArray class]]) {
        return tmpValue;
    }
    return defaultValue;
}

- (NSDictionary*)getDictionaryForKey:(NSString *)key defaultValue:(NSDictionary *)defaultValue {
    if (![self isKindOfClass:[NSDictionary class]]) {
        return defaultValue;
    }
    
    id tmpValue = [self objectForKey:key];
    if (tmpValue == nil || tmpValue == [NSNull null]) {
        return defaultValue;
    }
    
    if ([tmpValue isKindOfClass:[NSDictionary class]]) {
        return tmpValue;
    }
    return defaultValue;
}

@end

@implementation NSMutableDictionary (Additions)

- (void)setObjectCanNil:(id)anObject forKey:(id <NSCopying>)aKey {
    if (anObject != nil) {
        [self setObject:anObject forKeyedSubscript:aKey];
    }
}

@end
