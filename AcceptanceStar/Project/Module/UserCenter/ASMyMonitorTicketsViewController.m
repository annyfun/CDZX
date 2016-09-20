//
//  ASMyMonitorTicketsViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/9/17.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASMyMonitorTicketsViewController.h"
#import "ASMyMonitorTicketsCell.h"

@interface ASMyMonitorTicketsViewController ()
@property (weak, nonatomic) IBOutlet YSCTextField *searchKeyTextField;
@end

@implementation ASMyMonitorTicketsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WEAKSELF
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"添加" style:UIBarButtonItemStylePlain handler:^(id sender) {
        YSCResultBlock block = ^(NSObject *object) {
            [blockSelf.tableView.header beginRefreshing];
        };
        [blockSelf pushViewController:@"ASAddMonitorTicketViewController" withParams:@{kParamBlock : block}];
    }];
    self.searchKeyTextField.textChangedBlock = ^(NSString *text) {
        if (isEmpty(text)) {
            [blockSelf.tableView.header beginRefreshing];
        }
    };
    self.searchKeyTextField.textReturnBlock = ^(NSString *text) {
        [blockSelf searchButtonClicked:nil];
    };
}

- (IBAction)searchButtonClicked:(id)sender {
    [self hideKeyboard];
    if (isEmpty(self.searchKeyTextField.text)) {
        [self showResultThenHide:@"请输入票据号"];
        return ;
    }
    [self searchTicketByNo:Trim(self.searchKeyTextField.text)];
}

- (void)deleteTicketAtIndexPath:(NSIndexPath *)indexPath {
    CourtMyModel *model = self.dataArray[indexPath.row];
    WEAKSELF
    [self showHUDLoading:@"正在删除"];
    [AFNManager getDataWithAPI:kResPathAppCourtDel
                   andDictParam:@{@"id" : Trim(model.id)}
                      modelName:nil
               requestSuccessed:^(id responseObject) {
                   [blockSelf showResultThenHide:@"删除成功"];
                   [blockSelf.dataArray removeObjectAtIndex:indexPath.row];
                   [blockSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
               }
                 requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     [blockSelf hideHUDLoading];
                     [blockSelf showAlertVieWithMessage:errorMessage];
                 }];
}
//搜索票据
- (void)searchTicketByNo:(NSString *)number {
    WEAKSELF
    [self showHUDLoading:@"正在搜索"];
    [AFNManager getDataWithAPI:kResPathAppCourtSearchMy
                   andDictParam:@{@"no" : Trim(number)}
                      modelName:[CourtMyModel class]
               requestSuccessed:^(id responseObject) {
                   [blockSelf hideHUDLoading];
                   NSArray *array = (NSArray *)responseObject;
                   [blockSelf.dataArray removeAllObjects];
                   if (isNotEmpty(array)) {
                       [blockSelf.dataArray addObjectsFromArray:array];
                   }
                   blockSelf.isTipsViewHidden = [blockSelf.dataArray count] > 0;
                   [blockSelf.tableView reloadData];
               }
                 requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     [blockSelf hideHUDLoading];
                     [blockSelf showAlertVieWithMessage:errorMessage];
                 }];
}

#pragma mark - 重写基类方法
- (NSString *)methodWithPath {
    return kResPathAppCourtMy;
}
- (Class)modelClassOfData {
    return [CourtMyModel class];
}
- (NSString *)nibNameOfCell {
    return @"ASMyMonitorTicketsCell";
}
- (NSDictionary *)dictParamWithPage:(NSInteger)page {
    return @{kParamPage : @(page), kParamPageSize : @(kDefaultPageSize)};
}
- (void)clickedCell:(id)object atIndexPath:(NSIndexPath *)indexPath {
    CourtMyModel *model = (CourtMyModel *)object;
    [self pushViewController:@"ASDraftQueryViewController"
                       withParams:@{kParamNumber : Trim(model.tno)}];
}
- (NSString *)hintStringWhenNoData {
    return @"暂时没有您的预警票据哦";
}
-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteTicketAtIndexPath:indexPath];
    }
}

@end
