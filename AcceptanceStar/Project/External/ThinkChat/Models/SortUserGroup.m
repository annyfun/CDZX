//
//  SortUserGroup.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-19.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "SortUserGroup.h"

@implementation SortUserGroup

@synthesize name;
@synthesize userList;

- (id)init {
    self = [super init];
    if (self) {
        self.userList = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
