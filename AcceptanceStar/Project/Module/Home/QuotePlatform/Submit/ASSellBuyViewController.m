//
//  ASSellBuyViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/7/19.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASSellBuyViewController.h"
#import "YSCPickerView.h"

@interface ASSellBuyViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,ZYQAssetPickerControllerDelegate>

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *viewArray;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelArray;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFieldArray;
@property (strong, nonatomic) NSArray *propertyArray;//票据属性
@property (strong, nonatomic) NSArray *bankTypeArray;//承兑行类型
@property (assign, nonatomic) NSInteger selectIndex;
@property (assign, nonatomic) CGFloat contentOffsetY;
@property (assign, nonatomic) CGFloat contentOffsetYOld;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *ticketImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextView *remarkTextView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) YSCPickerView *yscPickerView;
@property (strong, nonatomic) RegionModel *regionModel;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) UIImage *selectedImage;

@property (assign, nonatomic) NSInteger currentCityId;

@end

@implementation ASSellBuyViewController

- (void)dealloc {
    [self.yscPickerView removeFromSuperview];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发布卖票信息";
    self.propertyArray = @[@"纸银",@"电银",@"纸商",@"电商"];
    self.bankTypeArray = @[@"国股",@"大商",@"小商",@"其他"];
    [self initPicerView];
    [self initBlocks];
    
    //设置输入框
    for (UITextField *textField in self.textFieldArray) {
        textField.textColor = RGB(146, 146, 146);
        textField.borderStyle = UITextBorderStyleNone;
        textField.backgroundColor = [UIColor clearColor];
    }
    UITextField *textField = (UITextField *)self.textFieldArray[1];
    textField.userInteractionEnabled = NO;
    [UIView makeRoundForView:self.remarkTextView withRadius:5];
    [UIView makeBorderForView:self.remarkTextView withColor:kDefaultBorderColor borderWidth:1];
    [UIView makeRoundForView:self.submitButton withRadius:5];

    self.nickNameLabel.text = Trim(USER.nickname);
    self.phoneLabel.text = Trim(USER.phone);
    self.remarkTextView.text = nil;
}
- (void)initPicerView {
    self.yscPickerView = [YSCPickerView CreateYSCPickerView];
    self.yscPickerView.datePicker.maximumDate = [NSDate distantFuture];
    WEAKSELF
    self.yscPickerView.selectingBlock = ^(id selectingObject) {
        UILabel *label = (UILabel *)blockSelf.labelArray[blockSelf.selectIndex]; 
        if (3 == blockSelf.selectIndex) {
            blockSelf.regionModel = (RegionModel *)selectingObject;
            label.text = blockSelf.regionModel.city;
        }
        else if (2 == blockSelf.selectIndex) {//到期日
            blockSelf.selectedDate = (NSDate *)selectingObject;
            label.text = [blockSelf.selectedDate stringWithFormat:DateFormat3];
            UITextField *textField = (UITextField *)blockSelf.textFieldArray[1];
            textField.text = [NSString stringWithFormat:@"%ld", [blockSelf.selectedDate daysAfterDate:[NSDate date]]];
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
    //到期日
    [self.viewArray[2] bk_whenTapped:^{
        blockSelf.selectIndex = 2;
        blockSelf.contentOffsetY = MAX(0, AUTOLAYOUT_LENGTH(268) + CGRectGetMaxY(((UIView *)blockSelf.viewArray[2]).frame) + AUTOLAYOUT_LENGTH(360) - SCREEN_HEIGHT);;
        blockSelf.contentOffsetYOld = blockSelf.scrollView.contentOffset.y;
        [blockSelf hideKeyboard];
        [blockSelf.yscPickerView setPickerType:YSCPickerTypeDate];
        [blockSelf.yscPickerView showPickerView:blockSelf.selectedDate];
    }];

    //贴现地点
    [self.viewArray[3] bk_whenTapped:^{
        blockSelf.selectIndex = 3;
        YSCObjectResultBlock block = ^(NSObject *object, NSError *error) {
            ASCityModel *city = (ASCityModel *)object;
            blockSelf.currentCityId = city.id;
            UILabel *label = (UILabel *)blockSelf.labelArray[3];
            label.text = city.city;
        };
        
        [blockSelf pushViewController:@"ASCitySelectionViewController"
                           withParams:@{kParamBlock : block,
                                        kParamIndex : @(blockSelf.currentCityId)}];
    }];
    
    //正面照片
    [self.viewArray[4] bk_whenTapped:^{
        [UIView showImagePickerActionSheetWithDelegate:blockSelf allowsEditing:NO singleImage:YES numberOfSelection:1 onViewController:blockSelf];
    }];
}

- (IBAction)submitButtonClicked:(id)sender {
    //判空
    NSString *pjsx = Trim(((UILabel *)self.labelArray[0]).text);
    NSString *cdhlx = Trim(((UILabel *)self.labelArray[1]).text);
    NSString *cdhmc = Trim(((UITextField *)self.textFieldArray[0]).text);//承兑行名称
    NSString *syts = Trim(((UITextField *)self.textFieldArray[1]).text);//剩余天数
    NSString *pmje = Trim(((UITextField *)self.textFieldArray[2]).text);//票面金额
    NSString *dqr = Trim(((UILabel *)self.labelArray[2]).text);//到期日期
    NSString *txdd = Trim(((UILabel *)self.labelArray[3]).text);
    NSString *bz = Trim(self.remarkTextView.text);
    if (nil == self.selectedImage) {
        [self showResultThenHide:@"请拍摄或选择票据照片"];
        return;
    }
    CheckStringNotMatchRegex(@"^请选择$", pjsx, @"请选择票据属性");
    CheckStringNotMatchRegex(@"^请选择$", cdhlx, @"请选择承兑行类型");
    CheckStringEmpty(pmje, @"请输入票面金额");
    CheckStringNotMatchRegex(@"^请选择$", dqr, @"请选择到期日期");
    CheckStringEmpty(syts, @"请输入剩余天数");
    CheckStringNotMatchRegex(@"^请选择$", txdd, @"请选择贴现地点");
    CheckStringEmpty(cdhmc, @"请输入承兑行名称");
    
    NSDate *dqrDate = [NSDate dateFromString:dqr withFormat:DateFormat3];
    dqr = [dqrDate timeStamp];
    
    WEAKSELF
    [self showHUDLoading:@"正在发布"];
    [AFNManager uploadImageDataParam:@{@"img" : self.selectedImage}
                      toUrl:kResPathAppBaseUrl
                    withApi:kResPathAppBondSellAdd
               andDictParam:@{kParamAttr : @([self.propertyArray indexOfObject:pjsx]),
                              kParamClass : @([self.bankTypeArray indexOfObject:cdhlx]),
                              kParamDays : syts,
                              kParamCity : @(self.currentCityId),
                              kParamPrice : pmje,
                              kParamComment : bz,
                              @"class_name" : cdhmc,
                              @"exp" : dqr,
                              kParamPhone : Trim(USER.phone)}
                           modelName:nil
               imageQuality:ImageQualityHigh requestSuccessed:^(id responseObject) {
                   [blockSelf showResultThenBack:@"发布成功"];
                   postN(kNotificationRefreshSellList);
               }
             requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                 [blockSelf hideHUDLoading];
                 [blockSelf showAlertVieWithMessage:errorMessage];
             }];
}

//------------------------------------------------------
//
// UIImagePickerController相关回调
//
//------------------------------------------------------
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if ( ! pickedImage) {
        pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    if (pickedImage) {
        pickedImage = [YSCImageUtils resizeImage:pickedImage toSize:CGSizeMake(640, 640)];
        self.ticketImageView.image = pickedImage;
        self.selectedImage = pickedImage;
    }
    else {
        [self showResultThenHide:@"未选择图片"];
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}


@end
