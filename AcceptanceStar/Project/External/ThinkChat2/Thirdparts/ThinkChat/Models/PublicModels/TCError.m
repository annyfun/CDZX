//
//  TCError.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-14.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCError.h"

@implementation TCError

@synthesize code;
@synthesize message;

+ (id)errorWithCode:(NSInteger)aCode message:(NSString *)aMessage {
    TCError* err = [[TCError alloc] init];
    err.code = aCode;
    err.message = aMessage;
    return err;
}

@end
