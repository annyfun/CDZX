//
//  ASWebViewViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/26.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASWebViewViewController.h"

#define KeyOfCachedHtmlString(type)       [NSString stringWithFormat:@"KeyOfCachedHtmlString_%@", (type)]

@interface ASWebViewViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *htmlString;
@property (copy, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *keyOfCachedHtml;

@end

@implementation ASWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *url = Trim(self.params[kParamUrl]);
    NSString *method = Trim(self.params[kParamMethod]);
    if (NO == [url hasPrefix:@"http"]) {
        url = [NSString stringWithFormat:@"http://%@", url];
    }
    self.keyOfCachedHtml = @"KeyOfCachedHtmlString";
    if ([NSString isNotEmpty:url]) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
    else if ([NSString isNotEmpty:method]) {
        NSDictionary *params = (NSDictionary *)self.params[kParamParams];
        self.keyOfCachedHtml = KeyOfCachedHtmlString(Trim(params[kParamType]));
        self.htmlString = [self cachedObjectForKey:self.keyOfCachedHtml];
        [self layoutHtmlString];
        [self loadHtmlWithMethod:method andParams:params];
    }
    else {
        [self showResultThenBack:@"传入的参数有误！"];
    }
}

//直接显示html数据
- (void)layoutHtmlString {
    [self.webView loadHTMLString:self.htmlString baseURL:nil];
}

#pragma mark - 网络访问
- (void)loadHtmlWithMethod:(NSString *)method andParams:(NSDictionary *)params {
    [self showHUDLoading:@"正在更新..."];
    WeakSelfType blockSelf = self;
    [AFNManager getDataWithAPI:method
                  andDictParam:params
                     modelName:nil
              requestSuccessed:^(id responseObject) {
                  [blockSelf hideHUDLoading];
                  blockSelf.htmlString = responseObject;
                  [blockSelf saveObject:responseObject forKey:blockSelf.keyOfCachedHtml];
                  [blockSelf layoutHtmlString];
              } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                  [blockSelf showResultThenHide:errorMessage];
                  [blockSelf bk_performBlock:^(id obj) {
                      [blockSelf backViewController];
                  } afterDelay:1];
              }];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.view layoutIfNeeded];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.view layoutIfNeeded];
}


@end
