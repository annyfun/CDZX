//
//  NSStringAdditions.h
//  LfMall
//
//  Created by keen on 13-9-6.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import <Foundation/Foundation.h>

//Functions for Encoding Data.
@interface NSData (kEncode)
- (NSString *)MD5EncodedString;
- (NSData *)HMACSHA1EncodedDataWithKey:(NSString *)key;
//- (NSString *)base64EncodedString;
@end

//Functions for Encoding String.
@interface NSString (kEncode)

@property (readonly) BOOL hasValue;

+ (NSString *)GUIDString;

- (NSString *)MD5EncodedString;
- (NSString *)md5Hex;
- (NSData *)HMACSHA1EncodedDataWithKey:(NSString *)key;
//- (NSString *)base64EncodedString;
- (NSString *)URLEncodedString;
- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding;
- (NSString*)URLDecodedString;
- (NSString *)URLDecodedStringWithCFStringEncoding:(CFStringEncoding)encoding;

- (CGSize)sizeWithFont:(UIFont*)font maxWidth:(CGFloat)width maxNumberLines:(int)num;

- (NSString *)iPhoneStandardFormat;

- (NSUInteger)lengthGBK;

@end
