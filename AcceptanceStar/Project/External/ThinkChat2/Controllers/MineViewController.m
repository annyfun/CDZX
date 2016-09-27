//
//  MineViewController.m
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "MineViewController.h"
#import "UserDetailController.h"
#import "SettingController.h"

@interface MineViewController () {
    BaseClient* clientHide;
    BOOL        shouldRefreshHide;
}

@property (nonatomic, strong) User*     user;
@property (nonatomic, strong) UIImage*  headImage;

@end

@implementation MineViewController

@synthesize user;
@synthesize headImage;

- (id)init
{
    self = [super initWithNibName:@"MineViewController" bundle:nil];
    if (self) {
        // Custom initialization
        
        self.user = [BaseEngine currentBaseEngine].user;
    }
    return self;
}

- (void)dealloc {
    [clientHide cancel];
    clientHide = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"我";
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
        NSDictionary* dic = [obj objectForKey:@"data"];
        User* item = [User objWithJsonDic:dic];
        if (item) {
            self.user = item;
            [[BaseEngine currentBaseEngine] setCurrentUser:item password:[BaseEngine currentBaseEngine].passWord];
            self.headImage = nil;
            [listView reloadData];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
    return 2;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 90;
    }
    return 44;
}

// Header

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 25;
    }
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [[UIView alloc] init];
    }
    return nil;
}

// Footer

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 25;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"Cell";
    BaseTableViewCell* cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    }
    
    if (indexPath.section == 0) {
        if (headImage) {
            cell.imageView.image = headImage;
        } else {
            cell.imageView.image = kImageDefaultHeadUser;
        }
        cell.textLabel.text = user.nickName;
        cell.detailTextLabel.text = user.sign;
    } else if (indexPath.section == 1) {
        cell.imageView.image = [UIImage imageNamed:@"cell_setting"];
        cell.textLabel.text = @"设置";
        cell.detailTextLabel.text = nil;
    }
    
    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(BaseTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        [cell update:^{
            CGRect frame = cell.contentView.frame;
            CGFloat offSetX = 10.0;
            CGFloat offSetY = 4.0;
            CGRect frameImg = CGRectMake(offSetX, offSetY, 60, frame.size.height - offSetY*2);
            cell.imageView.frame = frameImg;
            
            CGFloat labHeight = 26.0;
            cell.textLabel.frame = CGRectMake(80, frame.size.height/2 - labHeight, frame.size.width - 80 - 10, labHeight);
            cell.detailTextLabel.frame = CGRectMake(80, frame.size.height/2, frame.size.width - 80 - 10, labHeight);
        }];
    } else if (indexPath.section == 1) {
        [cell update:^{
            CGRect frame = cell.contentView.frame;
            CGFloat offSetX = 10.0;
            CGFloat offSetY = 8.0;
            CGRect frameImg = CGRectMake(offSetX, offSetY, 60, frame.size.height - offSetY*2);
            cell.imageView.frame = frameImg;
            
            cell.textLabel.frame = CGRectMake(80, offSetY, frame.size.width - 80 - 10, frame.size.height - offSetY*2);
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    id con = nil;
    if (indexPath.section == 0) {
        con = [[UserDetailController alloc] initWithUser:user];
    } else if (indexPath.section == 1) {
        con = [[SettingController alloc] init];
    }
    [self pushViewController:con];
}

#pragma mark - ImageControl

- (NSInteger)baseTableView:(UITableView *)sender numberOfImagesAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (headImage == nil) {
            return 1;
        }
    }
    return 0;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    return user.headImgUrlS;
}

- (UIImage*)baseTableView:(UITableView *)sender imageDefaultAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    return nil;
}

- (void)baseTableView:(UITableView *)sender loadImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    if (image) {
        self.headImage = image;
        [listView reloadData];
    }
}

@end
