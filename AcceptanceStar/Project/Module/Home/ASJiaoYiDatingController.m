//
//  ASJiaoYiDatingController.m
//  AcceptanceStar
//
//  Created by Jinjin on 2016/11/21.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "ASJiaoYiDatingController.h"
#import "YSCInfiniteLoopView.h"
#import "ASJiaoYiDatingCell.h"
#import "ASElectricViewController.h"
#import "MJRefresh.h"

@interface ASJiaoYiDatingController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet YSCInfiniteLoopView *infiniteLoopView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;

@property (nonatomic,strong) NSMutableArray *bannerArray;
@property (nonatomic,strong) NSMutableArray *electricModelArray;

@property (nonatomic,strong) NSString *rateKey;
@property (nonatomic,strong) NSString *amountKey;
@property (nonatomic,strong) NSString *daysKey;
@property (nonatomic,strong) NSString *bankNameKey;
@property (nonatomic,assign) NSInteger typeKey;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adHeight;
@end

@implementation ASJiaoYiDatingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
    WEAKSELF
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"筛选" style:UIBarButtonItemStylePlain handler:^(id sender) {
        
        NSMutableDictionary *dict = [@{@"actionBlock":^(NSString *rate,NSString *amount,NSString *days){
            
            blockSelf.rateKey = rate;
            blockSelf.amountKey = amount;
            blockSelf.daysKey = days;

            [blockSelf getList:blockSelf.rateKey price:blockSelf.amountKey];
        }} mutableCopy];
        
        if (blockSelf.rateKey) {
            [dict setObject:blockSelf.rateKey forKey:@"ASRate"];
        }
        if (blockSelf.amountKey) {
            [dict setObject:blockSelf.amountKey forKey:@"ASAmount"];
        }
        if (blockSelf.daysKey) {
            [dict setObject:blockSelf.daysKey forKey:@"ASDays"];
        }
        
        [blockSelf pushViewController:@"ASSearchEViewController" withParams:dict];
    }];
    
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ASJiaoYiDatingCell class]) bundle:nil] forCellReuseIdentifier:@"ASJiaoYiDatingCell"];
    
    
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [blockSelf refreshBanner];
        [blockSelf getList:blockSelf.rateKey price:blockSelf.amountKey];
    }];
    
    self.bannerArray = [self commonLoadCaches:@"keyOfCachedBanner"];
    [blockSelf layoutBannerView];
    [self refreshBanner];
    [self getList:nil price:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Layout
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
    
    [UIView animateWithDuration:0.3 animations:^{
       
        self.adHeight.constant = self.infiniteLoopView.totalPageCount?(SCREEN_WIDTH*(120.0/320)):0;
        
    }];
}

#pragma mark - Request
- (void)refreshBanner {
    WeakSelfType blockSelf = self;
    [AFNManager getDataWithAPI:kResPathAppSlideIndex
                  andDictParam:@{@"cat" : @"electric"}
                     modelName:ClassOfObject(BannerModel)
              requestSuccessed:^(id responseObject) {
                  if ([responseObject isKindOfClass:[NSArray class]]) {
                      if ([NSObject isNotEmpty:responseObject]) {
                          blockSelf.bannerArray = [NSMutableArray array];
                          [blockSelf.bannerArray addObjectsFromArray:responseObject];
                          [blockSelf layoutBannerView];
                      }
                  }
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    
                    NSLog(@"%@",errorMessage);
                }];
}

/*
 sort	N		利率类型排序，rt_1,rt_2,rt_3,rt_4
 price	N		票面金额（万） 500- , 0-500
 */
- (void)getList:(NSString *)sort price:(NSString *)price{
    
    NSMutableDictionary *params = [@{} mutableCopy];
    if (sort) {
        [params setObject:sort forKey:@"sort"];
    }
    if (price) {
        [params setObject:price forKey:@"price"];
    }
    if (self.daysKey) {
        [params setObject:self.daysKey forKey:@"days"];
    }
    [params setObject:[NSString stringWithFormat:@"%zd",self.typeKey] forKey:@"type"];
   
    if (self.bankNameKey) {
        [params setObject:self.bankNameKey forKey:@"company"];
    }
    
    WeakSelfType blockSelf = self;
    [AFNManager getDataWithAPI:@"/bond/electric"
                  andDictParam:params
                     modelName:ClassOfObject(ElectricModel)
              requestSuccessed:^(id responseObject) {
                  if ([responseObject isKindOfClass:[NSArray class]]) {
                      blockSelf.electricModelArray = [responseObject mutableCopy];
                      [blockSelf.tableView reloadData];

                  }
                  
                  [blockSelf.tableView.legendHeader endRefreshing];
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    
                    
                    [blockSelf.tableView.legendHeader endRefreshing];
                }];
}

#pragma mark - Event Methods
- (IBAction)bankBtnDidTap:(id)sender {
    self.typeKey = 0;
    [self getList:self.rateKey price:self.amountKey];
}
- (IBAction)piaoJuBtnDidTap:(id)sender {
    self.typeKey = 1;
    [self getList:self.rateKey price:self.amountKey];
}
- (IBAction)chouYanBtnDidTap:(id)sender {
}

- (IBAction)searchBtnDidTap:(id)sender{
    [self.searchField resignFirstResponder];
    [self textFieldDidEndEditing:self.searchField];
}

#pragma mark - UITextFieldDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    if (gestureRecognizer.view==self.searchField.superview) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{

    self.bankNameKey = textField.text;
    [self getList:self.rateKey price:self.amountKey];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return ceil(self.electricModelArray.count * 0.5);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 185;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSInteger loc = indexPath.row * 2;
    NSInteger len = ((loc+2)<=self.electricModelArray.count)?2:1;
    
    
    ASJiaoYiDatingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ASJiaoYiDatingCell"];
    cell.tag = indexPath.row;
    [cell loadData:[self.electricModelArray subarrayWithRange:NSMakeRange(loc, len)]];
    
    WeakSelfType ws = self;
    cell.didTap = ^(NSInteger index){
        if (index<ws.electricModelArray.count) {
            
            id model = ws.electricModelArray[index];
            if (model) {
                
                [ws pushViewController:@"ASElectricViewController"
                              withParams:@{kParamTitle : @"银行报价详细",
                                           kParamModel : model}];
            }
        }
    };
    return cell;
}


#pragma mark - Overwrite
- (BOOL)resetAutolayout{
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
     [self.view endEditing:YES];
}
@end
