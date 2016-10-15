//
//  TCLocationMessageBody.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-8.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCMessageBody.h"

@interface TCLocationMessageBody : TCMessageBody

@property (nonatomic, strong) NSString* address;        // 地址
@property (nonatomic, assign) double    lat;            // 经度
@property (nonatomic, assign) double    lng;            // 纬度

- (id)initWithLat:(double)lat lng:(double)lng address:(NSString*)address;

@end
