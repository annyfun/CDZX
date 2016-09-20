//
//  Globals.h
//  Base
//
//  Created by keen on 13-10-18.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Globals : NSObject

+ (void)initializeGlobals;

// Alert

+ (void)showAlertTitle:(NSString*)title msg:(NSString*)msg;
+ (void)showAlertTitle:(NSString*)title
                   msg:(NSString*)msg
              delegate:(id)del
                cancel:(NSString*)cancelTitle
                others: (NSArray*)otherTitleArr
                   tag:(int)tag;

// Time

+ (NSString*)timeString;
+ (NSString*)timeStringWith:(NSTimeInterval)timestamp;
+ (NSString*)timeStringMultiLineWith:(NSTimeInterval)timestamp;

+ (BOOL)isNotify;
+ (void)setIsNotify:(BOOL)value;

+ (BOOL)isAudioNotify;
+ (void)setIsAudioNotify:(BOOL)value;

@end
