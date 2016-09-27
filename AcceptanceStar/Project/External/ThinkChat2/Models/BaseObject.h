//
//  BaseObject.h
//  Base
//
//  Created by keen on 13-10-19.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseObject : NSObject {
    BOOL isInitSuccuss;
}

+ (id)objWithJsonDic:(NSDictionary*)dic;
- (id)initWithJsonDic:(NSDictionary*)dic;
- (void)updateWithJsonDic:(NSDictionary*)dic;

@end
