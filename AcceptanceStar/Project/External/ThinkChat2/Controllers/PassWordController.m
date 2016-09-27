//
//  PassWordController.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-18.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "PassWordController.h"

@interface PassWordController () {
    IBOutlet UITextField*   tfOldPwd;
    IBOutlet UITextField*   tfNewPwd;
    IBOutlet UITextField*   tfConfirm;
    IBOutlet UIButton*      btnCommit;
    
    NSMutableArray*     inputArr;
}

@end

@implementation PassWordController

- (id)init
{
    self = [super initWithNibName:@"PassWordController" bundle:nil];
    if (self) {
        // Custom initialization
        inputArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"修改密码";
    
    [inputArr addObject:tfOldPwd];
    [inputArr addObject:tfNewPwd];
    [inputArr addObject:tfConfirm];
    
    [btnCommit setBackgroundImage:[UIImage imageWithColor:kColorBtnBkgBlue] forState:UIControlStateNormal];
    [btnCommit setTitleColor:kColorWhite forState:UIControlStateNormal];
    [btnCommit setTitleColor:kColorWhite forState:UIControlStateHighlighted];
    btnCommit.layer.cornerRadius = kCornerRadiusButton;
    btnCommit.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnPressed:(id)sender {
    if (sender == btnCommit) {
        if (![self isEmpty]) {
            if (![tfNewPwd.text isEqualToString:tfConfirm.text]) {
                [WCAlertView showAlertWithTitle:@"提示" message:@"两次输入的密码不一致" customizationBlock:nil completionBlock:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                return;
            } else {
                [self sendRequest];
            }
        }
    }
}

- (BOOL)isEmpty {
    for (UITextField* tfInput in inputArr) {
        if (tfInput.text.length == 0) {
            NSString* msg = [NSString stringWithFormat:@"请输入 %@",tfInput.placeholder];
            [WCAlertView showAlertWithTitle:@"提示" message:msg customizationBlock:nil completionBlock:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            return YES;
        }
    }
    return NO;
}

#pragma mark - Request

- (BOOL)sendRequest {
    if ([super sendRequest]) {
        [client editPasswordOld:tfOldPwd.text new:tfNewPwd.text];
        return YES;
    }
    return NO;
}

- (BOOL)getResponse:(BaseClient *)sender obj:(NSObject *)obj {
    if ([super getResponse:sender obj:obj]) {
        [BaseEngine currentBaseEngine].passWord = tfNewPwd.text;
        [BaseEngine currentBaseEngine].user.passWord = tfNewPwd.text;
        [[BaseEngine currentBaseEngine] saveAuthorizeData];
        [KAlertView showType:KAlertTypeCheck text:sender.errorMessage for:1.5 animated:YES];
        [self popViewController];
        return YES;
    }
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    NSInteger index = [inputArr indexOfObject:sender];
    if (index < inputArr.count - 1) {
        UITextField* tfNext = [inputArr objectAtIndex:index+1];
        [tfNext becomeFirstResponder];
    } else {
        [sender resignFirstResponder];
    }
    return YES;
}

@end
