//
//  ASTieXianShenQingViewController.m
//  AcceptanceStar
//
//  Created by lcyu on 2016/11/24.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "ASTieXianShenQingViewController.h"
#import "ASReceivedTieXianShenQingTableViewCell.h"
#import "ASTieXianShenQingTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ASShenQingTieXianViewController.h"

@interface ASTieXianShenQingViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *totalBtn;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation ASTieXianShenQingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if([self isCompany]){
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ASTieXianShenQingTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ASTieXianShenQingTableViewCell class])];
    } else {
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ASReceivedTieXianShenQingTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ASReceivedTieXianShenQingTableViewCell class])];
    }
    [self requestData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if([self isCompany]){
        ASTieXianShenQingTableViewCell *txCell =  [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ASTieXianShenQingTableViewCell class])];
        txCell.tieXianModel = self.dataArray[indexPath.row];
        cell = txCell;
    } else{
        ASReceivedTieXianShenQingTableViewCell *rtxCell =  [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ASReceivedTieXianShenQingTableViewCell class])];
        rtxCell.tieXianModel = self.dataArray[indexPath.row];
        cell = rtxCell;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self isCompany]){
        return [tableView fd_heightForCellWithIdentifier:NSStringFromClass([ASTieXianShenQingTableViewCell class]) configuration:^(ASTieXianShenQingTableViewCell *cell) {
            cell.tieXianModel = self.dataArray[indexPath.row];
        }];
    }
    return 56;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ASShenQingTieXianViewController *vc = [[ASShenQingTieXianViewController alloc] initWithTieXianModel:self.dataArray[indexPath.row] tieXianType:[self isCompany] ? TieXianTypeApply : TieXianTypeReceivedApply];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)requestData
{
    [UIView showHUDLoadingOnWindow:@""];
    [AFNManager postDataWithAPI: [self isCompany] ? kResPathAppBondSellElectricOrder :kResPathAppBondElectricOrder andDictParam:@{@"type":@"electric"} modelName:nil requestSuccessed:^(id responseObject) {
                [UIView hideHUDLoadingOnWindow];
                if([responseObject[@"data"][@"list"] isKindOfClass:[NSArray class]])
                {
                    self.dataArray = [TieXianModel arrayOfModelsFromDictionaries:responseObject[@"data"][@"list"]];
                }
                [self.totalBtn setTitle:[NSString stringWithFormat:@"今日贴现%@万元，累计贴现%@万元",responseObject[@"data"][@"today_price"],responseObject[@"data"][@"total_price"]] forState:UIControlStateNormal];
                [self.tableView reloadData];
            } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                [UIView showResultThenHideOnWindow:errorMessage afterDelay:1.5];
            }];
}

-(bool)isCompany
{
    return 2 == USER.itype;
}
@end
