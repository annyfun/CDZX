//
//  BaseViewController.h
//  Base
//
//  Created by keen on 13-10-17.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseClient.h"
#import "BaseEngine.h"
#define DefaultKeyBoardHeight 216

@class BaseClient;

@interface BaseViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate> {
    id          currentInputView;
    CGFloat     keyboardHeight;
    BOOL        isFirstAppear;
    BaseClient*   client;
    NSString*   tagRequest;
}

@property (nonatomic, assign) BOOL loading;

- (IBAction)btnPressed:(id)sender;
- (void)barButtonItemRightPressed:(id)sender;
- (void)barButtonItemLeftPressed:(id)sender;

- (void)popViewController;
- (void)pushViewController:(id)con;

- (void)addBarButtonItemBack;
- (void)addBarButtonItemBackWithAction:(SEL)action;
- (void)addBarButtonItemRightNormalImageName:(NSString*)imgNameN hightLited:(NSString*)imgNameD;
- (void)addBarButtonItemLeftNormalImageName:(NSString*)imgNameN hightLited:(NSString*)imgNameD;

- (void)loadDataIfNeeded;

- (BOOL)sendRequest;
- (BOOL)getResponse:(BaseClient*)sender obj:(NSObject*)obj;

- (void)addKeyBoardControl;
- (void)hideKeyBoard;
- (void)keyBoardWillShow:(id)sender;
- (void)keyBoardWillHide:(id)sender;

@end
