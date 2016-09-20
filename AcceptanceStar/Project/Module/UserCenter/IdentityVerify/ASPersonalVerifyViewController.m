//
//  ASPersonalVerifyViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/7/24.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASPersonalVerifyViewController.h"
#import "YSCTextField.h"
#import "YSCTextView.h"
#import <UIImage+Resize.h>
#import "TOCropViewController.h"

#define TextField(i) ((YSCTextField*)self.textFieldArray[i])

@interface ASPersonalVerifyViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,ZYQAssetPickerControllerDelegate, TOCropViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *statusLabelArray;
@property (assign, nonatomic) NSInteger verifyStatus;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFieldArray;
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

@implementation ASPersonalVerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIView makeRoundForView:self.submitButton withRadius:5];
    TextField(1).textType = YSCTextTypeMobilePhone;
    TextField(2).textType = YSCTextTypePhone;
    TextField(4).textType = YSCTextTypeIdentityNum;
    
    WEAKSELF
    [[self.view viewWithTag:100] bk_whenTapped:^{
        blockSelf.imageIndex = 0;
        [UIView showImagePickerActionSheetWithDelegate:blockSelf allowsEditing:NO singleImage:YES numberOfSelection:1 onViewController:blockSelf];
    }];
    [[self.view viewWithTag:101] bk_whenTapped:^{
        blockSelf.imageIndex = 1;
        [UIView showImagePickerActionSheetWithDelegate:blockSelf allowsEditing:NO singleImage:YES numberOfSelection:1 onViewController:blockSelf];
    }];
    [self checkVerifyStatus];
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
                  blockSelf.verifyStatus = blockSelf.statusModel.iactive;
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
    NSString *contact = TextField(0).textString;
    NSString *mobilePhone = TextField(1).textString;
    NSString *fixedPhone = TextField(2).textString;
    NSString *qq = TextField(3).textString;
    NSString *idNum = TextField(4).textString;
    
    CheckStringEmpty(contact, @"联系人不能为空");
    CheckStringEmpty(mobilePhone, @"联系手机不能为空");
    CheckStringEmpty(idNum, @"身份证号不能为空");
    if (NO == TextField(1).isValid) {
        [self showResultThenHide:@"联系人手机不合法"];
        return;
    }
    if (NO == isEmpty(fixedPhone)) {
        if (NO == TextField(2).isValid) {
            [self showResultThenHide:@"固定电话不合法"];
            return;
        }
    }
    if (NO == TextField(4).isValid) {
        [self showResultThenHide:@"身份证号不合法"];
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
    [AFNManager uploadImageDataParam:@{@"idcard_img" : self.idcard1ImageView.image,
                                       @"idcard_img_back" : self.idcard2ImageView.image}
                               toUrl:kResPathAppBaseUrl
                             withApi:kResPathAppUserAccreditation
                        andDictParam:@{
                                       @"name" : contact,
                                       @"phone" : mobilePhone,
                                       @"phone2" : fixedPhone,
                                       @"idcard" : idNum,
                                       @"QQ" : qq,
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


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if ( ! pickedImage) {
        pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    //处理获得的图片对象
    if (pickedImage) {
        pickedImage = [YSCImageUtils resizeImage:pickedImage toSize:CGSizeMake(580, 366)];
        TOCropViewController *cropController = [[TOCropViewController alloc] initWithImage:pickedImage];
        cropController.delegate = self;
        [self presentViewController:cropController animated:YES completion:nil];
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

#pragma mark - TOCropViewControllerDelegate
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle {
    [cropViewController dismissViewControllerAnimated:YES completion:nil];
    
    image = [YSCImageUtils resizeImage:image toSize:CGSizeMake(180, 80)];
    //NOTE:test file size
    //    NSString *imageString = [NSString EncodeBase64Data:UIImageJPEGRepresentation(image, ScaleOfImage)];
    //    [LogManager saveLog:imageString intoFileName:@"test1"];
    
    if (0 == self.imageIndex) {
        self.idcard1ImageView.image = image;
    }
    else if (1 == self.imageIndex) {
        self.idcard2ImageView.image = image;
    }
}
- (void)cropViewController:(TOCropViewController *)cropViewController didFinishCancelled:(BOOL)cancelled {
    [cropViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
