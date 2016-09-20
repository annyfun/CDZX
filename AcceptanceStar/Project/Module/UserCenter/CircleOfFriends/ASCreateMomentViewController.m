//
//  ASCreateMomentViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/6/18.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASCreateMomentViewController.h"
#import "ASAddPhotoCell.h"

#define MaxCountOfPhoto     9

@interface ASCreateMomentViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;
@property (strong, nonatomic) NSMutableArray *photoArray;

@end

@implementation ASCreateMomentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"分享";
    self.photoArray = [NSMutableArray array];
    [self initCollectionView];
    
    WEAKSELF
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"发布" style:UIBarButtonItemStylePlain handler:^(id sender) {
        [blockSelf addMoment];
    }];
}

- (void)initCollectionView {
    [self.collectionView registerNib:[ASAddPhotoCell NibNameOfCell] forCellWithReuseIdentifier:kItemCellIdentifier];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.scrollEnabled = NO;
}

- (void)addMoment {
    if ([NSString isEmpty:self.textView.text]) {
        [self showResultThenHide:@"请填写文本信息"];
        return;
    }
    NSMutableDictionary *picDict = [NSMutableDictionary dictionary];
    for (int i = 0; i < [self.photoArray count]; i++) {
        NSString *imageName = [NSString stringWithFormat:@"pic%d", i];
        picDict[imageName] = self.photoArray[i];
    }
    
    WEAKSELF
    [self showHUDLoading:@"正在发布中"];
    [AFNManager uploadImageDataParam:picDict
                               toUrl:kResPathAppBaseUrl
                             withApi:kResPathAppMomentsAdd
                        andDictParam:@{@"text" : Trim(self.textView.text)}
                           modelName:nil
                        imageQuality:ImageQualityHigh
                    requestSuccessed:^(id responseObject) {
                        postN(@"ASMomentsViewController_refreshMoments");
                        [blockSelf showResultThenBack:@"发布成功"];
                    }
                      requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                          [blockSelf hideHUDLoading];
                          [blockSelf showAlertVieWithMessage:errorMessage];
                      }];
}

- (void)refreshCollectionData {
    NSInteger row = (1+[self.photoArray count]) / 3;
    NSInteger remainder = (1+[self.photoArray count]) % 3;    //余数
    self.collectionViewHeight.constant = (row + (remainder == 0 ? 0 : 1)) * AUTOLAYOUT_LENGTH(30 + 160);
    [self.collectionView reloadData];
}

//------------------------------------------------------
//
// UICollectionView相关回调
//
//------------------------------------------------------
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photoArray count] + 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ASAddPhotoCell *cell = (ASAddPhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kItemCellIdentifier forIndexPath:indexPath];
    if (indexPath.row < [self.photoArray count]) {
        cell.photoImageView.image = self.photoArray[indexPath.row];
    }
    else {
        cell.photoImageView.image = [UIImage imageNamed:@"addimage_normal"];
    }
    return cell;
}

#pragma mark - UICollectionFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return AUTOLAYOUT_SIZE_WH(160, 160);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return AUTOLAYOUT_EDGEINSETS(30, 30, 0, 30);
}
//cell的最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return AUTOLAYOUT_LENGTH(30);
}
//cell的最小列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.photoArray count]) {//增加一个选项：查看大图
        WeakSelfType blockSelf = self;
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:nil];
        [actionSheet bk_addButtonWithTitle:@"查看照片"
                                   handler:^{
                                       [ShowPhotosManager showPhotosWithImages:@[blockSelf.photoArray[indexPath.row]]
                                                                       atIndex:0
                                                                 fromImageView:nil];
                                   }];
        [actionSheet bk_addButtonWithTitle:@"删除照片"
                                   handler:^{
                                       [blockSelf.photoArray removeObjectAtIndex:indexPath.row];
                                       [blockSelf refreshCollectionData];
                                   }];
        [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [actionSheet showInView:self.view];
    }
    else {
        [UIView showImagePickerActionSheetWithDelegate:self allowsEditing:YES singleImage:YES numberOfSelection:1 onViewController:self];
    }
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
        pickedImage = [YSCImageUtils resizeImage:pickedImage toSize:CGSizeMake(160, 160)];
        [self.photoArray addObject:pickedImage];
        [self refreshCollectionData];
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
