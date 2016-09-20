//
//  HeadCheckCell.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-19.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "BaseHeadCell.h"

@interface HeadCheckCell : BaseHeadCell

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* content;
@property (nonatomic, assign) BOOL      isCheck;

@end
