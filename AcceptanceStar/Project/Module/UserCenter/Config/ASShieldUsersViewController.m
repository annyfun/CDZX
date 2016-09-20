//
//  ASShieldUsersViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/27.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASShieldUsersViewController.h"

@interface ASShieldUsersViewController ()

@end

@implementation ASShieldUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"屏蔽名单";
}

#pragma mark - 重写基类方法

- (NSString *)methodWithPath {
    return kResPathAppMomentsIndex;
}
- (NSDictionary *)dictParamWithPage:(NSInteger)page {
    return @{};
}
- (Class)modelClassOfData {
    return ClassOfObject(UserModel);
}
- (NSString *)nibNameOfCell {
    return @"ASShieldUsersTableViewCell";
}

@end
