//
//  GroupListController.m
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "GroupListController.h"
#import "GroupNewController.h"
#import "GroupSearchController.h"
#import "GroupDetailController.h"
#import "SimpleHeadCell.h"
#import "TCGroup.h"
#import "ChatViewController.h"

@interface GroupListController () <TCResultGroupListDelegate> {
    NSString* identifier;
}

@end

@implementation GroupListController

- (id)init
{
    self = [super initWithNibName:@"GroupListController" bundle:nil];
    if (self) {
        // Custom initialization
        identifier = @"SimpleHeadCell";
        shouldRefreshIfDropDown = YES;
        shouldRefreshIfLoadFirst = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    identifier = @"SimpleHeadCell";
    shouldRefreshIfDropDown = YES;
    shouldRefreshIfLoadFirst = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"群组";
    // Custom initialization
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinGroup:) name:kNotifyJoinGroup object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitGroup:) name:kNotifyQuitGroup object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editGroup:) name:kNotifyEditGroup object:nil];
    
    [self addBarButtonItemRightNormalImageName:@"nav_add_n" hightLited:@"nav_add_d"];
    [self addBarButtonItemLeftNormalImageName:@"nav_search_n" hightLited:@"nav_search_d"];
    
    [self registerNibForCellReuseIdentifier:identifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)barButtonItemRightPressed:(id)sender {
    id con = [[GroupNewController alloc] init];
    [self pushViewController:con];
}

- (void)barButtonItemLeftPressed:(id)sender {
    id con = [[GroupSearchController alloc] init];
    [self pushViewController:con];
}

#pragma mark - Notify Group

- (void)quitGroup:(NSNotification*)sender {
    [self refreshDataList];
}

- (void)joinGroup:(NSNotification*)sender {
    [self refreshDataList];
}

- (void)editGroup:(NSNotification*)sender {
    [self refreshDataList];
}

#pragma mark - Request

- (BOOL)sendRequest {
    if ([super sendRequest]) {
        tagRequest = [[ThinkChat instance] getGroupListDelegate:self];
        return YES;
    }
    return NO;
}

#pragma mark - TCResultGroupListDelegate

- (void)tcResultGroupList:(NSArray *)arr pageInfo:(TCPageInfo *)itemP error:(TCError *)itemE {
    [super getResponse:nil obj:nil];
    if (itemE == nil) {
        [contentArr addObjectsFromArray:arr];
        [listView reloadData];
    } else {
        [KAlertView showType:KAlertTypeError text:itemE.message for:1.5 animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
    return 1;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    return contentArr.count;
}

- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SimpleHeadCell heightWithItem:nil];
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SimpleHeadCell* cell = [sender dequeueReusableCellWithIdentifier:identifier];
    TCGroup*  itemG = [contentArr objectAtIndex:indexPath.row];
    cell.number = [NSString stringWithFormat:@"(%ld人)", (long)itemG.count];
    cell.title = itemG.name;
    cell.detail = itemG.description;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    TCGroup* itemG = [contentArr objectAtIndex:indexPath.row];
    id con = [[ChatViewController alloc] initWithGroup:itemG];
    [self pushViewController:con];
}

#pragma mark - ImageControl

- (NSInteger)baseTableView:(UITableView *)sender numberOfImagesAtIndexPath:(NSIndexPath *)indexPath {
    return 1;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    TCGroup* itemG = [contentArr objectAtIndex:indexPath.row];
    return itemG.headImgUrlS;
}

- (UIImage*)baseTableView:(UITableView *)sender imageDefaultAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    return kImageDefaultHeadGroup;
}

- (void)baseTableView:(UITableView *)sender loadImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    BaseHeadCell* cell = (BaseHeadCell*)[listView cellForRowAtIndexPath:indexPath];
    cell.imgHead = image;
}

@end
