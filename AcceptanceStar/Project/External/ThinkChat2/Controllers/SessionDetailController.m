//
//  SessionDetailController.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-25.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "SessionDetailController.h"
#import "UserDetailController.h"
#import "SessionNewController.h"
#import "SingleTextFieldController.h"
#import "MemberCell.h"
#import "TCSession.h"
#import "TCUser.h"
#import "AppDelegate.h"

@interface SessionDetailController () <MemberCellDelegate, SessionNewDelegate, TCResultGroupDelegate, TCResultNoneDelegate> {
    IBOutlet UISwitch*  swtGetMsg;
    IBOutlet UIView*    footerView;
    IBOutlet UIButton*  btnQuit;
    
    SessionDetailRequestType typeRequest;
}

@property (nonatomic, strong) TCSession*    session;
@property (nonatomic, strong) TCGroup*      group;
@property (nonatomic, strong) User*         userChoose;

@end

@implementation SessionDetailController

@synthesize session;
@synthesize group;
@synthesize userChoose;

- (id)initWithSession:(TCSession *)item
{
    self = [super initWithNibName:@"SessionDetailController" bundle:nil];
    if (self) {
        // Custom initialization
        self.session = item;
    }
    return self;
}

- (void)dealloc {
    self.session = nil;
    swtGetMsg = nil;
    footerView = nil;
    btnQuit = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitGroup:) name:kNotifyQuitGroup object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editGroup:) name:kNotifyEditGroup object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addGroupMember:) name:kNotifyAddGroupMember object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteGroupMember:) name:kNotifyDeleteGroupMember object:nil];

    self.navigationItem.title = session.name;
    
    swtGetMsg.onTintColor = kColorBtnBkgBlue;
    
    [btnQuit setTitleColor:kColorWhite forState:UIControlStateNormal];
    [btnQuit setTitleColor:kColorWhite forState:UIControlStateHighlighted];
    btnQuit.titleLabel.font = [UIFont systemFontOfSize:17];
    [btnQuit setBackgroundImage:[UIImage imageWithColor:kColorBtnBkgRed] forState:UIControlStateNormal];
    btnQuit.layer.cornerRadius = kCornerRadiusButton;
    btnQuit.clipsToBounds = YES;
    
    if (session.typeChat == forChatTypeUser) {
        User* itemU = [User objectWithTCUser:session.user];
        [contentArr addObject:itemU];
    } else {
        [btnQuit setTitle:@"退出" forState:UIControlStateNormal];
        listView.tableFooterView = footerView;
        [self sendRequest];
    }
}

- (void)btnPressed:(id)sender {
    if (sender == btnQuit) {
        if (group.isAdmin) {
            typeRequest = forSessionDetailRequest_Delete;
        } else {
            typeRequest = forSessionDetailRequest_Quit;
        }
        baseRequestType = forBaseListRequestOther;
        [self sendRequest];
    }
}

- (IBAction)switchValueChanged:(id)sender {
    baseRequestType = forBaseListRequestOther;
    typeRequest = forSessionDetailRequest_IsGetMsg;
    [self sendRequest];
}

- (void)cleanMessage {
    [[AppDelegate instance] clearSessionID:session.ID typeChat:session.typeChat];
    [KAlertView showType:KAlertTypeCheck text:@"已成功删除聊天记录" for:1.5 animated:YES];
}

- (void)quitGroup:(NSNotification*)sender {
    TCGroup* itemG = (TCGroup*)sender.object;
    if ([self isCurrentGroup:itemG]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)editGroup:(NSNotification*)sender {
    TCGroup* itemG = (TCGroup*)sender.object;
    if ([self isCurrentGroup:itemG]) {
        
        session.name = itemG.name;
        session.head = itemG.headImgUrlS;
        
        self.navigationItem.title = session.name;
        [listView reloadData];
    }
}

- (void)addGroupMember:(NSNotification*)sender {
    TCNotify* itemN = sender.object;
    TCGroup* itemG = itemN.group;
    if ([self isCurrentGroup:itemG]) {
        baseRequestType = forBaseListRequestDataList;
        [self sendRequest];
    }
}

- (void)deleteGroupMember:(NSNotification*)sender {
    TCNotify* itemN = sender.object;
    TCGroup* itemG = itemN.group;
    if ([self isCurrentGroup:itemG]) {
        baseRequestType = forBaseListRequestDataList;
        [self sendRequest];
    }
}

- (BOOL)isCurrentGroup:(TCGroup*)itemG {
    if (((itemG.type == forTCGroupType_Group &&
          session.typeChat == forChatTypeGroup) || (
                                                    itemG.type == forTCGroupType_Temp &&
                                                    session.typeChat == forChatTypeRoom)) && [
                                                                                            itemG.ID isEqualToString:session.ID]) {
        return YES;
    }
    return NO;
}

#pragma mark - Request

- (BOOL)sendRequest {
    if ([super sendRequest]) {
        if (baseRequestType == forBaseListRequestDataList) {
            tagRequest = [[ThinkChat instance] getConversationDetail:session.ID delegate:self];
        } else if (baseRequestType == forBaseListRequestOther) {
            if (typeRequest == forSessionDetailRequest_Kick) {
                tagRequest = [[ThinkChat instance] deleteUser:userChoose.ID fromConversation:session.ID delegate:self];
            } else if (typeRequest == forSessionDetailRequest_Quit) {
                tagRequest = [[ThinkChat instance] quitConversation:group.ID delegate:self];
            } else if (typeRequest == forSessionDetailRequest_Delete) {
                tagRequest = [[ThinkChat instance] deleteConversation:group.ID delegate:self];
            } else if (typeRequest == forSessionDetailRequest_IsGetMsg) {
                tagRequest = [[ThinkChat instance] setConversation:group.ID isGetMessage:!group.isGetMessage delegate:self];
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL)getResponse:(BaseClient *)sender obj:(NSObject *)obj {
    if ([super getResponse:sender obj:obj]) {
        return YES;
    }
    return NO;
}

#pragma mark - TCResultNoneDelegate

- (void)tcResultNoneError:(TCError *)itemE {
    [super getResponse:nil obj:nil];
    if (itemE == nil) {
        if (baseRequestType == forBaseListRequestOther) {
            if (typeRequest == forSessionDetailRequest_Kick) {
                [KAlertView showType:KAlertTypeCheck text:@"删除成功" for:1.5 animated:YES];
                [contentArr removeObject:userChoose];
                [listView reloadData];
            } else if (typeRequest == forSessionDetailRequest_Quit) {
                group.isLeave = YES;
                [[AppDelegate instance] quitGroup:group];
                [self popViewController];
            } else if (typeRequest == forSessionDetailRequest_Delete) {
                group.isLeave = YES;
                [[AppDelegate instance] quitGroup:group];
                [self popViewController];
            } else if (typeRequest == forSessionDetailRequest_IsGetMsg) {
                group.isGetMessage = !group.isGetMessage;
                [swtGetMsg setOn:group.isGetMessage animated:YES];
                [KAlertView showType:KAlertTypeCheck text:@"设置成功" for:1.5 animated:YES];
            }
        }
    } else {
        [KAlertView showType:KAlertTypeError text:itemE.message for:1.5 animated:YES];
    }
}

#pragma mark - TCResultGroupDelegate

- (void)tcResultGroup:(TCGroup *)itemG error:(TCError *)itemE {
    [super getResponse:nil obj:nil];
    if (itemE == nil) {
        self.group = itemG;
        if (group.isAdmin) {
            [btnQuit setTitle:@"删除并退出" forState:UIControlStateNormal];
        }
        for (TCUser* itemTC in itemG.userList) {
            User* itemU = [User objectWithTCUser:itemTC];
            [contentArr addObject:itemU];
        }
        [listView reloadData];
    } else {
        [KAlertView showType:KAlertTypeError text:itemE.message for:1.5 animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
    if (session.typeChat == forChatTypeUser) {
        return 2;
    } else {
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    if (section == 2) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [MemberCell heightWithItemCount:[self numberOfItemsInCell]];
    }
    
    CGFloat height = 44.0;
    
    return height;
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

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseTableViewCell* cellResult = nil;
    
    if (indexPath.section == 0) {
        static NSString* identifier = @"MemberCell";
        MemberCell* cell = [sender dequeueReusableCellWithIdentifier:identifier];
        
        if (cell == nil) {
            cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.delegate = self;
        }
        [cell setNeedsDisplay];
        
        cellResult = cell;
    } else {
        static NSString* identifier = @"Cell";
        BaseTableViewCell* cell = [sender dequeueReusableCellWithIdentifier:identifier];
        
        if (cell == nil) {
            cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textColor = kColorTitleBlack;
            cell.detailTextLabel.textColor = kColorTitleGray;
        }
        
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        if (indexPath.section == 1) {
            if (session.typeChat == forChatTypeUser) {
                cell.textLabel.text = @"清空聊天记录";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.textLabel.text = @"会话名称";
                cell.detailTextLabel.text = session.name;
                if (group.isAdmin) {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                } else {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
            }
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"新消息提醒";
                cell.accessoryView = swtGetMsg;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"清空聊天记录";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        cellResult = cell;
    }
    
    cellResult.isGrouped = isGrouped;
    
    return cellResult;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    
    id con = nil;
    
    if (indexPath.section == 0) {
        MemberCell* cell = (MemberCell*)[listView cellForRowAtIndexPath:indexPath];
        if (cell.editing) {
            cell.editing = NO;
        }
    } else {
        if (indexPath.section == 1) {
            if (session.typeChat == forChatTypeUser) {
                // 清空聊天记录
                [self cleanMessage];
            } else {
                if (group.isAdmin) {
                    id con = [[SingleTextFieldController alloc] initWithSession:session type:forSingleTextFieldEditSession];
                    [self pushViewController:con];
                }
            }
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                // 不应该点击
            } else if (indexPath.row == 1) {
                [self cleanMessage];
            }
        }
        
    }
    
    if (con) {
        [self pushViewController:con];
    }
}

#pragma mark - MemberCellDelegate

- (NSInteger)numberOfItemsInCell {
    if (session.typeChat == forChatTypeUser) {
        return 2;
    } else {
        if (group.isAdmin) {
            return contentArr.count + 2;
        } else {
            return contentArr.count;
        }
    }
}

- (NSString*)titleOfItemAtIndex:(NSInteger)index {
    if (index < contentArr.count) {
        User* itemU = [contentArr objectAtIndex:index];
        return itemU.nickName;
    }
    return nil;
}

- (UIImage*)imageNormalOfItemAtIndex:(NSInteger)index {
    if (index == contentArr.count) {
        return [UIImage imageNamed:@"btn_add_n"];
    } else if (index == contentArr.count + 1) {
        return [UIImage imageNamed:@"btn_delete_n"];
    } else {
        return kImageDefaultHeadUser;
    }
}

- (UIImage*)imageHighlightedOfItemAtIndex:(NSInteger)index {
    if (index == contentArr.count) {
        return [UIImage imageNamed:@"btn_add_d"];
    } else if (index == contentArr.count + 1) {
        return [UIImage imageNamed:@"btn_delete_d"];
    } else {
        return nil;
    }
}

- (BOOL)canEditItemAtIndex:(NSInteger)index {
    if (index < contentArr.count) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldHideItemAtIndex:(NSInteger)index {
    if (index >= contentArr.count) {
        return YES;
    }
    return NO;
}

- (void)memberCell:(MemberCell*)sender didPressAtIndex:(NSInteger)index {
    if (index == contentArr.count) {
        // add
        id con = [[SessionNewController alloc] initWithSession:session userList:contentArr delegate:session.typeChat == forChatTypeUser ? nil:self];
        [self pushViewController:con];
    } else if (index == contentArr.count + 1) {
        // del
        sender.editing = YES;
    } else {
        User* itemU = [contentArr objectAtIndex:index];
        if (sender.editing) {
            // del
            self.userChoose = [contentArr objectAtIndex:index];
            if ([[BaseEngine currentBaseEngine].user.ID isEqualToString:userChoose.ID]) {
                [KAlertView showType:KAlertTypeError text:@"管理员无法删除自己" for:1.5 animated:YES];
            } else {
                baseRequestType = forBaseListRequestOther;
                typeRequest = forSessionDetailRequest_Kick;
                [self sendRequest];
            }
        } else {
            // detail
            id con = [[UserDetailController alloc] initWithUser:itemU];
            [self pushViewController:con];
        }
    }
}

#pragma mark - ImageControl

- (NSInteger)baseTableView:(UITableView *)sender numberOfImagesAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return contentArr.count;
    }
    return 0;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    if (indexPath.section == 0) {
        User* itemU = [contentArr objectAtIndex:index];
        return itemU.headImgUrlS;
    }
    return nil;
}

- (UIImage*)baseTableView:(UITableView *)sender imageDefaultAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    return kImageDefaultHeadUser;
}

- (void)baseTableView:(UITableView *)sender loadImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    if (indexPath.section == 0) {
        MemberCell* cell = (MemberCell*)[listView cellForRowAtIndexPath:indexPath];
        [cell updateImage:image atIndex:index];
    }
}

#pragma mark - SessionNewDelegate

- (void)sessionNew:(id)sender addUserList:(NSArray *)arr {
    [contentArr addObjectsFromArray:arr];
    [listView reloadData];
}

@end
