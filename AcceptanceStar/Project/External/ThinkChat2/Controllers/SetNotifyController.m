//
//  SetNotifyController.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-26.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "SetNotifyController.h"

@interface SetNotifyController () {
    IBOutlet UISwitch* swtNewMsg;
    IBOutlet UISwitch* swtVoice;
}

@end

@implementation SetNotifyController

- (id)init
{
    self = [super initWithNibName:@"SetNotifyController" bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    swtNewMsg = nil;
    swtVoice = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"通知";
    
    swtNewMsg.onTintColor = kColorBtnBkgBlue;
    swtVoice.onTintColor = kColorBtnBkgBlue;
    
    [swtNewMsg setOn:[Globals isNotify] animated:NO];
    [swtVoice setOn:[Globals isAudioNotify] animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchValueChanged:(id)sender {
    if (sender == swtNewMsg) {
        [self sendRequest];
    } else if (sender == swtVoice) {
        [Globals setIsAudioNotify:swtVoice.isOn];
    }
}

#pragma mark - Request

- (BOOL)sendRequest {
    if ([super sendRequest]) {
        if (swtNewMsg.isOn) {
            [client setupAPNSDevice];
        } else {
            [client cancelAPNSDevice];
        }
        return YES;
    }
    return NO;
}

- (BOOL)getResponse:(BaseClient *)sender obj:(NSObject *)obj {
    if ([super getResponse:sender obj:obj]) {
        [Globals setIsNotify:swtNewMsg.isOn];
        return YES;
    }
    [swtNewMsg setOn:!swtNewMsg.isOn animated:YES];
    return NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
    return 1;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    return 2;
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
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"接受新消息通知";
        cell.accessoryView = swtNewMsg;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"声音";
        cell.accessoryView = swtVoice;
    }
    
    return cell;
}

@end
