//
//  Globals.m
//  Base
//
//  Created by keen on 13-10-18.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import "Globals.h"
#import "DBConnection.h"
#import "User.h"

@implementation Globals

+ (void)initializeGlobals {
    NSFileManager * fMan = [NSFileManager defaultManager];
    NSString * new_path_b = [NSString stringWithFormat:@"%@/Library/Cache",NSHomeDirectory()];
    NSString * new_path = [NSString stringWithFormat:@"%@/Library/Cache/Images",NSHomeDirectory()];
    NSString * new_path_a = [NSString stringWithFormat:@"%@/Library/Cache/Audios",NSHomeDirectory()];
    if ((![fMan fileExistsAtPath:new_path_b]) || (![fMan fileExistsAtPath:new_path])) {
        [fMan createDirectoryAtPath:new_path_b withIntermediateDirectories:YES attributes:nil error:nil];
        [fMan createDirectoryAtPath:new_path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![fMan fileExistsAtPath:new_path_a]) {
        [fMan createDirectoryAtPath:new_path_a withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [self createTableIfNotExists];
}

+ (void)createTableIfNotExists {
//    [DBConnection getSharedDatabase];
//    [User createTableIfNotExists];
}

#pragma mark - Alert

+ (void)showAlertTitle:(NSString*)title msg:(NSString*)msg {
    [self showAlertTitle:title msg:msg delegate:nil cancel:nil others:nil tag:0];
}

+ (void)showAlertTitle:(NSString*)title
                   msg:(NSString*)msg
              delegate:(id)del
                cancel:(NSString*)cancelTitle
                others: (NSArray*)otherTitleArr
                   tag:(int)tag {
    if (cancelTitle == nil) {
        cancelTitle = @"确定";
    }
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:del cancelButtonTitle:cancelTitle otherButtonTitles:nil];
    alert.tag = tag;
    for (NSString* otherTitle in otherTitleArr) {
        if (otherTitle != nil && [otherTitle isKindOfClass:[NSString class]]) {
            [alert addButtonWithTitle:otherTitle];
        }
    }
    [alert show];
}

#pragma mark - Time

+ (NSString*)timeString {
    return [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
}

+ (NSString*)timeStringWith:(NSTimeInterval)timestamp {
    return [self timeStringWith:timestamp multiLine:NO];
}

+ (NSString*)timeStringMultiLineWith:(NSTimeInterval)timestamp {
    return [self timeStringWith:timestamp multiLine:YES];
}

+ (NSString*)timeStringWith:(NSTimeInterval)timestamp multiLine:(BOOL)multi {
    if (timestamp > 1000000000000) {
        timestamp = timestamp / 1000;
    }
    
    static NSCalendar *calendar = nil;
    if (calendar == nil) {
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    
    NSDate* dateGet = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDate* dateNow = [NSDate date];
    
    unsigned int unitFlag = NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlag fromDate:dateGet toDate:dateNow options:0];
    NSInteger days = [components day];
    
    NSString*   multiString = nil;
    if (multi) {
        multiString = @"\r\n";
    } else {
        multiString = @" ";
    }
    
    static NSDateFormatter* df = nil;
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
    }
    NSString* formatString = nil;
    if (days == 0) {
        // 今天
        formatString = [NSString stringWithFormat:@"今天%@HH:mm",multiString];
    } else if (days == 1) {
        // 昨天
        formatString = [NSString stringWithFormat:@"昨天%@HH:mm",multiString];
    } else if (days == 2) {
        // 前天
        formatString = [NSString stringWithFormat:@"前天%@HH:mm",multiString];
    } else {
        formatString = [NSString stringWithFormat:@"MM-dd%@HH:mm",multiString];
    }
    [df setDateFormat:formatString];
    
    return [df stringFromDate:dateGet];
}

+ (BOOL)isNotify {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return ![defaults boolForKey:kBaseIfCloseAPNS];
}

+ (void)setIsNotify:(BOOL)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:!value forKey:kBaseIfCloseAPNS];
    [defaults synchronize];
}

+ (BOOL)isAudioNotify {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return ![defaults boolForKey:kBaseIfCloseVoice];
}

+ (void)setIsAudioNotify:(BOOL)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:!value forKey:kBaseIfCloseVoice];
    [defaults synchronize];
}

@end
