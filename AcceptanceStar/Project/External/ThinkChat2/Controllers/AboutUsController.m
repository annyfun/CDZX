//
//  AboutUsController.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-18.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "AboutUsController.h"

@interface AboutUsController () {
    IBOutlet UILabel*   labVersion;
    IBOutlet UIButton*  btnWebSite;
}

@end

@implementation AboutUsController

- (id)init
{
    self = [super initWithNibName:@"AboutUsController" bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    // data
    
    // view
    labVersion = nil;
    btnWebSite = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"关于我们";
    
    NSString * strVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];

    labVersion.text = [NSString stringWithFormat:@"Think Chat V %@",strVersion];
    [btnWebSite setTitleColor:kColorTitleBlue forState:UIControlStateNormal];
    [btnWebSite setTitleColor:kColorTitleGray forState:UIControlStateHighlighted];
}

- (void)btnPressed:(UIButton*)sender {
    if (sender == btnWebSite) {
        NSString* strUrl = sender.titleLabel.text;
        if (![strUrl hasPrefix:@"http:"]) {
            strUrl = [NSString stringWithFormat:@"http://%@",strUrl];
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];
    }
}

@end
