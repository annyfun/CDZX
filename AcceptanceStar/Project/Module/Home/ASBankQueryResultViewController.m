//
//  ASBankQueryResultViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/30.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASBankQueryResultViewController.h"

@interface ASBankQueryResultViewController ()

@end

@implementation ASBankQueryResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIView makeBorderForView:self.tableView withColor:DefaultBorderColor borderWidth:1];
    self.title = @"行号查询结果";
}

#pragma mark - 重写基类方法

- (NSString *)methodWithPath {
    return kResPathAppBankIndex;
}
- (NSDictionary *)dictParamWithPage:(NSInteger)page {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[kParamPageSize] = @(kDefaultPageSize);
    params[kParamPage] = @(page);
    [params addEntriesFromDictionary:self.params[kParamParams]];
    return params;
}
- (Class)modelClassOfData {
    return ClassOfObject(BankIndexModel);
}
- (NSString *)nibNameOfCell {
    return @"ASBankResultTableViewCell";
}

@end
