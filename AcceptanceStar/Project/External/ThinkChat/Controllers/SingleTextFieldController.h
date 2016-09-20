//
//  SingleTextFieldController.h
//  HomeBridge
//
//  Created by keen on 14-7-3.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "BaseViewController.h"

@class TCSession;

typedef enum {
    forSingleTextFieldSimpleInput = 0,
    forSingleTextFieldEditSession,
}SingleTextFieldType;

@protocol SingleTextFieldDelegate <NSObject>

- (void)singleTextField:(id)sender inputString:(NSString*)text;

@end

@interface SingleTextFieldController : BaseViewController

- (id)initWithTitle:(NSString*)strTitle placeHolder:(NSString*)strPlaceHolder delegate:(id <SingleTextFieldDelegate>)del;

- (id)initWithSession:(TCSession*)itemS type:(SingleTextFieldType)theType;

@end
