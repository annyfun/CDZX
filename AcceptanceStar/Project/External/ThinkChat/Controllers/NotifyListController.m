//
//  NotifyListController.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-13.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "NotifyListController.h"
#import "UserDetailController.h"
#import "ChatViewController.h"
#import "GroupDetailController.h"
#import "NotifyCell.h"
#import "KAlertView.h"
#import "TCNotify.h"
#import "TCGroup.h"
#import "TCUser.h"
#import "User.h"
#import "AppDelegate.h"
#import "ASUserProfileViewController.h"

@interface NotifyListController () <UIActionSheetDelegate, TCResultNoneDelegate> {
    NSString*               identifierNotice;
    NotifyListRequestType   typeRequest;
}

@property (nonatomic, strong) TCNotify*       actionNotify;

@end

@implementation NotifyListController

@synthesize actionNotify;

- (id)init
{
    self = [super initWithNibName:@"NotifyListController" bundle:nil];
    if (self) {
        // Custom initialization
        [contentArr addObjectsFromArray:[[ThinkChat instance] getNotifyListTimeLineWithFinalNotify:nil]];
        if (contentArr.count >= defaultSizeInt) {
            hasMore = YES;
        }
        identifierNotice = @"NotifyCell";
        isGrouped = YES;
    }
    return self;
}

- (void)dealloc {
    self.actionNotify = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"通知";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotify:) name:kNotifyReceiveNotify object:nil];
    
    [self addBarButtonItemRightNormalImageName:@"nav_edit_n" hightLited:@"nav_edit_d"];
    
    [self registerNibForCellReuseIdentifier:identifierNotice];
}

- (void)barButtonItemRightPressed:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        listView.editing = !listView.editing;
    } completion:^(BOOL finished) {
        if (listView.editing) {
            [self addBarButtonItemRightNormalImageName:@"nav_ok_n" hightLited:@"nav_ok_d"];
        } else {
            [self addBarButtonItemRightNormalImageName:@"nav_edit_n" hightLited:@"nav_edit_d"];
        }
    }];
}

- (void)addMoreDataList {
    if (hasMore) {
        hasMore = NO;
        TCNotify* itemM = [contentArr lastObject];
        NSArray* arr = [[ThinkChat instance] getNotifyListTimeLineWithFinalNotify:itemM];
        if (arr.count >= defaultSizeInt) {
            hasMore = YES;
        }
        [contentArr addObjectsFromArray:arr];
        [listView reloadData];
    }
}

#pragma mark - TCNotify

- (void)receivedNotify:(NSNotification*)sender {
    TCNotify* itemN = sender.object;
    if (itemN.content.length > 0) {
        [contentArr insertObject:itemN atIndex:0];
        [listView reloadData];
    }
}

#pragma mark - Request

- (BOOL)sendRequest {
    if ([super sendRequest]) {
        if (typeRequest == forNotifyListRequestAgree) {
            if (actionNotify.type == forNotifyType_FriendApply) {
                [client agreeFriend:actionNotify.user.ID];
            } else if (actionNotify.type == forNotifyType_GroupInviteApply) {
                tagRequest = [[ThinkChat instance] agreeInviteJoinGroup:actionNotify.group.ID delegate:self];
            } else if (actionNotify.type == forNotifyType_GroupJoinApply) {
                tagRequest = [[ThinkChat instance] agreeApplyJoinGroup:actionNotify.group.ID user:actionNotify.user.ID delegate:self];
            }
        } else if (typeRequest == forNotifyListRequestDisagree) {
            if (actionNotify.type == forNotifyType_FriendApply) {
                [client refuseFriend:actionNotify.user.ID];
            } else if (actionNotify.type == forNotifyType_GroupInviteApply) {
                tagRequest = [[ThinkChat instance] refuseInviteJoinGroup:actionNotify.group.ID delegate:self];
            } else if (actionNotify.type == forNotifyType_GroupJoinApply) {
                tagRequest = [[ThinkChat instance] refuseApplyJoinGroup:actionNotify.group.ID user:actionNotify.user.ID delegate:self];
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL)getResponse:(BaseClient *)sender obj:(NSObject *)obj {
    if ([super getResponse:sender obj:obj]) {
        if (typeRequest == forNotifyListRequestAgree) {
            if (actionNotify.type == forNotifyType_FriendApply) {
                User* itemU = [User objectWithTCUser:actionNotify.user];
                [[AppDelegate instance] addFriend:itemU];
            }
        }
        
        [[ThinkChat instance] hasDoneNotify:actionNotify];
        [listView reloadData];
        [KAlertView showType:KAlertTypeCheck text:sender.errorMessage for:1.5 animated:YES];
        return YES;
    }
    return NO;
}

#pragma mark - TCResultNoneDelegate

- (void)tcResultNoneError:(TCError *)itemE {
    [super getResponse:nil obj:nil];
    if (itemE == nil) {
        
        [[ThinkChat instance] hasDoneNotify:actionNotify];
        [listView reloadData];
        [KAlertView showType:KAlertTypeCheck text:@"操作成功" for:1.5 animated:YES];
        
        if (typeRequest == forNotifyListRequestAgree) {
            if (actionNotify.type == forNotifyType_GroupInviteAgree) {
                [[AppDelegate instance] joinGroup:actionNotify.group];
            } else if (actionNotify.type == forNotifyType_GroupJoinApply) {
                [[AppDelegate instance] addGroupMember:actionNotify];
            }
        }
    } else {
        [KAlertView showType:KAlertTypeError text:itemE.message for:1.5 animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
    return contentArr.count;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)sender heightForHeaderInSection:(NSInteger)section {
    return 10.0;
}

- (CGFloat)tableView:(UITableView *)sender heightForFooterInSection:(NSInteger)section {
    if (section == [self numberOfSectionsInTableView:sender] - 1) {
        return 10.0;
    }
    return 0.0;
}

- (UIView*)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (UIView*)tableView:(UITableView *)sender viewForFooterInSection:(NSInteger)section {
    if (section == [self numberOfSectionsInTableView:sender] - 1) {
        return [[UIView alloc] init];
    }
    return nil;
}

// cell

- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NotifyCell heightWithItem:[contentArr objectAtIndex:indexPath.section]];
}

-(NSString*)tableView:(UITableView *)sender titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

//设置滑动，
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotifyCell* cell = [listView dequeueReusableCellWithIdentifier:identifierNotice];
    
    cell.notify = [contentArr objectAtIndex:indexPath.section];
    
    cell.isGrouped = isGrouped;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    self.actionNotify = [contentArr objectAtIndex:indexPath.section];
    
    if (actionNotify.isDone) {
        return;
    }
    
    id con = nil;
    UIActionSheet* sheet = nil;
    
    switch (actionNotify.type) {
        case forNotifyType_System:
            // 1   系统通知
            
            break;
        case forNotifyType_ConversationQuit:
            // 300 用户退出 会话
            
            break;
        case forNotifyType_ConversationRemove:
            // 301 管理员删除 会话用户
            
            break;
        case forNotifyType_ConversationEdit:
            // 302 管理员编辑 会话名称
            
            break;
        case forNotifyType_ConversationDele:
            // 303 管理员删除 会话
            
            break;
        case forNotifyType_ConversationKick:
            // 304 自己被踢出 会话
            
            break;
        case forNotifyType_GroupJoinApply:
            // 202 申请加 群
            sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"同意",@"拒绝",@"用户详细", nil];
            break;
        case forNotifyType_GroupJoinAgree:
            // 203 同意申请入 群
            
            break;
        case forNotifyType_GroupJoinRefuse:
            // 204 不同意申请入 群
            
            break;
        case forNotifyType_GroupInviteApply:
            // 205 邀请入 群
            sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"同意",@"拒绝",@"群组详细", nil];
            break;
        case forNotifyType_GroupInviteAgree:
            // 206 同意邀请入 群
            
            break;
        case forNotifyType_GroupInviteRefuse:
            // 207 不同意邀请入 群
            
            break;
        case forNotifyType_GroupKick:
            // 208 自己被踢出 群
            
            break;
        case forNotifyType_GroupQuit:
            // 209 成员退出 群
            
            break;
        case forNotifyType_GroupDele:
            // 210 管理员删除 群
            
            break;
        case forNotifyType_GroupRemove:
            // 211 管理员删除 群成员
            
            break;
        default:
            // 扩展通知
            if (actionNotify.type == forNotifyType_FriendApply) {
                // 申请加好友
                sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"同意",@"拒绝",@"用户详细", nil];
            } else if (actionNotify.type == forNotifyType_FriendAgree) {
                // 同意加好友
                
            } else if (actionNotify.type == forNotifyType_FriendRefuse) {
                // 拒绝加好友
                
            } else if (actionNotify.type == forNotifyType_FriendDelete) {
                // 解除好友关系
                
            }
            break;
    }
    
    if (con) {
        [self pushViewController:con];
    } else if (sheet) {
        [sheet showFromTabBar:self.tabBarController.tabBar];
    }
    
    if (!actionNotify.isRead) {
        [[AppDelegate instance] hasReadNotify:actionNotify];
        [listView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)tableView:(UITableView *)sender commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TCNotify* itemN = [contentArr objectAtIndex:indexPath.section];
        [[ThinkChat instance] hasDeleteNotify:itemN];
        [contentArr removeObject:itemN];
        [sender deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString* strTitle = [sender buttonTitleAtIndex:buttonIndex];
    if ([strTitle isEqualToString:@"取消"]) {
        return;
    }
    
    id con = nil;
    
    if ([strTitle isEqualToString:@"同意"]) {
        baseRequestType = forBaseListRequestOther;
        typeRequest = forNotifyListRequestAgree;
        [self sendRequest];
    } else if ([strTitle isEqualToString:@"拒绝"]) {
        baseRequestType = forBaseListRequestOther;
        typeRequest = forNotifyListRequestDisagree;
        [self sendRequest];
    } else if ([strTitle isEqualToString:@"用户详细"]) {
//        User* itemU = [[User alloc] init];
//        itemU.ID = actionNotify.user.ID;
//        itemU.nickName = actionNotify.user.name;
//        itemU.headImgUrlS = actionNotify.user.head;
//        con = [[UserDetailController alloc] initWithUser:itemU];
        
        con = (ASUserProfileViewController *)[UIResponder createBaseViewController:@"ASUserProfileViewController"];
        ((ASUserProfileViewController *)con).params = @{kParamUserId : Trim(actionNotify.user.ID)};
        
    } else if ([strTitle isEqualToString:@"群组详细"]) {
        con = [[GroupDetailController alloc] initWithGroup:actionNotify.group];
    }
    
    if (con) {
        [self pushViewController:con];
    }
}

@end
