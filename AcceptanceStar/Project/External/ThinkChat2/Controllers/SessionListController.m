//
//  SessionListController.m
//  ThinkChat
//
//  Created by keen on 14-8-6.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "SessionListController.h"
#import "SessionNewController.h"
#import "ChatViewController.h"
#import "NotifyListController.h"
#import "SessionCell.h"
#import "TCSession.h"
#import "TCMessage.h"
#import "AppDelegate.h"

@interface SessionListController () {
    NSString*   identifierSession1;
    NSString*   identifierSession2;
    NSString*   identifierSession3;
    NSString*   identifierSession4;
}

@end

@implementation SessionListController

- (id)init
{
    self = [super initWithNibName:@"SessionListController" bundle:nil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessage:) name:kNotifyReceivedMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasReadSession:) name:kNotifyHasReadSession object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearSession:) name:kNotifyClearSession object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editGroup:) name:kNotifyEditGroup object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotify:) name:kNotifyReceiveNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasReadNotify:) name:kNotifyHasReadNotify object:nil];
    
    identifierSession1 = @"SessionCell1";
    identifierSession2 = @"SessionCell2";
    identifierSession3 = @"SessionCell3";
    identifierSession4 = @"SessionCell4";
    //        [contentArr addObjectsFromArray:[TCSession getSessionListTimeLine]];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshSessionList];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"会话";
    [self initialize];
    
    [self registerNibForCellReuseIdentifier:identifierSession1];
    [self registerNibForCellReuseIdentifier:identifierSession2];
    [self registerNibForCellReuseIdentifier:identifierSession3];
    [self registerNibForCellReuseIdentifier:identifierSession4];
    
//    [self addBarButtonItemRightNormalImageName:@"nav_session_n" hightLited:@"nav_session_d"];
//    [self addBarButtonItemLeftNormalImageName:@"nav_more_n" hightLited:@"nav_more_d"];
}

- (void)barButtonItemRightPressed:(id)sender {
    id con = [[SessionNewController alloc] init];
    [self pushViewController:con];
}

- (void)barButtonItemLeftPressed:(id)sender {
    id con = [[NotifyListController alloc] init];
    [self pushViewController:con];
}
- (void)refreshSessionList {
    [contentArr removeAllObjects];
    [contentArr addObjectsFromArray:[TCSession getSessionListTimeLine]];
    
    TCNotify* itemN = [TCNotify getLatestNotify];
    if (itemN) {
        TCSession* itemS = [[TCSession alloc] init];
        itemS.name = @"系统通知";
        itemS.content = itemN.content;
        itemS.typeChat = -1;
        itemS.time = itemN.time;
        itemS.unreadCount = [TCNotify getUnReadCount];
        
        int i = 0;
        for (; i < contentArr.count; i++) {
            TCSession* tmpS = [contentArr objectAtIndex:i];
            if (tmpS.time < itemS.time) {
                break;
            }
        }
        [contentArr insertObject:itemS atIndex:i];
    }
    
    NSString* strBadgeValue = nil;
    NSInteger totalUnread = 0;
    for (TCSession *session in contentArr) {
        totalUnread += session.unreadCount;
    }
    if (totalUnread > 99) {
        strBadgeValue = @"99+";
    } else if (totalUnread > 0) {
        strBadgeValue = [NSString stringWithFormat:@"%ld", (long)totalUnread];
    }
    self.navigationController.tabBarItem.badgeValue = strBadgeValue;
    [listView reloadData];
}

- (void)receivedMessage:(NSNotification*)sender {
    [self refreshSessionList];
    
//    TCMessage * msg = sender.object;
//    int i = 0;
//    for (; i < contentArr.count; i++) {
//        TCSession* itemS = [contentArr objectAtIndex:i];
//        if (itemS.typeChat == msg.typeChat && [itemS.ID isEqualToString:msg.withID]) {
//            [itemS updateWithMessage:msg];
//            if (i > 0) {
//                [contentArr removeObjectAtIndex:i];
//                [contentArr insertObject:itemS atIndex:0];
//            }
//            [listView reloadData];
//            break;
//        }
//    }
//    if (i == contentArr.count) {
//        TCSession* itemS = [TCSession sessionWithMessage:msg];
//        [contentArr insertObject:itemS atIndex:0];
//        [listView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
}

// 已读消息

- (void)hasReadSession:(NSNotification*)sender {
    TCSession* itemS = sender.object;
    for (TCSession* tmpS in contentArr) {
        if (tmpS.typeChat == itemS.typeChat && [tmpS.ID isEqualToString:itemS.ID]) {
            tmpS.unreadCount = 0;
            [listView reloadData];
            break;
        }
    }
}

- (void)clearSession:(NSNotification*)sender {
    TCSession* itemS = sender.object;
    for (TCSession* tmpS in contentArr) {
        if (tmpS.typeChat == itemS.typeChat && [tmpS.ID isEqualToString:itemS.ID]) {
            [contentArr removeObject:tmpS];
            [listView reloadData];
            break;
        }
    }
}

- (void)editGroup:(NSNotification*)sender {
    [self refreshSessionList];
}

- (void)hasReadNotify:(NSNotification*)sender {
    [self refreshSessionList];
}

#pragma mark - TCNotify

- (void)receivedNotify:(NSNotification*)sender {
    [self refreshSessionList];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    return contentArr.count;
}

- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SessionCell heightWithItem:nil];
}

- (SessionCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* identifierSession = nil;
    
    TCSession * itemS = [contentArr objectAtIndex:indexPath.row];
    if (itemS.typeChat == forChatTypeUser) {
        identifierSession = identifierSession1;
    } else if (itemS.typeChat == forChatTypeGroup) {
        identifierSession = identifierSession1;
    } else if (itemS.typeChat == forChatTypeRoom) {
        NSArray* tmpHeadArr = [itemS.head componentsSeparatedByString:@","];
        if (tmpHeadArr.count > 3) {
            identifierSession = identifierSession4;
        } else if (tmpHeadArr.count > 2) {
            identifierSession = identifierSession3;
        } else if (tmpHeadArr.count > 1) {
            identifierSession = identifierSession2;
        } else {
            identifierSession = identifierSession1;
        }
    } else {
        identifierSession = identifierSession1;
    }
    
    SessionCell * cell = [sender dequeueReusableCellWithIdentifier:identifierSession];
    
    cell.session = itemS;
    
    return cell;
}

-(NSString*)tableView:(UITableView *)sender titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

//设置滑动，
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSession * item = [contentArr objectAtIndex:indexPath.row];
    if (item.typeChat == forChatTypeUser ||
        item.typeChat == forChatTypeGroup ||
        item.typeChat == forChatTypeRoom) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    id con = nil;
    TCSession * item = [contentArr objectAtIndex:indexPath.row];
    if (item.typeChat == forChatTypeUser ||
        item.typeChat == forChatTypeGroup ||
        item.typeChat == forChatTypeRoom) {
        con = [[ChatViewController alloc] initWithSession:item];
    } else {
        con = [[NotifyListController alloc] init];
    }
    [self pushViewController:con];
}

- (void)tableView:(UITableView *)sender commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TCSession * item = [contentArr objectAtIndex:indexPath.row];
        [[AppDelegate instance] clearSessionID:item.ID typeChat:item.typeChat];
    }
}

#pragma mark - ImageControl

- (NSInteger)baseTableView:(UITableView *)sender numberOfImagesAtIndexPath:(NSIndexPath *)indexPath {
    TCSession* itemS = [contentArr objectAtIndex:indexPath.row];
    if (itemS.typeChat == forChatTypeUser) {
        return 1;
    } else if (itemS.typeChat == forChatTypeGroup) {
        return 1;
    } else if (itemS.typeChat == forChatTypeRoom) {
        NSArray* tmpHeadArr = [itemS.head componentsSeparatedByString:@","];
        return tmpHeadArr.count;
    } else {
        return 1;
    }
    return 0;
}

- (UIImage*)baseTableView:(UITableView *)sender imageDefaultAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    TCSession* itemS = [contentArr objectAtIndex:indexPath.row];
    if (itemS.typeChat == forChatTypeUser) {
        return kImageDefaultHeadUser;
    } else if (itemS.typeChat == forChatTypeGroup) {
        return kImageDefaultHeadGroup;
    } else if (itemS.typeChat == forChatTypeRoom) {
        return kImageDefaultHeadUser;
    } else {
        return [UIImage imageNamed:@"cell_system"];
    }
    return nil;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    TCSession* itemS = [contentArr objectAtIndex:indexPath.row];
    if (itemS.typeChat == forChatTypeUser) {
        return itemS.head;
    } else if (itemS.typeChat == forChatTypeGroup) {
        return itemS.head;
    } else if (itemS.typeChat == forChatTypeRoom) {
        NSArray* tmpHeadArr = [itemS.head componentsSeparatedByString:@","];
        return [tmpHeadArr objectAtIndex:index];
    } else {
        return nil;
    }
    return itemS.head;
}

- (void)baseTableView:(UITableView *)sender loadImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    SessionCell* cell = (SessionCell*)[listView cellForRowAtIndexPath:indexPath];
    [cell setImageHead:image tag:index];
}

@end