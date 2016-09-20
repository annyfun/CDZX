//
//  RegisterController.m
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "RegisterController.h"
#import "AppDelegate.h"
#import "BaseClient.h"

@interface RegisterController () <UITextFieldDelegate> {
    IBOutlet UITextField    *tfPhoneNumber;
    IBOutlet UITextField    *tfNickName;
    IBOutlet UITextField    *tfPassWord;
    IBOutlet UITextField    *tfConfirm;
    IBOutlet UIButton       *btnRegister;
    
    NSMutableArray* inputArr;
}

@end

@implementation RegisterController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    self.navigationItem.title = @"注册";
    
    [btnRegister setTitleColor:kColorWhite forState:UIControlStateNormal];
    [btnRegister setTitleColor:kColorWhite forState:UIControlStateHighlighted];
    btnRegister.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [btnRegister setBackgroundImage:[UIImage imageWithColor:kColorBtnBkgBlue] forState:UIControlStateNormal];
    btnRegister.layer.cornerRadius = kCornerRadiusButton;
    btnRegister.clipsToBounds = YES;

    [inputArr addObject:tfPhoneNumber];
    [inputArr addObject:tfNickName];
    [inputArr addObject:tfPassWord];
    [inputArr addObject:tfConfirm];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnPressed:(id)sender {
    [self hideKeyBoard];
    if (sender == btnRegister) {
        if (![self isEmpty]) {
            [self sendRequest];
        }
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
        [client registerWithPhoneNumber:tfPhoneNumber.text nickName:tfNickName.text passWord:tfPassWord.text];
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
