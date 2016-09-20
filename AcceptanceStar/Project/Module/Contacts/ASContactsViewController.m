//
//  ASContactsViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/28.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASContactsViewController.h"
#import "ASContactsCell.h"
#import "ASContactsHeader.h"
#import "HMSegmentedControl.h"
#import "ChatViewController.h"

@interface ASContactsViewController () <TCResultGroupDelegate, UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet HMSegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet YSCTableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpace;//49
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottom;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;
@property (nonatomic, strong) NSMutableArray *searchResultArray;
@property (strong, nonatomic) NSString *isUserChangedObserverIdentifier;
@end

@implementation ASContactsViewController

@synthesize searchDisplayController;

- (void)dealloc {
    if (self.isUserChangedObserverIdentifier) {
        [[Login sharedInstance] bk_removeObserversWithIdentifier:self.isUserChangedObserverIdentifier];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.methodName = kResPathAppUserFriendListWithGroup;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"通讯录";
    self.searchResultArray = [NSMutableArray array];
    self.bottomSpace.constant = 49;
    [self.nextButton makeRoundWithRadius:5];
    [self initSegmentControl];
    [self initTableView];
    [self initSearchBar];
    WEAKSELF
    self.block = ^(NSObject *object){
        [blockSelf.tableView.header beginRefreshing];
    };
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"button_add1"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        [blockSelf pushViewController:@"ASSearchUserViewController" withParams:@{kParamTitle : @"添加好友"}];
    }];
    self.isUserChangedObserverIdentifier = [[Login sharedInstance] bk_addObserverForKeyPath:@"isUserChanged" task:^(id target) {
        blockSelf.tableView.methodName = kResPathAppUserFriendListWithGroup;
        [blockSelf.tableView beginRefreshing];
    }];
}
- (void)initTableView {
    WEAKSELF1
    self.bottomView.hidden = YES;
    self.tableViewBottom.constant = 49;
    
    self.tableView.cellName = @"ASContactsCell";
    self.tableView.headerName = @"ASContactsHeader";
    self.tableView.methodName = kResPathAppUserFriendListWithGroup;
    self.tableView.modelName = @"UserGroupModel";
    self.tableView.tipsEmptyText = @"暂无好友数据哟";
    self.tableView.dictParamBlock = ^NSDictionary *(NSInteger page) {
        NSString *temp = [@"user/friendListWithGroup/token" stringByAppendingPathComponent:TOKEN];
        NSLog(@"temp=%@", temp);
        return @{kParamPage : @(page), kParamPageSize : @(10)};
    };
    self.tableView.preProcessBlock = ^NSArray *(NSArray *array) {
        NSMutableArray *retArray = [NSMutableArray array];
        if (kDefaultPageStartIndex == weakSelf.tableView.currentPageIndex) {
            UserModel *tempModel = [UserModel new];
            tempModel.sectionKey = @"分组管理";
            [retArray addObject:tempModel];
        }
        for (UserGroupModel *group in array) {
            for (UserModel *user in group.users) {
                user.sectionKey = Trim(group.name);
                [retArray addObject:user];
            }
        }
        return retArray;
    };
    self.tableView.layoutHeaderView = ^ (UIView *view, NSObject *object) {
        ASContactsHeader *headerView = (ASContactsHeader *)view;
        UserModel *user = (UserModel *)object;
        NSInteger section = [weakSelf.tableView.headerDataArray indexOfObject:object];
        if (0 == section) {
            headerView.groupNameLabel.text = Trim(user.sectionKey);
            headerView.arrowImageView.image = [UIImage imageNamed:@"icon_groupmanage"];
            headerView.markView.hidden = YES;
            return ;
        }
        
        NSArray *group = weakSelf.tableView.cellDataArray[section];
        headerView.groupNameLabel.text = Trim(user.sectionKey);
        [headerView layoutObject:user];
        headerView.markView.hidden = (0 == weakSelf.segmentControl.selectedSegmentIndex);
        
        [headerView.markView removeAllGestureRecognizers];
        [headerView.markView bk_whenTapped:^{
            user.isSelected = ! user.isSelected;
            [headerView resetSelected:user.isSelected];
            for (UserModel *tempUser in group) {
                tempUser.isSelected = user.isSelected;
            }
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
        }];
    };
    self.tableView.clickHeaderBlock = ^(NSObject *object, NSInteger section) {
        if (0 == section) {
            [weakSelf presentViewController:@"ASGroupManageViewController"
                                  withParams:@{kParamTitle : @"分组管理",
                                               kParamBlock : weakSelf.block}];
        }
        else {
            UserModel *user = (UserModel *)object;
            user.isOpen = !user.isOpen;
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
            if (user.isOpen) {
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
    };
    self.tableView.numberOfCellBlock = ^NSInteger (NSInteger section) {
        UserModel *user = weakSelf.tableView.headerDataArray[section];
        if (user.isOpen) {
            NSArray *array = weakSelf.tableView.cellDataArray[section];
            return [array count];
        }
        else {
            return 0;
        }
    };
    self.tableView.layoutCellView = ^(UIView *view, NSObject *object) {
        ASContactsCell *cell = (ASContactsCell *)view;
        cell.markView.hidden = (0 == weakSelf.segmentControl.selectedSegmentIndex);
    };
    self.tableView.clickCellBlock = ^(NSObject *object, NSIndexPath *indexPath) {
        [weakSelf pushViewController:@"ASUserProfileViewController"
                      withParams:@{kParamModel : object,
                                   kParamBlock : weakSelf.block}];
    };
    
    [self.tableView beginRefreshing];
}
- (void)initSearchBar {
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    searchBar.delegate = self;
    searchBar.placeholder = @"输入用户昵称搜索好友";
    self.tableView.tableHeaderView = searchBar;
    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    self.searchDisplayController.searchResultsTableView.backgroundColor = RGB(232, 234, 235);
    self.searchDisplayController.searchResultsTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [ASContactsCell registerCellToTableView:self.searchDisplayController.searchResultsTableView];
}
- (void)initSegmentControl {
    self.segmentControl.backgroundColor = [UIColor clearColor];
    self.segmentControl.textColor = RGB(75, 75, 75);
    self.segmentControl.selectedTextColor = RGB(49, 149, 242);
    self.segmentControl.sectionTitles = @[@"好友分组",@"群发消息"];
    self.segmentControl.selectionIndicatorColor = RGB(49, 149, 242);
    self.segmentControl.font = AUTOLAYOUT_FONT(34);
    self.segmentControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.segmentControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentControl.selectionIndicatorHeight = 2;
    WEAKSELF
    [self.segmentControl setIndexChangeBlock:^(NSInteger pageIndex) {
        [blockSelf.tableView reloadData];
        if (0 == pageIndex) {
            blockSelf.tableViewBottom.constant = 49;
            blockSelf.bottomView.hidden = YES;
        }
        else {
            blockSelf.tableViewBottom.constant = 49 + AUTOLAYOUT_LENGTH(120);
            blockSelf.bottomView.hidden = NO;
        }
    }];
}

//下一步
- (IBAction)nextStepButtonClicked:(id)sender {
    NSMutableArray *uids = [NSMutableArray array];
    for (NSArray *array in self.tableView.cellDataArray) {
        for (UserModel *user in array) {
            if (user.isSelected) {
                [uids addObject:Trim(user.userId)];
            }
        }
    }
    if (isEmpty(uids)) {
        [self showResultThenHide:@"请先选择用户"];
        return;
    }
    
    [[ThinkChat instance] createConversationName:@"群发消息" userList:uids delegate:self];
}

#pragma mark - TCResultGroupDelegate
- (void)tcResultGroup:(TCGroup*)itemG error:(TCError*)itemE {
    ChatViewController *chatVc = [[ChatViewController alloc] initWithGroup:itemG];
    chatVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVc animated:YES];
}



#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResultArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASContactsCell *cell = [ASContactsCell dequeueCellByTableView:self.searchDisplayController.searchResultsTableView];
    UserModel *dataModel = self.searchResultArray[indexPath.row];
    cell.markView.hidden = YES;
    [cell layoutObject:dataModel];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ASContactsCell HeightOfCellByObject:nil];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UserModel *dataModel = self.searchResultArray[indexPath.row];
    [self pushViewController:@"ASUserProfileViewController"
                      withParams:@{kParamModel : dataModel,
                                   kParamBlock : self.block}];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.searchResultArray removeAllObjects];
    for (NSArray *array in self.tableView.cellDataArray) {
        for (UserModel *user in array) {
            if ([user.nickname.lowercaseString containsString:searchText.lowercaseString]) {
                [self.searchResultArray addObject:user];
            }
        }
    }
    [self.searchDisplayController.searchResultsTableView reloadData];
}
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text) {
        
    }
}
@end
