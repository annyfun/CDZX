//
//  ASNewsDailyViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/30.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASNewsDailyViewController.h"
#import "ASNewsDailyTableViewCell.h"

@interface ASNewsDailyViewController ()

@end

@implementation ASNewsDailyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"票友日报";
}

#pragma mark - 重写基类方法
- (NSString *)methodWithPath {
    return kResPathAppPageIndex;
}
- (NSDictionary *)dictParamWithPage:(NSInteger)page {
    return @{kParamPage : @(page), kParamPageSize : @(kDefaultPageSize)};
}
- (Class)modelClassOfData {
    return ClassOfObject(PageIndexModel);
}
- (NSString *)nibNameOfCell {
    return @"ASNewsDailyTableViewCell";
}
- (void)clickedCell:(id)object atIndexPath:(NSIndexPath *)indexPath {
    PageIndexModel *model = (PageIndexModel *)object;
    [[NSUserDefaults standardUserDefaults] setBool:@(YES) forKey:[NSString stringWithFormat:@"newsId_%@", model.id]];
    [self pushViewController:@"ASDailyDetailViewController"
                  withParams:@{kParamTitle : Trim(model.title),
                               kParamModel : object}];
    ASNewsDailyTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.iconNewImageView.hidden = YES;
}

@end
