//
//  ASChangePasswordViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/9/3.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASChangePasswordViewController.h"

@interface ASChangePasswordViewController ()
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *textFieldViewArray;
@property (weak, nonatomic) IBOutlet UITextField *oldPwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *neewPwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPwdTextField;

@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@end

@implementation ASChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改密码";
    self.oldPwdTextField.maxLength = 20;
    self.neewPwdTextField.maxLength = 20;
    self.confirmPwdTextField.maxLength = 20;
    [UIView makeRoundForView:self.confirmButton withRadius:5];
    
    for (UIView *textFieldView in self.textFieldViewArray) {
        [UIView makeRoundForView:textFieldView withRadius:5];
        [UIView makeBorderForView:textFieldView withColor:kDefaultBorderColor borderWidth:1];
    }
}

- (IBAction)confirmButtonClicked:(id)sender {
    NSString *oldPwd = Trim(self.oldPwdTextField.text);
    NSString *newPwd = Trim(self.neewPwdTextField.text);
    NSString *newPwd1 = Trim(self.confirmPwdTextField.text);
    CheckStringEmpty(oldPwd, @"旧密码不能为空");
    CheckStringEmpty(newPwd, @"新密码不能为空");
    CheckStringEmpty(newPwd1, @"确认新密码不能为空");
    if (NO == [newPwd1 isEqualToString:newPwd]) {
        [UIView showResultThenHideOnWindow:@"两次输入的密码不一致"];
        return;
    }
    
    WeakSelfType blockSelf = self;
    [UIView showHUDLoadingOnWindow:@"正在重置密码"];
    [AFNManager postDataWithAPI:kResPathAppUserEditPassword
                   andDictParam:@{@"oldpassword" : oldPwd,
                                  @"newpassword" : newPwd}
                      modelName:nil
               requestSuccessed:^(id responseObject) {
                   [UIView showResultThenHideOnWindow:@"重置成功"];
                   [blockSelf bk_performBlock:^(id obj) {
                       [blockSelf backViewController];
                   } afterDelay:1];
               }
                 requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     [UIView showResultThenHideOnWindow:errorMessage];
                 }];
}

@end
