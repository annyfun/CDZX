//
//  ASMyAlbumViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/29.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASMyAlbumViewController.h"
#import "ASMyAlbumCell.h"

@interface ASMyAlbumViewController ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *headerBgImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView  *avatarImageView;

@end

@implementation ASMyAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"朋友圈";
    
    [self.headerView resetFontSizeOfView];
    [self.headerView resetConstraintOfView];
    self.headerView.height = AUTOLAYOUT_LENGTH(340);
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    
}

#pragma mark - 重写基类方法

- (NSString *)methodWithPath {
    return kResPathAppMomentsIndex;
}
- (NSDictionary *)dictParamWithPage:(NSInteger)page {
    return @{kParamPage : @(page),
             kParamPageSize : @(kDefaultPageSize)};
}
- (Class)modelClassOfData {
    return ClassOfObject(MomentsIndexModel);
}
- (NSString *)nibNameOfCell {
    return @"ASMyAlbumCell";
}

@end
