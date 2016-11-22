//
//  ASAppendCreditBankViewController.m
//  AcceptanceStar
//
//  Created by benson on 11/21/16.
//  Copyright © 2016 Builder. All rights reserved.
//

#import "ASAppendCreditBankViewController.h"
#import "ASAppendCreditBankCell.h"

@interface ASAppendCreditBankViewController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *tabBars;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray<CreditBankModel *> *creditBanks;
@property (strong, nonatomic) NSMutableArray<NSString *> *selectedIDs; // 选中的授信银行ID
@property (assign, nonatomic) NSInteger selectedIndex;  // 选中类索引

@end

@implementation ASAppendCreditBankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = @"添加授信银行";
    [self setUpTableView];
    [self loadCreditBanks];
}

- (void)setUpTableView {
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ASAppendCreditBankCell class]) bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    self.tableView.rowHeight = 52;
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.creditBanks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASAppendCreditBankCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    CreditBankModel *model = self.creditBanks[indexPath.row];
    cell.nameLabel.text = model.name;
    cell.checkbox.selected = [self.selectedIDs containsObject:model.id];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 改变状态
    ASAppendCreditBankCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.checkbox.selected = YES;
    // 存储值
    CreditBankModel *model = self.creditBanks[indexPath.row];
    [self.selectedIDs addObject:model.id];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 改变状态
    ASAppendCreditBankCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.checkbox.selected = NO;
    // 删除值
    CreditBankModel *model = self.creditBanks[indexPath.row];
    [self.selectedIDs removeObject:model.id];
}

#pragma mark - User Action

- (IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)confirmSelection:(id)sender {
    if (self.selectedIDs.count == 0) {
        [UIView showResultThenHideOnWindow:@"请至少选择一个银行" afterDelay:1.5];
        return;
    }
    [UIView showHUDLoadingOnWindow:@"正在添加授信银行"];
    WEAKSELF
    NSString *ids = [self.selectedIDs componentsJoinedByString:@","];
    [AFNManager postDataWithAPI:kResPathAppBankSXMyAdd andDictParam:@{@"banks": ids, @"rt": @(self.selectedIndex + 1)} modelName:nil requestSuccessed:^(id responseObject) {
        [UIView showResultThenHideOnWindow:@"添加成功"];
        [blockSelf dismissViewControllerAnimated:YES completion:nil];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [UIView showResultThenHideOnWindow:errorMessage afterDelay:1.5];
    }];
}

- (IBAction)tapTabBar:(UIButton *)sender {
    // UI状态改变
    for (UIButton *button in self.tabBars) {
        button.selected = (button == sender);
    }
    // 操作
    self.selectedIndex = sender.tag;
}

#pragma mark - Private Method

- (void)loadCreditBanks {
    [UIView showHUDLoadingOnWindow:nil];
    WEAKSELF
    [AFNManager getDataWithAPI:kResPathAppBankSXBankList andDictParam:nil modelName:ClassOfObject(CreditBankModel) requestSuccessed:^(id responseObject) {
        [UIView hideHUDLoadingOnWindow];
        blockSelf.creditBanks = responseObject;
        [blockSelf.tableView reloadData];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [UIView showResultThenHideOnWindow:errorMessage afterDelay:1.5];
    }];
}

#pragma mark - Property Getter

- (NSMutableArray<NSString *> *)selectedIDs {
    if (!_selectedIDs) {
        _selectedIDs = @[].mutableCopy;
    }
    return _selectedIDs;
}

@end
