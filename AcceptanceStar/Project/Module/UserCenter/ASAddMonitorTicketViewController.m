//
//  ASAddMonitorTicketViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/10/15.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "ASAddMonitorTicketViewController.h"

@interface ASAddMonitorTicketViewController () <UMSocialUIDelegate>
@property (strong, nonatomic) IBOutletCollection(YSCTextField) NSArray *ticketNumberTextFieldArray;
@property (weak, nonatomic) IBOutlet UIView *ticketNumberContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *addMoreButton;
@property (assign, nonatomic) NSInteger ticketCount;

@property (nonatomic, weak) IBOutlet UIView *shareView;
@property (nonatomic, weak) IBOutlet UIImageView *shareImageView;
@property (nonatomic, weak) IBOutlet UIView *payView;
@property (nonatomic, weak) IBOutlet UIImageView *payImageView;
@property (nonatomic, weak) IBOutlet UILabel *payCountLabel;
@property (nonatomic, assign) BOOL isShare;

@property (weak, nonatomic) IBOutlet UIButton *confirmAddButton;
@end

@implementation ASAddMonitorTicketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"添加预警票据";
    self.ticketNumberContainerView.backgroundColor = [UIColor clearColor];
    self.ticketNumberContainerView.clipsToBounds = YES;
    self.ticketCount = 1;
    self.isShare = YES;
    [self.addMoreButton makeRoundWithRadius:5];
    [self.confirmAddButton makeRoundWithRadius:5];
    
    WEAKSELF
    [self.shareView bk_whenTapped:^{
        blockSelf.isShare = YES;
    }];
    [self.payView bk_whenTapped:^{
        blockSelf.isShare = NO;
    }];
}
- (IBAction)addMoreButtonClicked:(id)sender {
    [self hideKeyboard];
    if (self.ticketCount >= 5) {
        [self showAlertVieWithMessage:@"一次性最多只能添加5个票号"];
        return;
    }
    self.ticketCount += 1;
}
- (IBAction)confirmAddButtonClicked:(id)sender {
    [self hideKeyboard];
    if (isEmpty([self ticketsToBeAdded])) {
        [self showResultThenHide:@"票号不能为空"];
        return;
    }
    if (self.isShare) {
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:kUMAppKey
                                          shareText:@"下载“承兑之星”APP，瞬间认识30万票据中介，买票、卖票、回购、转贴、票据挂失预警等等，应有尽有。http://www.yhcd.net"
                                         shareImage:[UIImage imageNamed:@"icon_logo"]
                                    shareToSnsNames:@[UMShareToWechatTimeline, UMShareToQzone]
                                           delegate:self];
    }
    else {
        [self addTicketsToMonitor];
    }
}
- (NSString *)ticketsToBeAdded {
    NSMutableString *tickets = [NSMutableString string];
    for (UITextField *textField in self.ticketNumberTextFieldArray) {
        if (isNotEmpty(textField.text)) {
            if (isEmpty(tickets)) {
                [tickets appendString:Trim(textField.text)];
            }
            else {
                [tickets appendFormat:@",%@", Trim(textField.text)];
            }
        }
    }
    return tickets;
}
- (void)setTicketCount:(NSInteger)ticketCount {
    _ticketCount = ticketCount;
    self.containerViewHeight.constant = AUTOLAYOUT_LENGTH(ticketCount * 100 - 20);
    self.payCountLabel.text = [NSString stringWithFormat:@"余额付费%ld元添加", (long)ticketCount];
}
- (void)setIsShare:(BOOL)isShare {
    _isShare = isShare;
    if (isShare) {
        self.shareImageView.image = [UIImage imageNamed:@"radio_selected"];
        self.payImageView.image = [UIImage imageNamed:@"radio_unselected"];
    }
    else {
        self.shareImageView.image = [UIImage imageNamed:@"radio_unselected"];
        self.payImageView.image = [UIImage imageNamed:@"radio_selected"];
    }
}
#pragma mark - UMSocialUIDelegate
//关闭当前页面之后
-(void)didCloseUIViewController:(UMSViewControllerType)fromViewControllerType {
    NSLog(@"fromViewControllerType");
}
-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData {
    if (UMShareToWechatTimeline == platformName) {
        [UMSocialData defaultData].extConfig.wechatTimelineData.url = @"http://www.yhcd.net";
        socialData.shareImage = nil;
    }
    else if (UMShareToQzone == platformName) {
        [UMSocialData defaultData].extConfig.qzoneData.url = @"http://www.yhcd.net";
    }
}
//各个页面执行授权完成、分享完成、或者评论完成时的回调函数
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response {
    NSLog(@"didFinishGetUMSocialDataInViewController");
    if (response.responseCode == UMSResponseCodeSuccess) {
        [self showResultThenHide:@"分享成功"];
        [self performSelector:@selector(addTicketsToMonitor) withObject:nil afterDelay:1];
    }
    else if (UMSResponseCodeCancel == response.responseCode){
        [self showResultThenHide:@"取消分享"];
    }
    else {
        [self showResultThenHide:@"分享失败"];
    }
}
//添加到监控列表
- (void)addTicketsToMonitor {
    NSString *tickets = [self ticketsToBeAdded];
    WEAKSELF
    [self showHUDLoading:@"正在添加至监控列表"];
    NSInteger ispay = 0;
    if(self.isShare == NO)
        ispay = self.ticketCount;
    
    [AFNManager getDataWithAPI:kResPathAppCourtFollow
                  andDictParam:@{@"no" : Trim(tickets), @"pay" : @(ispay)}
                     modelName:nil
              requestSuccessed:^(id responseObject) {
                  if (blockSelf.block) {
                      blockSelf.block(nil);
                  }
                  [blockSelf showResultThenBack:@"添加成功"];
                  postN(kNotificationRefreshUserCenter);//更新余额信息
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    [blockSelf hideHUDLoading];
                    [blockSelf showAlertVieWithMessage:errorMessage];
                }];
}


@end
