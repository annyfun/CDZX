//
//  ASImproveInformationViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/26.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASImproveInformationViewController.h"
#import "YSCPickerView.h"

#define AgeStart    10

@interface ASImproveInformationViewController () <UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
ZYQAssetPickerControllerDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *textFieldViewArray;

@property (nonatomic, weak) IBOutlet UITextField *nickNameTextField;

@property (nonatomic, weak) IBOutlet UIView *maleView;
@property (nonatomic, weak) IBOutlet UIImageView *maleImageView;
@property (nonatomic, weak) IBOutlet UIView *femaleView;
@property (nonatomic, weak) IBOutlet UIImageView *femaleImageView;
@property (nonatomic, assign) BOOL isMale;

@property (nonatomic, weak) IBOutlet UILabel *ageLabel;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UITextField *companyTextField;
@property (nonatomic, weak) IBOutlet UITextField *positionTextField;
@property (nonatomic, weak) IBOutlet UILabel *cityLabel;

@property (nonatomic, weak) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) YSCPickerView *yscPickerView;
@property (strong, nonatomic) NSMutableArray *agesArray;
@property (strong, nonatomic) UIImage *pickedImage;//选择的要修改的图片
@property (assign, nonatomic) NSInteger currentCityId;

@end

@implementation ASImproveInformationViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    WeakSelfType blockSelf = self;
    self.agesArray = [NSMutableArray array];
    for (int i = AgeStart; i < 80; i++) {
        [self.agesArray addObject:@(i)];
    }
    
    [UIView makeRoundForView:self.doneButton withRadius:5];
    for (UIView *textFieldView in self.textFieldViewArray) {
        [UIView makeRoundForView:textFieldView withRadius:5];
        [UIView makeBorderForView:textFieldView withColor:kDefaultBorderColor borderWidth:1];
    }
    
    [self.maleView bk_whenTapped:^{
        blockSelf.isMale = YES;
    }];
    [self.femaleView bk_whenTapped:^{
        blockSelf.isMale = NO;
    }];
    
    //设置用户头像圆角，边框白色
    [UIView makeRoundForView:self.avatarImageView withRadius:AUTOLAYOUT_LENGTH(140) / 2];
    [UIView makeBorderForView:self.avatarImageView withColor:[UIColor whiteColor] borderWidth:4];
    
    // 点击修改头像
    [self.avatarImageView setImageWithURLString:USER.headlarge placeholderImage:DefaultAvatarImage];
    self.avatarImageView.userInteractionEnabled = YES;
    [self.avatarImageView bk_whenTapped:^{
        [blockSelf hideKeyboard];
        [UIActionSheet showImagePickerActionSheetWithDelegate:blockSelf
                                                allowsEditing:YES
                                                  singleImage:YES
                                            numberOfSelection:1
                                             onViewController:blockSelf];
    }];
    
    self.yscPickerView = [YSCPickerView CreateYSCPickerView];
    self.yscPickerView.customDataArray = @[self.agesArray];
    
    //年龄选择
    [((UIView *)self.textFieldViewArray[2]) bk_whenTapped:^{
        [blockSelf hideKeyboard];
        [blockSelf.yscPickerView setPickerType:YSCPickerTypeCustom];
        [blockSelf.yscPickerView showPickerView:@(MAX(0, blockSelf.ageLabel.text.integerValue - AgeStart))];
    }];
    
    //业务所在地选择
    [((UIView *)self.textFieldViewArray[6]) bk_whenTapped:^{
        YSCObjectResultBlock block = ^(NSObject *object, NSError *error) {
            ASCityModel *city = (ASCityModel *)object;
            blockSelf.currentCityId = city.id;
            blockSelf.cityLabel.text = city.city;
        };
        
        [blockSelf pushViewController:@"ASCitySelectionViewController"
                           withParams:@{kParamBlock : block,
                                        kParamIndex : @(blockSelf.currentCityId)}];
    }];
    
    //选择器的3个回调
    self.yscPickerView.selectingBlock = ^(id selectingObject) {
        NSArray *array = selectingObject;
        NSInteger selectedIndex = [array[0] integerValue];
        blockSelf.ageLabel.text = [NSString stringWithFormat:@"%ld", selectedIndex + AgeStart];
    };
    self.yscPickerView.completionShowBlock = ^{
    };
    self.yscPickerView.completionHideBlock = ^{
    };
    
    [self initUserInfo];
    
    BOOL showEditItem = [self.params[@"showEditItem"] boolValue];
    if (showEditItem) {
        self.doneButton.hidden = YES;
        
        for (UIView *subView in self.scrollView.subviews) {
            subView.userInteractionEnabled = NO;
        }
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"编辑" style:UIBarButtonItemStylePlain handler:^(id sender) {
            for (UIView *subView in blockSelf.scrollView.subviews) {
                subView.userInteractionEnabled = YES;
            }
            blockSelf.navigationItem.rightBarButtonItem = nil;
            blockSelf.title = @"编辑资料";
            blockSelf.doneButton.hidden = NO;
        }];
    }
}

- (void)initUserInfo {
    self.nickNameTextField.text = USER.nickname;
    self.isMale = (1 == USER.isex);
    self.ageLabel.text = [NSString stringWithFormat:@"%ld", USER.age];
    self.nameTextField.text =  USER.name;
    if (USER.itype == 1) {
         self.companyTextField.placeholder = @"公司名称 选填";
    }else{
        self.companyTextField.placeholder = @"公司名称 必填";

    }
    self.companyTextField.text =  USER.company;
    self.positionTextField.text = USER.position;
    if ([NSString isMatchRegex:@"[\u4E00-\u9FBB]+" withString:USER.city]) {
        self.cityLabel.text = Trim(USER.city);
    }
    else {
        self.cityLabel.text = @"";
    }
    self.currentCityId = USER.icity;
}
- (void)setIsMale:(BOOL)isMale {
    if (isMale) {
        self.maleImageView.image = [UIImage imageNamed:@"radio_selected"];
        self.femaleImageView.image = [UIImage imageNamed:@"radio_unselected"];
    }
    else {
        self.femaleImageView.image = [UIImage imageNamed:@"radio_selected"];
        self.maleImageView.image = [UIImage imageNamed:@"radio_unselected"];
    }
}
- (IBAction)doneButtonClicked:(id)sender {
    NSString *nickname = Trim(self.nickNameTextField.text);
    NSString *age = Trim(self.ageLabel.text);
    NSString *name = Trim(self.nameTextField.text);
    NSString *company = Trim(self.companyTextField.text);
    NSString *position = Trim(self.positionTextField.text);
    NSString *city = Trim(self.cityLabel.text);
    CheckStringEmpty(nickname, @"昵称不能为空");
    CheckStringEmpty(age, @"请选择年龄");
    //CheckStringEmpty(name, @"姓名不能为空");
    //CheckStringEmpty(company, @"公司名称不能为空");
    //CheckStringEmpty(position, @"职务不能为空");
    CheckStringEmpty(city, @"请选择业务地址");
    if (nil == self.pickedImage) {
        [self showResultThenHide:@"请选择头像"];
        return;
    }
    
    WeakSelfType blockSelf = self;
    [self showHUDLoading:@"正在保存"];
    [AFNManager uploadImageDataParam:@{@"pic" : self.pickedImage}
                               toUrl:kResPathAppBaseUrl
                             withApi:kResPathAppUserEditDetail
                        andDictParam:@{kParamNickName : nickname,
                                       kParamSex : @(self.isMale),
                                       kParamAge : age,
                                       kParamName : name,
                                       kParamCompany: company,
                                       kParamPosition : position,
                                       kParamCity : @(self.currentCityId)}
                           modelName:ClassOfObject(UserModel)
                        imageQuality:ImageQualityNormal
                    requestSuccessed:^(id responseObject) {
                        UserModel *user = responseObject;
                        if ([user isKindOfClass:[UserModel class]]) {
                            
                            [LOGIN resetUser:user];
                        }
                        [blockSelf showResultThenDismiss:@"保存成功"];
                    }
                      requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                          [blockSelf showResultThenHide:errorMessage];
                      }];
}

//----------------------UIImagePickerControllerDelegate------------------------------------
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:NULL];
    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if ( ! pickedImage) {
        pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    if (pickedImage) {
        pickedImage = [UIImage resizeImage:pickedImage toSize:CGSizeMake(188, 188) scale:YES];//resize image
        self.pickedImage = pickedImage;
        [self.avatarImageView setImageWithURLString:nil placeholderImage:pickedImage];
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
