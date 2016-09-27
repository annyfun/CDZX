//
//  LoginController.m
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "LoginController.h"
#import "RegisterController.h"
#import "AppDelegate.h"

@interface LoginController () {
    IBOutlet UITextField    *tfPhoneNumber;
    IBOutlet UITextField    *tfPassWord;
    IBOutlet UIButton       *btnLogin;
    IBOutlet UIButton       *btnRegister;
    
    NSMutableArray* inputArr;
}

@end

@implementation LoginController

- (id)init
{
    self = [super initWithNibName:@"LoginController" bundle:nil];
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
    self.navigationItem.title = @"登陆";
    
    [btnLogin setTitleColor:kColorWhite forState:UIControlStateNormal];
    [btnLogin setTitleColor:kColorWhite forState:UIControlStateHighlighted];
    btnLogin.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [btnLogin setBackgroundImage:[UIImage imageWithColor:kColorBtnBkgBlue] forState:UIControlStateNormal];
    btnLogin.layer.cornerRadius = kCornerRadiusButton;
    btnLogin.clipsToBounds = YES;
    
    [btnRegister setTitleColor:kColorTitleGray forState:UIControlStateNormal];
    [btnRegister setTitleColor:kColorTitleLightGray forState:UIControlStateHighlighted];
    btnRegister.titleLabel.font = [UIFont systemFontOfSize:16];
    
    [inputArr addObject:tfPhoneNumber];
    [inputArr addObject:tfPassWord];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnPressed:(id)sender {
    [self hideKeyBoard];
    if (sender == btnLogin) {
        if (![self isEmpty]) {
            [self sendRequest];
        }
    } else if (sender == btnRegister) {
        id con = [[RegisterController alloc] init];
        [self pushViewController:con];
    }
}

- (BOOL)isEmpty {
    NSString* strEmpty = nil;
    for (UITextField* tfInput in inputArr) {
        if (tfInput.text.length == 0) {
            strEmpty = tfInput.placeholder;
            break;
        }
    }
    if (strEmpty) {
        NSString* strAlert = [NSString stringWithFormat:@"请输入 %@",strEmpty];
        [WCAlertView showAlertWithTitle:@"提示" message:strAlert customizationBlock:nil completionBlock:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        return YES;
    }
    return NO;
}

- (BOOL)sendRequest {
    if ([super sendRequest]) {
        [client loginWithPhoneNumber:tfPhoneNumber.text passWord:tfPassWord.text];
        return YES;
    }
    return NO;
}

- (BOOL)getResponse:(BaseClient*)sender obj:(NSDictionary*)obj {
    if ([super getResponse:sender obj:obj]) {
        obj = [obj getDictionaryForKey:@"data" defaultValue:nil];
        User* itemU = [User objWithJsonDic:obj];
        if (itemU && itemU.ID) {
            [[AppDelegate instance] loginWithUser:itemU passWord:tfPassWord.text];
        }
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
