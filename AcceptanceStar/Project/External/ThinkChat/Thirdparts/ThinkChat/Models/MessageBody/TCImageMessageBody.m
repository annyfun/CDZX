//
//  TCImageMessageBody.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-8.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "TCImageMessageBody.h"

@implementation TCImageMessageBody

@synthesize imgUrlS;
@synthesize imgUrlL;
@synthesize imgWidth;
@synthesize imgHeight;

- (id)initWithFilePath:(NSString *)path {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    self.imgUrlL = nil;
    self.imgUrlS = nil;
}

- (void)updateWithJsonDic:(NSDictionary *)dic {
    [super updateWithJsonDic:dic];
    if (isInitSuccuss) {
        self.imgUrlS   = [dic getStringValueForKey:@"urlsmall" defaultValue:nil];
        self.imgUrlL   = [dic getStringValueForKey:@"urllarge" defaultValue:nil];
        self.imgWidth  = [dic getIntValueForKey:   @"width"    defaultValue:0];
        self.imgHeight = [dic getIntValueForKey:   @"height"   defaultValue:0];
    }
}

//- (void)setImgUrlL:(NSString *)url {
//    [super setExtendValue:url forKey:@"imgUrlL"];
//}
//
//- (NSString*)imgUrlL {
//    return [super getExtendValueForKey:@"imgUrlL"];
//}
//
//- (void)setImgUrlS:(NSString *)url {
//    [super setExtendValue:url forKey:@"imgUrlS"];
//}
//
//- (NSString*)imgUrlS {
//    return [super getExtendValueForKey:@"imgUrlS"];
//}
//
//- (void)setImgWidth:(int)value {
//    [super setExtendValue:[NSString stringWithFormat:@"%d",value] forKey:@"imgWidth"];
//}
//
//- (int)imgWidth {
//    return [[super getExtendValueForKey:@"imgWidth"] intValue];
//}
//
//- (void)setImgHeight:(int)value {
//    [super setExtendValue:[NSString stringWithFormat:@"%d",value] forKey:@"imgHeight"];
//}
//
//- (int)imgHeight {
//    return [[super getExtendValueForKey:@"imgHeight"] intValue];
//}

@end
