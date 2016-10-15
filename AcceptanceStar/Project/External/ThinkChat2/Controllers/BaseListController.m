//
//  BaseListController.m
//  Base
//
//  Created by keen on 13-11-15.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import "BaseListController.h"
#import "NSDictionaryAdditions.h"
#import "ImageProgressQueue.h"
#import "SRRefreshView.h"
#import "BaseHeadCell.h"

#define BaseListImageProgressQueueForListView   20000
#define BaseListImageProgressQueueForFilter     10000

@interface BaseListController () <SRRefreshDelegate, UIScrollViewDelegate> {
    ImageProgressQueue  * baseFilterImageQueue;
}

@end

@implementation BaseListController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        contentArr = [[NSMutableArray alloc] init];
        filteredArr = [[NSMutableArray alloc] init];
        
        baseRequestType = forBaseListRequestDataList;
        
        isAddMore = NO;
        hasMore = NO;
        nextPage = 1;
        count = 20;
        
        shouldRefreshIfLoadFirst = NO;
        shouldRefreshIfDropDown = NO;
        shouldAddMoreAutomatic = NO;
        
        baseOperationQueue = [[NSOperationQueue alloc] init];
        baseOperationQueue.maxConcurrentOperationCount = 1;
        baseImageQueue = [[ImageProgressQueue alloc] initWithDelegate:self];
        baseFilterImageQueue = [[ImageProgressQueue alloc] initWithDelegate:self];
    }
    return self;
}

- (void)dealloc {
    // data
    [baseOperationQueue cancelAllOperations];
    [baseImageQueue cancelOperations];
    [baseFilterImageQueue cancelOperations];
    baseOperationQueue = nil;
    baseImageQueue = nil;
    baseFilterImageQueue = nil;
    
    contentArr = nil;
    filteredArr = nil;
    
    // view
    listView.delegate = nil;
    listView.dataSource = nil;
    listView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    listView.backgroundColor = kColorViewBkg;
    if ([listView respondsToSelector:@selector(setBackgroundView:)]) {
        [listView setBackgroundView:nil];
    }
    if ([listView respondsToSelector:@selector(setKeyboardDismissMode:)]) {
        listView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
    
    if (isGrouped) {
        listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    UIView* tmpFooterView = [[UIView alloc] init];
    listView.tableFooterView = tmpFooterView;
    
    if (shouldRefreshIfDropDown) {
        [self enableSlimeRefresh];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (shouldRefreshIfLoadFirst) {
        shouldRefreshIfLoadFirst = NO;
        [self refreshDataList];
    }
}

- (void)registerNibForCellReuseIdentifier:(NSString *)value {
    UINib* nibFile = nil;
    nibFile = [UINib nibWithNibName:value bundle:nil];
    [listView registerNib:nibFile forCellReuseIdentifier:value];
}

- (void)cancelImageLoadQueue {
    [baseOperationQueue cancelAllOperations];
    [baseImageQueue cancelOperations];
    [baseFilterImageQueue cancelOperations];
}

- (void)addMoreDataList {
    if (client) {
        return;
    }
    if (hasMore) {
        isAddMore = YES;
        hasMore = NO;
        baseRequestType = forBaseListRequestDataList;
        [self sendRequest];
    }
}

- (void)refreshDataList {
    if (client) {
        return;
    }
    hasMore = NO;
    isAddMore = NO;
    nextPage = 1;
    baseRequestType = forBaseListRequestDataList;
    [self sendRequest];
}

- (BOOL)getResponse:(BaseClient *)sender obj:(NSDictionary *)obj {
    [refreshControl performSelector:@selector(endRefreshing)
                         withObject:nil afterDelay:0
                            inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    if ([super getResponse:sender obj:obj]) {
        if (baseRequestType == forBaseListRequestDataList) {
            if (!isAddMore) {
                [contentArr removeAllObjects];
            }
            hasMore = NO;
            NSDictionary* pageInfo = [obj objectForKey:@"pageInfo"];
            if (pageInfo != nil && [pageInfo isKindOfClass:[NSDictionary class]]) {
                hasMore = [pageInfo getBoolValueForKey:@"hasMore" defaultValue:NO];
                if (hasMore) {
                    nextPage++;
                }
            }
        }
        return YES;
    }
    if (isAddMore) {
        hasMore = YES;
    }
    return NO;
}

- (BOOL)baseTableView:(UITableView *)sender isAddMoreAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSInteger)baseTableView:(UITableView *)sender numberOfImagesAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    return nil;
}

- (UIImage*)baseTableView:(UITableView *)sender imageDefaultAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    return kImageDefaultHeadUser;
}

- (void)baseTableView:(UITableView *)sender loadImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    // set image
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (sender == listView) {
        if ([refreshControl isKindOfClass:[SRRefreshView class]])
            [(SRRefreshView*)refreshControl scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)sender willDecelerate:(BOOL)decelerate {
    if (sender == listView) {
        if ([refreshControl isKindOfClass:[SRRefreshView class]])
            [(SRRefreshView*)refreshControl scrollViewDidEndDraging];
    }
}

#pragma mark - SlimeRefresh

- (void)enableSlimeRefresh {
    if (systemVersionFloatValue < 6.0) {
        SRRefreshView * refC = [[SRRefreshView alloc] init];
        refC.delegate = self;
        refC.upInset = 0;
        refC.slimeMissWhenGoingBack = YES;
        refC.slime.bodyColor = RGBCOLOR(165, 165, 165);
        refC.slime.skinColor = RGBCOLOR(195, 195, 195);
        refC.slime.lineWith = 2;
        refC.slime.shadowBlur = 2;
        refC.slime.shadowColor = RGBCOLOR(50, 50, 50);
        refC.backgroundColor = [UIColor clearColor];
        [listView addSubview:refC];
        refreshControl = refC;
    } else {
        UIRefreshControl * refC = [[UIRefreshControl alloc] init];
        refC.tintColor = RGBCOLOR(165, 165, 165);
        [refC addTarget:self action:@selector(slimeRefreshStartRefresh:) forControlEvents:UIControlEventValueChanged];
        [listView addSubview:refC];
        [refC endRefreshing];
        refreshControl = refC;
    }
}

- (void)beginRefreshing {
    if (systemVersionFloatValue < 6) {
        
    } else {
        UIRefreshControl * refC = (UIRefreshControl*)refreshControl;
        [refC beginRefreshing];
        if (systemVersionFloatValue < 7) {
            [listView setContentOffset:CGPointMake(0, -refreshControl.frame.size.height) animated:YES];
        } else {
            [listView setContentOffset:CGPointMake(0, -refreshControl.frame.size.height * 2) animated:YES];
        }
    }
    [self performSelector:@selector(slimeRefreshStartRefresh:) withObject:refreshControl];
}

- (void)slimeRefreshStartRefresh:(SRRefreshView *)sender {
    [self refreshDataList];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
    return 1;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    NSInteger rowsNumber = 0;
    if (sender == listView) {
        rowsNumber = contentArr.count;
    } else if (sender == self.searchDisplayController.searchResultsTableView) {
        rowsNumber = filteredArr.count;
    }
    return rowsNumber;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"Cell";
    UITableViewCell* cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
}

- (void)tableView:(UITableView *)sender willDisplayCell:(BaseHeadCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isGrouped) {
        UIImage* imgN = nil;
        UIImage* imgD = nil;
        if (indexPath.row == 0 && indexPath.row == [self tableView:sender numberOfRowsInSection:indexPath.section] - 1) {
            // 单独一行
            imgN = [[UIImage imageNamed:@"cell_group_gray_single_n"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
            imgD = [[UIImage imageNamed:@"cell_group_gray_single_d"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
        } else if (indexPath.row == 0) {
            // 第一行
            imgN = [[UIImage imageNamed:@"cell_group_gray_top_n"] stretchableImageWithLeftCapWidth:8 topCapHeight:6];
            imgD = [[UIImage imageNamed:@"cell_group_gray_top_d"] stretchableImageWithLeftCapWidth:8 topCapHeight:6];
        } else if (indexPath.row == [self tableView:sender numberOfRowsInSection:indexPath.section] - 1) {
            // 最后一行
            imgN = [[UIImage imageNamed:@"cell_group_gray_bottom_n"] stretchableImageWithLeftCapWidth:8 topCapHeight:1];
            imgD = [[UIImage imageNamed:@"cell_group_gray_bottom_d"] stretchableImageWithLeftCapWidth:8 topCapHeight:1];
        } else {
            // 中间行
            imgN = [[UIImage imageNamed:@"cell_group_gray_middle_n"] stretchableImageWithLeftCapWidth:8 topCapHeight:1];
            imgD = [[UIImage imageNamed:@"cell_group_gray_middle_d"] stretchableImageWithLeftCapWidth:8 topCapHeight:1];
        }
        ((UIImageView*)cell.backgroundView).image = imgN;
        ((UIImageView*)cell.selectedBackgroundView).image = imgD;
        cell.backgroundView.backgroundColor = kColorClear;
        cell.selectedBackgroundView.backgroundColor = kColorClear;
    }
    if (shouldAddMoreAutomatic && hasMore) {
        if (indexPath.section == [self numberOfSectionsInTableView:sender] - 1) {
            if (indexPath.row == [self tableView:sender numberOfRowsInSection:indexPath.section] - 1) {
                [self addMoreDataList];
            }
        }
    }
    if (cell != nil) {
        if ([self baseTableView:sender numberOfImagesAtIndexPath:indexPath] > 0) {
            SEL action = nil;
            if (sender == listView) {
                action = @selector(baseImageLoadThread:);
            } else if (sender == self.searchDisplayController.searchResultsTableView) {
                action = @selector(baseFilterImageLoadThread:);
            }
            if (action != nil) {
                NSInvocationOperation * opItem = [[NSInvocationOperation alloc] initWithTarget:self selector:action object:indexPath];
                [baseOperationQueue addOperation:opItem];
            }
        }
    }
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ImageQueueDelegate & ImageThread

- (void)baseImageLoadThread:(NSIndexPath*)indexPath {
    @autoreleasepool {
        NSInteger numberTags = [self baseTableView:listView numberOfImagesAtIndexPath:indexPath];
        for (int i = 0; i < numberTags; i++) {
            NSString* url = [self baseTableView:listView imageURLAtIndexPath:indexPath index:i];
            //        if (url != nil && [url hasPrefix:@"http"]) {
            ImageProgress * pro = [[ImageProgress alloc] initWithUrl:url delegate:baseImageQueue];
            pro.indexPath = indexPath;
            pro.tag = BaseListImageProgressQueueForListView + i;
            [self performSelectorOnMainThread:@selector(baseImageUpdateOnMain:) withObject:pro waitUntilDone:YES];
            //        }
        }
    }
}

- (void)baseFilterImageLoadThread:(NSIndexPath*)indexPath {
    @autoreleasepool {
        NSInteger numberTags = [self baseTableView:self.searchDisplayController.searchResultsTableView numberOfImagesAtIndexPath:indexPath];
        for (int i = 0; i < numberTags; i++) {
            NSString* url = [self baseTableView:self.searchDisplayController.searchResultsTableView imageURLAtIndexPath:indexPath index:i];
            //        if (url != nil && [url hasPrefix:@"http"]) {
            ImageProgress * pro = [[ImageProgress alloc] initWithUrl:url delegate:baseImageQueue];
            pro.indexPath = indexPath;
            pro.tag = BaseListImageProgressQueueForFilter + i;
            [self performSelectorOnMainThread:@selector(baseImageUpdateOnMain:) withObject:pro waitUntilDone:YES];
            //        }
        }
    }
}

- (void)baseImageUpdateOnMain:(ImageProgress*)pro {
    UITableView* tmpListView = nil;
    ImageProgressQueue* tmpImageQueue = nil;
    NSInteger tag = -1;
    if (pro.tag >= BaseListImageProgressQueueForListView) {
        tmpListView = listView;
        tmpImageQueue = baseImageQueue;
        tag = pro.tag - BaseListImageProgressQueueForListView;
    } else if (pro.tag >= BaseListImageProgressQueueForFilter) {
        tmpListView = self.searchDisplayController.searchResultsTableView;
        tmpImageQueue = baseFilterImageQueue;
        tag = pro.tag - BaseListImageProgressQueueForFilter;
    }
    if (tmpListView && tmpImageQueue) {
        if (pro.loaded) {
            [self baseTableView:tmpListView loadImage:pro.image atIndexPath:pro.indexPath index:tag];
        } else {
            UIImage* tmpImage = [self baseTableView:tmpListView imageDefaultAtIndexPath:pro.indexPath index:tag];
            [self baseTableView:tmpListView loadImage:tmpImage atIndexPath:pro.indexPath index:tag];
            [tmpImageQueue addOperation:pro];
        }
    }
    pro = nil;
}

- (void)imageProgressCompleted:(UIImage*)img indexPath:(NSIndexPath*)idx tag:(int)tag {
    UITableView* tmpListView = nil;
    if (tag >= BaseListImageProgressQueueForListView) {
        tmpListView = listView;
        tag -= BaseListImageProgressQueueForListView;
    } else if (tag >= BaseListImageProgressQueueForFilter) {
        tmpListView = self.searchDisplayController.searchResultsTableView;
        tag -= BaseListImageProgressQueueForFilter;
    }
    [self baseTableView:tmpListView loadImage:img atIndexPath:idx index:tag];
}

#pragma mark -
#pragma mark Content Filtering

- (void)baseFilterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    // 在子类中实现具体的筛选过程
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [filteredArr removeAllObjects];
    
    [self baseFilterContentForSearchText:searchText scope:scope];
    
    if (filteredArr.count == 0) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.001);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            for (UIView* v in self.searchDisplayController.searchResultsTableView.subviews) {
                if ([v isKindOfClass: [UILabel class]]) {
                    UILabel *lbl = (UILabel *)v;
                    [lbl setText:@"没有更多信息"];
                    break;
                }
            }
        });
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    UIView * superView = nil;
    if (systemVersionFloatValue < 7) {
        superView = self.searchDisplayController.searchBar;
    } else {
        superView = [self.searchDisplayController.searchBar.subviews lastObject];
    }
    for (UIView *v in superView.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton * btn = (UIButton *)v;
            [btn setTitle:@"取消"  forState:UIControlStateNormal];
            [btn.titleLabel setShadowOffset:CGSizeZero];
            [btn setTitleColor:kColorTitleBlue forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
        }
    }
    return YES;
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (void)baseSearchDisplayControllerWillBeginSearch:(UISearchDisplayController *)sender {
    // 在子类中实现,如果 Cell 使用 nib 初始化,需要向 searchResultsTableView 注册.
}

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)sender {
    [baseFilterImageQueue cancelOperations];
    
    [self baseSearchDisplayControllerWillBeginSearch:sender];
    
    sender.searchResultsTableView.backgroundColor = kColorViewBkg;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)sender shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)sender shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
