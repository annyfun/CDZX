//
//  TCNSJSONSerializationAdditions.m
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCNSJSONSerializationAdditions.h"

@implementation NSJSONSerialization (TCAdditions)

+ (id)JSONObjectWithString:(NSString *)string options:(NSJSONReadingOptions)opt error:(NSError **)error {
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self JSONObjectWithData:data options:opt error:error];
}

@end
