//
//  TCTextMessageBody.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-8.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCMessageBody.h"

@interface TCTextMessageBody : TCMessageBody

@property (nonatomic, strong) NSString* content;

- (id)initWithContent:(NSString*)str;

@end
