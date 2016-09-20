//
//  ASJuBaoViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/9/5.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASJuBaoViewController.h"

@interface ASJuBaoViewController ()
@property (weak, nonatomic) IBOutlet YSCTextView *textView;
@end

@implementation ASJuBaoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"举报";
    self.textView.text = @"";
    WEAKSELF
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"button_ok"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        [blockSelf jubao];
    }];
}

- (void)jubao {
    if (isEmpty(Trim(self.textView.text))) {
        [self showResultThenHide:@"内容不能为空"];
        return;
    }
    WEAKSELF
    [AFNManager postDataWithAPI:kResPathAppUserJuBao
                   andDictParam:@{@"fuid" : Trim(self.params[@"fuid"]),
                                  @"content" : Trim(self.textView.text)}
                      modelName:nil
               requestSuccessed:^(id responseObject) {
                   [blockSelf showResultThenBack:@"举报成功"];
               }
                 requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     [blockSelf hideHUDLoading];
                     [blockSelf showAlertVieWithMessage:errorMessage];
                 }];
}

@end
