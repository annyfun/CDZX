//
//  ASHomeViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/26.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASHomeViewController.h"
#import "ASHomeCollectionViewCell.h"
#import "YSCInfiniteLoopView.h"
#import <AVOSCloud/AVOSCloud.h>

#define keyOfCachedBanner               @"keyOfCachedBanner"

@interface ASHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet YSCInfiniteLoopView *infiniteLoopView;
@property (nonatomic, strong) NSMutableArray *bannerArray;
@property (nonatomic, weak) IBOutlet UIButton *enterButton;//立即进入
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionHeight;
@property (nonatomic, strong) NSMutableArray *itemArray;

@end

@implementation ASHomeViewController

- (void)viewDidiLoadExtension {
    [self layoutBannerView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshBanner];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.infiniteLoopView.backgroundColor = [UIColor clearColor];
    self.bannerArray = [self commonLoadCaches:keyOfCachedBanner];
    
    [self initItemArray];
    [self initCollectionView];
    [self.enterButton makeBorderWithColor:RGB(62, 186, 237) borderWidth:1];
    [self.enterButton makeRoundWithRadius:5];
}
//弹出报价平台界面
- (void)presentQuotePlatformWithInitTabBarIndex:(NSInteger)tabBarIndex {
    UITabBarController *tabBarController = [self rootViewController];
    tabBarController.selectedIndex = tabBarIndex;
    [self presentViewController:tabBarController animated:YES completion:nil];
}
- (UITabBarController *)rootViewController {
    //top class of tabbar
    NSArray *tabClassArray = @[@"ASBuyViewController",         //买票信息
                               @"ASSellViewController",      //卖票信息
                               @"ASQuotePriceViewController",    //机构报价
                               @"ASReSaleViewController",     //转贴信息
                               @"ASRePurchaseViewController"];  //回购信息
    //normal tabbar icon
    NSArray *tabNormalImageArray = @[@"icon_tabbar_buy_normal",
                                     @"icon_tabbar_sale_normal",
                                     @"icon_tabbar_quoteprice_normal",
                                     @"icon_tabbar_repost_normal",
                                     @"icon_tabbar_buyback_normal"];
    //selected tabbar icon
    NSArray *tabSeletedImageArray = @[@"icon_tabbar_buy_selected",
                                      @"icon_tabbar_sale_selected",
                                      @"icon_tabbar_quoteprice_selected",
                                      @"icon_tabbar_repost_selected",
                                      @"icon_tabbar_buyback_selected"];
    NSArray *tabItemNamesArray = @[@"买票信息", @"卖票信息", @"机构报价", @"转贴信息", @"回购信息"];
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (NSUInteger i = 0; i < [tabClassArray count]; i++) {
        UIViewController *tabbarRootViewController = [UIResponder createBaseViewController:tabClassArray[i]];
        tabbarRootViewController.hidesBottomBarWhenPushed = NO;//NOTE:一级页面的tabbar不能隐藏
        tabbarRootViewController.navigationItem.title = tabItemNamesArray[i];
        UITabBarItem *tabbaritem = [[UITabBarItem alloc] initWithTitle:tabItemNamesArray[i]
                                                                 image:[UIImage imageNamed:tabNormalImageArray[i]]
                                                         selectedImage:[UIImage imageNamed:tabSeletedImageArray[i]]];
        //修改未选中时的image,否则会是灰色的
        @try {
            [tabbaritem setValue:[UIImage imageNamed:tabNormalImageArray[i]] forKey:@"unselectedImage"];
            [tabbaritem setValue:[UIImage imageNamed:tabSeletedImageArray[i]] forKey:@"selectedImage"];
        }
        @catch (NSException *exception) { }
        @finally { }
        //以下两行代码是调整image和label的位置
        tabbaritem.imageInsets = UIEdgeInsetsMake(-1, 0, 1, 0);
        [tabbaritem setTitlePositionAdjustment:UIOffsetMake(0, -2)];
        
        //创建navigationController
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tabbarRootViewController];
        navigationController.customNavigationDelegate = [[ADNavigationControllerDelegate alloc] init];
        navigationController.navigationController.navigationBar.translucent = YES;
        navigationController.tabBarItem = tabbaritem;
        [viewControllers addObject:navigationController];
    }
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = viewControllers;
    tabBarController.tabBar.barStyle = UIBarStyleDefault;
    //以下两行是去掉顶部阴影
    tabBarController.tabBar.backgroundColor = RGB(247, 247, 247);
    tabBarController.tabBar.tintColor = RGB(34, 108, 232);//设置选中后的图片颜色（这个必须有，否则会默认是蓝色）
    return tabBarController;
}
- (IBAction)enterButtonClicked:(id)sender {
    [self presentQuotePlatformWithInitTabBarIndex:1];
}
- (void)initCollectionView {
    [self.collectionView registerNib:[ASHomeCollectionViewCell NibNameOfCell] forCellWithReuseIdentifier:kItemCellIdentifier];
    self.collectionView.showsHorizontalScrollIndicator = NO;        //TODO:以后这里可以扩展
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.alwaysBounceVertical = NO;
}
- (void)initItemArray {
    self.itemArray = [NSMutableArray array];
    [self.itemArray addObject:[CommonItemModel buildNewItem:@"icon_home_notice" title:@"公示催告" viewController:@"ASDraftQueryViewController"]];
    [self.itemArray addObject:[CommonItemModel buildNewItem:@"icon_home_mymonitor" title:@"票据挂失预警" viewController:@"ASMyMonitorTicketsViewController"]];
    [self.itemArray addObject:[CommonItemModel buildNewItem:@"icon_financial_expert" title:@"财税专家" viewController:@"ASLawyerOnlineViewController"]];
    [self.itemArray addObject:[CommonItemModel buildNewItem:@"icon_lawyer_online" title:@"律师在线" viewController:@"ASLawyerOnlineViewController"]];
    [self.itemArray addObject:[CommonItemModel buildNewItem:@"icon_home_bankquery" title:@"行号查询" viewController:@"ASBankNumQueryViewController"]];
    [self.itemArray addObject:[CommonItemModel buildNewItem:@"icon_home_calculator" title:@"贴现计算器" viewController:@"ASDiscountCalculatorViewController"]];
    [self.itemArray addObject:[CommonItemModel buildNewItem:@"icon_home_shiborquery" title:@"shibor查询" viewController:@"ASShiBorQueryViewController"]];
    [self.itemArray addObject:[CommonItemModel buildNewItem:@"icon_home_newsdaily" title:@"票友日报" viewController:@"ASNewsDailyViewController"]];
    NSInteger rowCount = (NSInteger)([self.itemArray count] / 2);
    if ([self.itemArray count] % 2 != 0) {
        rowCount++;
    }
    self.collectionHeight.constant = AUTOLAYOUT_LENGTH(rowCount * (SCREEN_WIDTH>375?145:142));
}
- (void)refreshBanner {
    WeakSelfType blockSelf = self;
    [AFNManager getDataWithAPI:kResPathAppSlideIndex
                  andDictParam:@{@"cat" : @"index"}
                     modelName:ClassOfObject(BannerModel)
              requestSuccessed:^(id responseObject) {
                  if ([responseObject isKindOfClass:[NSArray class]]) {
                      if ([NSObject isNotEmpty:responseObject]) {
                          [blockSelf.bannerArray removeAllObjects];
                          
                          if ([[AVAnalytics getConfigParams:[NSString stringWithFormat:@"Review_%@",AppVersion]] boolValue]) {
                              for (BannerModel *item in responseObject) {
                                  if (![item.thumb isEqualToString:@"http://www.yhcd.net//thumb/slide/img/2015-09-24/800x600_0_1443085759_2273.jpg"]) {
                                      [blockSelf.bannerArray addObject:item];
                                  }
                              }
                          }else{
                              [blockSelf.bannerArray addObjectsFromArray:responseObject];
                          }
                          [blockSelf saveObject:responseObject forKey:keyOfCachedBanner];//缓存banner数组
                          [blockSelf layoutBannerView];
                      }
                  }
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    [blockSelf showResultThenHide:errorMessage];
                }];
}
- (void)layoutBannerView {
    WeakSelfType blockSelf = self;
    //设置数据源
    self.infiniteLoopView.pageViewAtIndex = ^UIView *(NSInteger pageIndex) {
        if (pageIndex >= [blockSelf.bannerArray count]) {
            return nil;
        }
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:blockSelf.infiniteLoopView.bounds];
        BannerModel *item = blockSelf.bannerArray[pageIndex];
        [imageView setImageWithURLString:item.thumb withFadeIn:NO];
        return imageView;
    };
    //设置点击事件
    self.infiniteLoopView.tapPageAtIndex = ^void(NSInteger pageIndex, UIView *contentView) {
        if (pageIndex >= 0 && pageIndex < [blockSelf.bannerArray count]) {
            BannerModel *item = blockSelf.bannerArray[pageIndex];
            [blockSelf pushViewController:@"ASWebViewViewController" withParams:@{kParamTitle : Trim(item.title), kParamUrl : Trim(item.url)}];
        }
    };
    self.infiniteLoopView.totalPageCount = [self.bannerArray count];
    [self.infiniteLoopView reloadData];
    if (1 == [self.bannerArray count]) {
        [self.infiniteLoopView.timer invalidate];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.itemArray count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ASHomeCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kItemCellIdentifier forIndexPath:indexPath];
    CommonItemModel *item = self.itemArray[indexPath.row];
    cell.backgroundColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.itemNameLabel.text = item.title;
    cell.iconImageView.image = [UIImage imageNamed:item.icon];
    cell.lineRightLabel.hidden = (indexPath.row % 2 == 1);
    cell.lineBottomLabel.hidden = indexPath.row >= 6;
    return cell;
}

#pragma mark - UICollectionFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return AUTOLAYOUT_SIZE_WH(320, SCREEN_WIDTH>375?145:142);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}
//cell的最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
//cell的最小列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CommonItemModel *item = self.itemArray[indexPath.row];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[kParamTitle] = Trim(item.title);
    if ([@"财税专家" isEqualToString:item.title]) {
        params[kParamType] = @"0";
    }
    else if ([@"律师在线" isEqualToString:item.title]) {
        params[kParamType] = @"1";
    }
    
    if ([NSString isNotEmpty:item.viewController]) {
        [self presentViewController:item.viewController withParams:params];
    }
}

@end
