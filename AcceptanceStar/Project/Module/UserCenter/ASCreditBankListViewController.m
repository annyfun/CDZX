//
//  ASCreditBankListViewController.m
//  AcceptanceStar
//
//  Created by benson on 11/21/16.
//  Copyright © 2016 Builder. All rights reserved.
//

#import "ASCreditBankListViewController.h"
#import "ASCreditBankCell.h"

@interface ASCreditBankListViewController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *tabbars; // 顺序(一类,二类,三类,四类)
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<CreditBankModel *> *creditBanks;
@property (weak, nonatomic) IBOutlet UIView *menuView;

@end

@implementation ASCreditBankListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = @"授信银行";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCreditBank:)];
    [self setUpTableView];
    // 触发事件
    [self.tabbars.firstObject sendActionsForControlEvents:UIControlEventTouchUpInside];
    
}

- (void)setUpTableView {
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ASCreditBankCell class]) bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    self.tableView.rowHeight = 52;
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.creditBanks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASCreditBankCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.nameLabel.text = self.creditBanks[indexPath.row].bank;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.menuView.hidden = NO;
    
    NSIndexPath *mindexPath = [self.tableView indexPathForSelectedRow];
    
}

#pragma mark - User Action

- (IBAction)tapTabBar:(UIButton *)sender {
    // UI状态改变
    for (UIButton *button in self.tabbars) {
        button.selected = (button == sender);
    }
    // 操作
    [self loadCreditBanksWithIndex:sender.tag];
}

- (void)addCreditBank:(id)sender {
    // TODO-tsw:
}

/// Menu

// 取消
- (IBAction)cancelMenu:(id)sender {
    self.menuView.hidden = YES;
}

// 取消授信
- (IBAction)removeCreditBank:(id)sender {
    [UIView showHUDLoadingOnWindow:@"正在取消授信"];
    NSInteger selectedRow = [self.tableView indexPathForSelectedRow].row;
    CreditBankModel *model = self.creditBanks[selectedRow];
    WEAKSELF
    [AFNManager postDataWithAPI:@"banksx/my_del" andDictParam:@{@"id": model.id} modelName:nil requestSuccessed:^(id responseObject) {
        [UIView hideHUDLoadingOnWindow];
        
        [blockSelf.tableView reloadData];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [UIView showResultThenHideOnWindow:errorMessage afterDelay:1.5];
    }];
}

// 调整授信类别
- (IBAction)setCreditBankIndex:(id)sender {
}

#pragma mark - Private Method

- (void)loadCreditBanksWithIndex:(NSInteger)index {
    [UIView showHUDLoadingOnWindow:@"正在请求数据"];
    WEAKSELF
    [AFNManager getDataWithAPI:kResPathAppBankSXMyList andDictParam:@{@"rt": @(index)} modelName:nil requestSuccessed:^(id responseObject) {
        [UIView hideHUDLoadingOnWindow];
        [blockSelf.tableView reloadData];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [UIView showResultThenHideOnWindow:errorMessage afterDelay:1.5];
    }];
}

@end
