//
//  BaseListController.h
//  Base
//
//  Created by keen on 13-11-15.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import "BaseViewController.h"
#import "ImageProgressQueue.h"
#import "BaseTableViewCell.h"

typedef enum {
    forBaseListRequestDataList,
    forBaseListRequestOther,
}BaseListRequestType;

@interface BaseListController : BaseViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView    * listView;
    NSMutableArray          * contentArr;
    NSMutableArray          * filteredArr;
    
    BaseListRequestType     baseRequestType;
    
    BOOL    isAddMore;
    BOOL    hasMore;
    int     nextPage;
    int     count;
    
    NSOperationQueue    * baseOperationQueue;
    ImageProgressQueue  * baseImageQueue;
    
    UIView * refreshControl;

    BOOL                    shouldRefreshIfLoadFirst;   // 首次加载,自动刷新,默认 no
    BOOL                    shouldRefreshIfDropDown;    // 支持下拉刷新,默认 no
    BOOL                    shouldAddMoreAutomatic;     // 支持自动加载更多,默认 no
    BOOL                    isGrouped;
}

// Add More
- (BOOL)baseTableView:(UITableView *)sender isAddMoreAtIndexPath:(NSIndexPath *)indexPath;

// Image Load
- (NSInteger)baseTableView:(UITableView *)sender numberOfImagesAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index;
- (UIImage *)baseTableView:(UITableView *)sender imageDefaultAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index;
- (void)baseTableView:(UITableView *)sender loadImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index;

- (void)baseFilterContentForSearchText:(NSString *)searchText scope:(NSString *)scope;
- (void)baseSearchDisplayControllerWillBeginSearch:(UISearchDisplayController *)sender;

- (void)cancelImageLoadQueue;
- (void)addMoreDataList;
- (void)refreshDataList;

- (void)registerNibForCellReuseIdentifier:(NSString*)value;

@end
