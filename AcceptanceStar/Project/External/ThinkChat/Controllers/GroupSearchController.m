//
//  GroupSearchController.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-11.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "GroupSearchController.h"
#import "GroupDetailController.h"
#import "SimpleHeadCell.h"
#import "TCGroup.h"

@interface GroupSearchController () <UITextFieldDelegate, TCResultGroupListDelegate> {
    IBOutlet UIView*        headerView;
    IBOutlet UITextField*   tfInput;
    NSString*   identifier;
}

@property (nonatomic, strong) NSString* searchKey;

@end

@implementation GroupSearchController

@synthesize searchKey;

- (id)init
{
    self = [super initWithNibName:@"GroupSearchController" bundle:nil];
    if (self) {
        // Custom initialization
        identifier = @"SimpleHeadCell";
    }
    return self;
}

- (void)dealloc {
    headerView = nil;
    tfInput = nil;
    self.searchKey = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"搜索群组";
    tfInput.delegate = self;
    headerView.backgroundColor = kColorClear;

    [self registerNibForCellReuseIdentifier:identifier];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (contentArr.count == 0) {
        [tfInput becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    self.searchKey = tfInput.text;
    [self sendRequest];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Request

- (void)refreshDataList {
    [self hideKeyBoard];
    if (tfInput.text.length == 0) {
        [refreshControl performSelector:@selector(endRefreshing)
                             withObject:nil afterDelay:0
                                inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        [KAlertView showType:KAlertTypeError text:@"请输入群组名称" for:1.5 animated:YES];
        [tfInput becomeFirstResponder];
        return;
    } else {
        self.searchKey = tfInput.text;
    }
    [super refreshDataList];
}

- (BOOL)sendRequest {
    if ([super sendRequest]) {
        tagRequest = [[ThinkChat instance] searchGroup:searchKey count:count page:nextPage delegate:self];
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
    
    cell.title = itemG.name;
    cell.detail = itemG.description;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    TCGroup* itemG = [contentArr objectAtIndex:indexPath.row];
    id con = [[GroupDetailController alloc] initWithGroup:itemG];
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
