//
//  TCNSJSONSerializationAdditions.h
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (TCAdditions)

+ (id)JSONObjectWithString:(NSString *)string options:(NSJSONReadingOptions)opt error:(NSError **)error;

@end
