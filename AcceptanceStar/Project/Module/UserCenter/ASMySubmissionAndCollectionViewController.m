//
//  ASMyCollectionViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/29.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASMySubmissionAndCollectionViewController.h"
#import <HMSegmentedControl/HMSegmentedControl.h>

@interface ASMySubmissionAndCollectionViewController ()
@property (weak, nonatomic) IBOutlet HMSegmentedControl *hmSegmentedControl;
@property (strong, nonatomic) NSArray *paramArray;
@property (strong, nonatomic) NSArray *cellArray;
@property (strong, nonatomic) NSArray *classArray;
@end

@implementation ASMySubmissionAndCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSegmentedControl];
    self.paramArray = @[@"buy",@"sell",@"company",@"resale",@"repurchase"];
    self.cellArray = @[@"ASBuyCell",@"ASSellCell",@"ASQuotePriceCell",@"ASReSaleCell",@"ASRePurchaseCell"];
    for (NSString *cellIdentifier in self.cellArray) {
        [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    }
    self.classArray = @[BondBuyModel.class,
                        BondSellModel.class,
                        QuotePriceModel.class,
                        BondReSaleModel.class,
                        BondRePurchaseModel.class];
    
    
}

- (void)initSegmentedControl {
    //添加自定义segmentControl
    self.hmSegmentedControl.backgroundColor = [UIColor clearColor];
    self.hmSegmentedControl.sectionTitles = @[@"买票信息", @"卖票信息", @"机构报价", @"转贴信息", @"回购信息"];
    self.hmSegmentedControl.layer.borderWidth = AUTOLAYOUT_LENGTH(1);
    self.hmSegmentedControl.layer.borderColor = kDefaultNaviBarColor.CGColor;
    //设置选中和默认的字体颜色
    self.hmSegmentedControl.font = AUTOLAYOUT_FONT(26);
    self.hmSegmentedControl.textColor = kDefaultNaviBarColor;
    self.hmSegmentedControl.selectedTextColor = [UIColor whiteColor];
    //设置选中和不选中的背景颜色
    self.hmSegmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    self.hmSegmentedControl.selectionIndicatorHeight = .0f;
    self.hmSegmentedControl.selectionIndicatorBoxOpacity = 1.0f;//不透明
    self.hmSegmentedControl.backgroundColor = [UIColor clearColor];
    self.hmSegmentedControl.selectionIndicatorColor = kDefaultNaviBarColor;
    //设置默认值
    self.hmSegmentedControl.selectedSegmentIndex = 0; //默认选中第一个
    self.hmSegmentedControl.shouldAnimateUserSelection = NO;
    //响应点击事件
    WEAKSELF
    [self.hmSegmentedControl setIndexChangeBlock:^(NSInteger pageIndex) {
        [blockSelf.dataArray removeAllObjects];
        [blockSelf.tableView reloadData];
        [blockSelf.tableView.header beginRefreshing];
    }];
    
    self.hmSegmentedControl.indexChangeBlock(0);
}

#pragma mark - 重写基类方法

- (NSString *)methodWithPath {
    if (0 == [self.params[kParamIndex] integerValue]) {//我的发布
        return kResPathAppCollectMyAdd;
    }
    else {//我的收藏
        return kResPathAppCollectMyCollect;
    }
}
- (NSDictionary *)dictParamWithPage:(NSInteger)page {
    return @{@"type" : self.paramArray[self.hmSegmentedControl.selectedSegmentIndex]};
}
- (Class)modelClassOfData {
    return self.classArray[self.hmSegmentedControl.selectedSegmentIndex];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id objectModel = nil;
    if (indexPath.row < [self.dataArray count]) {
        objectModel = [self.dataArray objectAtIndex:indexPath.row];
    }
    NSString *cellIdentifier = self.cellArray[self.hmSegmentedControl.selectedSegmentIndex];
    YSCBaseTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ([cell isKindOfClass:[YSCBaseTableViewCell class]]) {
        [(YSCBaseTableViewCell *)cell layoutDataModel:objectModel];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id objectModel = nil;
    if (indexPath.row < [self.dataArray count]) {
        objectModel = [self.dataArray objectAtIndex:indexPath.row];
    }
    NSString *nibName = self.cellArray[self.hmSegmentedControl.selectedSegmentIndex];
    if ([NSClassFromString(nibName) isSubclassOfClass:[YSCBaseTableViewCell class]]) {
        return [NSClassFromString(nibName) HeightOfCell];
    }
    return 100;
}
- (void)clickedCell:(id)object atIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.hmSegmentedControl.sectionTitles[self.hmSegmentedControl.selectedSegmentIndex];
    [self pushViewController:@"ASPriceDetailViewController"
                  withParams:@{kParamTitle : Trim(title),
                               kParamPriceType : @(self.hmSegmentedControl.selectedSegmentIndex + 1),
                               kParamModel : object}];
}

@end
