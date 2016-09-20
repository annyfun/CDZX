//
//  ASLawyerOnlineViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/12/30.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "ASLawyerOnlineViewController.h"
#import "YSCInfiniteLoopView.h"
#import "ASLawyerOnlineCell.h"
#import "ChatViewController.h"

@interface ASLawyerOnlineViewController () <TCResultGroupDelegate>
@property (nonatomic, weak) IBOutlet YSCTableView *tableView;

@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet YSCInfiniteLoopView *infiniteLoopView;
@property (nonatomic, weak) IBOutlet UIView *searchContainerView;
@property (nonatomic, weak) IBOutlet YSCTextField *searchTextField;
@property (nonatomic, strong) NSMutableArray *bannerArray;
@end

@implementation ASLawyerOnlineViewController

- (void)viewDidiLoadExtension {
    [self layoutBannerView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.infiniteLoopView.backgroundColor = [UIColor clearColor];
    self.bannerArray = [NSMutableArray array];
    [self initTableView];
    
    self.searchContainerView.backgroundColor = [UIColor whiteColor];
    [self.searchContainerView makeRoundWithRadius:5];
    [self.searchContainerView makeBorderWithColor:kDefaultBorderColor borderWidth:1];
    WEAKSELF1
    self.searchTextField.textReturnBlock = ^(NSString *text) {
        [weakSelf.tableView beginRefreshing];
    };
}
- (void)refreshBanner {
    WeakSelfType blockSelf = self;
    NSString *cat = [self.params[kParamType] integerValue] == 0 ? @"caishui" : @"lvshi";
    [AFNManager getDataWithAPI:kResPathAppSlideIndex
                  andDictParam:@{@"cat" : cat}
                     modelName:ClassOfObject(BannerModel)
              requestSuccessed:^(id responseObject) {
                  [blockSelf.bannerArray removeAllObjects];
                  [blockSelf.bannerArray addObjectsFromArray:responseObject];
                  [blockSelf layoutBannerView];
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    NSLog(@"errmsg=%@", errorMessage);
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
- (void)initTableView {
    WEAKSELF1
    [self.headerView resetConstraintOfView];
    [self.headerView resetFontSizeOfView];
    self.headerView.height = AUTOLAYOUT_LENGTH(340);
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.headerName = @"ASLawyerOnlineHeaderView";
    self.tableView.cellName = @"ASLawyerOnlineCell";
    self.tableView.methodName = kResPathAppCaiShuiIndex;
    self.tableView.modelName = @"CaiShuiModel";
    self.tableView.enableTips = NO;
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf refreshBanner];
        [weakSelf.tableView refreshAtPageIndex:kDefaultPageStartIndex];
    }];
    self.tableView.preProcessBlock = ^NSArray *(NSArray *array) {
        for (CaiShuiModel *model in array) {
            model.sectionKey = model.cityzimu.uppercaseString;
        }
        return array;
    };
    self.tableView.dictParamBlock = ^NSDictionary *(NSInteger page) {
        return @{kParamType : Trim(weakSelf.params[kParamType]),
                 @"search" : Trim(weakSelf.searchTextField.text),
                 kParamPageIndex : @(page),
                 kParamPageSize : @(kDefaultPageSize)};
    };
    self.tableView.layoutCellView = ^(UIView *view, NSObject *object) {
        ASLawyerOnlineCell *cell = (ASLawyerOnlineCell *)view;
        CaiShuiModel *model = (CaiShuiModel *)object;
        [cell.chatView removeAllGestureRecognizers];
        [cell.chatView bk_whenTapped:^{
            if (NO == ISLOGGED) {
                [weakSelf pushViewController:@"ASLoginViewController"];
                return ;
            }
            
            //只根据用户id进行单聊
            [weakSelf showHUDLoading:@""];
            [AFNManager getDataWithAPI:kResPathAppUserDetail
                          andDictParam:@{@"fuid" : Trim(model.linkid)}
                             modelName:ClassOfObject(UserModel)
                      requestSuccessed:^(id responseObject) {
                          [weakSelf hideHUDLoading];
                          if (responseObject) {
                              UserModel *userModel = (UserModel *)responseObject;
                              User *user = [userModel createUser];
                              ChatViewController *chatVC = [[ChatViewController alloc] initWithUser:user];
                              [weakSelf.navigationController pushViewController:chatVC animated:YES];
                          }
                          else {
                              [weakSelf showResultThenHide:@"用户不存在"];
                          }
                      }
                        requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                            [weakSelf hideHUDLoading];
                            [weakSelf showAlertVieWithMessage:errorMessage];
                        }];
        }];
    };
    self.tableView.clickCellBlock = ^(NSObject *object, NSIndexPath *indexPath) {
        CaiShuiModel *model = (CaiShuiModel *)object;
        NSString *tempUrl = Trim(model.url);
        if (isNotEmpty(tempUrl) && NO == [tempUrl hasPrefix:@"http"]) {
            tempUrl = [NSString stringWithFormat:@"http://%@", tempUrl];
        }
        if ([tempUrl isUrl]) {
            [weakSelf pushViewController:@"ASWebViewViewController"
                              withParams:@{kParamTitle : Trim(model.name),
                                           kParamUrl : tempUrl}];
        }
    };
    [self.tableView beginRefreshing];
}

#pragma mark - TCResultGroupDelegate
- (void)tcResultGroup:(TCGroup*)itemG error:(TCError*)itemE {
    ChatViewController *chatVc = [[ChatViewController alloc] initWithGroup:itemG];
    chatVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVc animated:YES];
}

@end
