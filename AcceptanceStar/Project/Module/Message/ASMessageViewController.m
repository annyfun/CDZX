//
//  ASMessageViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/28.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASMessageViewController.h"

@interface ASMessageViewController ()

@end

@implementation ASMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WeakSelfType blockSelf = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"icon_message"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        //TODO:
    }];
}

#pragma mark - 重写基类方法

- (NSString *)methodWithPath {
    return kResPathAppMomentsIndex;
}
- (NSDictionary *)dictParamWithPage:(NSInteger)page {
    return @{};
}
- (Class)modelClassOfData {
    return ClassOfObject(MomentsIndexModel);
}
- (NSString *)nibNameOfCell {
    return @"";
}


@end
