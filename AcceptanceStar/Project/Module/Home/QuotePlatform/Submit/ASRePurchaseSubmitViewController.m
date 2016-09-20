//
//  ASRePurchaseSubmitViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/7/19.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASRePurchaseSubmitViewController.h"
#import "YSCPickerView.h"
@interface ASRePurchaseSubmitViewController ()

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *viewArray;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelArray;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFieldArray;
@property (strong, nonatomic) NSArray *directionArray;//方向
@property (strong, nonatomic) NSArray *propertyArray;//票据属性
@property (strong, nonatomic) NSArray *typeArray;//类型
@property (assign, nonatomic) NSInteger selectIndex;

@property (strong, nonatomic) YSCPickerView *yscPickerView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;//机构名称
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextView *remarkTextView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation ASRePurchaseSubmitViewController

- (void)dealloc {
    [self.yscPickerView removeFromSuperview];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发布回购信息";
    self.directionArray = @[@"正回购", @"逆回购"];
    self.propertyArray = @[@"纸银",@"电银",@"纸商",@"电商"];
    self.typeArray = @[@"纸银国股",@"纸银大商",@"纸银小商",@"纸银其他",@"电银国股",@"电银大商",@"电银小商",@"电银其他",@"商业汇票"];
    [self initPicerView];
    [self initBlocks];
    
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
        UILabel *label = (UILabel *)blockSelf.labelArray[blockSelf.selectIndex];
        NSArray *indexArray = (NSArray *)selectingObject;
        NSInteger index = [indexArray[0] integerValue];
        if (0 == blockSelf.selectIndex) {
            label.text = blockSelf.directionArray[index];
        }
        else if (1 == blockSelf.selectIndex) {
            label.text = blockSelf.propertyArray[index];
        }
        else if (2 == blockSelf.selectIndex) {
            label.text = blockSelf.typeArray[index];
        }
    };
    self.yscPickerView.completionShowBlock = ^{
    };
    self.yscPickerView.completionHideBlock = ^{
    };
}
- (void)initBlocks {
    WEAKSELF
    //方向
    [self.viewArray[0] bk_whenTapped:^{
        blockSelf.selectIndex = 0;
        [blockSelf hideKeyboard];
        blockSelf.yscPickerView.customDataArray = @[blockSelf.directionArray];
        [blockSelf.yscPickerView setPickerType:YSCPickerTypeCustom];
        if ([blockSelf.directionArray containsObject:((UILabel *)blockSelf.labelArray[0]).text]) {
            [blockSelf.yscPickerView showPickerView:@[@([blockSelf.directionArray indexOfObject:((UILabel *)blockSelf.labelArray[0]).text])]];
        }
        else {
            [blockSelf.yscPickerView showPickerView:@[@(0)]];
        }
    }];
    //票据属性
    [self.viewArray[1] bk_whenTapped:^{
        blockSelf.selectIndex = 1;
        [blockSelf hideKeyboard];
        blockSelf.yscPickerView.customDataArray = @[blockSelf.propertyArray];
        [blockSelf.yscPickerView setPickerType:YSCPickerTypeCustom];
        if ([blockSelf.propertyArray containsObject:((UILabel *)blockSelf.labelArray[1]).text]) {
            [blockSelf.yscPickerView showPickerView:@[@([blockSelf.propertyArray indexOfObject:((UILabel *)blockSelf.labelArray[1]).text])]];
        }
        else {
            [blockSelf.yscPickerView showPickerView:@[@(0)]];
        }
    }];
    //类型
    [self.viewArray[2] bk_whenTapped:^{
        blockSelf.selectIndex = 2;
        [blockSelf hideKeyboard];
        blockSelf.yscPickerView.customDataArray = @[blockSelf.typeArray];
        [blockSelf.yscPickerView setPickerType:YSCPickerTypeCustom];
        if ([blockSelf.typeArray containsObject:((UILabel *)blockSelf.labelArray[2]).text]) {
            [blockSelf.yscPickerView showPickerView:@[@([blockSelf.typeArray indexOfObject:((UILabel *)blockSelf.labelArray[2]).text])]];
        }
        else {
            [blockSelf.yscPickerView showPickerView:@[@(0)]];
        }
    }];
}

- (IBAction)submitButtonClicked:(id)sender {
    //判空
    NSString *direction = Trim(((UILabel *)self.labelArray[0]).text);
    NSString *attr = Trim(((UILabel *)self.labelArray[1]).text);
    NSString *type = Trim(((UILabel *)self.labelArray[2]).text);
    NSString *rate = Trim(((UITextField *)self.textFieldArray[0]).text);
    NSString *amount = Trim(((UITextField *)self.textFieldArray[1]).text);
    NSString *days = Trim(((UITextField *)self.textFieldArray[2]).text);
    NSString *remarks = Trim(self.remarkTextView.text);
    CheckStringNotMatchRegex(@"^请选择$", direction, @"请选择方向");
    CheckStringNotMatchRegex(@"^请选择$", attr, @"请选择票据属性");
    CheckStringNotMatchRegex(@"^请选择$", type, @"请选择类型");
    CheckStringEmpty(rate, @"请输入年利率");
    CheckStringEmpty(amount, @"请输入金额");
    CheckStringEmpty(days, @"请输入剩余天数");
    
    WEAKSELF
    [self showHUDLoading:@"正在发布"];
    [AFNManager postDataWithAPI:kResPathAppBondRepurchaseAdd
                   andDictParam:@{@"action" : @([self.directionArray indexOfObject:direction]),
                                  kParamAttr : @([self.propertyArray indexOfObject:attr]),
                                  kParamKind : @(1 + [self.typeArray indexOfObject:type]),
                                  kParamRate : rate,
                                  kParamPrice : amount,
                                  kParamDays : days,
                                  kParamPhone : Trim(USER.phone),
                                  @"companyName" : Trim(USER.company),
                                  kParamComment : remarks
                                  }
                      modelName:nil
               requestSuccessed:^(id responseObject) {
                   [blockSelf showResultThenBack:@"发布成功"];
                   postN(kNotificationRefreshRePurchaseList);
               }
                 requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     [blockSelf hideHUDLoading];
                     [blockSelf showAlertVieWithMessage:errorMessage];
                 }];
}
@end
