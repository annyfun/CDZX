//
//  ASDailyDetailViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/8/2.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASDailyDetailViewController.h"

@interface ASDailyDetailViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation ASDailyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshNewsDetail];
}

- (void)refreshNewsDetail {
    PageIndexModel *pageIndex = self.params[kParamModel];
    WEAKSELF
    [self showHUDLoading:@"正在查询日记详情"];
    [AFNManager getDataWithAPI:kResPathAppPageHtml
                  andDictParam:@{@"id" : Trim(pageIndex.id)}
                     modelName:nil
              requestSuccessed:^(id responseObject) {
                  [blockSelf hideHUDLoading];
                  [blockSelf.webView loadHTMLString:responseObject baseURL:nil];
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    [blockSelf hideHUDLoading];
                    [blockSelf showAlertVieWithMessage:errorMessage];
                }];
}

@end
