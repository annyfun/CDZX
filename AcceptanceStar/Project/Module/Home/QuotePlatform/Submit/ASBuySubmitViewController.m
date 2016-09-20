//
//  ASBuySubmitViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/7/19.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASBuySubmitViewController.h"
#import "YSCPickerView.h"

@interface ASBuySubmitViewController ()

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *viewArray;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelArray;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFieldArray;
@property (strong, nonatomic) NSArray *propertyArray;//票据属性
@property (strong, nonatomic) NSArray *bankTypeArray;//承兑行类型
@property (assign, nonatomic) NSInteger selectIndex;
@property (assign, nonatomic) CGFloat contentOffsetY;
@property (assign, nonatomic) CGFloat contentOffsetYOld;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextView *remarkTextView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) YSCPickerView *yscPickerView;
@property (strong, nonatomic) RegionModel *regionModel;

@property (assign, nonatomic) NSInteger currentCityId;

@end

@implementation ASBuySubmitViewController

- (void)dealloc {
    [self.yscPickerView removeFromSuperview];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发布买票信息";
    self.propertyArray = @[@"纸银",@"电银",@"纸商",@"电商"];
    self.bankTypeArray = @[@"国股",@"大商",@"小商",@"其他"];
    [self initPicerView];
    [self initBlocks];
    
    //设置输入框
    for (UITextField *textField in self.textFieldArray) {
        textField.borderStyle = UITextBorderStyleNone;
        textField.textColor = RGB(146, 146, 146);
        textField.backgroundColor = [UIColor clearColor];
    }
    [UIView makeRoundForView:self.remarkTextView withRadius:5];
    [UIView makeBorderForView:self.remarkTextView withColor:kDefaultBorderColor borderWidth:1];
    [UIView makeRoundForView:self.submitButton withRadius:5];
    
    self.nickNameLabel.text = Trim(USER.nickname);
    self.phoneLabel.text = Trim(USER.phone);
    self.remarkTextView.text = nil;
}
- (void)initPicerView {
    self.yscPickerView = [YSCPickerView CreateYSCPickerView];
    WEAKSELF
    self.yscPickerView.selectingBlock = ^(id selectingObject) {
        UILabel *label = (UILabel *)blockSelf.labelArray[blockSelf.selectIndex];
        if (2 == blockSelf.selectIndex) {
            blockSelf.regionModel = (RegionModel *)selectingObject;
            label.text = blockSelf.regionModel.city;
        }
        else {
            NSArray *indexArray = (NSArray *)selectingObject;
            NSInteger index = [indexArray[0] integerValue];
            if (0 == blockSelf.selectIndex) {
                label.text = blockSelf.propertyArray[index];
            }
            else if (1 == blockSelf.selectIndex) {
                label.text = blockSelf.bankTypeArray[index];
            }
        }
    };
    self.yscPickerView.completionShowBlock = ^{
        blockSelf.scrollView.contentOffset = CGPointMake(0, blockSelf.contentOffsetY);
    };
    self.yscPickerView.completionHideBlock = ^{
        blockSelf.scrollView.contentOffset = CGPointMake(0, blockSelf.contentOffsetYOld);
    };
}
- (void)initBlocks {
    WEAKSELF
    //票据属性
    [self.viewArray[0] bk_whenTapped:^{
        blockSelf.selectIndex = 0;
        blockSelf.contentOffsetY = blockSelf.contentOffsetYOld = 0;
        [blockSelf hideKeyboard];
        blockSelf.yscPickerView.customDataArray = @[blockSelf.propertyArray];
        [blockSelf.yscPickerView setPickerType:YSCPickerTypeCustom];
        if ([blockSelf.propertyArray containsObject:((UILabel *)blockSelf.labelArray[0]).text]) {
            [blockSelf.yscPickerView showPickerView:@[@([blockSelf.propertyArray indexOfObject:((UILabel *)blockSelf.labelArray[0]).text])]];
        }
        else {
            [blockSelf.yscPickerView showPickerView:@[@(0)]];
        }
    }];
    //承兑行类型
    [self.viewArray[1] bk_whenTapped:^{
        blockSelf.selectIndex = 1;
        blockSelf.contentOffsetY = blockSelf.contentOffsetYOld = 0;
        [blockSelf hideKeyboard];
        blockSelf.yscPickerView.customDataArray = @[blockSelf.bankTypeArray];
        [blockSelf.yscPickerView setPickerType:YSCPickerTypeCustom];
        if ([blockSelf.bankTypeArray containsObject:((UILabel *)blockSelf.labelArray[1]).text]) {
            [blockSelf.yscPickerView showPickerView:@[@([blockSelf.bankTypeArray indexOfObject:((UILabel *)blockSelf.labelArray[1]).text])]];
        }
        else {
            [blockSelf.yscPickerView showPickerView:@[@(0)]];
        }
    }];
    //贴现地点
    [self.viewArray[2] bk_whenTapped:^{
        YSCObjectResultBlock block = ^(NSObject *object, NSError *error) {
            ASCityModel *city = (ASCityModel *)object;
            blockSelf.currentCityId = city.id;
            UILabel *label = (UILabel *)blockSelf.labelArray[2];
            label.text = city.city;
        };
        
        [blockSelf pushViewController:@"ASCitySelectionViewController"
                           withParams:@{kParamBlock : block,
                                        kParamIndex : @(blockSelf.currentCityId)}];
    }];
}

- (IBAction)submitButtonClicked:(id)sender {
    //判空
    NSString *pjsx = Trim(((UILabel *)self.labelArray[0]).text);
    NSString *cdhlx = Trim(((UILabel *)self.labelArray[1]).text);
    NSString *syqx = Trim(((UITextField *)self.textFieldArray[0]).text);
    NSString *pmje = Trim(((UITextField *)self.textFieldArray[1]).text);
    NSString *bjll = Trim(((UITextField *)self.textFieldArray[2]).text);
    NSString *txdd = Trim(((UILabel *)self.labelArray[2]).text);
    NSString *bz = Trim(self.remarkTextView.text);
    CheckStringNotMatchRegex(@"^请选择$", pjsx, @"请选择票据属性");
    CheckStringNotMatchRegex(@"^请选择$", cdhlx, @"请选择承兑行类型");
    CheckStringEmpty(syqx, @"请输入剩余天数");
    CheckStringEmpty(pmje, @"请输入票面金额");
    CheckStringEmpty(bjll, @"请输入报价利率");
    CheckStringNotMatchRegex(@"^请选择$", txdd, @"请选择贴现地点");
    
    WEAKSELF
    [self showHUDLoading:@"正在发布"];
    [AFNManager postDataWithAPI:kResPathAppBondBuyAdd
                   andDictParam:@{kParamAttr : @([self.propertyArray indexOfObject:pjsx]),
                                  kParamClass : @([self.bankTypeArray indexOfObject:cdhlx]),
                                  kParamCity : @(self.currentCityId),
                                  kParamPrice : pmje,
                                  kParamRate : bjll,
                                  kParamComment : bz,
                                  kParamDays : syqx,
                                  kParamPhone : Trim(USER.phone)}
                      modelName:nil
               requestSuccessed:^(id responseObject) {
                   [blockSelf showResultThenBack:@"发布成功"];
                   postN(kNotificationRefreshBuyList);
               }
                 requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     [blockSelf hideHUDLoading];
                     [blockSelf showAlertVieWithMessage:errorMessage];
                 }];
}

@end
