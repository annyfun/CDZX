//
//  ASGroupManageViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/9/5.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASGroupManageViewController.h"
#import "ASGroupCell.h"

@interface ASGroupManageViewController ()

@end

@implementation ASGroupManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([@"分组管理" isEqualToString:self.params[kParamTitle]]) {
        WEAKSELF
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"button_add1"] style:UIBarButtonItemStylePlain handler:^(id sender) {
            UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"创建新的分组"];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField *textField = [alertView textFieldAtIndex:0];
            [alertView bk_addButtonWithTitle:@"添加" handler:^{
                [blockSelf addGroup:textField.text];
            }];
            [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
            [alertView show];
        }];
    }
}

- (UIViewController *)backViewController {
    if ([@"分组管理" isEqualToString:self.params[kParamTitle]]) {
        if (self.block) {
            self.block(nil);
        }
    }
    return [super backViewController];
}

- (NSString *)methodWithPath {
    return kResPathAppUserFriendListWithGroup;
}
- (Class)modelClassOfData {
    return ClassOfObject(UserGroupModel);
}
- (NSString *)nibNameOfCell {
    return @"ASGroupCell";
}
- (NSArray *)preProcessData:(NSArray *)anArray {
    if ([@"分组管理" isEqualToString:self.params[kParamTitle]]) {
        return anArray;
    }
    //NOTE:移动分组的时候要过滤掉当前用户所在的分组名称
    NSMutableArray *retArray = [NSMutableArray array];
    for (UserGroupModel *group in anArray) {
        if (![group.name isEqualToString:self.params[@"groupName"]]) {
            [retArray addObject:group];
        }
    }
    return retArray;
}
- (UIView *)layoutCellWithData:(id)object atIndexPath:(NSIndexPath *)indexPath {
    ASGroupCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    UserGroupModel *group = (UserGroupModel *)object;
    cell.groupNameLabel.text = group.name;
    if ([@"分组管理" isEqualToString:self.params[kParamTitle]]) {
        cell.deleteImageView.hidden = (group.system || [group.name isEqualToString:@"我的好友"]);
        WEAKSELF
        [cell.deleteImageView removeAllGestureRecognizers];
        [cell.deleteImageView bk_whenTapped:^{
            NSString *msg = [NSString stringWithFormat:@"确定要删除分组[%@]", group.name];
            UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:msg];
            [alertView bk_addButtonWithTitle:@"删除" handler:^{
               [blockSelf deleteGroup:group.name];
            }];
            [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
            [alertView show];
            
        }];
    }
    else {
        cell.deleteImageView.hidden = YES;
    }
    return cell;
}
- (void)clickedCell:(id)object atIndexPath:(NSIndexPath *)indexPath {
    UserGroupModel *group = (UserGroupModel *)object;
    if ([@"分组管理" isEqualToString:self.params[kParamTitle]]) {
        if ((NO == group.system) && (NO == [group.name isEqualToString:@"我的好友"])) {
            WEAKSELF
            UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"重命名分组"];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField *textField = [alertView textFieldAtIndex:0];
            textField.text = group.name;
            [alertView bk_addButtonWithTitle:@"修改" handler:^{
                [blockSelf renameGroup:group.name toName:textField.text];
            }];
            [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
            [alertView show];
        }
    }
    else {
        [self moveUser:self.params[@"fuid"] toGroup:group.name];
    }
}


- (void)moveUser:(NSString *)fuid toGroup:(NSString *)name {
    WEAKSELF
    [self showHUDLoading:@"正在移动"];
    [AFNManager postDataWithAPI:kResPathAppUserGroup
                   andDictParam:@{@"fuid" : Trim(fuid), @"name" : Trim(name)}
                      modelName:nil
               requestSuccessed:^(id responseObject) {
                   [blockSelf showResultThenBack:@"操作成功"];
                   if (blockSelf.block) {
                       blockSelf.block(name);
                   }
               } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                   [blockSelf hideHUDLoading];
                   [blockSelf showAlertVieWithMessage:errorMessage];
               }];
}

- (void)addGroup:(NSString *)name {
    WEAKSELF
    [self showHUDLoading:@"正在添加"];
    [AFNManager postDataWithAPI:kResPathAppUserGroup
                   andDictParam:@{@"name" : Trim(name)}
                      modelName:nil
               requestSuccessed:^(id responseObject) {
                   [blockSelf showResultThenHide:@"添加成功"];
                   [blockSelf.tableView.header beginRefreshing];
               } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                   [blockSelf hideHUDLoading];
                   [blockSelf showAlertVieWithMessage:errorMessage];
               }];
}
- (void)deleteGroup:(NSString *)name {
    WEAKSELF
    [self showHUDLoading:@"正在删除"];
    [AFNManager postDataWithAPI:kResPathAppUserDelGroup
                   andDictParam:@{@"name" : Trim(name)}
                      modelName:nil
               requestSuccessed:^(id responseObject) {
                   [blockSelf showResultThenHide:@"删除成功"];
                   [blockSelf.tableView.header beginRefreshing];
               } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                   [blockSelf hideHUDLoading];
                   [blockSelf showAlertVieWithMessage:errorMessage];
               }];
}

- (void)renameGroup:(NSString *)name toName:(NSString *)rename {
    if (isEmpty(rename)) {
        [self showResultThenHide:@"分组名称不能为空"];
        return;
    }
    
    WEAKSELF
    [self showHUDLoading:@"正在修改"];
    [AFNManager postDataWithAPI:kResPathAppUserRenameGroup
                   andDictParam:@{@"name" : Trim(name), @"rename" : Trim(rename)}
                      modelName:nil
               requestSuccessed:^(id responseObject) {
                   [blockSelf showResultThenHide:@"修改成功"];
                   [blockSelf.tableView.header beginRefreshing];
               } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                   [blockSelf hideHUDLoading];
                   [blockSelf showAlertVieWithMessage:errorMessage];
               }];
}

@end
