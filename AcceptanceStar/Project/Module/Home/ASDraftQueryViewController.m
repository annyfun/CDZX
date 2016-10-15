//
//  ASDraftQueryViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/30.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASDraftQueryViewController.h"

@interface ASDraftQueryViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UIView *hintView;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *queryButton;

@end

@implementation ASDraftQueryViewController

- (void)dealloc {
    removeAllObservers(self.textField);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"公示催告查询";
    [UIView makeRoundForView:self.inputView withRadius:5];
    [UIView makeRoundForView:self.hintView withRadius:5];
    [UIView makeRoundForView:self.queryButton withRadius:5];
    WEAKSELF
    [self.view bk_whenTapped:^{
        [blockSelf performSelector:@selector(hideKeyboard) withObject:nil afterDelay:0.1f];
    }];
    
    NSMutableString *tempNumber = [NSMutableString stringWithString:Trim(self.params[kParamNumber])];
    if ([tempNumber length] > 8) {
        [tempNumber insertString:@"  " atIndex:8];
    }
    self.textField.text = tempNumber;
    self.textField.maxLength = 18;
    self.textField.bk_shouldChangeCharactersInRangeWithReplacementStringBlock = ^(UITextField *textField, NSRange range, NSString *string) {
        if (isNotEmpty(string) && [Trim(textField.text) length] == 8) {
            textField.text = [NSString stringWithFormat:@"%@  ", Trim(textField.text)];
        }
        return YES;
    };
    
    
    if (self.code) {
        self.textField.text = self.code;
        [self queryButtonClicked:nil];
    }
}

- (IBAction)queryButtonClicked:(id)sender {
    [self hideKeyboard];
    NSString *num = Trim(self.textField.text);
    num = [NSString replaceString:num byRegex:@"[ ]+" to:@""];
    if (isEmpty(num)) {
        [self showResultThenHide:@"请输入汇票票号"];
        return;
    }
    WEAKSELF
    [self showHUDLoading:@"正在查询"];
    [AFNManager getDataWithAPI:kResPathAppCourtIndex
                   andDictParam:@{@"no" : num}
                      modelName:ClassOfObject(CourtIndexModel)
               requestSuccessed:^(id responseObject) {
                   [blockSelf hideHUDLoading];
                   [blockSelf pushViewController:@"ASDraftQueryResultViewController"
                                      withParams:@{kParamModel : responseObject, kParamNumber : num}];
               }
                 requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     [blockSelf hideHUDLoading];
                     [blockSelf pushViewController:@"ASDraftQueryResultViewController"
                                        withParams:@{kParamNumber : num}];
                 }];
}
@end
