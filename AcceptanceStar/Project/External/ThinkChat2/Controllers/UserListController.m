//
//  UserListController.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-12.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "UserListController.h"
#import "UserDetailController.h"
#import "SimpleHeadCell.h"
#import "ButtonHeadCell.h"
#import "User.h"
#import "TCGroup.h"

@interface UserListController () <ButtonHeadDelegate, TCResultUserListDelegate, TCResultNoneDelegate> {
    UserListType    typeList;
    NSString*   identifier;
}

@property (nonatomic, strong) TCGroup*  group;
@property (nonatomic, strong) User*     chooseUser;

@end

@implementation UserListController

@synthesize group;
@synthesize chooseUser;

- (id)initWithGroup:(TCGroup *)item type:(UserListType)theType
{
    self = [super initWithNibName:@"UserListController" bundle:nil];
    if (self) {
        // Custom initialization
        self.group = item;
        typeList = theType;
        
        identifier = @"SimpleHeadCell";
        if (typeList == forUserListType_GroupInvite) {
            identifier = @"ButtonHeadCell";
        } else if (typeList == forUserListType_GroupMember && group.isAdmin) {
            identifier = @"ButtonHeadCell";
        }
        shouldRefreshIfDropDown = YES;
        shouldRefreshIfLoadFirst = YES;
        shouldAddMoreAutomatic = YES;
    }
    return self;
}

- (void)dealloc {
    self.group = nil;
    self.chooseUser = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"用户列表";
    
    [self registerNibForCellReuseIdentifier:identifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)sendRequest {
    if ([super sendRequest]) {
        if (baseRequestType == forBaseListRequestDataList) {
            if (typeList == forUserListType_GroupInvite) {
                [client getFriendList];
            } else if (typeList == forUserListType_GroupMember) {
                tagRequest = [[ThinkChat instance] getUserListInGroup:group.ID count:count page:nextPage delegate:self];
            } else if (typeList == forUserListType_ConversationAdd) {
                [client getFriendList];
            }
        } else if (baseRequestType == forBaseListRequestOther) {
            if (typeList == forUserListType_GroupInvite) {
                tagRequest = [[ThinkChat instance] inviteJoinGroup:group.ID user:chooseUser.ID delegate:self];
            } else if (typeList == forUserListType_GroupMember) {
                tagRequest = [[ThinkChat instance] deleteUser:chooseUser.ID fromGroup:group.ID delegate:self];
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL)getResponse:(BaseClient *)sender obj:(NSDictionary *)obj {
    if ([super getResponse:sender obj:obj]) {
        if (typeList == forUserListType_GroupInvite ||
            typeList == forUserListType_ConversationAdd) {
            NSArray* arr = [obj getArrayForKey:@"data" defaultValue:nil];
            for (NSDictionary* dic in arr) {
                User* itemU = [User objWithJsonDic:dic];
                if (itemU) {
                    if (![group.memberIDs containsObject:itemU.ID]) {
                        [contentArr addObject:itemU];
                    }
                }
            }
        }
        [listView reloadData];
        return YES;
    }
    return NO;
}

- (void)didCompletionBlock:(NSArray*)itemArr error:(TCError*)itemErr {
    [super getResponse:nil obj:nil];
    if (itemErr == nil) {
        if (itemArr != nil && [itemArr isKindOfClass:[NSArray class]]) {
            for (TCUser* tmpU in itemArr) {
                User* itemU = [User objectWithTCUser:tmpU];
                [contentArr addObject:itemU];
            }
            [listView reloadData];
        }
    } else {
        [KAlertView showType:KAlertTypeError text:itemErr.message for:1.5 animated:YES];
    }
}

#pragma mark - TCResultNoneDelegate

- (void)tcResultNoneError:(TCError *)itemE {
    [super getResponse:nil obj:nil];
    tagRequest = nil;
    if (itemE == nil) {
        if (baseRequestType == forBaseListRequestOther) {
            if (typeList == forUserListType_GroupInvite) {
                [KAlertView showType:KAlertTypeCheck text:@"邀请成功" for:1.5 animated:YES];
            } else if (typeList == forUserListType_GroupMember) {
                [KAlertView showType:KAlertTypeCheck text:@"删除成功" for:1.5 animated:YES];
                group.count -= 1;
                [contentArr removeObject:chooseUser];
                [listView reloadData];
            }
        }
    } else {
        [KAlertView showType:KAlertTypeError text:itemE.message for:1.5 animated:YES];
    }
}

#pragma mark - TCResultUserListDelegate

- (void)tcResultUserList:(NSArray *)arr pageInfo:(TCPageInfo *)itemP error:(TCError *)itemE {
    [super getResponse:nil obj:nil];
    tagRequest = nil;
    if (itemE == nil) {
        if (arr != nil && [arr isKindOfClass:[NSArray class]]) {
            for (NSDictionary* tmpU in arr) {
                User* itemU = [User objWithJsonDic:tmpU];
                [contentArr addObject:itemU];
            }
            [listView reloadData];
        }
    } else {
        [KAlertView showType:KAlertTypeError text:itemE.message for:1.5 animated:YES];
    }
}

#pragma mark - ButtonHeadDelegate

- (void)ButtonHeadCellDidPressedButton:(id)sender {
    NSIndexPath* indexPath = [listView indexPathForCell:sender];
    self.chooseUser = [contentArr objectAtIndex:indexPath.row];
    baseRequestType = forBaseListRequestOther;
    [self sendRequest];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
    return 1;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    return contentArr.count;
}

- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ButtonHeadCell heightWithItem:nil];
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ButtonHeadCell* cell = [sender dequeueReusableCellWithIdentifier:identifier];
    
    User*  itemU = [contentArr objectAtIndex:indexPath.row];
    
    cell.title = itemU.nickName;
    cell.detail = itemU.sign;
    
    if (typeList == forUserListType_GroupInvite) {
        cell.titleButton = @"邀请";
        cell.bkgImage = [UIImage imageWithColor:kColorBtnBkgGreen];
        cell.delegate = self;
    } else if (typeList == forUserListType_GroupMember && group.isAdmin) {
        cell.bkgImage = [UIImage imageWithColor:kColorBtnBkgRed];
        cell.delegate = self;

        if ([itemU.ID isEqualToString:[BaseEngine currentBaseEngine].user.ID]) {
            cell.titleButton = nil;
        } else {
            cell.titleButton = @"删除";
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    User* itemU = [contentArr objectAtIndex:indexPath.row];
    id con = [[UserDetailController alloc] initWithUser:itemU];
    [self pushViewController:con];
}

#pragma mark - ImageControl

- (NSInteger)baseTableView:(UITableView *)sender numberOfImagesAtIndexPath:(NSIndexPath *)indexPath {
    return 1;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    User* itemU = [contentArr objectAtIndex:indexPath.row];
    return itemU.headImgUrlS;
}

- (UIImage*)baseTableView:(UITableView *)sender imageDefaultAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    return kImageDefaultHeadUser;
}

- (void)baseTableView:(UITableView *)sender loadImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    BaseHeadCell* cell = (BaseHeadCell*)[listView cellForRowAtIndexPath:indexPath];
    cell.imgHead = image;
}

@end
