//
//  UIImageAddtions.h
//  LfMall
//
//  Created by keen on 13-8-19.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (Addtions)

+ (UIImage*)imageWithColor:(UIColor*)color;
+ (UIImage*)imageNamed:(NSString *)imgName isCache:(BOOL)isCache;

- (UIImage *) renderAtSize:(const CGSize) size;
- (UIImage *) maskWithImage:(const UIImage *) maskImage;

@end
