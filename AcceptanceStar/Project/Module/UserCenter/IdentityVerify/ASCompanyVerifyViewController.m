//
//  ASCompanyVerifyViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/7/24.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASCompanyVerifyViewController.h"
#import "YSCTextField.h"
#import "YSCTextView.h"
#import <UIImage+Resize.h>
#import "TOCropViewController.h"

#define TextField(i) ((YSCTextField*)self.textFieldArray[i])

@interface ASCompanyVerifyViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,ZYQAssetPickerControllerDelegate, TOCropViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *statusLabelArray;
@property (assign, nonatomic) NSInteger verifyStatus;

@property (strong, nonatomic) IBOutletCollection(YSCTextField) NSArray *textFieldArray;
@property (weak, nonatomic) IBOutlet YSCTextView *introduceTextView;
@property (weak, nonatomic) IBOutlet UIImageView *companyImageView;//企业营业执照
@property (weak, nonatomic) IBOutlet UIImageView *idcard1ImageView;//身份证正面
@property (weak, nonatomic) IBOutlet UIImageView *idcard2ImageView;//身份证反面
@property (assign, nonatomic) NSInteger imageIndex;
//中间提示框
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *tipsButton;
//提交按钮
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) VerifyStatusModel *statusModel;
@end

@implementation ASCompanyVerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIView makeRoundForView:self.submitButton withRadius:5];
    TextField(4).textType = YSCTextTypeMobilePhone;
    TextField(5).textType = YSCTextTypePhone;
    TextField(6).textType = YSCTextTypeIdentityNum;
    
    WEAKSELF
    [[self.view viewWithTag:100] bk_whenTapped:^{
        blockSelf.imageIndex = 0;
        [UIView showImagePickerActionSheetWithDelegate:blockSelf allowsEditing:NO singleImage:YES numberOfSelection:1 onViewController:blockSelf];
    }];
    [[self.view viewWithTag:101] bk_whenTapped:^{
        blockSelf.imageIndex = 1;
        [UIView showImagePickerActionSheetWithDelegate:blockSelf allowsEditing:NO singleImage:YES numberOfSelection:1 onViewController:blockSelf];
    }];
    [[self.view viewWithTag:102] bk_whenTapped:^{
        blockSelf.imageIndex = 2;
        [UIView showImagePickerActionSheetWithDelegate:blockSelf allowsEditing:NO singleImage:YES numberOfSelection:1 onViewController:blockSelf];
    }];
    
    [self checkVerifyStatus];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    CGSize imgSize = image.size;
    
    if (imgSize.width>600) {
        imgSize.width = 600;
        imgSize.height = (image.size.height/image.size.width) * 600;
        image = [image resizedImage:imgSize interpolationQuality:kCGInterpolationDefault];
    }
    
    switch (self.imageIndex) {
        case 0:
            self.companyImageView.image = image;
            break;
        case 1:
            
            self.idcard1ImageView.image = image;
            break;
        case 2:
            
            self.idcard2ImageView.image = image;
            break;
            
        default:
            break;
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{

    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)checkVerifyStatus {
    self.scrollView.hidden = YES;
    self.middleView.hidden = YES;
    
    WEAKSELF
    [self showHUDLoading:@"正在查询审核状态"];
    [AFNManager getDataWithAPI:kResPathAppUserAccreditation
                  andDictParam:nil
                     modelName:ClassOfObject(VerifyStatusModel)
              requestSuccessed:^(id responseObject) {
                  [blockSelf hideHUDLoading];
                  blockSelf.statusModel = (VerifyStatusModel *)responseObject;
                  if (-1 == blockSelf.statusModel.iactive) {
                      blockSelf.statusModel.iactive = 0;
                  }
                  blockSelf.verifyStatus = blockSelf.statusModel.iactive;//TODO:test
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    [blockSelf hideHUDLoading];
                    [blockSelf showAlertVieWithMessage:errorMessage];
                }];
}

- (void)setVerifyStatus:(NSInteger)verifyStatus {
    _verifyStatus = verifyStatus;
    for (int i = 0; i < [self.statusLabelArray count]; i++) {
        UILabel *lbl = self.statusLabelArray[i];
        if (i == self.verifyStatus) {
            lbl.backgroundColor = RGB(49, 117, 242);
        }
        else {
            lbl.backgroundColor = RGB(216, 216, 216);
        }
    }
    
    self.scrollView.hidden = (verifyStatus != 0);
    self.submitButton.hidden = (verifyStatus != 0);
    self.middleView.hidden = (verifyStatus == 0);
    if (1 == verifyStatus) {
        self.tipsLabel.text = @"资料审核中";
        self.tipsButton.hidden = YES;
    }
    else if (2 == verifyStatus) {
        self.tipsLabel.text = @"恭喜您，审核通过！";
        self.tipsButton.hidden = YES;
    }
    else if (3 == verifyStatus) {
        self.tipsLabel.text = [NSString stringWithFormat:@"很遗憾，审核未通过。原因：%@", self.statusModel.reason];
        self.tipsButton.hidden = NO;
    }
}

- (IBAction)tipsButtonClicked:(id)sender {
    self.verifyStatus = 0;
}
- (IBAction)submitButtonClicked:(id)sender {
    NSString *comName = TextField(0).textString;
    NSString *comShortName = TextField(1).textString;
    NSString *comIntro = self.introduceTextView.textString;
    NSString *address = TextField(2).textString;
    NSString *contact = TextField(3).textString;
    NSString *mobilePhone = TextField(4).textString;
    NSString *fixedPhone = TextField(5).textString;
    NSString *idNum = TextField(6).textString;
    NSString *qq = TextField(7).textString;
    
    CheckStringEmpty(comName, @"机构名称不能为空");
    CheckStringEmpty(comShortName, @"机构简称不能为空");
    CheckStringEmpty(comIntro, @"机构简介不能为空");
    CheckStringEmpty(address, @"地址不能为空");
    CheckStringEmpty(contact, @"联系人不能为空");
    CheckStringEmpty(mobilePhone, @"联系手机不能为空");
    CheckStringEmpty(idNum, @"身份证号不能为空");
    if (NO == TextField(4).isValid) {
        [self showResultThenHide:@"联系人手机不合法"];
        return;
    }
    if (NO == isEmpty(fixedPhone)) {
        if (NO == TextField(5).isValid) {
            [self showResultThenHide:@"固定电话不合法"];
            return;
        }
    }
    if (NO == TextField(6).isValid) {
        [self showResultThenHide:@"身份证号不合法"];
        return;
    }
    if (nil == self.companyImageView.image) {
        [self showResultThenHide:@"营业执照不能为空"];
        return;
    }
    if (nil == self.idcard1ImageView.image) {
        [self showResultThenHide:@"身份证正面不能为空"];
        return;
    }
    if (nil == self.idcard2ImageView.image) {
        [self showResultThenHide:@"身份证反面不能为空"];
        return;
    }
    
    WEAKSELF
    [self showHUDLoading:@"正在提交"];
    [AFNManager uploadImageDataParam:@{@"licence" : self.companyImageView.image,
                                       @"idcard_img" : self.idcard1ImageView.image,
                                       @"idcard_img_back" : self.idcard2ImageView.image}
                               toUrl:kResPathAppBaseUrl
                             withApi:kResPathAppUserAccreditation
                        andDictParam:@{
                                       @"company_name" : comName,
                                       @"company_sname" : comShortName,
                                       @"company_content" : comIntro,
                                       @"address" : address,
                                       @"name" : contact,
                                       @"phone" : mobilePhone,
                                       @"phone2" : fixedPhone,
                                       @"idcard" : idNum,
                                       @"QQ" : qq
                                       }
                           modelName:nil
                        imageQuality:ImageQualityNormal
                    requestSuccessed:^(id responseObject) {
                        [blockSelf showResultThenBack:@"提交成功"];
                    }
                      requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                          [blockSelf hideHUDLoading];
                          [blockSelf showAlertVieWithMessage:errorMessage];
                      }];
}


@end
