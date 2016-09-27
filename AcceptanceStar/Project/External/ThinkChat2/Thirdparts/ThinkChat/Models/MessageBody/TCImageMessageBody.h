//
//  TCImageMessageBody.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-8.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCMessageBody.h"

@interface TCImageMessageBody : TCMessageBody

@property (nonatomic, strong) NSString* imgUrlS;        // 小图
@property (nonatomic, strong) NSString* imgUrlL;        // 大图
@property (nonatomic, assign) int       imgWidth;       // 宽度 (小)
@property (nonatomic, assign) int       imgHeight;      // 高度 (小)

- (id)initWithFilePath:(NSString*)path;

@end
