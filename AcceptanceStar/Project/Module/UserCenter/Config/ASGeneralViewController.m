//
//  ASGeneralViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/27.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASGeneralViewController.h"

@interface ASGeneralViewController ()

@property (nonatomic, weak) IBOutlet UISwitch *notifySwitch;
@property (nonatomic, weak) IBOutlet UISwitch *voiceSwitch;

@end

@implementation ASGeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"通用";
    
    [self.notifySwitch setOn:[Globals isNotify] animated:NO];
    [self.voiceSwitch setOn:[Globals isAudioNotify] animated:NO];
}

- (IBAction)switchValueChanged:(id)sender {
    if (sender == self.notifySwitch) {
        [Globals setIsNotify:self.notifySwitch.isOn];
    } else if (sender == self.voiceSwitch) {
        [Globals setIsAudioNotify:self.voiceSwitch.isOn];
    }
}

@end
