//
//  TCJsonObject.m
//  ThinkChat
//
//  Created by keen on 14-8-21.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCJsonObject.h"

@implementation TCJsonObject

+ (id)objWithJsonDic:(NSDictionary *)dic {
    return [[[self class] alloc] initWithJsonDic:dic];
}

- (id)initWithJsonDic:(NSDictionary*)dic {
    if (self = [self init]) {
        isInitSuccuss = NO;
        [self updateWithJsonDic:dic];
    }
    if (!isInitSuccuss) {
        self = nil;
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
