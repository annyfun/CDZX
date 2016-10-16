//
//  ASDraftQueryResultViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/8/2.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASDraftQueryResultViewController.h"

@interface ASDraftQueryResultViewController () <UMSocialUIDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *ticketNumLabel;
@property (weak, nonatomic) IBOutlet UIButton *addToObserverButton;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (strong, nonatomic) CourtIndexModel *model;
@end

@implementation ASDraftQueryResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.model = self.params[kParamModel];
    self.title = @"汇票查询结果";
    self.contentLabel.text = nil;
    self.bottomView.backgroundColor = [UIColor clearColor];
    [UIView makeRoundForView:self.topView withRadius:5];
    [UIView makeBorderForView:self.topView withColor:DefaultBorderColor borderWidth:1];
    [UIView makeRoundForView:self.bottomView withRadius:5];
    [UIView makeBorderForView:self.bottomView withColor:DefaultBorderColor borderWidth:1];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [UIView makeRoundForView:self.addToObserverButton withRadius:5];
    
    [self layoutModel];
}
- (void)layoutModel {
    NSMutableString *tempNumber = [NSMutableString stringWithString:Trim(self.params[kParamNumber])];
    if ([tempNumber length] > 8) {
        [tempNumber insertString:@"  " atIndex:8];
    }
    
    if (self.model) {
        self.resultLabel.text = @"检测到此票已被公示催告，请注意申报权利";
        self.bottomView.hidden = NO;
        NSMutableString *content = [NSMutableString stringWithFormat:@"公示催告内容：\r\n%@", Trim(self.model.content)];
        [content appendString:@"\r\n"];
        if (isNotEmpty(self.model.sname)) {
            [content appendFormat:@"\r\n当事人：%@", Trim(self.model.sname)];
        }
        if (isNotEmpty(self.model.gdate)) {
            [content appendFormat:@"\r\n刊登日期：%@", Trim(self.model.gdate)];
        }
        if (isNotEmpty(self.model.posttime)) {
            [content appendFormat:@"\r\n上传日期：%@", [NSDate StringFromTimeStamp:self.model.posttime withFormat:DateFormat3]];
        }
        self.bottomViewHeight.constant = [NSString HeightOfNormalString:content maxWidth:AUTOLAYOUT_LENGTH(584) withFont:AUTOLAYOUT_FONT(24)] + 30;
        self.contentLabel.text = content;
    }
    else {
        self.resultLabel.text = @"没有找到查询结果";
        self.bottomView.hidden = YES;
    }
    self.ticketNumLabel.text = tempNumber;
}

- (IBAction)addToObserverButtonClicked:(id)sender {
    
   
#ifndef AFAPP
    if (NO == ISLOGGED) {
        [self presentViewController:@"ASLoginViewController"];
        return;
    }
    WEAKSELF
    UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"选择付费方式"];
    [alert bk_addButtonWithTitle:@"分享并免费添加" handler:^{
        [UMSocialSnsService presentSnsIconSheetView:blockSelf
                                             appKey:kUMAppKey
                                          shareText:@"下载“承兑之星”APP，瞬间认识30万票据中介，买票、卖票、回购、转贴、票据挂失预警等等，应有尽有。http://www.yhcd.net"
                                         shareImage:[UIImage imageNamed:@"icon_logo"]
                                    shareToSnsNames:@[UMShareToWechatTimeline, UMShareToQzone]
                                           delegate:blockSelf];
    }];
    [alert bk_addButtonWithTitle:@"余额付费1元添加" handler:^{
        [blockSelf addToMonitorList:@"true"];
    }];
    [alert bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [alert show];
#else
    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"wx02be3a6564b7a50d"]];
    [WCAlertView showAlertWithTitle:@"此票号添加到挂失预警监控列表，需要下载承兑之星APP" message:nil customizationBlock:NULL completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex==1) {
            if (canOpen) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"wx02be3a6564b7a50d"]];
            }
            else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/cheng-dui-zhi-xing/id1045101824?mt=8"]];
                
            }
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:canOpen?@"打开承兑之星":canOpen?@"打开":@"下载", nil];
    
    
#endif
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
        [self performSelector:@selector(addToMonitorList:) withObject:@"false" afterDelay:1];
    }
    else if (UMSResponseCodeCancel == response.responseCode){
        [self showResultThenHide:@"取消分享"];
    }
    else {
        [self showResultThenHide:@"分享失败"];
    }
}


//添加到监控列表
- (void)addToMonitorList:(NSObject *)pay {
    
    NSString *path = @"Court/follow/token";
#ifndef AFAPP
    path = kResPathAppCourtFollow;
#endif
    
    NSString *payString = [NSString stringWithFormat:@"%@", pay];
    WEAKSELF
    [UIView showHUDLoadingOnWindow:@"正在添加至监控列表"];
    [AFNManager getDataWithAPI:path
                   andDictParam:@{@"no" : Trim(self.params[kParamNumber]), @"pay" : payString}
                      modelName:nil
               requestSuccessed:^(id responseObject) {
                   [UIView showResultThenHideOnWindow:@"添加成功"];
                   postN(kNotificationRefreshUserCenter);
               }
                 requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     [UIView hideHUDLoadingOnWindow];
                     [blockSelf showAlertVieWithMessage:errorMessage];
                 }];
}


@end
