//
//  TCNSStringAdditions.m
//  ThinkChat
//
//  Created by keen on 14-8-21.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "TCNSStringAdditions.h"

@implementation NSString (TCAdditions)

+ (NSString *)GUIDString
{
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	return (__bridge NSString *)string;
}

- (NSString *)URLEncodedString
{
	return [self URLEncodedStringWithCFStringEncoding:kCFStringEncodingUTF8];
}

- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding
{
	return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[self mutableCopy], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"), encoding));
}

- (NSString*)URLDecodedString
{
    return [self URLDecodedStringWithCFStringEncoding:kCFStringEncodingUTF8];
}

- (NSString *)URLDecodedStringWithCFStringEncoding:(CFStringEncoding)encoding
{
	return (NSString *) CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""),encoding));
}

- (NSString *)md5Hex
{
    const char *cStr = [self UTF8String];
    
    unsigned char result[32];
    
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    
    return [NSString stringWithFormat:
            
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            
            result[0],result[1],result[2],result[3],
            result[4],result[5],result[6],result[7],
            result[8],result[9],result[10],result[11],
            result[12],result[13],result[14],result[15]/*,
                                                        result[16], result[17],result[18], result[19],
                                                        result[20], result[21],result[22], result[23],
                                                        result[24], result[25],result[26], result[27],
                                                        result[28], result[29],result[30], result[31]*/];
}

@end