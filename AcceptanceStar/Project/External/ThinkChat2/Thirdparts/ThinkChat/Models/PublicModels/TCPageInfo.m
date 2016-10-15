//
//  TCPageInfo.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-14.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCPageInfo.h"

@implementation TCPageInfo

@synthesize hasMore;
@synthesize page;
@synthesize total;
@synthesize pageCount;
@synthesize count;

- (void)updateWithJsonDic:(NSDictionary *)dic {
    [super updateWithJsonDic:dic];
    if (isInitSuccuss) {
        self.hasMore = [dic getBoolValueForKey:@"hasMore" defaultValue:NO];
        self.page = [dic getIntValueForKey:@"page" defaultValue:0];
        self.total = [dic getIntValueForKey:@"total" defaultValue:0];
        self.count = [dic getIntValueForKey:@"count" defaultValue:0];
        self.pageCount = [dic getIntValueForKey:@"pageCount" defaultValue:0];
    }
}

@end
