//
//  FriendListController.m
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "FriendListController.h"
#import "UserSearchController.h"
#import "UserDetailController.h"
#import "SimpleHeadCell.h"
#import "SortUserGroup.h"

@interface FriendListController () {
    NSString*   identifier;
}

@end

@implementation FriendListController

- (id)init
{
    self = [super initWithNibName:@"FriendListController" bundle:nil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    // Custom initialization
    identifier = @"SimpleHeadCell";
    shouldRefreshIfDropDown = YES;
    shouldRefreshIfLoadFirst = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialize];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addFriend:) name:kNotifyAddFriend object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteFriend:) name:kNotifyDeleteFriend object:nil];

    self.navigationItem.title = @"通讯录";
    [self addBarButtonItemRightNormalImageName:@"nav_add_n" hightLited:@"nav_add_d"];

    [self registerNibForCellReuseIdentifier:identifier];
    
    self.searchDisplayController.searchBar.placeholder = @"请输入昵称/星星号";
    
    UIView * superView = nil;
    if (systemVersionFloatValue < 7) {
        superView = self.searchDisplayController.searchBar;
    } else {
        superView = [self.searchDisplayController.searchBar.subviews lastObject];
    }
    for (UIView *subview in superView.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
            break;
        }
    }
    
    self.searchDisplayController.searchBar.backgroundColor = kColorSearchBkg;
    if (systemVersionFloatValue < 7.0) {
        self.searchDisplayController.searchBar.tintColor = kColorViewBkg;
    } else {
        self.searchDisplayController.searchBar.tintColor = kColorTitleBlue;
    }
#ifdef __IPHONE_7_0
    if ([self.searchDisplayController.searchBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.searchDisplayController.searchBar.barStyle = UIBarStyleDefault;
        self.searchDisplayController.searchBar.barTintColor = kColorTitleBlue;
    }
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addFriend:(NSNotification*)sender {
//    User* itemU = (User*)sender.object;
    [self sendRequest];
}

- (void)deleteFriend:(NSNotification*)sender {
//    User* itemU = (User*)sender.object;
    [self sendRequest];
}

- (void)barButtonItemRightPressed:(id)sender {
    id con = [[UserSearchController alloc] init];
    [self pushViewController:con];
}

- (BOOL)sendRequest {
    if ([super sendRequest]) {
        [client getFriendList];
        return YES;
    }
    return NO;
}

- (BOOL)getResponse:(BaseClient *)sender obj:(NSDictionary *)obj {
    if ([super getResponse:sender obj:obj]) {
        NSArray* arr = [obj getArrayForKey:@"data" defaultValue:nil];
        for (NSDictionary* dic in arr) {
            User* itemU = [User objWithJsonDic:dic];
            if (itemU) {
                SortUserGroup* userGroup = nil;
                if (contentArr.count == 0) {
                    userGroup = [[SortUserGroup alloc] init];
                    [contentArr addObject:userGroup];
                } else {
                    userGroup = [contentArr lastObject];
                    if (userGroup.name == nil || ![userGroup.name isEqualToString:itemU.sort]) {
                        userGroup = [[SortUserGroup alloc] init];
                        [contentArr addObject:userGroup];
                    }
                }
                userGroup.name = itemU.sort;
                [userGroup.userList addObject:itemU];
            }
        }
        [listView reloadData];
        return YES;
    }
    return NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
    if (sender == listView) {
        return contentArr.count;
    } else if (sender == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    if (sender == listView) {
        SortUserGroup* userGroup = [contentArr objectAtIndex:section];
        return userGroup.userList.count;
    } else if (sender == self.searchDisplayController.searchResultsTableView) {
        return filteredArr.count;
    }
    return 0;
}

// Header
- (CGFloat)tableView:(UITableView *)sender heightForHeaderInSection:(NSInteger)section {
    if (sender == listView) {
        return 20;
    }
    return 0;
}

- (UIView*)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    if (sender == listView) {
        UIView* bkgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sender.width, [self tableView:sender heightForHeaderInSection:section])];
        bkgView.backgroundColor = kColorViewBkg;
        
        CGFloat offSetX = 10.0;
        UILabel* labTitle = [[UILabel alloc] initWithFrame:CGRectMake(offSetX, 0, bkgView.width - offSetX*2, bkgView.height)];
        labTitle.backgroundColor = kColorClear;
        labTitle.font = [UIFont systemFontOfSize:16];
        labTitle.textColor = kColorTitleBlack;
        [bkgView addSubview:labTitle];
        
        SortUserGroup* userGroup = [contentArr objectAtIndex:section];
        labTitle.text = userGroup.name;
        
        return bkgView;
    }
    return nil;
}

// Footer

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 8;
//}
//
//- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    return [[UIView alloc] init];
//}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)sender {
    if (sender == listView) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (SortUserGroup* userGroup in contentArr) {
            [arr addObject:userGroup.name];
        }
        return arr;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)sender sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SimpleHeadCell heightWithItem:nil];
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SimpleHeadCell* cell = [sender dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    User* itemU = nil;
    if (sender == listView) {
        SortUserGroup* userGroup = [contentArr objectAtIndex:indexPath.section];
        itemU = [userGroup.userList objectAtIndex:indexPath.row];
    } else if (sender == self.searchDisplayController.searchResultsTableView) {
        itemU = [filteredArr objectAtIndex:indexPath.row];
    }
    
    cell.title = itemU.nickName;
    cell.detail = itemU.sign;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    User* itemU = nil;
    if (sender == listView) {
        SortUserGroup* userGroup = [contentArr objectAtIndex:indexPath.section];
        itemU = [userGroup.userList objectAtIndex:indexPath.row];
    } else if (sender == self.searchDisplayController.searchResultsTableView) {
        itemU = [filteredArr objectAtIndex:indexPath.row];
        [self.searchDisplayController setActive:NO animated:YES];
    }
    
    id con = [[UserDetailController alloc] initWithUser:itemU];
    [self pushViewController:con];
}

#pragma mark - ImageControl

- (NSInteger)baseTableView:(UITableView *)sender numberOfImagesAtIndexPath:(NSIndexPath *)indexPath {
    return 1;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    User* itemU = nil;
    if (sender == listView) {
        SortUserGroup* userGroup = [contentArr objectAtIndex:indexPath.section];
        itemU = [userGroup.userList objectAtIndex:indexPath.row];
    } else if (sender == self.searchDisplayController.searchResultsTableView) {
        itemU = [filteredArr objectAtIndex:indexPath.row];
    }
    return itemU.headImgUrlS;
}

- (UIImage*)baseTableView:(UITableView *)sender imageDefaultAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    return kImageDefaultHeadUser;
}

- (void)baseTableView:(UITableView *)sender loadImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    BaseHeadCell* cell = (BaseHeadCell*)[sender cellForRowAtIndexPath:indexPath];
    cell.imgHead = image;
}

#pragma mark - Search

- (void)baseFilterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    for (SortUserGroup* userGroup in contentArr) {
        for (User* itemU in userGroup.userList) {
            NSRange textRange = [itemU.nickName rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
            if (textRange.length > 0) {
                [filteredArr addObject:itemU];
            }
        }
    }
}

- (void)baseSearchDisplayControllerWillBeginSearch:(UISearchDisplayController *)sender {
    UINib* nibFile = [UINib nibWithNibName:identifier bundle:nil];
    [sender.searchResultsTableView registerNib:nibFile forCellReuseIdentifier:identifier];
}

@end
