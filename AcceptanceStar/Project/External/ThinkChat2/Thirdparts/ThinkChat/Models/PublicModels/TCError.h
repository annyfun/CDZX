//
//  TCError.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-14.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCError : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString* message;

+ (id)errorWithCode:(NSInteger)aCode message:(NSString*)aMessage;

@end
