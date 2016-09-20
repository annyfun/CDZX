//
//  ASShiBorQueryViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/30.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASShiBorQueryViewController.h"
#import "ASShiBorTableViewCell.h"

@interface ASShiBorQueryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (strong, nonatomic) NSDate *currentDate;
@property (weak, nonatomic) IBOutlet UILabel *currentDateLabel;
@end

@implementation ASShiBorQueryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(98, 82, 73);
    self.title = @"shibor查询";
    self.currentDate = [NSDate date];
    [UIView makeRoundForView:self.dateView withRadius:5];
    self.dataArray = [NSMutableArray array];
    [self initTableView];
    [self refreshShiBor];
    
    WEAKSELF
    [self.leftView bk_whenTapped:^{
        blockSelf.currentDate = [blockSelf.currentDate dateByAddingDays:-1];
        [blockSelf refreshShiBor];
    }];
    [self.rightView bk_whenTapped:^{
        blockSelf.currentDate = [blockSelf.currentDate dateByAddingDays:1];
        [blockSelf refreshShiBor];
    }];
}

- (void)setCurrentDate:(NSDate *)currentDate {
    _currentDate = currentDate;
    self.currentDateLabel.text = [currentDate stringWithFormat:DateFormat3];
}

- (void)refreshShiBor {
    WeakSelfType blockSelf = self;
    [self showHUDLoading:@"正在查询"];
    [AFNManager getDataWithAPI:kResPathAppShiborIndex
                  andDictParam:@{@"date" : [self.currentDate stringWithFormat:DateFormat3]}
                     modelName:ClassOfObject(ShiBorModel)
              requestSuccessed:^(id responseObject) {
                  [blockSelf hideHUDLoading];
                  NSArray *tempArray = responseObject;
                  [blockSelf.dataArray removeAllObjects];
                  if ([tempArray isKindOfClass:[NSArray class]] && [tempArray count] > 0) {
                      [blockSelf.dataArray addObjectsFromArray:tempArray];
                  }
                  [blockSelf.tableView reloadData];
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    [blockSelf showResultThenHide:errorMessage];
                }];
}

- (void)initTableView {
    [self.tableView registerNib:[ASShiBorTableViewCell NibNameOfCell] forCellReuseIdentifier:kCellIdentifier];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:[self edgeInsetsOfCellSeperator]];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:[self edgeInsetsOfCellSeperator]];
    }
}

- (UIEdgeInsets)edgeInsetsOfCellSeperator {
    return UIEdgeInsetsZero;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ASShiBorTableViewCell HeightOfCell];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASShiBorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    [cell layoutObject:self.dataArray[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:[self edgeInsetsOfCellSeperator]];
    }
}


@end
