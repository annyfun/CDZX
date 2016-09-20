//
//  ASPriceDetailViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/6/3.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASPriceDetailViewController.h"
#import "ASPriceDetailCell.h"
#import "ChatViewController.h"

@interface ASPriceDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIImageView *ticketImageView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) PriceType priceType;

@property (nonatomic, weak) IBOutlet UILabel *nickNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneNumberLabel;
@property (nonatomic, weak) IBOutlet UIView *makeCallView;
@property (nonatomic, weak) IBOutlet UIView *commentView;
@property (nonatomic, weak) IBOutlet UIView *collectView;
@property (nonatomic, weak) IBOutlet UIImageView *collectImageView;
@property (nonatomic, assign) BOOL isCollected;
@property (nonatomic, assign) BOOL isBuyed;

@end

@implementation ASPriceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    
    [self.tableView registerNib:[ASPriceDetailCell NibNameOfCell] forCellReuseIdentifier:kCellIdentifier];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.priceType = [self.params[kParamPriceType] integerValue];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}
- (void)setPriceType:(PriceType)priceType {
    WEAKSELF
    _priceType = priceType;
    NSInteger iuid = -1;
    NSInteger status = -1;
    NSString *ID = nil;
    NSString *type = nil;
    if (PriceTypeBuy == priceType) {
        BondBuyModel *bondBuy = self.params[kParamModel];
        iuid = bondBuy.iuid;
        status = bondBuy.istatus;
        ID = bondBuy.id;
        type = @"buy";
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_ticketcommon" title:@"票据属性" rightTitle1:bondBuy.attr]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_banktype" title:@"承兑行类型" rightTitle1:bondBuy.jsonClass]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_days" title:@"剩余天数"
                                                    rightTitle1:[NSString stringWithFormat:@"%ld天", bondBuy.days]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_amount" title:@"买入金额"
                                                    rightTitle1:[NSString stringWithFormat:@"%.2f万元", bondBuy.price.floatValue]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_rate2" title:@"报价利率"
                                                    rightTitle1:[NSString stringWithFormat:@"%@‰", bondBuy.rate]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_city" title:@"贴现地点" rightTitle1:bondBuy.city]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_remark" title:@"备注" rightTitle1:bondBuy.comment]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_sendtime" title:@"发布时间"
                                                    rightTitle1:[NSDate StringFromTimeStamp:bondBuy.date withFormat:DateFormat1]]];
        
        [self initBottomViewByPhone:bondBuy.phone nickName:bondBuy.uid uid:bondBuy.iuid isCollect:bondBuy.collect
         ticketId:bondBuy.id type:@"buy" userType:bondBuy.itype];
    }
    else if (PriceTypeSell == priceType) {//卖票信息
        BondSellModel *bondSell = self.params[kParamModel];
        iuid = bondSell.iuid;
        status = bondSell.istatus;
        ID = bondSell.id;
        type = @"sell";
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_ticketcommon" title:@"票据属性" rightTitle1:bondSell.attr]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_banktype" title:@"承兑行名称" rightTitle1:bondSell.class_name]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_banktype" title:@"承兑行类型" rightTitle1:bondSell.jsonClass]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_amount" title:@"票面金额"
                                                    rightTitle1:[NSString stringWithFormat:@"%@万元", bondSell.price]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_exp" title:@"到期日"
                                                    rightTitle1:[NSDate StringFromTimeStamp:bondSell.exp withFormat:DateFormat3]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_days" title:@"剩余天数" rightTitle1:[NSString stringWithFormat:@"%ld天", (long)bondSell.days]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_city" title:@"贴现地点" rightTitle1:bondSell.city]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_sendtime" title:@"发布时间"
                                                    rightTitle1:[NSDate StringFromTimeStamp:bondSell.date withFormat:DateFormat1]]];
        self.headerView.height = AUTOLAYOUT_LENGTH(240);
        self.headerView.backgroundColor = [UIColor clearColor];
        [self.headerView resetConstraintOfView];
        [self.ticketImageView setImageWithURLString:bondSell.img];
        self.tableView.tableHeaderView = self.headerView;
        
        [self initBottomViewByPhone:bondSell.phone nickName:bondSell.uid uid:bondSell.iuid isCollect:bondSell.collect
         ticketId:bondSell.id type:@"sell" userType:bondSell.itype];
        self.ticketImageView.userInteractionEnabled = YES;
        [self.headerView bk_whenTapped:^{
            [ShowPhotosManager showPhotosWithImageUrls:@[bondSell.img] atIndex:0 fromImageView:nil];
        }];
    }
    else if (PriceTypeQuotePrice == priceType) {
        QuotePriceModel *quotePrice = self.params[kParamModel];
        iuid = quotePrice.iuid;
        status = quotePrice.istatus;
        ID = quotePrice.id;
        type = @"company";
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_ticketcommon" title:@"票据属性" rightTitle1:quotePrice.attr]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_sender" title:@"发布人" rightTitle1:quotePrice.companyName]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_city" title:@"地址" rightTitle1:quotePrice.city]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_rate2" title:@"今日利率" rightTitle1:@"" rightTitle2:[NSString stringWithFormat:@"%@‰", quotePrice.rate]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_exp" title:@"期限" rightTitle1:[NSString stringWithFormat:@"%ld天起", quotePrice.days]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_rate2" title:@"国股" rightTitle1:@"月利率" rightTitle2:[NSString stringWithFormat:@"%@‰", quotePrice.gg_r]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_rate2" title:@"大商" rightTitle1:@"月利率" rightTitle2:[NSString stringWithFormat:@"%@‰", quotePrice.ds_r]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_rate2" title:@"小商" rightTitle1:@"月利率" rightTitle2:[NSString stringWithFormat:@"%@‰", quotePrice.xs_r]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_rate2" title:@"其他" rightTitle1:@"月利率" rightTitle2:[NSString stringWithFormat:@"%@‰", quotePrice.qt_r]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_remark" title:@"备注" rightTitle1:quotePrice.comment]];
        
        [self initBottomViewByPhone:quotePrice.phone nickName:quotePrice.uid uid:quotePrice.iuid isCollect:quotePrice.collect
         ticketId:quotePrice.id type:@"company" userType:quotePrice.itype];
    }
    else if (PriceTypeReSale == priceType) {
        BondReSaleModel *bondReSale = self.params[kParamModel];
        iuid = bondReSale.iuid;
        status = bondReSale.istatus;
        ID = bondReSale.id;
        type = @"resale";
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_ticketcommon" title:@"方向" rightTitle1:bondReSale.action]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_banktype" title:@"类型" rightTitle1:bondReSale.kind]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_rate2" title:@"年利率" rightTitle1:@""
                                                    rightTitle2:[NSString stringWithFormat:@"%@‰",bondReSale.rate]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_amount" title:@"金额"
                                                    rightTitle1:[NSString stringWithFormat:@"%@万元", bondReSale.price]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_days" title:@"剩余天数"
                                                    rightTitle1:[NSString stringWithFormat:@"%ld天", (long)bondReSale.days]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_sendtime" title:@"发布时间"
                                                    rightTitle1:[NSDate StringFromTimeStamp:bondReSale.date withFormat:DateFormat1]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_sender" title:@"发布人"
                                                    rightTitle1:bondReSale.companyName]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_ticketcommon" title:@"星星号" rightTitle1:bondReSale.uid]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_remark" title:@"备注" rightTitle1:bondReSale.comment]];
        
        [self initBottomViewByPhone:bondReSale.phone nickName:bondReSale.uid uid:bondReSale.iuid isCollect:bondReSale.collect
         ticketId:bondReSale.id type:@"resale" userType:bondReSale.itype];
    }
    else if (PriceTypeRePurchase == priceType) {
        BondRePurchaseModel *bondRePurchase = self.params[kParamModel];
        iuid = bondRePurchase.iuid;
        status = bondRePurchase.istatus;
        ID = bondRePurchase.id;
        type = @"repurchase";
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_ticketcommon" title:@"方向" rightTitle1:bondRePurchase.action]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_banktype" title:@"类型" rightTitle1:bondRePurchase.kind]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_rate2" title:@"年利率" rightTitle1:@""
                                                    rightTitle2:[NSString stringWithFormat:@"%@‰",bondRePurchase.rate]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_amount" title:@"金额"
                                                    rightTitle1:[NSString stringWithFormat:@"%@万元", bondRePurchase.price]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_days" title:@"剩余天数"
                                                    rightTitle1:[NSString stringWithFormat:@"%ld天", (long)bondRePurchase.days]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_sendtime" title:@"发布时间"
                                                    rightTitle1:[NSDate StringFromTimeStamp:bondRePurchase.date withFormat:DateFormat1]]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_sender" title:@"发布人" rightTitle1:bondRePurchase.companyName]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_ticketcommon" title:@"星星号" rightTitle1:bondRePurchase.uid]];
        [self.dataArray addObject:[CommonItemModel CreateByIcon:@"icon_remark" title:@"备注" rightTitle1:bondRePurchase.comment]];
        
        [self initBottomViewByPhone:bondRePurchase.phone nickName:bondRePurchase.uid uid:bondRePurchase.iuid isCollect:bondRePurchase.collect
         ticketId:bondRePurchase.id type:@"repurchase" userType:bondRePurchase.itype];
    }
    
    //交易完成
    if ([USERID integerValue] == iuid) {
        if (1 == status) {//1-未完成 2-已经完成
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"交易完成" style:UIBarButtonItemStylePlain handler:^(id sender) {
                [blockSelf showHUDLoading:@"正在操作"];
                [AFNManager getDataWithAPI:kResPathAppBondComplete
                               andDictParam:@{@"id" : Trim(ID), @"type" : Trim(type)}
                                  modelName:nil
                           requestSuccessed:^(id responseObject) {
                               [blockSelf showResultThenBack:@"交易完成"];
                               if (blockSelf.block) {
                                   blockSelf.block(nil);
                               }
                           } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                               [blockSelf hideHUDLoading];
                               [blockSelf showAlertVieWithMessage:errorMessage];
                           }];
            }];
        }
        else {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"已交易" style:UIBarButtonItemStylePlain handler:^(id sender) {
                
            }];
        }
    }
}
- (void)initBottomViewByPhone:(NSString *)phone
                     nickName:(NSString *)nickName
                          uid:(NSInteger)uid
                    isCollect:(BOOL)isCollect
                     ticketId:(NSString *)ticketId
                         type:(NSString *)type
                     userType:(NSString *)identity
{
    WEAKSELF
    self.phoneNumberLabel.hidden = !ISLOGGED;
    self.isCollected = isCollect;
    [self.collectView bk_whenTapped:^{
        if (NO == ISLOGGED) {
            [blockSelf pushViewController:@"ASLoginViewController"];
            return ;
        }
        [blockSelf collectByTicketId:ticketId type:type act:!blockSelf.isCollected];
    }];
    
    BOOL canView = YES;
    NSString *modelId = @"";
    if ([@"sell" isEqualToString:type]) {
        BondSellModel *bondSell = self.params[kParamModel];
//        if (bondSell.istatus == 2) {
//            canView = YES;
//        }
//        else {
//            canView = bondSell.canview;
//        }
        canView = bondSell.canview;

        
        modelId = Trim(bondSell.id);
    }
    
    NSString *tempNickName = [NSString stringWithFormat:@"%@ %@", Trim(nickName), Trim(identity)];
    if (canView) {//已购买
        self.nickNameLabel.text = tempNickName;
        self.phoneNumberLabel.text = Trim(phone);
        [self.makeCallView bk_whenTapped:^{
            [YSCCommonUtils MakeCall:phone];
        }];
        [self.commentView bk_whenTapped:^{
            if (NO == ISLOGGED) {
                [blockSelf pushViewController:@"ASLoginViewController"];
                return ;
            }
            NSString *tempUid = [NSString stringWithFormat:@"%ld", (long)uid];
            if (isNotEmpty(tempUid)) {
                [blockSelf chatWithUserId:tempUid];
            }
            else {
                [blockSelf showResultThenHide:@"用户不存在"];
            }
        }];
    }
    else {
        self.nickNameLabel.text = Trim(identity);
        self.phoneNumberLabel.text = [NSString stringWithFormat:@"%@********",
                                      phone.length >= 3 ? [phone substringToIndex:2] : @""];
        [self.makeCallView bk_whenTapped:^{
            if (blockSelf.isBuyed) {
                [YSCCommonUtils MakeCall:phone];
            }
            else {
                [blockSelf showAlertWarningBy:nil phone:Trim(phone) modelId:modelId nickName:tempNickName];
            }
        }];
        [self.commentView bk_whenTapped:^{
            if (NO == ISLOGGED) {
                [blockSelf pushViewController:@"ASLoginViewController"];
                return ;
            }
            NSString *tempUid = [NSString stringWithFormat:@"%ld", (long)uid];
            if (blockSelf.isBuyed) {
                [blockSelf chatWithUserId:tempUid];
            }
            else {
                [blockSelf showAlertWarningBy:Trim(tempUid) phone:nil modelId:modelId nickName:tempNickName];
            }
        }];
    }
}
- (void)showAlertWarningBy:(NSString *)uid phone:(NSString *)phone modelId:(NSString *)modelId nickName:(NSString *)nickName {
    WEAKSELF1
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"需要扣除1元服务费用，确定要联系么？"];
    [alertView bk_addButtonWithTitle:@"确定" handler:^{
        [weakSelf showHUDLoading:@""];
        [AFNManager postDataWithAPI:kResPathAppBondViewSellInfo
                       andDictParam:@{@"id" : Trim(modelId)}
                          modelName:nil
                   requestSuccessed:^(id responseObject) {
                       [weakSelf hideHUDLoading];
                       BondSellModel *bondSell = weakSelf.params[kParamModel];
                       bondSell.canview = YES;
                       weakSelf.nickNameLabel.text = nickName;
                       weakSelf.phoneNumberLabel.text = phone;
                       NSString *money = [NSString stringWithFormat:@"%@", responseObject];
                       USER.money = @([money integerValue]);
                       LOGIN.isUserChanged = YES;
                       weakSelf.isBuyed = YES;
                       
                       if (nil != phone) {
                           [YSCCommonUtils MakeCall:phone];
                       }
                       else {
                           [weakSelf chatWithUserId:uid];
                       }
                   }
                     requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                         [weakSelf hideHUDLoading];
                         [UIView showAlertVieWithMessage:errorMessage];
                     }];
    }];
    [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [alertView show];
}
- (void)chatWithUserId:(NSString *)uid {
    WEAKSELF1
    [self showHUDLoading:@""];
    [AFNManager getDataWithAPI:kResPathAppUserDetail
                  andDictParam:@{@"fuid" : Trim(uid)}
                     modelName:ClassOfObject(UserModel)
              requestSuccessed:^(id responseObject) {
                  [weakSelf hideHUDLoading];
                  if (responseObject) {
                      UserModel *userModel = (UserModel *)responseObject;
                      User *user = [userModel createUser];
                      ChatViewController *chatVC = [[ChatViewController alloc] initWithUser:user];
                      [weakSelf.navigationController pushViewController:chatVC animated:YES];
                  }
                  else {
                      [weakSelf showResultThenHide:@"用户不存在"];
                  }
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    [weakSelf hideHUDLoading];
                    [weakSelf showAlertVieWithMessage:errorMessage];
                }];
}
- (void)collectByTicketId:(NSString *)ticketId type:(NSString *)type act:(BOOL)action {
    WEAKSELF
    if (action) {
        [self showHUDLoading:@"正在添加收藏"];
    }
    else {
        [self showHUDLoading:@"正在删除收藏"];
    }
    [AFNManager getDataWithAPI:kResPathAppCollectIndex
                   andDictParam:@{@"type" : type, @"id" : ticketId, @"action" : @(action)}
                      modelName:nil
               requestSuccessed:^(id responseObject) {
                   blockSelf.isCollected = action;
                   if (action) {
                       [blockSelf showResultThenHide:@"添加收藏成功"];
                   }
                   else {
                       [blockSelf showResultThenHide:@"删除收藏成功"];
                   }
                   
                   //刷新列表
                   if (PriceTypeBuy == blockSelf.priceType) {
                       postN(kNotificationRefreshBuyList);
                   }
                   else if (PriceTypeSell == blockSelf.priceType) {
                       postN(kNotificationRefreshSellList);
                   }
                   else if (PriceTypeQuotePrice == blockSelf.priceType) {
                       postN(kNotificationRefreshQuotePriceList);
                   }
                   else if (PriceTypeReSale == blockSelf.priceType) {
                       postN(kNotificationRefreshReSaleList);
                   }
                   else if (PriceTypeRePurchase == blockSelf.priceType) {
                       postN(kNotificationRefreshRePurchaseList);
                   }
               }
                 requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     NSLog(@"err=%@", errorMessage);
                     if (action) {
                         [blockSelf showResultThenHide:@"添加收藏失败"];
                     }
                     else {
                         [blockSelf showResultThenHide:@"删除收藏失败"];
                     }
                 }];
}
- (void)setIsCollected:(BOOL)isCollected {
    _isCollected = isCollected;
    if (isCollected) {
        self.collectImageView.image = [UIImage imageNamed:@"icon_collection"];
    }
    else {
        self.collectImageView.image = [UIImage imageNamed:@"icon_uncollection"];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ASPriceDetailCell HeightOfCellByObject:self.dataArray[indexPath.row]];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASPriceDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    [cell layoutObject:self.dataArray[indexPath.row]];
    return cell;
}

@end
