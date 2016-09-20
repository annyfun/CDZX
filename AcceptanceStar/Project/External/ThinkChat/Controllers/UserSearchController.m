//
//  UserSearchController.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-11.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "UserSearchController.h"
#import "UserDetailController.h"
#import "SimpleHeadCell.h"
#import "User.h"

@interface UserSearchController () <UITextFieldDelegate> {
    IBOutlet UIView*        headerView;
    IBOutlet UITextField*   tfInput;
    NSString*   identifier;
}

@property (nonatomic, strong) NSString* searchKey;

@end

@implementation UserSearchController

@synthesize searchKey;

- (id)init
{
    self = [super initWithNibName:@"UserSearchController" bundle:nil];
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
    self.navigationItem.title = @"搜索用户";
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

- (BOOL)textField:(UITextField *)sender shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string hasPrefix:@"\n"]) {
        if (tfInput.text.length > 0) {
            self.searchKey = tfInput.text;
            [self sendRequest];
            [tfInput setText:nil];
        }
        [tfInput resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - Request

- (void)refreshDataList {
    [self hideKeyBoard];
    if (tfInput.text.length == 0) {
        [refreshControl performSelector:@selector(endRefreshing)
                             withObject:nil afterDelay:0
                                inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        [KAlertView showType:KAlertTypeError text:@"请输入昵称/星星号" for:1.5 animated:YES];
        [tfInput becomeFirstResponder];
        return;
    } else {
        self.searchKey = tfInput.text;
    }
    [super refreshDataList];
}

- (BOOL)sendRequest {
    if ([super sendRequest]) {
        [client searchUser:searchKey];
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
                [contentArr addObject:itemU];
            }
        }
        [listView reloadData];
        return YES;
    }
    return NO;
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
    
    User*  itemG = [contentArr objectAtIndex:indexPath.row];
    
    cell.title = itemG.nickName;
    cell.detail = itemG.sign;
    
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
    return kImageDefaultHeadGroup;
}

- (void)baseTableView:(UITableView *)sender loadImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    BaseHeadCell* cell = (BaseHeadCell*)[listView cellForRowAtIndexPath:indexPath];
    cell.imgHead = image;
}

@end
