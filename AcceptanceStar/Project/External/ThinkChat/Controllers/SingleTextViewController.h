//
//  SingleTextViewController.h
//  HomeBridge
//
//  Created by keen on 14-7-3.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "BaseViewController.h"

@class User;

typedef enum {
    forSingleTextViewSimpleInput = 0,
    forSingleTextViewFeedBack,
    forSingleTextViewReportUser,
}SingleTextViewType;

@protocol SingleTextViewDelegate <NSObject>

- (void)singleTextView:(id)sender inputString:(NSString*)text;

@end

@interface SingleTextViewController : BaseViewController

- (id)initWithTitle:(NSString*)strTitle placeHolder:(NSString*)strPlaceHolder delegate:(id <SingleTextViewDelegate>)del;

- (id)initWithType:(SingleTextViewType)theType;

- (id)initWithUser:(User*)item;

@end
