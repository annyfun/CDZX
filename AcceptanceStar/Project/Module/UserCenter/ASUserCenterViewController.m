//
//  ASUserCenterViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/27.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASUserCenterViewController.h"
#import "YSCTableViewCell.h"
#import "JSBadgeView.h"
#import "AppDelegate.h"

@interface ASUserCenterViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *starNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobilePhoneLabel;

@property (weak, nonatomic) IBOutlet UIView *unLoginContainerView;      //未登录容器
@property (weak, nonatomic) IBOutlet UIView *configView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (strong, nonatomic) NSMutableArray *userCenterItemArray;      //个人中心功能入口列表
@property (strong, nonatomic) NSString *isUserChangedObserverIdentifier;
@property (strong, nonatomic) JSBadgeView *badgeView;
@property (strong, nonatomic) UIView *badgeSuperView;
@end

@implementation ASUserCenterViewController

- (void)dealloc {
    if (self.isUserChangedObserverIdentifier) {
        [[Login sharedInstance] bk_removeObserversWithIdentifier:self.isUserChangedObserverIdentifier];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (JSBadgeView *)badgeView{
    if (nil==_badgeView) {
        self.badgeSuperView = [UIView new];
        self.badgeSuperView.backgroundColor = [UIColor clearColor];
        self.badgeSuperView.hidden = YES;
        
        _badgeView = [[JSBadgeView alloc] initWithParentView:nil alignment:JSBadgeViewAlignmentCenter];
        [self.badgeSuperView addSubview:_badgeView];
    }
    return _badgeView;
}

- (void)messageDidUpdate{
 
    AppDelegate *deleagte = (id)[[UIApplication sharedApplication] delegate];
    self.badgeView.badgeText = [NSString stringWithFormat:@"%zd",deleagte.messageCount];
    self.badgeSuperView.hidden = !deleagte.messageCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    WeakSelfType blockSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDidUpdate) name:@"AFGetNewMessageCount" object:nil];
    
    [self messageDidUpdate];
    
    [self.headerView resetFontSizeOfView];
    [self.headerView resetConstraintOfView];
    //设置用户头像圆角，边框白色
    [UIView makeRoundForView:self.avatarImageView withRadius:AUTOLAYOUT_LENGTH(90) / 2];
    [UIView makeBorderForView:self.avatarImageView withColor:[UIColor whiteColor] borderWidth:2];
    self.headerView.height = AUTOLAYOUT_LENGTH(135);
    [self.headerView bk_whenTapped:^{
        [blockSelf pushViewController:@"ASImproveInformationViewController" withParams:@{kParamTitle : @"个人资料",@"showEditItem":@YES}];
    }];


    //1. 设置tableview
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:AUTOLAYOUT_CGRECT(0, 0, 0, 20)];
    self.tableView.separatorInset = AUTOLAYOUT_EDGEINSETS(0, 86, 0, 0);
    [self.tableView registerNib:[YSCTableViewCell NibNameOfCell] forCellReuseIdentifier:kCellIdentifier];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //2. 设置列表数据源
    self.userCenterItemArray = [NSMutableArray array];
    [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_friendcircle" title:@"朋友圈" viewController:@"ASMomentsViewController"]];
    [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_balance" title:@"余额" viewController:@"ASBalanceViewController"]];
    if (0 == USER.itype) {//银行同行
        [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_verify" title:@"个人认证" viewController:@"ASPersonalVerifyViewController"]];
    }
    else {//企业认证 + 票据经理
        [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_verify" title:@"企业认证" viewController:@"ASCompanyVerifyViewController"]];
    }
    [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_changephone" title:@"更换手机号" viewController:@"ASChangePhoneViewController"]];
    [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_submission" title:@"我的发布" viewController:@""]];
    [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_collection" title:@"我的收藏" viewController:@""]];
    [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_mymonitor" title:@"我的预警票据" viewController:@"ASMyMonitorTicketsViewController"]];
    [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_config" title:@"设置" viewController:@"ASConfigViewController"]];
    
    //3. 监控是否登录
    self.isUserChangedObserverIdentifier = [[Login sharedInstance] bk_addObserverForKeyPath:@"isUserChanged" task:^(id target) {
        [blockSelf layoutHeaderView];
        [blockSelf.tableView reloadData];
    }];
    [self layoutHeaderView];
    
    //4. 注册通知
    addNObserver(@selector(refreshUserCenter), kNotificationRefreshUserCenter);
    
    //5. 设置未登录界面
    [self.unLoginContainerView resetFontSizeOfView];
    [self.unLoginContainerView resetConstraintOfView];
    [self.view addSubview:self.unLoginContainerView];
    self.unLoginContainerView.width = SCREEN_WIDTH;
    self.unLoginContainerView.height = SCREEN_HEIGHT - 64 - 49;
    [self.configView bk_whenTapped:^{
        [blockSelf presentViewController:@"ASConfigViewController"];
    }];
    [UIView makeRoundForView:self.loginButton withRadius:5];
    [UIView makeRoundForView:self.registerButton withRadius:5];
}

/**
 *  刷新并显示tableHeaderView内容
 */
- (void)layoutHeaderView {
    if (ISLOGGED) {
        self.tableView.hidden = NO;
        self.unLoginContainerView.hidden = YES;
        [self.avatarImageView setImageWithURLString:USER.headlarge placeholderImage:DefaultAvatarImage];
        self.nickNameLabel.text = Trim(USER.nickname);
        self.starNumLabel.text = Trim(USER.userId);
        self.userTypeLabel.text = Trim(USER.type);
        self.mobilePhoneLabel.text = [NSString stringWithFormat:@"手机号：%@", Trim(USER.phone)];
    }
    else {
        self.tableView.hidden = YES;
        self.unLoginContainerView.hidden = NO;
    }
}

#pragma mark - 按钮事件
- (IBAction)loginButtonClicked:(id)sender {
    [self presentViewController:@"ASLoginViewController"];
}
- (IBAction)registerButtonCliked:(id)sender {
    [self presentViewController:@"ASRegisterViewController"];
}

#pragma mark - 网络访问

- (void)refreshUserCenter {
    [[Login sharedInstance] refreshUserInfo];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.userCenterItemArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AUTOLAYOUT_LENGTH(100);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YSCTableViewCell *cell = (YSCTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    CommonItemModel *item = self.userCenterItemArray[indexPath.row];
    cell.style = YSCTableViewCellStyleIcon | YSCTableViewCellStyleArrow;
    cell.subtitleLeftTitleLabel.text = item.title;
    cell.iconImageView.image = [UIImage imageNamed:item.icon];
    
    //控制cell特殊内容的显示
    if ([item.title isEqualToString:@"余额"]) {
        cell.style = YSCTableViewCellStyleIcon | YSCTableViewCellStyleArrow | YSCTableViewCellStyleSubtitleRight;
        cell.subtitleBottomTitleLabel.text = item.title;
        cell.subtitleRightLabel.text = [YSCCommonUtils formatPrice:USER.money];
    }
    if ([item.title isContains:@"朋友圈"]) {
        [cell addSubview:self.badgeSuperView];
        
        [self.badgeSuperView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@24);
            make.right.equalTo(cell.mas_right).offset(-25);
            make.centerY.equalTo(cell);
        }];
    }
    return cell;
}

//HEADER
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return AUTOLAYOUT_LENGTH(20); //注意：在Group Style下，必须要设置Header不为0的数字！设置为0会有默认40个像素高度的view
}
// FOOTER
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CommonItemModel *item = self.userCenterItemArray[indexPath.row];
    if ([NSString isNotEmpty:item.viewController]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[kParamTitle] = item.title;
        if ([item.title isContains:@"朋友圈"]) {
            params[kParamUserId] = USERID;
            params[kParamNickName] = USER.nickname;
            params[@"facepic"] = Trim(USER.facepic);
            params[@"headsmall"] = Trim(USER.headsmall);
            
            //重置badge
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ASMomentsViewControllerIn" object:nil];
        }
        if ([item.title isContains:@"设置"]) {
            [self presentViewController:item.viewController withParams:params];
        }
        else {
            [self pushViewController:item.viewController withParams:params];
        }
    }
    else {
        if ([item.title isContains:@"发布"]) {
            [self pushViewController:@"ASMySubmissionAndCollectionViewController"
                             withParams:@{kParamTitle : item.title,
                                          kParamIndex : @(0)}];
        }
        else if ([item.title isContains:@"收藏"]) {
            [self pushViewController:@"ASMySubmissionAndCollectionViewController"
                             withParams:@{kParamTitle : item.title,
                                          kParamIndex : @(1)}];
        }
    }
}


@end
