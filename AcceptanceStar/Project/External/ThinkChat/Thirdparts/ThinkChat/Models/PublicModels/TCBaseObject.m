//
//  TCBaseObject.m
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCBaseObject.h"

@implementation TCBaseObject

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
