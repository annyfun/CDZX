//
//  ASBalanceViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/29.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASBalanceViewController.h"

@interface ASBalanceViewController ()
@property (weak, nonatomic) IBOutlet UILabel *banlanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *rechargeButton;
@property (strong, nonatomic) NSString *isUserChangedObserverIdentifier;
@end

@implementation ASBalanceViewController

- (void)dealloc {
    if (self.isUserChangedObserverIdentifier) {
        [[Login sharedInstance] bk_removeObserversWithIdentifier:self.isUserChangedObserverIdentifier];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WEAKSELF
    [UIView makeRoundForView:self.rechargeButton withRadius:5];
    self.isUserChangedObserverIdentifier = [[Login sharedInstance] bk_addObserverForKeyPath:@"isUserChanged" task:^(id target) {
        blockSelf.banlanceLabel.text = [YSCCommonUtils formatPrice:USER.money];
    }];
    self.banlanceLabel.text = [YSCCommonUtils formatPrice:USER.money];
}

- (IBAction)rechargeButtonClicked:(id)sender {
    [self pushViewController:@"ASRechargeViewController"];
}

@end
