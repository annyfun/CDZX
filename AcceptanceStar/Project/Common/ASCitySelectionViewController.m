//
//  ASCitySelectionViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/7/26.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASCitySelectionViewController.h"
#import "ASCitySelectionHeader.h"
#import "YSCTableViewCell.h"
#import "AppDelegate.h"

@interface ASCitySelectionViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSInteger currentSection;
@property (nonatomic, assign) NSInteger currentRow;
@property (nonatomic, copy) YSCObjectResultBlock block;

@end

@implementation ASCitySelectionViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self performSelector:@selector(scrollTableViewToSection) withObject:nil afterDelay:0];
}
- (void)scrollTableViewToSection {
    if (self.params[kParamIndex] && self.currentSection >= 0 && self.currentRow >= 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentRow inSection:self.currentSection]
                              atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择地区";
    self.currentSection = -1;
    self.currentRow = 0;
    self.block = self.params[kParamBlock];
    
    //初始化传递进来的
    if (self.params[kParamIndex]) {
        NSInteger cityId = [self.params[kParamIndex] integerValue];
        for (int i = 0; i < [[AppDelegate instance].provinceArray count]; i++) {
            ASProvinceModel *p = [AppDelegate instance].provinceArray[i];
            for (int j = 0; j < [p.Cities count]; j++) {
                ASCityModel *c = p.Cities[j];
                if (c.id == cityId) {
                    self.currentSection = i;
                    self.currentRow = j;
                    break;
                }
            }
        }
    }
    [self initTableView];
}

- (void)initTableView {
    //1. 注册cell
    [self.tableView registerNib:[ASCitySelectionHeader NibNameOfView] forHeaderFooterViewReuseIdentifier:kHeaderIdentifier];
    [self.tableView registerNib:[YSCTableViewCell NibNameOfCell] forCellReuseIdentifier:kCellIdentifier];
    //2. 设置cell的分割线
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:[self edgeInsetsOfCellSeperator]];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:[self edgeInsetsOfCellSeperator]];
    }
    //3. 设置其他参数
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = kDefaultViewColor;
}
- (UIEdgeInsets)edgeInsetsOfCellSeperator {
    return AUTOLAYOUT_EDGEINSETS(0, 80, 0, 0);
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[AppDelegate instance].provinceArray count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == self.currentSection) {
        ASProvinceModel *province = [AppDelegate instance].provinceArray[section];
        return [province.Cities count];
    }
    else {
        return 0;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ASProvinceModel *province = [AppDelegate instance].provinceArray[section];
    ASCitySelectionHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderIdentifier];
    header.provinceLabel.text = province.State;
    WEAKSELF
    [header removeAllGestureRecognizers];
    [header bk_whenTapped:^{
        if (section == blockSelf.currentSection) {
            blockSelf.currentSection = -1;
            [blockSelf.tableView reloadData];
        }
        else {
            blockSelf.currentRow = 0;
            blockSelf.currentSection = section;
            [blockSelf.tableView reloadData];
            [blockSelf performSelector:@selector(scrollTableViewToSection) withObject:nil afterDelay:0];
        }
    }];
    return header;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return AUTOLAYOUT_LENGTH(90);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YSCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    ASProvinceModel *province = [AppDelegate instance].provinceArray[indexPath.section];
    ASCityModel *city = province.Cities[indexPath.row];
    cell.subtitleLeftTitleLabel.text = [NSString stringWithFormat:@"      %@", city.city];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AUTOLAYOUT_LENGTH(88);
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ASProvinceModel *province = [AppDelegate instance].provinceArray[indexPath.section];
    ASCityModel *city = province.Cities[indexPath.row];
    if (self.block) {
        self.block(city, nil);
        [self backViewController];
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:[self edgeInsetsOfCellSeperator]];
    }
}

@end
