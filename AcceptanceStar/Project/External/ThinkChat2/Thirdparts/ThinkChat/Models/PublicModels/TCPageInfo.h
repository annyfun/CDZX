//
//  TCPageInfo.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-14.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCBaseObject.h"

@interface TCPageInfo : TCBaseObject

@property (nonatomic, assign) BOOL  hasMore;    // 是否有更多
@property (nonatomic, assign) int   page;       // 当前页玛
@property (nonatomic, assign) int   total;      // 数据总数
@property (nonatomic, assign) int   count;      // 分页大小
@property (nonatomic, assign) int   pageCount;  // 总页数

@end
