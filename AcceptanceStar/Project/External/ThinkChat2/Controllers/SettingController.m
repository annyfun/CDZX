//
//  SettingController.m
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "SettingController.h"
#import "PassWordController.h"
#import "SetNotifyController.h"
#import "SingleTextViewController.h"
#import "AboutUsController.h"
#import "AppDelegate.h"

@interface SettingController () {
    IBOutlet UIView*    footerView;
    IBOutlet UIButton*  btnLogOut;
}

@end

@implementation SettingController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"设置";
    
    footerView.backgroundColor = kColorClear;
    
    [btnLogOut setTitleColor:kColorWhite forState:UIControlStateNormal];
    [btnLogOut setTitleColor:kColorWhite forState:UIControlStateHighlighted];
    btnLogOut.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [btnLogOut setBackgroundImage:[UIImage imageWithColor:kColorBtnBkgRed] forState:UIControlStateNormal];
    btnLogOut.layer.cornerRadius = kCornerRadiusButton;
    btnLogOut.clipsToBounds = YES;

    listView.tableFooterView = footerView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnPressed:(id)sender {
    if (sender == btnLogOut) {
        [[AppDelegate instance] signOut];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
    return 4;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    return 8;
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
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    
    if (indexPath.section == 0) {
        cell.imageView.image = [UIImage imageNamed:@"cell_password"];
        cell.textLabel.text = @"修改密码";
    } else if (indexPath.section == 1) {
        cell.imageView.image = [UIImage imageNamed:@"cell_notify"];
        cell.textLabel.text = @"通知";
    } else if (indexPath.section == 2) {
        cell.imageView.image = [UIImage imageNamed:@"cell_feedback"];
        cell.textLabel.text = @"意见反馈";
    } else if (indexPath.section == 3) {
        cell.imageView.image = [UIImage imageNamed:@"cell_aboutus"];
        cell.textLabel.text = @"关于我们";
    }
    
    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(BaseTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    [cell update:^{
        CGRect frame = cell.contentView.frame;
        CGFloat offSetX = 10.0;
        CGFloat offSetY = 10.0;
        CGRect frameImg = CGRectMake(offSetX, offSetY, 40, frame.size.height - offSetY*2);
        cell.imageView.frame = frameImg;
        
        cell.textLabel.frame = CGRectMake(60, offSetY, frame.size.width - 60 - 10, frame.size.height - offSetY*2);
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    id con = nil;
    if (indexPath.section == 0) {
        // 修改密码
        con = [[PassWordController alloc] init];
    } else if (indexPath.section == 1) {
        // 通知
        con = [[SetNotifyController alloc] init];
    } else if (indexPath.section == 2) {
        // 意见反馈
        con = [[SingleTextViewController alloc] initWithType:forSingleTextViewFeedBack];
    } else if (indexPath.section == 3) {
        // 关于我们
        con = [[AboutUsController alloc] init];
    }

    [self pushViewController:con];
}

@end
