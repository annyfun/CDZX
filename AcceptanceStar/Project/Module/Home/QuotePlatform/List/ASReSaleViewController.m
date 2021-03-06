//
//  ASRepostInfromationViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/6/1.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASReSaleViewController.h"
#import "YSCInfiniteLoopView.h"
#import "ASPopView.h"

#define keyOfCachedBanner               @"keyOfCachedBanner"

@interface ASReSaleViewController ()
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet YSCInfiniteLoopView *infiniteLoopView;
@property (nonatomic, strong) NSMutableArray *bannerArray;
@property (nonatomic, strong) ASPopView *asPopView;
@end

@implementation ASReSaleViewController


- (void)viewDidiLoadExtension {
    [self layoutBannerView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.asPopView = [ASPopView CreatePaymentView:PriceTypeReSale];
    self.asPopView.hidden = YES;
    WeakSelfType blockSelf = self;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"arrow_left_white"] style:UIBarButtonItemStyleDone handler:^(id sender) {
        [blockSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"btn_more"] style:UIBarButtonItemStyleDone handler:^(id sender) {
        blockSelf.asPopView.hidden = NO;
    }];
    
    //banner
    self.headerView.width = SCREEN_WIDTH;
    self.headerView.height = AUTOLAYOUT_LENGTH(305);
    [self.headerView resetFontSizeOfView];
    [self.headerView resetConstraintOfView];
    self.headerView.backgroundColor = [UIColor clearColor];
    self.infiniteLoopView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.bannerArray = [self commonLoadCaches:keyOfCachedBanner];
    
    addNObserver(@selector(refreshByNotification), kNotificationRefreshReSaleList);
}
- (void)refreshByNotification {
    [self.tableView.header beginRefreshing];

}

//------------------------------------
//
// banner
//
//------------------------------------
- (void)refreshBanner {
    WeakSelfType blockSelf = self;
    [AFNManager getDataWithAPI:kResPathAppSlideIndex
                  andDictParam:@{@"cat" : @"resale"}
                     modelName:ClassOfObject(BannerModel)
              requestSuccessed:^(id responseObject) {
                  if ([responseObject isKindOfClass:[NSArray class]]) {
                      if ([NSObject isNotEmpty:responseObject]) {
                          [blockSelf.bannerArray removeAllObjects];
                          [blockSelf.bannerArray addObjectsFromArray:responseObject];
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
        BannerModel *item = blockSelf.bannerArray[pageIndex];
        if ([NSString isUrl:item.url]) {
            [blockSelf pushViewController:@"ASWebViewViewController"
                               withParams:@{kParamTitle : Trim(blockSelf.navigationItem.title),
                                            kParamUrl : Trim(item.url)}];
        }
    };
    self.infiniteLoopView.totalPageCount = [self.bannerArray count];
    [self.infiniteLoopView reloadData];
    if (1 == [self.bannerArray count]) {
        [self.infiniteLoopView.timer invalidate];
    }
}

#pragma mark - 重写基类方法
- (UIEdgeInsets)edgeInsetsOfCellSeperator {
    return UIEdgeInsetsZero;
}
- (void)refreshWithSuccessed:(PullToRefreshSuccessed)successed failed:(PullToRefreshFailed)failed {
    [super refreshWithSuccessed:successed failed:failed];
    [self refreshBanner];
}
- (NSString *)methodWithPath {
    return kResPathAppBondResale;
}
- (NSDictionary *)dictParamWithPage:(NSInteger)page {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[kParamPageIndex] = @(page);
    params[kParamPageSize] = @(kDefaultPageSize);
    [params addEntriesFromDictionary:LOGIN.sortParams];
    return params;
}
- (Class)modelClassOfData {
    return ClassOfObject(BondReSaleModel);
}
- (NSString *)nibNameOfCell {
    return @"ASReSaleCell";
}
- (void)clickedCell:(id)object atIndexPath:(NSIndexPath *)indexPath {
    WEAKSELF
    YSCResultBlock refreshBlock = ^(NSObject *object) {
        [blockSelf.tableView.header beginRefreshing];
    };
    [self pushViewController:@"ASPriceDetailViewController"
                  withParams:@{kParamTitle : self.navigationItem.title,
                               kParamBlock : refreshBlock,
                               kParamPriceType : @(PriceTypeReSale),
                               kParamModel : object}];
}

@end
