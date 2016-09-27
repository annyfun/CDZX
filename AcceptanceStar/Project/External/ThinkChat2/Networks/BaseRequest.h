//
//  BaseRequest.h
//  Base
//
//  Created by keen on 13-10-25.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    kBaseRequestPostDataTypeNone,
	kBaseRequestPostDataTypeNormal,			// for normal data post, such as "user=name&password=psd"
	kBaseRequestPostDataTypeMultipart,        // for uploading images and files.
}BaseRequestPostDataType;

@class BaseRequest;

@protocol BaseRequestDelegate <NSObject>
@optional
- (void)request:(BaseRequest*)request didReceiveResponse:(NSURLResponse *)response;
- (void)request:(BaseRequest*)request didReceiveRawData:(NSData *)data;
- (void)request:(BaseRequest*)request didFailWithError:(NSError *)error;
- (void)request:(BaseRequest*)request didFinishLoadingWithResult:(id)result;
@end

@interface BaseRequest : NSObject

@property (nonatomic, assign) id <BaseRequestDelegate> delegate;

+ (BaseRequest *)requestWithURL:(NSString *)url
                    httpMethod:(NSString *)httpMethod
                        params:(NSDictionary *)params
                  postDataType:(BaseRequestPostDataType)postDataType
              httpHeaderFields:(NSDictionary *)httpHeaderFields
                      delegate:(id<BaseRequestDelegate>)delegate;

- (void)connect;
- (void)disconnect;

@end
