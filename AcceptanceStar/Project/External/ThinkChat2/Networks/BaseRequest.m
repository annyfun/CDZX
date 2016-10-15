//
//  BaseRequest.m
//  Base
//
//  Created by keen on 13-10-25.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import "BaseRequest.h"

#define kBaseRequestTimeOutInterval   30.0
#define kBaseRequestStringBoundary    @"293iosfksdfkiowjksdf31jsiuwq003s02dsaffafass3qw"

@interface BaseRequest () {
    NSURLConnection * connection;
    NSMutableData   * responseData;
}
@property (nonatomic, assign) BaseRequestPostDataType postDataType;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *httpMethod;
@property (nonatomic, strong) NSDictionary * params;
@property (nonatomic, strong) NSDictionary *httpHeaderFields;

@end

@implementation BaseRequest
@synthesize delegate;
@synthesize postDataType, url, httpMethod, params, httpHeaderFields;

#pragma mark - BaseRequest Life Circle

- (void)dealloc {
    responseData = nil;
    [connection cancel];
    connection = nil;
    self.url = nil;
    self.httpMethod = nil;
    self.params = nil;
    self.httpHeaderFields = nil;
}

#pragma mark - BaseRequest Private Methods

+ (NSString *)stringFromDictionary:(NSDictionary *)dict {
    NSMutableArray *pairs = [NSMutableArray array];
	for (NSString *key in [dict keyEnumerator])
	{
		if (!([[dict valueForKey:key] isKindOfClass:[NSString class]]))
		{
			continue;
		}
		
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [[dict objectForKey:key] URLEncodedString]]];
	}
	
	return [pairs componentsJoinedByString:@"&"];
}

+ (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString {
    [body appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSMutableData *)postBody {
    NSMutableData *body = [NSMutableData data];
    
    if (postDataType == kBaseRequestPostDataTypeNormal)
    {
        [BaseRequest appendUTF8Body:body dataString:[BaseRequest stringFromDictionary:params]];
    } else if (postDataType == kBaseRequestPostDataTypeMultipart) {
        NSString *bodyPrefixString = [NSString stringWithFormat:@"--%@\r\n", kBaseRequestStringBoundary];
		NSString *bodySuffixString = [NSString stringWithFormat:@"\r\n--%@--\r\n", kBaseRequestStringBoundary];
        
        NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
        
        
        for (id key in [params keyEnumerator])
		{
			if (([[params valueForKey:key] isKindOfClass:[UIImage class]]) || ([[params valueForKey:key] isKindOfClass:[NSData class]]))
			{
				[dataDictionary setObject:[params valueForKey:key] forKey:key];
				continue;
			}
            [BaseRequest appendUTF8Body:body dataString:bodyPrefixString];
			[BaseRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", key, [params valueForKey:key]]];
		}
		
		if ([dataDictionary count] > 0)
		{
			for (id key in dataDictionary)
			{
                [BaseRequest appendUTF8Body:body dataString:bodyPrefixString];
				NSObject *dataParam = [dataDictionary valueForKey:key];
				
				if ([dataParam isKindOfClass:[UIImage class]])
				{
                    NSData* imageData = UIImageJPEGRepresentation((UIImage *)dataParam, 0.4);
					[BaseRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file.jpg\"\r\n",key]];
					[BaseRequest appendUTF8Body:body dataString:@"Content-Type: image/jpg\r\nContent-Transfer-Encoding: binary\r\n\r\n"];
					[body appendData:imageData];
				} else if ([dataParam isKindOfClass:[NSData class]]) {
                    [BaseRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file.mp3\"\r\n",key]];
					[BaseRequest appendUTF8Body:body dataString:@"Content-Type: audio/mp3\r\nContent-Transfer-Encoding: binary\r\n\r\n"];
					[body appendData:(NSData*)dataParam];
				}
                [BaseRequest appendUTF8Body:body dataString:@"\r\n"];
			}
            [BaseRequest appendUTF8Body:body dataString:bodySuffixString];
		}
    }
    
    NSString* strBody =  [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
    //    TCDemoLog(@"POST BODY (原始数据):\r\n%@",strBody);
    TCDemoLog(@"POST BODY (解码后的数据):\r\n%@",[strBody URLDecodedString]);
    strBody = nil;
    
    return body;
}

- (void)handleResponseData:(NSData *)data {
    if ([delegate respondsToSelector:@selector(request:didReceiveRawData:)]) {
        [delegate request:self didReceiveRawData:data];
    }
	
	NSError* error = nil;
	id result = [self parseJSONData:data error:&error];
    
	if (error) {
        NSString* gotResult =  nil;
        if (gotResult == nil) {
            gotResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        if (gotResult == nil) {
            NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            gotResult = [[NSString alloc] initWithData:data encoding:gbkEncoding];
        }
        if (gotResult == nil) {
            gotResult = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        }
        if (gotResult) {
            TCDemoLog(@"JSON format Error:\r\n%@",gotResult);
            gotResult = nil;
        }
        [self failedWithError:error];
	} else {
//        TCDemoLog(@"%@",result);
        if ([delegate respondsToSelector:@selector(request:didFinishLoadingWithResult:)]) {
            [delegate request:self didFinishLoadingWithResult:result];
		}
	}
}

- (id)parseJSONData:(NSData *)data error:(NSError **)error {
	NSError *parseError = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
	if (parseError) {
        if (error != nil) {
            *error = [self errorWithCode:kBaseErrorCodeSDK
                                userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", kBaseSDKErrorCodeParseError]
                                                                     forKey:kBaseSDKErrorCodeKey]];
        }
	}
	return result;
}

- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo {
    return [NSError errorWithDomain:kBaseSDKErrorDomain code:code userInfo:userInfo];
    return nil;
}

- (void)failedWithError:(NSError *)error {
	if ([delegate respondsToSelector:@selector(request:didFailWithError:)]) {
		[delegate request:self didFailWithError:error];
	}
}

#pragma mark - BMRequest Public Methods

+ (BaseRequest *)requestWithURL:(NSString *)url
                    httpMethod:(NSString *)httpMethod
                        params:(NSDictionary *)params
                  postDataType:(BaseRequestPostDataType)postDataType
              httpHeaderFields:(NSDictionary *)httpHeaderFields
                      delegate:(id)delegate {
    
    BaseRequest *request = [[BaseRequest alloc] init];
    request.url = url;
    request.httpMethod = httpMethod;
    request.params = params;
    request.postDataType = postDataType;
    request.httpHeaderFields = httpHeaderFields;
    request.delegate = delegate;
    
    return request;
}

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod {
    if (![httpMethod isEqualToString:@"GET"]) {
        return baseURL;
    }
    //    NSURL * parsedURL = [NSURL URLWithString:baseURL];
	NSString * queryPrefix = @"&";
	NSString * query = [BaseRequest stringFromDictionary:params];
	return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
}

- (void)connect {
    NSString *urlString = [BaseRequest serializeURL:url params:params httpMethod:httpMethod];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:kBaseRequestTimeOutInterval];
    [request setHTTPMethod:httpMethod];
    TCDemoLog(@"URL : %@", urlString);
    
    if ([httpMethod isEqualToString:@"POST"]) {
        if (postDataType == kBaseRequestPostDataTypeMultipart) {
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kBaseRequestStringBoundary];
            [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        }
        
        NSData* postBody = [self postBody];
        
        NSTimeInterval timeinterval = kBaseRequestTimeOutInterval + ([postBody length]>>14);
        TCDemoLog(@"请求超时时间设置为 : %.2f s \nPost Body Length : %.2f K",timeinterval,[postBody length]/1000.0);
        
        [request setTimeoutInterval:timeinterval];
        
        [request setHTTPBody:postBody];
    }
    
    for (NSString *key in [httpHeaderFields keyEnumerator]) {
        [request setValue:[httpHeaderFields objectForKey:key] forHTTPHeaderField:key];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)disconnect {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    delegate = nil;
    responseData = nil;
    [connection cancel];
    connection = nil;
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	responseData = [[NSMutableData alloc] init];
	
	if ([delegate respondsToSelector:@selector(request:didReceiveResponse:)]) {
		[delegate request:self didReceiveResponse:response];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
				  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
	return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
#if ShouldLogAfterRequest == 1
    NSString* gotResult =  nil;
    if (gotResult == nil) {
        gotResult = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    }
    if (gotResult == nil) {
        NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        gotResult = [[NSString alloc] initWithData:responseData encoding:gbkEncoding];
    }
    if (gotResult == nil) {
        gotResult = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    }
    TCDemoLog(@"connectionDidFinishLoading\r\n%@",gotResult);
    gotResult = nil;
#endif
    
	[self handleResponseData:responseData];
    
	responseData = nil;
    
    [connection cancel];
    connection = nil;
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self failedWithError:error];
	responseData = nil;
    [connection cancel];
    connection = nil;
}

@end
