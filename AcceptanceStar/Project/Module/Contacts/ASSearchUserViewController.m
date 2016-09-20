//
//  ASSearchUserViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/9/5.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASSearchUserViewController.h"

@interface ASSearchUserViewController ()
@property (nonatomic, weak) IBOutlet YSCTextField *searchTextField;
@end

@implementation ASSearchUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WEAKSELF
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"搜索" style:UIBarButtonItemStylePlain handler:^(id sender) {
        [blockSelf doSearch];
    }];
    self.searchTextField.textReturnBlock = ^(NSString *text) {
        [blockSelf doSearch];
    };
}


- (void)doSearch {
    if (isEmpty(self.searchTextField.text)) {
        [self showResultThenHide:@"请输入昵称或星星号"];
        return;
    }
    [self.tableView.header beginRefreshing];
}
- (void)refreshWithSuccessed:(PullToRefreshSuccessed)successed failed:(PullToRefreshFailed)failed {
    if (isEmpty(self.searchTextField.text)) {
        [self.tableView.header endRefreshing];
    }
    else {
        [super refreshWithSuccessed:successed failed:failed];
    }
}
- (BOOL)loadMoreEnable {return NO;}
- (NSString *)hintStringWhenNoData {
    return @"没有查询到用户信息";
}
- (NSString *)methodWithPath {
    return kResPathAppUserSearch;
}
- (NSDictionary *)dictParamWithPage:(NSInteger)page {
    return @{@"search" : Trim(self.searchTextField.text)};
}
- (NSString *)nibNameOfCell {
    return @"ASContactsCell";
}
- (Class)modelClassOfData {
    return ClassOfObject(UserModel);
}
- (void)clickedCell:(id)object atIndexPath:(NSIndexPath *)indexPath {
    [self pushViewController:@"ASUserProfileViewController"
                  withParams:@{kParamModel : object}];
}

@end
