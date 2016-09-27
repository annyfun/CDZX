//
//  TCNSStringAdditions.h
//  ThinkChat
//
//  Created by keen on 14-8-21.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TCAdditions)

+ (NSString *)GUIDString;

- (NSString *)URLEncodedString;
- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding;
- (NSString*)URLDecodedString;
- (NSString *)URLDecodedStringWithCFStringEncoding:(CFStringEncoding)encoding;

- (NSString *)md5Hex;

@end
