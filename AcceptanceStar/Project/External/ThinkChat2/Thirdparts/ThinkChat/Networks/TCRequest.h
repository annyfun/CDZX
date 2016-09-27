//
//  TCRequest.h
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    kTCRequestPostDataTypeNone,
	kTCRequestPostDataTypeNormal,			// for normal data post, such as "user=name&password=psd"
	kTCRequestPostDataTypeMultipart,        // for uploading images and files.
}TCRequestPostDataType;

@class TCRequest;

@protocol TCRequestDelegate <NSObject>
@optional
- (void)request:(TCRequest*)request didReceiveResponse:(NSURLResponse *)response;
- (void)request:(TCRequest*)request didReceiveRawData:(NSData *)data;
- (void)request:(TCRequest*)request didFailWithError:(NSError *)error;
- (void)request:(TCRequest*)request didFinishLoadingWithResult:(id)result;
@end

@interface TCRequest : NSObject

@property (nonatomic, assign) id <TCRequestDelegate> delegate;

+ (TCRequest *)requestWithURL:(NSString *)url
                   httpMethod:(NSString *)httpMethod
                       params:(NSDictionary *)params
                 postDataType:(TCRequestPostDataType)postDataType
             httpHeaderFields:(NSDictionary *)httpHeaderFields
                     delegate:(id<TCRequestDelegate>)delegate;

- (void)connect;
- (void)disconnect;

@end
