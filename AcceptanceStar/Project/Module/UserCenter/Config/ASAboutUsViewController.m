//
//  ASAboutUsViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/27.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASAboutUsViewController.h"

@interface ASAboutUsViewController ()
@property (nonatomic, weak) IBOutlet UILabel *versionLabel;
@property (nonatomic, weak) IBOutlet UILabel *websiteLabel;
@end

@implementation ASAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于";
    WEAKSELF
    self.versionLabel.text = [NSString stringWithFormat:@"承兑之星 V%@ (%@)", AppVersion, BundleVersion];
    self.websiteLabel.userInteractionEnabled = YES;
    [self.websiteLabel bk_whenTapped:^{
        [blockSelf pushViewController:@"ASWebViewViewController"
                           withParams:@{kParamTitle : @"承兑之星",
                                        kParamUrl : blockSelf.websiteLabel.text}];
    }];
}

@end
