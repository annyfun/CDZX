//
//  ASDiscountCalculatorViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/26.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASDiscountCalculatorViewController.h"
#import "YSCPickerView.h"
#import "OpenShare+QQ.h"
#import "OpenShare+Weibo.h"
#import "OpenShare+Weixin.h"
#import "OpenShare+Renren.h"
#import "OpenShare+Alipay.h"
#import "SNSShareManager.h"
#import "YSCInfiniteLoopView.h"
#import <AVOSCloud/AVOSCloud.h>

@interface ASDiscountCalculatorViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UITextField *ticketTextField;
@property (weak, nonatomic) IBOutlet UITextField *monthRateTextField;
@property (weak, nonatomic) IBOutlet UITextField *yearRateTextField;

@property (weak, nonatomic) IBOutlet UIView *discountDateView;//贴现日期
@property (weak, nonatomic) IBOutlet UITextField *discountDateTextField;
@property (strong, nonatomic) NSDate *discountDate;

@property (weak, nonatomic) IBOutlet UIView *expireDateView;//过期日期
@property (weak, nonatomic) IBOutlet UITextField *expireDateTextField;
@property (strong, nonatomic) NSDate *expireDate;

@property (weak, nonatomic) IBOutlet UITextField *daysTextField;
@property (strong, nonatomic) YSCPickerView *yscPickerView;
@property (assign, nonatomic) NSInteger pickerIndex;

@property (weak, nonatomic) IBOutlet UITextField *interestDaysTextField;
@property (weak, nonatomic) IBOutlet UITextField *interestMoneyTextField;
@property (weak, nonatomic) IBOutlet UITextField *discountMoneyTextField;
@property (weak, nonatomic) IBOutlet UIButton *zhiPiaoBtn;
@property (weak, nonatomic) IBOutlet UIButton *dianPiaoBtn;
@property (weak, nonatomic) IBOutlet UIButton *chaXun;
@property (weak, nonatomic) IBOutlet UITextField *chaXunField;
@property (nonatomic, weak) IBOutlet YSCInfiniteLoopView *infiniteLoopView;
@property (nonatomic, strong) NSMutableArray *bannerArray;

@property (weak, nonatomic) IBOutlet UITextField *shiWanTextField;
@property (assign, nonatomic) BOOL isDianPiao;
@property (strong, nonatomic) NSDictionary *daysDict;
@end

@implementation ASDiscountCalculatorViewController

- (void)dealloc {
    [self.yscPickerView removeFromSuperview];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"贴现计算器";
    self.view.backgroundColor = RGB(221, 221, 221);
    
    [self resetSubviewsOfView:self.inputView];
    [self initTextFields];
    [self initPicerView];
    [self initBlocks];
    [self resetCalSubviews];
    
    addNObserverWithObj(@selector(textFieldChanged:), UITextFieldTextDidChangeNotification, self.discountDateTextField);
    addNObserverWithObj(@selector(textFieldChanged:), UITextFieldTextDidChangeNotification, self.expireDateTextField);
    
    
    WEAKSELF
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"分享" style:UIBarButtonItemStylePlain handler:^(id sender) {
        

        
       //TODO HEMY 分享截图分享
        UIImage *shareImage = [UIView screenshotOfView:blockSelf.inputView.superview];
        
        ShareType shareType = ShareTypeWechatSession;
        
        OSMessage *message = [[OSMessage alloc] init];
        message.image = shareImage;
        message.thumbnail = [blockSelf thumbnailForWeChat:shareImage size:32];
        void(^success)(void) = ^() {
            [MobClick event:UMEventKeyShareSuccess];
            [UIView showResultThenHideOnWindow:@"分享成功"];
        };
        void(^fail)(void) = ^() {
            [MobClick event:UMEventKeyShareFail];
            [UIView showResultThenHideOnWindow:@"分享失败"];
        };
        
        
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"分享截图"];
        [actionSheet bk_addButtonWithTitle:@"微信好友"
                                   handler:^{
                                       
                                       [MobClick event:UMEventKeyShareWechatSession];
                                       [OpenShare shareToWeixinSession:message Success:^(OSMessage *message) {
                                           success();
                                       } Fail:^(OSMessage *message, NSError *error) {
                                           fail();
                                       }];
                                   }];
        [actionSheet bk_addButtonWithTitle:@"微信朋友圈"
                                   handler:^{
                                       
                                       [MobClick event:UMEventKeyShareWechatTimeline];
                                       [OpenShare shareToWeixinTimeline:message Success:^(OSMessage *message) {
                                           success();
                                       } Fail:^(OSMessage *message, NSError *error) {
                                           fail();
                                       }];
                                   }];
        [actionSheet bk_addButtonWithTitle:@"QQ空间"
                                   handler:^{
                                       
                                       [MobClick event:UMEventKeyShareWeiboTencent];
                                       message.title = @" ";
                                       message.link = @"http://xizue.com";
                                       message.desc = @" ";
                                       [OpenShare shareToQQZone:message Success:^(OSMessage *message) {
                                           success();
                                       } Fail:^(OSMessage *message, NSError *error) {
                                           fail();
                                       }];
                                   }];
        [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [actionSheet showInView:blockSelf.view];

        
    }];
}

- (UIImage *)thumbnailForWeChat:(UIImage *)oImage size:(CGFloat)size
{
    UIImage *thumbnail = oImage;
    while (UIImagePNGRepresentation(thumbnail).length > size * 1024) {
        thumbnail = [self thumbnailWithScale:0.95 image:thumbnail];
    }
    return thumbnail;
}

- (UIImage *)thumbnailWithScale:(CGFloat)scale image:(UIImage *)image
{
    
    CGSize size = CGSizeMake(image.size.width * scale, image.size.height * scale);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return thumbnail;
}


- (void)resetSubviewsOfView:(UIView *)view {
    
    for (UIView *subview in view.subviews) {
        if ([subview isMemberOfClass:[UIView class]]) {
            [self resetSubviewsOfView:subview];
        }
        else if ([subview isMemberOfClass:[UITextField class]]) {
            subview.layer.cornerRadius = 3;
            subview.clipsToBounds = YES;
            [UIView makeBorderForView:subview withColor:RGB(170, 170, 170) borderWidth:1];
        }
        else if ([subview isMemberOfClass:[UIButton class]]) {
            
            if (subview.tag!=20) {
                [UIView makeRoundForView:subview withRadius:4];
            }else{
                
                [UIView makeRoundForView:subview withRadius:3];
            }
        }
    }
}

- (void)initPicerView {
    self.yscPickerView = [YSCPickerView CreateYSCPickerView];
    self.yscPickerView.pickerType = YSCPickerTypeDate;
    self.yscPickerView.datePicker.maximumDate = [NSDate distantFuture];
    WEAKSELF
    self.yscPickerView.selectingBlock = ^(id selectingObject) {
        NSDate *date = (NSDate *)selectingObject;
        NSString *dateString = [date stringWithFormat:DateFormat3];
        NSString *weekDay = [date chineseWeekDay];
        if (1 == blockSelf.pickerIndex) {
            blockSelf.discountDate = date;
            blockSelf.discountDateTextField.text = [NSString stringWithFormat:@"%@ %@", dateString, weekDay];
        }
        else if (2 == blockSelf.pickerIndex) {
            blockSelf.expireDate = date;
            blockSelf.expireDateTextField.text = [NSString stringWithFormat:@"%@ %@", dateString, weekDay];
            [blockSelf setDays];
        }
    };
    self.yscPickerView.completionShowBlock = ^{
    };
    self.yscPickerView.completionHideBlock = ^{
    };
}
- (void)initBlocks {
    WEAKSELF
    [self.discountDateView bk_whenTapped:^{
        [blockSelf hideKeyboard];
        blockSelf.pickerIndex = 1;
        NSDate *date = blockSelf.discountDate;
        if (date == nil) {
            date = [NSDate date];
        }
        [blockSelf.yscPickerView showPickerView:date];
    }];
    [self.expireDateView bk_whenTapped:^{
        [blockSelf hideKeyboard];
        blockSelf.pickerIndex = 2;
        NSDate *date = blockSelf.expireDate;
        if (date == nil) {
            date = [NSDate date];
        }
        [blockSelf.yscPickerView showPickerView:date];
    }];
}

- (void)initTextFields {
    self.ticketTextField.text = nil;
    self.monthRateTextField.text = nil;
    self.yearRateTextField.text = nil;
    self.discountDateTextField.text = nil;
    self.discountDateTextField.userInteractionEnabled = NO;
    self.expireDateTextField.text = nil;
    self.expireDateTextField.userInteractionEnabled = NO;
    self.daysTextField.text = nil;
    self.interestDaysTextField.text = nil;
    self.interestMoneyTextField.text = nil;
    self.discountMoneyTextField.text = nil;
    self.discountMoneyTextField.userInteractionEnabled = NO;
    self.shiWanTextField.text = nil;
    
    NSDate *date = [NSDate date];
    NSString *dateString = [date stringWithFormat:DateFormat3];
    NSString *weekDay = [date chineseWeekDay];
    self.discountDate = date;
    self.discountDateTextField.text = [NSString stringWithFormat:@"%@ %@", dateString, weekDay];
 
    [self setExpireDate];
    [self setDays];
}

#pragma mark - 按钮事件
- (IBAction)clearButtonClicked:(id)sender {
    [self hideKeyboard];
    [self initTextFields];
}
- (IBAction)calculateButtonClicked:(id)sender {
    [self hideKeyboard];
    CGFloat ticketMoney = self.ticketTextField.text.floatValue * 10000;
    CGFloat monthRate = self.monthRateTextField.text.floatValue / 1000;
    CGFloat yearRate = self.yearRateTextField.text.floatValue / 100;
    NSInteger tztsf = self.daysTextField.text.integerValue;
    
    
    NSInteger days = [self.expireDate daysAfterDate:self.discountDate] + tztsf + 1;
    
    CGFloat interestMoney = (yearRate / 360 * (days) * ticketMoney);
    self.interestDaysTextField.text = [NSString stringWithFormat:@"%ld", (long)(days)];
    
    if (ticketMoney == 0) {
        [self showResultThenHide:@"请输入票面金额"];
        return;
    }
    if (monthRate == 0) {
        [self showResultThenHide:@"请输入月利率"];
        return;
    }
    if (yearRate == 0) {
        [self showResultThenHide:@"请输入年利率"];
        return;
    }
    if ([self.expireDate isEarlierThanDate:self.discountDate]) {
        [self showResultThenHide:@"到期日期不能小于贴现日期"];
        return;
    }
    if (tztsf == 0 && !self.isDianPiao) {
        [self showResultThenHide:@"请输入调整天数"];
        return;
    }
    
    self.shiWanTextField.text = [NSString stringWithFormat:@"%.2f", (yearRate / 360 * (days) * 100000)];
    self.interestMoneyTextField.text = [NSString stringWithFormat:@"%.2f", interestMoney];
    self.discountMoneyTextField.text = [NSString stringWithFormat:@"%.2f", ticketMoney - interestMoney];
}
//再计算
- (IBAction)recalculateButtonClicked:(id)sender {
    [self hideKeyboard];
    [self pushViewController:@"ASCalculatorViewController" withParams:@{kParamNumber : Trim(self.discountMoneyTextField.text)}];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldChanged:(NSNotification *)notification {
    UITextField *textField = (UITextField *)notification.object;
    if (self.monthRateTextField.isFirstResponder && self.monthRateTextField == textField) {
        self.yearRateTextField.text = [NSString stringWithFormat:@"%.2f", self.monthRateTextField.text.floatValue * 1.2];
    }
    else if (self.yearRateTextField.isFirstResponder && self.yearRateTextField == textField) {
        self.monthRateTextField.text = [NSString stringWithFormat:@"%.2f", self.yearRateTextField.text.floatValue / 1.2];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(self.chaXunField == textField){
        NSString *targetString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        BOOL add = targetString.length>textField.text.length;
        NSString * str= [targetString stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (add && str.length>8) {
            
            NSMutableString *newString = [[NSMutableString alloc] initWithString:str];
            [newString insertString:@" " atIndex:8];
            textField.text = newString;
            
            return NO;
        }
    }
    
    return YES;
}


- (IBAction)col_selected:(id)sender{
    
    BOOL isDianPiao = self.dianPiaoBtn==sender;
    
    self.dianPiaoBtn.selected = isDianPiao;
    self.zhiPiaoBtn.selected = !isDianPiao;
    [self setExpireDate];
    [self setDays];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField==self.monthRateTextField) {
        
        CGFloat value = [self.monthRateTextField.text floatValue];
        self.yearRateTextField.text = [NSString stringWithFormat:@"%.2f",value*12 / 10];
        
    }else if (textField==self.yearRateTextField){
    
        CGFloat value = [self.yearRateTextField.text floatValue];
        self.monthRateTextField.text = [NSString stringWithFormat:@"%.2f",value/12 * 10];
    }
}


- (void)setExpireDate{
    NSDate *date = [self dayOfAfterMonth:self.isDianPiao?12:6 date:self.discountDate];
    date = [date dateByAddingDays:-1];
    NSString *dateString = [date stringWithFormat:DateFormat3];
    NSString *weekDay = [date chineseWeekDay];
    self.expireDate = date;
    self.expireDateTextField.text = [NSString stringWithFormat:@"%@ %@", dateString, weekDay];
}

- (void)setDays{
    
    //计算到期日
    NSString *dateString = [self.expireDate stringWithFormat:@"yyyy-M-d"];
   
    __block NSString *daysStr = nil;
    
    [self.daysDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isEqualToString:dateString]) {
            daysStr = obj;
            *stop = YES;
        }
    }];
    
    if (daysStr) {
        NSInteger day = [daysStr integerValue];
        if (self.isDianPiao) {
            self.daysTextField.text = [NSString stringWithFormat:@"%ld",MAX(0, day-3)];
        }else{
            self.daysTextField.text = [NSString stringWithFormat:@"%ld",MAX(0, day)];
        }
    }
    else{
    //7是周6 ; 1是周日
        if (self.isDianPiao) {
            if (self.expireDate.weekday == 7) {
                self.daysTextField.text = @"2";
            }
            else if (self.expireDate.weekday == 1) {
                self.daysTextField.text = @"1";
            }
            else {
                self.daysTextField.text = @"0";
            }
        }else{
            if (self.expireDate.weekday == 7) {
                self.daysTextField.text = @"5";
            }
            else if (self.expireDate.weekday == 1) {
                self.daysTextField.text = @"4";
            }
            else {
                self.daysTextField.text = @"3";
            }
        }
    }
}

- (NSDate *)dayOfAfterMonth:(NSInteger)month date:(NSDate *)date{
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = nil;
    comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:0];
    [adcomps setMonth:month];
    [adcomps setDay:0];
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:date options:0];
    
    return newdate;
}

- (BOOL)isDianPiao{
    return self.dianPiaoBtn.selected==YES;
}

- (NSDictionary *)daysDict{
    if (nil==_daysDict || _daysDict.count==0) {
        NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:@"hehehe"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        if (string) {
            string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];

            NSArray *all = [string componentsSeparatedByString:@"\n"];
            [all enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray *items = [obj componentsSeparatedByString:@","];
                if (items.count==2) {
                    [dict setObject:items[1] forKey:items[0]];
                }
            }];
        }
        _daysDict = dict;
    }
    return _daysDict;
}



#pragma Cal App

- (void)doCalApp{
    
    self.bannerArray = [self commonLoadCaches:@"ABCBBCC"];
    [self refreshBanner];
}

- (IBAction)chaXunAction:(id)sender{

    [self hideKeyboard];
    NSString *num = Trim(self.chaXunField.text);
    num = [NSString replaceString:num byRegex:@"[ ]+" to:@""];
    if (isEmpty(num)) {
        [self showResultThenHide:@"请输入汇票票号"];
        return;
    }
    WEAKSELF
    [self showHUDLoading:@"正在查询"];
    [AFNManager getDataWithAPI:@"Court/index/token"
                  andDictParam:@{@"no" : num}
                     modelName:ClassOfObject(CourtIndexModel)
              requestSuccessed:^(id responseObject) {
                  [blockSelf hideHUDLoading];
                  [blockSelf pushViewController:@"ASDraftQueryResultViewController"
                                     withParams:@{kParamModel : responseObject, kParamNumber : num}];
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    [blockSelf hideHUDLoading];
                    [blockSelf pushViewController:@"ASDraftQueryResultViewController"
                                       withParams:@{kParamNumber : num}];
                }];
}


- (void)resetCalSubviews{
        self.infiniteLoopView.backgroundColor = [UIColor clearColor];
    self.chaXunField.backgroundColor = [UIColor whiteColor];
    [UIView makeBorderForView:self.chaXunField withColor:RGB(170, 170, 170) borderWidth:1];
    
    [UIView makeRoundForView:self.chaXun withRadius:4];
    
    [UIView makeRoundForView:self.chaXunField withRadius:3];
}



- (void)layoutBannerView {
    WeakSelfType blockSelf = self;
    //设置数据源
    self.infiniteLoopView.pageViewAtIndex = ^UIView *(NSInteger pageIndex) {
        if (pageIndex >= [blockSelf.bannerArray count]) {
            return nil;
        }
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:blockSelf.infiniteLoopView.bounds];
        BannerModel *item = blockSelf.bannerArray[pageIndex];
        [imageView setImageWithURLString:item.thumb withFadeIn:NO];
        return imageView;
    };
    //设置点击事件
    self.infiniteLoopView.tapPageAtIndex = ^void(NSInteger pageIndex, UIView *contentView) {
        if (pageIndex >= 0 && pageIndex < [blockSelf.bannerArray count]) {
            BannerModel *item = blockSelf.bannerArray[pageIndex];
            [blockSelf pushViewController:@"ASWebViewViewController" withParams:@{kParamTitle : Trim(item.title), kParamUrl : Trim(item.url)}];
        }
    };
    self.infiniteLoopView.totalPageCount = [self.bannerArray count];
    [self.infiniteLoopView reloadData];
    if (1 == [self.bannerArray count]) {
        [self.infiniteLoopView.timer invalidate];
    }
}

- (void)refreshBanner {
    WeakSelfType blockSelf = self;
    [AFNManager getDataWithAPI:kResPathAppSlideIndex
                  andDictParam:@{@"cat" : @"calculator"}
                     modelName:ClassOfObject(BannerModel)
              requestSuccessed:^(id responseObject) {
                  if ([responseObject isKindOfClass:[NSArray class]]) {
                      if ([NSObject isNotEmpty:responseObject]) {
                          [blockSelf.bannerArray removeAllObjects];
                          
                          if ([[AVAnalytics getConfigParams:[NSString stringWithFormat:@"Review_%@",AppVersion]] boolValue]) {
                              for (BannerModel *item in responseObject) {
                                  if (![item.thumb isEqualToString:@"http://www.yhcd.net//thumb/slide/img/2015-09-24/800x600_0_1443085759_2273.jpg"]) {
                                      [blockSelf.bannerArray addObject:item];
                                  }
                              }
                          }else{
                              [blockSelf.bannerArray addObjectsFromArray:responseObject];
                          }
                          [blockSelf saveObject:responseObject forKey:@"ABCBBCC"];//缓存banner数组
                          [blockSelf layoutBannerView];
                      }
                  }
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    [blockSelf showResultThenHide:errorMessage];
                }];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.infiniteLoopView) {
        [self doCalApp];
    }
}

@end
