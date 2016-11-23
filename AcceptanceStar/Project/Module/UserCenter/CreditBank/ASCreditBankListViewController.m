//
//  ASCreditBankListViewController.m
//  AcceptanceStar
//
//  Created by benson on 11/21/16.
//  Copyright © 2016 Builder. All rights reserved.
//

#import "ASCreditBankListViewController.h"
#import "ASAppendCreditBankViewController.h"
#import "ASCreditBankCell.h"

@interface ASCreditBankListViewController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *tabbars; // 顺序(一类,二类,三类,四类)
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIView *emptyView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuHeightConstraint;

@property (strong, nonatomic) NSArray<CreditBankModel *> *creditBanks;
@property (assign, nonatomic) NSInteger selectedIndex;  // 选中类索引
@end

@implementation ASCreditBankListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = @"授信银行";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCreditBank:)];
    [self setUpTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 触发事件
    [self.tabbars[self.selectedIndex] sendActionsForControlEvents:UIControlEventTouchUpInside];
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
    [UIView animateWithDuration:0.3 animations:^{
        self.menuBottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - User Action

- (IBAction)tapTabBar:(UIButton *)sender {
    // UI状态改变
    for (UIButton *button in self.tabbars) {
        button.selected = (button == sender);
    }
    // 操作
    self.selectedIndex = sender.tag;
    [self loadCreditBanksWithIndex:sender.tag];
}

- (void)addCreditBank:(id)sender {
    ASAppendCreditBankViewController *appendVC = [[ASAppendCreditBankViewController alloc] init];
    appendVC.selectedIndex = self.selectedIndex;
    [self presentViewController:appendVC animated:YES completion:nil];
}

/// Menu

// 取消
- (IBAction)cancelMenu:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.menuBottomConstraint.constant = -self.menuHeightConstraint.constant;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.menuView.hidden = YES;
    }];
}

// 取消授信
- (IBAction)removeCreditBank:(id)sender {
    [UIView showHUDLoadingOnWindow:@"正在取消授信"];
    NSInteger selectedRow = [self.tableView indexPathForSelectedRow].row;
    CreditBankModel *model = self.creditBanks[selectedRow];
    WEAKSELF
    [AFNManager postDataWithAPI:kResPathAppBankSXMyDel andDictParam:@{@"id": model.id} modelName:nil requestSuccessed:^(id responseObject) {
        [UIView hideHUDLoadingOnWindow];
        blockSelf.menuView.hidden = YES;
        blockSelf.menuBottomConstraint.constant = -blockSelf.menuHeightConstraint.constant;
        [blockSelf loadCreditBanksWithIndex:self.selectedIndex];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [UIView showResultThenHideOnWindow:errorMessage afterDelay:1.5];
    }];
}

// 调整授信类别
- (IBAction)setCreditBankIndex:(UIButton *)sender {
    [UIView showHUDLoadingOnWindow:@"正在调整授信"];
    NSInteger selectedRow = [self.tableView indexPathForSelectedRow].row;
    CreditBankModel *model = self.creditBanks[selectedRow];
    WEAKSELF
    [AFNManager postDataWithAPI:kResPathAppBankSXMyUpdate andDictParam:@{@"id": model.id, @"rt": @(sender.tag)} modelName:nil requestSuccessed:^(id responseObject) {
        [UIView hideHUDLoadingOnWindow];
        blockSelf.menuView.hidden = YES;
        blockSelf.menuBottomConstraint.constant = -blockSelf.menuHeightConstraint.constant;
        [blockSelf loadCreditBanksWithIndex:self.selectedIndex];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [UIView showResultThenHideOnWindow:errorMessage afterDelay:1.5];
    }];
}

#pragma mark - Private Method

- (void)loadCreditBanksWithIndex:(NSInteger)index {
    [UIView showHUDLoadingOnWindow:nil];
    WEAKSELF
    [AFNManager getDataWithAPI:kResPathAppBankSXMyList andDictParam:@{@"rt": @(index + 1)} modelName:ClassOfObject(CreditBankModel) requestSuccessed:^(id responseObject) {
        [UIView hideHUDLoadingOnWindow];
        blockSelf.creditBanks = responseObject;
        [blockSelf.tableView reloadData];
        if (blockSelf.creditBanks.count == 0) {
            blockSelf.tableView.backgroundView = blockSelf.emptyView;
        } else {
            blockSelf.tableView.backgroundView = nil;
        }
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [UIView showResultThenHideOnWindow:errorMessage afterDelay:1.5];
    }];
}

#pragma mark - Property Getter

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [UIView new];
        _emptyView.backgroundColor = [UIColor clearColor];
        UILabel *guideLabel = [UILabel new];
        guideLabel.text = @"授信银行为空，请点击右上角添加";
        guideLabel.font = [UIFont systemFontOfSize:15];
        [_emptyView addSubview:guideLabel];
        [guideLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_emptyView);
        }];
    }
    return _emptyView;
}

@end
