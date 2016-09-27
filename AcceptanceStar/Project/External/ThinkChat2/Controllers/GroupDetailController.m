//
//  GroupDetailController.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-11.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "GroupDetailController.h"
#import "GroupModifyController.h"
#import "UserListController.h"
#import "ChatViewController.h"
#import "TCGroup.h"
#import "TCSession.h"
#import "AppDelegate.h"

@interface GroupDetailController () <TCResultNoneDelegate, TCResultGroupDelegate> {
    IBOutlet UIView*    footerView;
    IBOutlet UIButton*  btnEnter;
    IBOutlet UIButton*  btnDelete;
    IBOutlet UISwitch*  swtIsGetMessage;
    
    CGRect  frameFooter;

    GroupDetailRequestType  typeRequest;
}

@property (nonatomic, strong) TCGroup*    group;
@property (nonatomic, strong) UIImage*  headImage;

@end

@implementation GroupDetailController

@synthesize group;
@synthesize headImage;

- (id)initWithGroup:(TCGroup *)item
{
    self = [super initWithNibName:@"GroupDetailController" bundle:nil];
    if (self) {
        // Custom initialization
        self.group = item;
    }
    return self;
}

- (void)dealloc {
    footerView = nil;
    btnEnter = nil;
    btnDelete = nil;
    swtIsGetMessage = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinGroup:) name:kNotifyJoinGroup object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitGroup:) name:kNotifyQuitGroup object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editGroup:) name:kNotifyEditGroup object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addGroupMember:) name:kNotifyAddGroupMember object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteGroupMember:) name:kNotifyDeleteGroupMember object:nil];

    frameFooter = footerView.frame;

    swtIsGetMessage.onTintColor = kColorBtnBkgBlue;
    
    [self updateUI];
    [self sendRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)joinGroup:(NSNotification*)sender {
    TCGroup* itemG = (TCGroup*)sender.object;
    if ([self isCurrentGroup:itemG]) {
        group.isJoin = YES;
        [self updateUI];
    }
}

- (void)quitGroup:(NSNotification*)sender {
    TCGroup* itemG = (TCGroup*)sender.object;
    if ([self isCurrentGroup:itemG]) {
        group.isJoin = NO;
        [self updateUI];
    }
}

- (void)editGroup:(NSNotification*)sender {
    TCGroup* itemG = (TCGroup*)sender.object;
    if ([self isCurrentGroup:itemG]) {
        group.name = itemG.name;
        group.headImgUrlS = itemG.headImgUrlS;
        group.headImgUrlL = itemG.headImgUrlL;
        group.description = itemG.description;
        [self updateUI];
    }
}

- (void)addGroupMember:(NSNotification*)sender {
    TCNotify* itemT = (TCNotify*)sender.object;
    TCGroup* itemG = itemT.group;
    if ([self isCurrentGroup:itemG]) {
        group.count += 1;
        [self updateUI];
    }
}

- (void)deleteGroupMember:(NSNotification*)sender {
    TCNotify* itemT = (TCNotify*)sender.object;
    TCGroup* itemG = itemT.group;
    if ([self isCurrentGroup:itemG]) {
        group.count -= 1;
        [self updateUI];
    }
}

- (BOOL)isCurrentGroup:(TCGroup*)itemG {
    if (itemG.type == group.type && [itemG.ID isEqualToString:group.ID]) {
        return YES;
    }
    return NO;
}

- (void)btnPressed:(id)sender {
    if (sender == btnEnter) {
        if (group.isJoin) {
            // 进入聊天界面
            id con = [[ChatViewController alloc] initWithGroup:group];
            [self pushViewController:con];
        } else {
            baseRequestType = forBaseListRequestOther;
            typeRequest = forGroupDetailRequestType_ApplyJoin;
            [self sendRequest];
        }
    } else if (sender == btnDelete) {
        if (group.isAdmin) {
            typeRequest = forGroupDetailRequestType_Delete;
        } else {
            typeRequest = forGroupDetailRequestType_Quit;
        }
        baseRequestType = forBaseListRequestOther;
        [self sendRequest];
    }
}

- (IBAction)switchValueChanged:(id)sender {
    baseRequestType = forBaseListRequestOther;
    typeRequest = forGroupDetailRequestType_IsGetMessage;
    [self sendRequest];
}

- (void)barButtonItemRightPressed:(id)sender {
    id con = [[GroupModifyController alloc] initWithGroup:group];
    [self pushViewController:con];
}

- (void)updateUI {
    self.navigationItem.title = group.name;

    [swtIsGetMessage setOn:group.isGetMessage];
    
    if (group.isAdmin) {
        [self addBarButtonItemRightNormalImageName:@"nav_edit_n" hightLited:@"nav_edit_d"];
    }

    btnDelete.hidden = !group.isJoin;
    if (btnDelete.hidden) {
        CGRect frame = frameFooter;
        frame.size.height -= btnDelete.frame.size.height + 8;
        footerView.frame = frame;
    } else {
        footerView.frame = frameFooter;
    }
    
    [btnEnter setTitleColor:kColorWhite forState:UIControlStateNormal];
    [btnEnter setTitleColor:kColorWhite forState:UIControlStateHighlighted];
    [btnDelete setTitleColor:kColorWhite forState:UIControlStateNormal];
    [btnDelete setTitleColor:kColorWhite forState:UIControlStateHighlighted];
    
    [btnDelete setBackgroundImage:[UIImage imageWithColor:kColorBtnBkgRed] forState:UIControlStateNormal];
    
    btnEnter.layer.cornerRadius = kCornerRadiusButton;
    btnDelete.layer.cornerRadius = kCornerRadiusButton;
    btnEnter.clipsToBounds = YES;
    btnDelete.clipsToBounds = YES;
    
    if (group.isJoin) {
        [btnEnter setTitle:@"进入" forState:UIControlStateNormal];
        [btnEnter setBackgroundImage:[UIImage imageWithColor:kColorBtnBkgBlue] forState:UIControlStateNormal];
    } else {
        [btnEnter setTitle:@"申请加入" forState:UIControlStateNormal];
        [btnEnter setBackgroundImage:[UIImage imageWithColor:kColorBtnBkgGreen] forState:UIControlStateNormal];
    }
    
    if (group.isAdmin) {
        [btnDelete setTitle:@"退出并删除" forState:UIControlStateNormal];
    } else {
        [btnDelete setTitle:@"退出" forState:UIControlStateNormal];
    }
    
    listView.tableFooterView = footerView;
    
    [listView reloadData];
}

#pragma mark - Request

- (BOOL)sendRequest {
    if ([super sendRequest]) {
        if (baseRequestType == forBaseListRequestDataList) {
            tagRequest = [[ThinkChat instance] getGroupDetail:group.ID delegate:self];
        } else if (baseRequestType == forBaseListRequestOther) {
            switch (typeRequest) {
                case forGroupDetailRequestType_ApplyJoin:
                    tagRequest = [[ThinkChat instance] applyJoinGroup:group.ID delegate:self];
                    break;
                case forGroupDetailRequestType_Quit:
                    tagRequest = [[ThinkChat instance] quitGroup:group.ID delegate:self];
                    break;
                case forGroupDetailRequestType_Delete:
                    tagRequest = [[ThinkChat instance] deleteGroup:group.ID delegate:self];
                    break;
                case forGroupDetailRequestType_IsGetMessage:
                    tagRequest = [[ThinkChat instance] setGroup:group.ID isGetMessage:!group.isGetMessage delegate:self];
                    break;
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL)getResponse:(BaseClient *)sender obj:(NSObject *)obj {
    if ([super getResponse:sender obj:obj]) {
        [KAlertView showType:KAlertTypeCheck text:sender.errorMessage for:1.5 animated:YES];
        switch (typeRequest) {
            case forGroupDetailRequestType_ApplyJoin:

                break;
            case forGroupDetailRequestType_Quit:
                group.isJoin = NO;
                [self updateUI];
                break;
            case forGroupDetailRequestType_Delete:
                [self popViewController];
                break;
            case forGroupDetailRequestType_IsGetMessage:
                group.isGetMessage = !group.isGetMessage;
                [swtIsGetMessage setOn:group.isGetMessage animated:YES];
                break;
        }
        return YES;
    }
    return NO;
}

#pragma mark - TCResultNoneDelegate

- (void)tcResultNoneError:(TCError *)itemE {
    [super getResponse:nil obj:nil];
    if (itemE == nil) {
        if (baseRequestType == forBaseListRequestOther) {
            switch (typeRequest) {
                case forGroupDetailRequestType_ApplyJoin:
                    [KAlertView showType:KAlertTypeCheck text:@"申请成功" for:1.5 animated:YES];
                    break;
                case forGroupDetailRequestType_Quit:
                    group.isLeave = YES;
                    [[AppDelegate instance] quitGroup:group];
                    break;
                case forGroupDetailRequestType_Delete:
                    group.isLeave = YES;
                    [[AppDelegate instance] quitGroup:group];
                    [KAlertView showType:KAlertTypeCheck text:@"删除成功" for:1.5 animated:YES];
                    [self popViewController];
                    break;
                case forGroupDetailRequestType_IsGetMessage:
                    group.isGetMessage = !group.isGetMessage;
                    [swtIsGetMessage setOn:group.isGetMessage animated:YES];
                    [KAlertView showType:KAlertTypeCheck text:@"设置成功" for:1.5 animated:YES];
                    break;
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
        [self updateUI];
    } else {
        [KAlertView showType:KAlertTypeError text:itemE.message for:1.5 animated:YES];
    }
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    } else if (section == 1) {
        if (group.isAdmin) {
            return 1;
        }
    } else if (section == 2) {
        if (group.isJoin) {
            return 2;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 100;
        } else if (indexPath.row == 4) {
            CGFloat height = 44.0;
            NSString* strDisplay = group.description;

            if (strDisplay) {
                height = [strDisplay sizeWithFont:[UIFont systemFontOfSize:14] maxWidth:210 maxNumberLines:0].height + 20;
            }
            
            if (height < 44) {
                height = 44;
            }
            return height;
        }
    }

    return 44;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * CellIdentifier = @"Cell";
    
    BaseTableViewCell* cell = [listView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    cell.detailTextLabel.text = nil;
    cell.imageView.image = nil;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"群头像";
            if (headImage) {
                cell.imageView.image = headImage;
            } else {
                cell.imageView.image = kImageDefaultHeadGroup;
            }
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"群名称";
            cell.detailTextLabel.text = group.name;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"群ID";
            cell.detailTextLabel.text = group.ID;
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"群成员";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d人",group.count];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else if (indexPath.row == 4) {
            cell.textLabel.text = @"群简介";
            cell.detailTextLabel.text = group.description;
        }
    } else if (indexPath.section == 1) {
        cell.textLabel.text = @"邀请新成员";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"新消息提醒";
            cell.accessoryView = swtIsGetMessage;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"清空聊天记录";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
    }
    
    return cell;
}

// Header

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1 && !group.isAdmin) {
        return 0;
    } else if (section == 2 && !group.isJoin) {
        return 0;
    }
    return 25;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1 && !group.isAdmin) {
        return nil;
    } else if (section == 2 && !group.isJoin) {
        return 0;
    }
    return [[UIView alloc] init];
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(BaseTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        // 头像
        [cell update:^{
            CGRect frame = cell.contentView.frame;
            cell.textLabel.frame = CGRectMake(10, 2, 70, frame.size.height - 4);
            CGRect frameImg = CGRectMake(frame.size.width - frame.size.height, 4, frame.size.height - 8, frame.size.height - 8);
            cell.imageView.frame = frameImg;
        }];
    } else if (indexPath.section == 0 && indexPath.row == 4) {
        // 简介
        [cell update:^{
            cell.textLabel.frame = CGRectMake(10, 2, 70, 40);
            cell.detailTextLabel.frame = CGRectMake(100, 2, 210, cell.contentView.height-4);
        }];
    } else {
        [cell update:^{
            cell.textLabel.frame = CGRectMake(10, 2, 120, 40);
            cell.detailTextLabel.frame = CGRectMake(10 + 120 + 8, 2, cell.contentView.width - (10 + 120 + 8) - 10, cell.contentView.height-4);
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    id con = nil;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // 群头像
        } else if (indexPath.row == 1) {
            // 群名称
        } else if (indexPath.row == 2) {
            // 群ID
        } else if (indexPath.row == 3) {
            // 群成员
            con = [[UserListController alloc] initWithGroup:group type:forUserListType_GroupMember];
        } else if (indexPath.row == 4) {
            // 群简介
        }
    } else if (indexPath.section == 1) {
        // 邀请新成员
        con = [[UserListController alloc] initWithGroup:group type:forUserListType_GroupInvite];
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            // 新消息提醒
        } else if (indexPath.row == 1) {
            // 清空聊天记录
            [[AppDelegate instance] clearSessionID:group.ID typeChat:forChatTypeGroup];
            [KAlertView showType:KAlertTypeCheck text:@"已成功删除聊天记录" for:1.5 animated:YES];
        }
    }
    [self pushViewController:con];
}

#pragma mark - ImageControl

- (NSInteger)baseTableView:(UITableView *)sender numberOfImagesAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (headImage == nil) {
            return 1;
        }
    }
    return 0;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    return group.headImgUrlL;
}

- (UIImage*)baseTableView:(UITableView *)sender imageDefaultAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    return nil;
}

- (void)baseTableView:(UITableView *)sender loadImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    self.headImage = image;
    [listView reloadData];
}

@end
