//
//  TCJsonObject.h
//  ThinkChat
//
//  Created by keen on 14-8-21.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCExtend.h"
#import "TCNSDictionaryAdditions.h"

@interface TCJsonObject : TCExtend {
    BOOL isInitSuccuss;
}

+ (id)objWithJsonDic:(NSDictionary*)dic;
- (id)initWithJsonDic:(NSDictionary*)dic;
- (void)updateWithJsonDic:(NSDictionary*)dic;

@end
