//
//  ASQuotePriceSubmitViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/7/19.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASQuotePriceSubmitViewController.h"
#import "YSCPickerView.h"

@interface ASQuotePriceSubmitViewController ()
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFieldArray;

@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;//机构名称
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextView *remarkTextView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (strong, nonatomic) NSArray *propertyArray;//票据属性
@property (weak, nonatomic) IBOutlet UIView *attrView;
@property (weak, nonatomic) IBOutlet UILabel *attrLabel;
@property (strong, nonatomic) YSCPickerView *yscPickerView;
@end

@implementation ASQuotePriceSubmitViewController

- (void)dealloc {
    [self.yscPickerView removeFromSuperview];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发布机构报价信息";
    self.propertyArray = @[@"纸银",@"电银",@"纸商",@"电商"];
    [self initPicerView];
    //设置输入框
    for (UITextField *textField in self.textFieldArray) {
        textField.textColor = RGB(146, 146, 146);
        textField.borderStyle = UITextBorderStyleNone;
        textField.backgroundColor = [UIColor clearColor];
    }
    [UIView makeRoundForView:self.remarkTextView withRadius:5];
    [UIView makeBorderForView:self.remarkTextView withColor:kDefaultBorderColor borderWidth:1];
    [UIView makeRoundForView:self.submitButton withRadius:5];
    
    self.groupNameLabel.text = Trim(USER.company);
    self.nickNameLabel.text = Trim(USER.nickname);
    self.phoneLabel.text = Trim(USER.phone);
    self.remarkTextView.text = nil;
}
- (void)initPicerView {
    self.yscPickerView = [YSCPickerView CreateYSCPickerView];
    WEAKSELF
    self.yscPickerView.selectingBlock = ^(id selectingObject) {
        NSArray *indexArray = (NSArray *)selectingObject;
        NSInteger index = [indexArray[0] integerValue];
        blockSelf.attrLabel.text = blockSelf.propertyArray[index];
    };
    
    [self.attrView bk_whenTapped:^{
        [blockSelf hideKeyboard];
        blockSelf.yscPickerView.customDataArray = @[blockSelf.propertyArray];
        [blockSelf.yscPickerView setPickerType:YSCPickerTypeCustom];
        if ([blockSelf.propertyArray containsObject:blockSelf.attrLabel.text]) {
            [blockSelf.yscPickerView showPickerView:@[@([blockSelf.propertyArray indexOfObject:blockSelf.attrLabel.text])]];
        }
        else {
            [blockSelf.yscPickerView showPickerView:@[@(0)]];
        }
    }];
}

- (IBAction)submitButtonClicked:(id)sender {
    //判空
    NSString *jrll = Trim(((UITextField *)self.textFieldArray[0]).text);
    NSString *qx = Trim(((UITextField *)self.textFieldArray[1]).text);
    NSString *gg = Trim(((UITextField *)self.textFieldArray[2]).text);
    NSString *ds = Trim(((UITextField *)self.textFieldArray[3]).text);
    NSString *xs = Trim(((UITextField *)self.textFieldArray[4]).text);
    NSString *qt = Trim(((UITextField *)self.textFieldArray[5]).text);
    NSString *bz = Trim(self.remarkTextView.text);
    NSString *pjsx = Trim(self.attrLabel.text);
    CheckStringNotMatchRegex(@"^请选择$", pjsx, @"请选择票据属性");
    CheckStringEmpty(jrll, @"请输入今日利率");
    CheckStringEmpty(qx, @"请输入期限天数");
    CheckStringEmpty(gg, @"请输入国股月利率");
    CheckStringEmpty(ds, @"请输入大商月利率");
    CheckStringEmpty(xs, @"请输入小商月利率");
    CheckStringEmpty(qt, @"请输入其它月利率");
    
    WEAKSELF
    [self showHUDLoading:@"正在发布"];
    [AFNManager postDataWithAPI:kResPathAppBondCompanyAdd
                   andDictParam:@{kParamRate : jrll,
                                  @"gg_r" : gg,
                                  @"ds_r" : ds,
                                  @"xs_r" : xs,
                                  @"qt_r" : qt,
                                  @"days" : qx,
                                  kParamAttr : @([self.propertyArray indexOfObject:pjsx]),
                                  @"companyName" : Trim(USER.company),
                                  @"phone" : Trim(USER.phone),
                                  @"comment" : bz
                                  }
                      modelName:nil
               requestSuccessed:^(id responseObject) {
                   [blockSelf showResultThenBack:@"发布成功"];
                   postN(kNotificationRefreshQuotePriceList);
               }
                 requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     [blockSelf hideHUDLoading];
                     [blockSelf showAlertVieWithMessage:errorMessage];
                 }];
}

@end
