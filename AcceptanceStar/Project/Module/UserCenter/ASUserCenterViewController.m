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

@property (weak, nonatomic) IBOutlet UIView *unLoginContainerView;      //未登录容器
@property (weak, nonatomic) IBOutlet UIView *configView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (strong, nonatomic) NSMutableArray *userCenterItemArray;      //个人中心功能入口列表
@property (strong, nonatomic) NSString *isUserChangedObserverIdentifier;
@property (strong, nonatomic) JSBadgeView *badgeView;
@property (strong, nonatomic) UIView *badgeSuperView;


@property (strong, nonatomic) JSBadgeView *recivedBadge;
@property (strong, nonatomic) UIView *recivedBadgeSuperView;


@property (strong, nonatomic) JSBadgeView *myBadge;
@property (strong, nonatomic) UIView *myBadgeSuperView;
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

- (JSBadgeView *)recivedBadge{
    if (nil==_recivedBadge) {
        self.recivedBadgeSuperView = [UIView new];
        self.recivedBadgeSuperView.backgroundColor = [UIColor clearColor];
        self.recivedBadgeSuperView.hidden = YES;
        
        _recivedBadge = [[JSBadgeView alloc] initWithParentView:nil alignment:JSBadgeViewAlignmentCenter];
        [self.recivedBadgeSuperView addSubview:_recivedBadge];
    }
    return _badgeView;
}

- (JSBadgeView *)myBadge{
    if (nil==_myBadge) {
        self.myBadgeSuperView = [UIView new];
        self.myBadgeSuperView.backgroundColor = [UIColor clearColor];
        self.myBadgeSuperView.hidden = YES;
        
        _myBadge = [[JSBadgeView alloc] initWithParentView:nil alignment:JSBadgeViewAlignmentCenter];
        [self.myBadgeSuperView addSubview:_myBadge];
    }
    return _badgeView;
}

- (void)messageDidUpdate{
 
    return;
    AppDelegate *deleagte = (id)[[UIApplication sharedApplication] delegate];
    self.badgeView.badgeText = [NSString stringWithFormat:@"%zd",deleagte.messageCount];
    self.badgeSuperView.hidden = !deleagte.messageCount;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self requestMessageData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    WeakSelfType blockSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDidUpdate) name:@"AFGetNewMessageCount" object:nil];
    
    [self messageDidUpdate];
    
    [self.headerView resetFontSizeOfView];
    [self.headerView resetConstraintOfView];
    self.headerView.height = AUTOLAYOUT_LENGTH(206);
    [self.headerView bk_whenTapped:^{
        [blockSelf pushViewController:@"ASImproveInformationViewController" withParams:@{kParamTitle : @"个人资料",@"showEditItem":@YES}];
    }];


    //1. 设置tableview
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:AUTOLAYOUT_CGRECT(0, 0, 0, 20)];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    if([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [self.tableView registerNib:[YSCTableViewCell NibNameOfCell] forCellReuseIdentifier:kCellIdentifier];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //2. 设置列表数据源
    self.userCenterItemArray = [NSMutableArray array];
    [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_friendcircle" title:@"朋友圈" viewController:@"ASMomentsViewController"]];
    [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_balance" title:@"余额" viewController:@"ASBalanceViewController"]];
    if (0 == USER.itype) {//银行同行
        [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_verify" title:@"认证机构" viewController:@"ASPersonalVerifyViewController"]];
    }
    else {//企业认证 + 票据经理
        [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_verify" title:@"企业认证" viewController:@"ASCompanyVerifyViewController"]];
    }
    [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_changephone" title:@"更换手机号" viewController:@"ASChangePhoneViewController"]];
    [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_submission" title:@"我的发布" viewController:@""]];
    [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_collection" title:@"我的收藏" viewController:@""]];
    [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_mymonitor" title:@"我的预警票据" viewController:@"ASMyMonitorTicketsViewController"]];
    
    if (0 == USER.itype || 1 == USER.itype) {
        // 银行同业和票据经纪
        [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_bank_quotation" title:@"发布本行报价" viewController:@"ASBankPriceQuotationViewController"]];
        [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_discount_apply" title:@"收到的贴现申请" viewController:@"ASTieXianShenQingViewController"]];
        [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_bank_maintenance" title:@"授信银行维护" viewController:@"ASCreditBankListViewController"]];
    } else if (2 == USER.itype) {
        // 企业
        [self.userCenterItemArray addObject:[CommonItemModel buildNewItem:@"icon_usercenter_discount_apply" title:@"我的贴现申请" viewController:@"ASTieXianShenQingViewController"]];
    }
    
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
    
    [self requestMessageData];
}


- (void)requestMessageData{
    
    WeakSelfType blockSelf = self;
    [AFNManager getDataWithAPI:[@"/moments/getMsgCount2" stringByAppendingPathComponent:TOKEN]
                  andDictParam:nil
                     modelName:nil
              requestSuccessed:^(NSDictionary *responseObject) {
                  if ([responseObject isKindOfClass:[NSDictionary class]]) {
                      
                      NSInteger friendCount = [responseObject[@"friendCount"]  integerValue];
                      NSInteger receivedCount = [responseObject[@"receivedCount"]  integerValue];
                      NSInteger applyCount = [responseObject[@"applyCount"]  integerValue];
                      
                      blockSelf.badgeView.badgeText = [NSString stringWithFormat:@"%zd",friendCount];
                      blockSelf.badgeSuperView.hidden = friendCount<=0;

                      
                      blockSelf.myBadge.badgeText = [NSString stringWithFormat:@"%zd",applyCount];
                      blockSelf.myBadgeSuperView.hidden = applyCount<=0;
                      
                      blockSelf.recivedBadge.badgeText = [NSString stringWithFormat:@"%zd",receivedCount];
                      blockSelf.recivedBadgeSuperView.hidden = receivedCount<=0;
                  }
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                }];
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
        cell.arrowImageView.hidden = NO;
        [cell addSubview:self.badgeSuperView];
        
        [self.badgeSuperView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@24);
            make.right.equalTo(cell.mas_right).offset(-25);
            make.centerY.equalTo(cell);
        }];
    }
    else if ([item.title isContains:@"收到的贴现申请"]) {
        cell.arrowImageView.hidden = NO;
        [cell addSubview:self.recivedBadgeSuperView];
        
        [self.recivedBadgeSuperView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@24);
            make.right.equalTo(cell.mas_right).offset(-25);
            make.centerY.equalTo(cell);
        }];
    }
    else if ([item.title isContains:@"我的贴现申请"]) {
        cell.arrowImageView.hidden = NO;
        [cell addSubview:self.myBadgeSuperView];
        [self.myBadgeSuperView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@24);
            make.right.equalTo(cell.mas_right).offset(-25);
            make.centerY.equalTo(cell);
        }];
    }
    else {
        cell.arrowImageView.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 调整cell的分割线left margin
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
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
