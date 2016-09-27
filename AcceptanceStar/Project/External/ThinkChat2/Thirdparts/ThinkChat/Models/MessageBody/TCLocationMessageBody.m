//
//  TCLocationMessageBody.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-8.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCLocationMessageBody.h"

@implementation TCLocationMessageBody

@synthesize address;
@synthesize lat;
@synthesize lng;

- (id)initWithLat:(double)vLat lng:(double)vLng address:(NSString *)vAddress {
    self = [super init];
    if (self) {
        self.lat = vLat;
        self.lng = vLng;
        self.address = vAddress;
    }
    return self;
}

- (void)dealloc {
    self.address = nil;
}

- (void)updateWithJsonDic:(NSDictionary *)dic {
    [super updateWithJsonDic:dic];
    if (isInitSuccuss) {
        self.lat     = [dic getDoubleValueForKey:@"lat"     defaultValue:0.0];
        self.lng     = [dic getDoubleValueForKey:@"lng"     defaultValue:0.0];
        self.address = [dic getStringValueForKey:@"address" defaultValue:nil];
    }
}

@end
