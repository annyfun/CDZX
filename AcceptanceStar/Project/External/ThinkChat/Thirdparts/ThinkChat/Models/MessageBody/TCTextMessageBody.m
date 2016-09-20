//
//  TCTextMessageBody.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-8.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCTextMessageBody.h"

@implementation TCTextMessageBody

@synthesize content;

- (id)initWithContent:(NSString *)str {
    self = [super init];
    if (self) {
        self.content = str;
    }
    return self;
}

- (void)dealloc {
    self.content = nil;
}

- (void)updateWithJsonDic:(NSDictionary *)dic {
    [super updateWithJsonDic:dic];
    if (isInitSuccuss) {
        self.content = [dic getStringValueForKey:@"content" defaultValue:nil];
    }
}

//- (void)setContent:(NSString *)value {
//    [super setExtendValue:value forKey:@"content"];
//}
//
//- (NSString*)content {
//    return [super getExtendValueForKey:@"content"];
//}


@end
