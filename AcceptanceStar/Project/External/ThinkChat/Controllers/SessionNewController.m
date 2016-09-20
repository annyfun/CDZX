//
//  SessionNewController.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-19.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "SessionNewController.h"
#import "ChatViewController.h"
#import "HeadCheckCell.h"
#import "SortUserGroup.h"
#import "TCSession.h"
#import "User.h"

@interface SessionNewController () <TCResultNoneDelegate, TCResultGroupDelegate> {
    IBOutlet UIView*        footerView;
    IBOutlet UIScrollView*  contentView;
    UIButton*   btnNewInvite;
    NSString*   identifier;
    CGFloat     offSet;
}

@property (nonatomic, strong) NSMutableArray*   inviteArr;
@property (nonatomic, strong) NSMutableArray*   btnArr;
@property (nonatomic, strong) TCSession*        session;
@property (nonatomic, strong) NSArray*          userList;
@property (nonatomic, assign) id <SessionNewDelegate> delegate;

@end

@implementation SessionNewController

@synthesize inviteArr;
@synthesize btnArr;
@synthesize session;
@synthesize userList;
@synthesize delegate;

- (id)init
{
    return [self initWithSession:nil userList:nil delegate:nil];
}

- (id)initWithSession:(TCSession *)itemS userList:(NSArray *)arr delegate:(id<SessionNewDelegate>)del {
    self = [super initWithNibName:@"SessionNewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.session = itemS;
        self.userList = arr;
        self.delegate = del;
        
        self.inviteArr = [NSMutableArray array];
        self.btnArr = [NSMutableArray array];
        
        offSet = 5.0;
        identifier = @"HeadCheckCell";
        shouldRefreshIfLoadFirst = YES;
    }
    return self;
}

- (void)dealloc {
    // data
    self.inviteArr = nil;
    self.btnArr = nil;
    self.session = nil;
    self.userList = nil;
    self.delegate = nil;
    
    // view
    btnNewInvite = nil;
    footerView = nil;
    contentView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"添加参与人";
    
    [self registerNibForCellReuseIdentifier:identifier];
    
    footerView.backgroundColor = kColorTabBkg;
    footerView.layer.borderColor = kColorTitleLightGray.CGColor;
    footerView.layer.borderWidth = 1.0;
    
    btnNewInvite = [[UIButton alloc] initWithFrame:CGRectMake(offSet, offSet, contentView.height - offSet*2, contentView.height - offSet*2)];
    [btnNewInvite setImage:[UIImage imageNamed:@"btn_add_n"] forState:UIControlStateNormal];
    [btnNewInvite setImage:[UIImage imageNamed:@"btn_add_d"] forState:UIControlStateHighlighted];
    [contentView addSubview:btnNewInvite];
    
    [btnArr addObject:btnNewInvite];
    
    [self addBarButtonItemRightNormalImageName:@"nav_ok_n" hightLited:@"nav_ok_d"];
    
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

- (void)btnPressed:(id)sender {
    if (sender == btnNewInvite) {
        // do nothing
    } else if ([btnArr containsObject:sender]) {
        NSInteger index = [btnArr indexOfObject:sender];
        User* itemU = [inviteArr objectAtIndex:index];
        [self removeInviteUser:itemU];
    }
}

- (void)barButtonItemRightPressed:(id)sender {
    if (inviteArr.count == 0) {
        [WCAlertView showAlertWithTitle:@"提示" message:@"请选择好友" customizationBlock:nil completionBlock:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        return;
    }
    if (session || inviteArr.count > 1) {
        baseRequestType = forBaseListRequestOther;
        [self sendRequest];
    } else if (inviteArr.count == 1) {
        id con = [[ChatViewController alloc] initWithUser:[inviteArr objectAtIndex:0]];
        [self pushViewController:con];
    }
}

- (void)addInviteUser:(User*)item {
    [inviteArr addObject:item];
    [listView reloadData];
    
    UIButton* btn = [[UIButton alloc] initWithFrame:btnNewInvite.frame];
    [btnArr insertObject:btn atIndex:btnArr.count-1];
    [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
//    NSInteger index = [contentArr indexOfObject:item];
    NSInteger section = 0;
    NSInteger row = 0;
    for (section = 0; section < contentArr.count; section++) {
        BOOL shouldBreak = NO;
        SortUserGroup* userGroup = [contentArr objectAtIndex:section];
        for (row = 0; row < userGroup.userList.count; row++) {
            User* itemU = [userGroup.userList objectAtIndex:row];
            if ([itemU.ID isEqualToString:item.ID]) {
                shouldBreak = YES;
                break;
            }
        }
        if (shouldBreak) {
            break;
        }
    }
    
    HeadCheckCell* cell = (HeadCheckCell*)[listView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    [btn setImage:cell.imgHead forState:UIControlStateNormal];
    
    CGRect frame = btnNewInvite.frame;
    frame.origin.x += offSet + frame.size.width;
    [UIView animateWithDuration:0.3 animations:^{
        btnNewInvite.frame = frame;
    } completion:^(BOOL finished) {
        [contentView addSubview:btn];
        contentView.contentSize = CGSizeMake((inviteArr.count + 1) * (btnNewInvite.width + offSet) + offSet, contentView.height);
        [contentView scrollRectToVisible:btnNewInvite.frame animated:YES];
    }];
}

- (void)removeInviteUser:(User*)item {
    NSInteger index = [inviteArr indexOfObject:item];
    
    UIButton* btn = [btnArr objectAtIndex:index];
    [btn removeFromSuperview];
    [btnArr removeObject:btn];
    
    [UIView animateWithDuration:0.3 animations:^{
        for (NSInteger i = index; i < btnArr.count; i++) {
            UIButton* btn = [btnArr objectAtIndex:i];
            CGRect frame = btn.frame;
            frame.origin.x -= btnNewInvite.width + offSet;
            btn.frame = frame;
        }
        contentView.contentSize = CGSizeMake((inviteArr.count + 1) * (btnNewInvite.width + offSet) + offSet, contentView.height);
    } completion:^(BOOL finished) {
        
    }];
    
    [inviteArr removeObject:item];
    [listView reloadData];
}

#pragma mark - Request

- (BOOL)sendRequest {
    if ([super sendRequest]) {
        if (baseRequestType == forBaseListRequestDataList) {
            [client getFriendList];
        } else if (baseRequestType == forBaseListRequestOther) {
            if (session == nil || session.typeChat == forChatTypeUser) {
                // 新建一个临时会话
                NSMutableArray* tmpNameArr = [[NSMutableArray alloc] init];
                NSMutableArray* tmpIDArr = [[NSMutableArray alloc] init];
                for (User* itemU in inviteArr) {
                    [tmpIDArr addObject:itemU.ID];
                    if (tmpNameArr.count < 4) {
                        [tmpNameArr addObject:itemU.nickName];
                    }
                }
                for (User* itemU in userList) {
                    [tmpIDArr addObject:itemU.ID];
                    if (tmpNameArr.count < 4) {
                        [tmpNameArr addObject:itemU.nickName];
                    }
                }
                if (tmpNameArr.count < 4) {
                    [tmpNameArr addObject:[BaseEngine currentBaseEngine].user.nickName];
                }
                tagRequest = [[ThinkChat instance] createConversationName:[tmpNameArr componentsJoinedByString:@","] userList:tmpIDArr delegate:self];
            } else if (session.typeChat == forChatTypeRoom) {
                // 为临时会话添加成员
                NSMutableArray* tmpIDArr = [[NSMutableArray alloc] init];
                for (User* itemU in inviteArr) {
                    [tmpIDArr addObject:itemU.ID];
                }
                tagRequest = [[ThinkChat instance] addUserList:tmpIDArr toConversation:session.ID delegate:self];
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL)getResponse:(BaseClient *)sender obj:(NSDictionary *)obj {
    if ([super getResponse:sender obj:obj]) {
        if (baseRequestType == forBaseListRequestDataList) {
            NSArray* arr = [obj getArrayForKey:@"data" defaultValue:nil];
            for (NSDictionary* dic in arr) {
                User* itemU = [User objWithJsonDic:dic];
                if (itemU) {
                    if ([self isAddedUser:itemU]) {
                        continue;
                    }
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
        } else if (baseRequestType == forBaseListRequestOther) {

        }
        return YES;
    }
    return NO;
}

- (BOOL)isAddedUser:(User*)item {
    for (User* tmpU in userList) {
        if ([tmpU.ID isEqualToString:item.ID]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - TCResultNoneDelegate

- (void)tcResultNoneError:(TCError *)itemE {
    [super getResponse:nil obj:nil];
    if (itemE == nil) {
        if ([delegate respondsToSelector:@selector(sessionNew:addUserList:)]) {
            [delegate sessionNew:self addUserList:inviteArr];
        }
        [self popViewController];
    } else {
        [KAlertView showType:KAlertTypeError text:itemE.message for:1.5 animated:YES];
    }
}

#pragma mark - TCResultGroupDelegate

- (void)tcResultGroup:(TCGroup *)itemG error:(TCError *)itemE {
    [super getResponse:nil obj:nil];
    if (itemE == nil) {
        id con = [[ChatViewController alloc] initWithGroup:itemG];
        [self pushViewController:con];
    } else {
        [KAlertView showType:KAlertTypeError text:itemE.message for:1.5 animated:YES];
    }
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
    return [HeadCheckCell heightWithItem:nil];
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HeadCheckCell* cell = [sender dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    User* itemU = nil;
    if (sender == listView) {
        SortUserGroup* userGroup = [contentArr objectAtIndex:indexPath.section];
        itemU = [userGroup.userList objectAtIndex:indexPath.row];
    } else if (sender == self.searchDisplayController.searchResultsTableView) {
        itemU = [filteredArr objectAtIndex:indexPath.row];
    }
    
    cell.title = itemU.nickName;
    cell.content = itemU.sign;
    
    if ([inviteArr containsObject:itemU]) {
        cell.isCheck = YES;
    } else {
        cell.isCheck = NO;
    }
    
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
    
    if ([inviteArr containsObject:itemU]) {
        [self removeInviteUser:itemU];
    } else {
        [self addInviteUser:itemU];
    }
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
