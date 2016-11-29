//
//  ASReciveEViewController.m
//  AcceptanceStar
//
//  Created by Jinjin on 2016/11/29.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "ASReciveEViewController.h"
#import "ASTieXianShenQingTableViewCell.h"

@interface ASReciveEViewController ()
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

/*
 {
 "id": "1",
 "buid": null,
 "uid": "没有",
 "pid": "1",
 "type": "电票订单",
 "phone": "13228159788",
 "name": "测试",
 "address": null,
 "ticket_no": "12315",
 "bank_name": "中国建设银行",
 "price": "10",
 "pic": "img/2015-10-17/56213ce04a601.png",
 "exp": 1480475813,
 "status": "未完成",
 "date": null,
 "_buid": null,
 "_uid": "101945",
 "_type": "票据经纪",
 "_status": "1",
 "n_status": null,
 "_url": "/bondorder/index/id/1.html"
 }
 */

@implementation ASReciveEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"收到的贴现申请";
    
    self.dataSource = [NSMutableArray array];
   
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    self.tableView.backgroundColor = RGB(235, 235, 235);
    [self.tableView registerNib:[UINib nibWithNibName:@"ASTieXianShenQingTableViewCell" bundle:nil] forCellReuseIdentifier:@"ASTieXianShenQingTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestData];
}

- (void)requestData{
    
    WeakSelfType blockSelf = self;
    [AFNManager getDataWithAPI:@"/bond/bondorder_buy"
                  andDictParam:@{@"type":@"electric"}
                     modelName:ClassOfObject(TieXianModel)
              requestSuccessed:^(ElectricModel *responseObject) {
                  if ([responseObject isKindOfClass:[NSArray class]]) {
                      
                      blockSelf.dataSource = [responseObject mutableCopy];
                  }
                  [blockSelf.tableView reloadData];
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    [blockSelf showResultThenHide:@"刷新失败"];
                }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    id data = self.dataSource[indexPath.row];
    ASTieXianShenQingTableViewCell *cell = (ASTieXianShenQingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ASTieXianShenQingTableViewCell"];
    [cell bindReciveE:data];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WEAKSELF
   
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Overwrite
- (BOOL)resetAutolayout{
    return NO;
}
@end
