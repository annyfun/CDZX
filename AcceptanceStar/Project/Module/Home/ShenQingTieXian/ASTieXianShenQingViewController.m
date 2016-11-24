//
//  ASTieXianShenQingViewController.m
//  AcceptanceStar
//
//  Created by lcyu on 2016/11/24.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "ASTieXianShenQingViewController.h"
#import "ASReceivedTieXianShenQingTableViewCell.h"

@interface ASTieXianShenQingViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation ASTieXianShenQingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ASReceivedTieXianShenQingTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ASReceivedTieXianShenQingTableViewCell class])];
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
    ASReceivedTieXianShenQingTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ASReceivedTieXianShenQingTableViewCell class])];
    cell.tieXianModel = self.dataArray[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

-(void)requestData
{
    [UIView showHUDLoadingOnWindow:@""];
    [AFNManager postDataWithAPI:kResPathAppBondElectricOrder andDictParam:@{@"type":@"electric"} modelName:nil requestSuccessed:^(id responseObject) {
                [UIView hideHUDLoadingOnWindow];
                if([responseObject[@"data"] isKindOfClass:[NSArray class]])
                {
                    self.dataArray = [TieXianModel arrayOfModelsFromDictionaries:responseObject[@"data"]];
                }
                [self.tableView reloadData];
            } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                [UIView showResultThenHideOnWindow:errorMessage afterDelay:1.5];
            }];

}
@end
