//
//  UIImageAddtions.m
//  LfMall
//
//  Created by keen on 13-8-19.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import "UIImageAddtions.h"

@implementation UIImage (Addtions)

+ (UIImage*)imageWithColor:(UIColor *)color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage*)imageNamed:(NSString *)imgName isCache:(BOOL)isCache {
    if (isCache) {
        return [UIImage imageNamed:imgName];
    } else {
        NSString* type = nil;
        NSString* name = nil;
        NSRange range = [imgName rangeOfString:@"."];
        if (range.location == NSNotFound) {
            name = imgName;
            type = @"png";
        } else {
            type = [imgName substringWithRange:NSMakeRange(range.location+1, imgName.length-range.location-1)];
            name = [imgName substringWithRange:NSMakeRange(0, range.location)];
        }
        NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:type];
        return [UIImage imageWithContentsOfFile:path];
    }
}

// Render a UIImage at the specified size. This is needed to render out the resizable image mask before sending it to maskImage:withMask:
- (UIImage *)renderAtSize:(const CGSize)size {
    UIGraphicsBeginImageContext(size);
    const CGContextRef context = UIGraphicsGetCurrentContext();
    //    CGContextScaleCTM(context, 2, 2);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    const CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *renderedImage = [UIImage imageWithCGImage:cgImage scale:2 orientation:UIImageOrientationUp];
    //    UIImage *renderedImage = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    UIGraphicsEndImageContext();
    
    return renderedImage;
}

- (UIImage *)maskWithImage:(const UIImage *) maskImage {
    const CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    const CGImageRef maskImageRef = maskImage.CGImage;
    
    const CGContextRef mainViewContentContext = CGBitmapContextCreate (NULL, maskImage.size.width, maskImage.size.height, 8, 0, colorSpace, 1);
    CGColorSpaceRelease(colorSpace);
    
    if (! mainViewContentContext)
    {
        return nil;
    }
    
    CGFloat ratio = maskImage.size.width / self.size.width;
    
    if (ratio * self.size.height < maskImage.size.height)
    {
        ratio = maskImage.size.height / self.size.height;
    }
    
    const CGRect maskRect  = CGRectMake(0, 0, maskImage.size.width, maskImage.size.height);
    
    const CGRect imageRect  = CGRectMake(-((self.size.width * ratio) - maskImage.size.width) / 2,
                                         -((self.size.height * ratio) - maskImage.size.height) / 2,
                                         self.size.width * ratio,
                                         self.size.height * ratio);
    
    CGContextClipToMask(mainViewContentContext, maskRect, maskImageRef);
    CGContextDrawImage(mainViewContentContext, imageRect, self.CGImage);
    
    CGImageRef newImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    UIImage *theImage = [UIImage imageWithCGImage:newImage];
    
    CGImageRelease(newImage);
    
    return theImage;
}

CGContextRef NYXImageCreateARGBBitmapContext(const size_t width, const size_t height, const size_t bytesPerRow) {
    /// Use the generic RGB color space
    /// We avoid the NULL check because CGColorSpaceRelease() NULL check the value anyway, and worst case scenario = fail to create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    /// Create the bitmap context, we want pre-multiplied ARGB, 8-bits per component
    CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8/*Bits per component*/, bytesPerRow, colorSpace, 1);
    
    CGColorSpaceRelease(colorSpace);
    
    return bmContext;
}

@end
