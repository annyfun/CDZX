//
//  UserDetailController.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-11.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "UserDetailController.h"
#import "ChatViewController.h"
#import "ProfileEditController.h"
#import "SingleTextViewController.h"
#import "User.h"
#import "AppDelegate.h"

@interface UserDetailController () <UIActionSheetDelegate> {
    IBOutlet UIView*    footerView;
    IBOutlet UIButton*  btnChat;
    IBOutlet UIButton*  btnApply;
    
    CGRect  frameFooter;
    
    UserDetailRequestType  typeRequest;
    BaseClient* clientHide;
    BOOL        shouldRefreshHide;
}

@property (nonatomic, strong) User*     user;
@property (nonatomic, strong) UIImage*  headImage;
@property (nonatomic, assign) BOOL      isMine;

@end

@implementation UserDetailController

@synthesize user;
@synthesize headImage;
@synthesize isMine;

- (id)initWithUser:(User *)item
{
    self = [super initWithNibName:@"UserDetailController" bundle:nil];
    if (self) {
        // Custom initialization
        self.user = item;
        self.isMine = [[BaseEngine currentBaseEngine].user.ID isEqualToString:user.ID];
        shouldRefreshHide = NO;
        shouldRefreshIfLoadFirst = YES;
        shouldRefreshIfDropDown = YES;
    }
    return self;
}

- (void)dealloc {
    [clientHide cancel];
    clientHide = nil;

    footerView = nil;
    btnChat = nil;
    btnApply = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addFriend:) name:kNotifyAddFriend object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteFriend:) name:kNotifyDeleteFriend object:nil];

    self.navigationItem.title = user.nickName;
    
    if (isMine) {
        [self addBarButtonItemRightNormalImageName:@"nav_edit_n" hightLited:@"nav_edit_d"];
    } else {
        if (user.isFriend) {
            [self addBarButtonItemRightNormalImageName:@"nav_more_n" hightLited:@"nav_more_d"];
        }
        frameFooter = footerView.frame;
    }
    
    [self updateUI];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    shouldRefreshHide = YES;
    [clientHide cancel];
    clientHide = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (shouldRefreshHide) {
        shouldRefreshHide = NO;
        [self hideRefresh];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addFriend:(NSNotification*)sender {
    User* itemU = (User*)sender.object;
    if ([itemU.ID isEqualToString:user.ID]) {
        user.isFriend = YES;
        [self updateUI];
    }
}

- (void)deleteFriend:(NSNotification*)sender {
    User* itemU = (User*)sender.object;
    if ([itemU.ID isEqualToString:user.ID]) {
        user.isFriend = NO;
        [self updateUI];
    }
}

- (void)btnPressed:(id)sender {
    if (sender == btnChat) {
        id con = [[ChatViewController alloc] initWithUser:user];
        [self pushViewController:con];
    } else if (sender == btnApply) {
        baseRequestType = forBaseListRequestOther;
        typeRequest = forUserDetailRequestType_ApplyFriend;
        [self sendRequest];
    }
}

- (void)barButtonItemRightPressed:(id)sender {
    if (isMine) {
        id con = [[ProfileEditController alloc] initWithUser:user];
        [self pushViewController:con];
    } else {
        UIActionSheet* sheet = nil;
        if (user.isFriend) {
            sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报", @"删除好友", nil];
        } else {
            sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报", nil];
        }
        [sheet showInView:self.view];
    }
}

- (void)updateUI {
    if (!isMine) {
        btnApply.hidden = user.isFriend;
        if (btnApply.hidden) {
            CGRect frame = frameFooter;
            frame.size.height -= btnApply.frame.size.height + 8;
            footerView.frame = frame;
        } else {
            footerView.frame = frameFooter;
        }
        
        [btnChat setTitleColor:kColorWhite forState:UIControlStateNormal];
        [btnChat setTitleColor:kColorWhite forState:UIControlStateHighlighted];
        [btnApply setTitleColor:kColorWhite forState:UIControlStateNormal];
        [btnApply setTitleColor:kColorWhite forState:UIControlStateHighlighted];
        
        [btnChat setBackgroundImage:[UIImage imageWithColor:kColorBtnBkgGreen] forState:UIControlStateNormal];
        [btnApply setBackgroundImage:[UIImage imageWithColor:kColorBtnBkgBlue] forState:UIControlStateNormal];
        
        btnChat.layer.cornerRadius = kCornerRadiusButton;
        btnApply.layer.cornerRadius = kCornerRadiusButton;
        btnChat.clipsToBounds = YES;
        btnApply.clipsToBounds = YES;
        
        [btnChat setTitle:@"发消息" forState:UIControlStateNormal];
        [btnApply setTitle:@"加为好友" forState:UIControlStateNormal];
        
        listView.tableFooterView = footerView;
    }
    [listView reloadData];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString* titleString = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([titleString isEqualToString:@"取消"]) {
        return;
    }
    if ([titleString isEqualToString:@"举报"]) {
        id con = [[SingleTextViewController alloc] initWithUser:user];
        [self pushViewController:con];
    } else if ([titleString isEqualToString:@"删除好友"]) {
        baseRequestType = forBaseListRequestOther;
        typeRequest = forUserDetailRequestType_DeleteFriend;
        [self sendRequest];
    }
}

#pragma mark - Request

- (void)hideRefresh {
    if (clientHide) {
        return;
    }
    if (client) {
        return;
    }
    clientHide = [[BaseClient alloc] initWithDelegate:self action:@selector(hideRefresh:obj:)];
    [clientHide getUserDetail:user.ID];
}

- (void)hideRefresh:(BaseClient*)sender obj:(NSDictionary*)obj {
    clientHide = nil;
    if (obj != nil && [obj isKindOfClass:[NSDictionary class]]) {
        obj = [obj objectForKey:@"data"];
        [user updateWithJsonDic:obj];
        self.headImage = nil;
        [self updateUI];
    }
}

- (BOOL)sendRequest {
    if (clientHide) {
        return NO;
    }
    if ([super sendRequest]) {
        if (baseRequestType == forBaseListRequestDataList) {
            [client getUserDetail:user.ID];
        } else if (baseRequestType == forBaseListRequestOther) {
            if (typeRequest == forUserDetailRequestType_ApplyFriend) {
                [client applyFriend:user.ID];
            } else if (typeRequest == forUserDetailRequestType_DeleteFriend) {
                [client deleteFriend:user.ID];
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL)getResponse:(BaseClient *)sender obj:(NSDictionary *)obj {
    if ([super getResponse:sender obj:obj]) {
        if (baseRequestType == forBaseListRequestDataList) {
            if (obj != nil && [obj isKindOfClass:[NSDictionary class]]) {
                obj = [obj objectForKey:@"data"];
                [user updateWithJsonDic:obj];
                [self updateUI];
            }
        } else if (baseRequestType == forBaseListRequestOther) {
            [KAlertView showType:KAlertTypeCheck text:sender.errorMessage for:1.5 animated:YES];
            if (typeRequest == forUserDetailRequestType_ApplyFriend) {

            } else if (typeRequest == forUserDetailRequestType_DeleteFriend) {
                [[AppDelegate instance] deleteFriend:user];
            }
        }
        return YES;
    }
    return NO;
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return 100;
    } else {
        CGFloat height = 44.0;
        NSString* strDisplay = nil;
        
        if (indexPath.row == 1) {
            strDisplay = user.nickName;
        } else if (indexPath.row == 2) {
            strDisplay = user.genderString;
        } else if (indexPath.row == 3) {
            strDisplay = user.sign;
        }
        
        
        if (strDisplay) {
            height = [strDisplay sizeWithFont:[UIFont systemFontOfSize:14] maxWidth:210 maxNumberLines:0].height + 20;
        }
        
        if (height < 44) {
            height = 44;
        }
        return height;
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
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"头像";
        if (headImage) {
            cell.imageView.image = headImage;
        } else {
            cell.imageView.image = kImageDefaultHeadUser;
        }
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"昵称";
        cell.detailTextLabel.text = user.nickName;
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"性别";
        cell.detailTextLabel.text = user.genderString;
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"个性签名";
        cell.detailTextLabel.text = user.sign;
    }
    
    return cell;
}

// Header

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
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
    } else {
        [cell update:^{
            cell.textLabel.frame = CGRectMake(10, 2, 70, 40);
            cell.detailTextLabel.frame = CGRectMake(100, 2, 210, cell.contentView.height-4);
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    id con = nil;
//    if (indexPath.section == 0) {
//        if (indexPath.row == 0) {
//            // 群头像
//        } else if (indexPath.row == 1) {
//            // 群名称
//        } else if (indexPath.row == 2) {
//            // 群ID
//        } else if (indexPath.row == 3) {
//            // 群成员
//            con = [[UserListController alloc] initWithUser:user type:forUserListType_UserMember];
//        } else if (indexPath.row == 4) {
//            // 群简介
//        }
//    } else if (indexPath.section == 1) {
//        // 邀请新成员
//        con = [[UserListController alloc] initWithUser:user type:forUserListType_UserInvite];
//    } else if (indexPath.section == 2) {
//        if (indexPath.row == 0) {
//            // 新消息提醒
//        } else if (indexPath.row == 1) {
//            // 清空聊天记录
//        }
//    }
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
    return user.headImgUrlL;
}

- (UIImage*)baseTableView:(UITableView *)sender imageDefaultAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    return nil;
}

- (void)baseTableView:(UITableView *)sender loadImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    self.headImage = image;
    [listView reloadData];
}
@end
