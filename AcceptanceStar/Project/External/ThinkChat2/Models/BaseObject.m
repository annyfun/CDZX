//
//  BaseObject.m
//  Base
//
//  Created by keen on 13-10-19.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import "BaseObject.h"

@implementation BaseObject

+ (id)objWithJsonDic:(NSDictionary *)dic {
    return [[[self class] alloc] initWithJsonDic:dic];
}

- (id)initWithJsonDic:(NSDictionary*)dic {
    if (self = [super init]) {
        isInitSuccuss = NO;
        [self updateWithJsonDic:dic];
    }
    if (!isInitSuccuss) {
        return nil;
    }
    return self;
}

- (void)updateWithJsonDic:(NSDictionary *)dic {
    isInitSuccuss = NO;
    if (dic != nil && [dic isKindOfClass:[NSDictionary class]]) {
        isInitSuccuss = YES;
    }
}

@end
