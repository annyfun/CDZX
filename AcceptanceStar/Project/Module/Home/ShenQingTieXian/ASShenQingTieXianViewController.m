//
//  ASShenQingTieXianViewController.m
//  AcceptanceStar
//
//  Created by lcyu on 2016/11/22.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "ASShenQingTieXianViewController.h"
#import "ASPiaoJuTableViewCell.h"
#import "ASInfoTableViewCell.h"

@interface ASShenQingTieXianViewController ()<UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ZYQAssetPickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) NSIndexPath *selectDateIndexPath;
@property (nonatomic, strong) TieXianModel *tieXianModel;
@property (nonatomic, strong) NSMutableDictionary *imageDic;
@end

@implementation ASShenQingTieXianViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ASPiaoJuTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ASPiaoJuTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ASInfoTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ASInfoTableViewCell class])];
    [self.dataArray addObject:[PaperModel new]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 6;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.dataArray.count) {
        ASInfoTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ASInfoTableViewCell class])];
        cell.tieXianModel = self.tieXianModel;
        return cell;
    }
    else
    {
        ASPiaoJuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ASPiaoJuTableViewCell class])];
        cell.paperModel = self.dataArray[indexPath.section];
        cell.expDateTF.inputView = self.datePicker;
        cell.expDateTF.inputAccessoryView = self.toolBar;
        WEAKSELF1
        cell.addClickBlock = ^(){
            [weakSelf.dataArray addObject:[PaperModel new]];
            [weakSelf.tableView reloadData];
        };
        cell.clickDateBlock = ^(UITableViewCell *cell){
            weakSelf.selectDateIndexPath = [weakSelf.tableView indexPathForCell:cell];
        };
        cell.priceChangeBlock = ^(NSInteger price){
            weakSelf.tieXianModel.totalPrice = 0;
            [weakSelf.dataArray enumerateObjectsUsingBlock:^(PaperModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                weakSelf.tieXianModel.totalPrice += obj.price;
            }];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:weakSelf.dataArray.count]] withRowAnimation:UITableViewRowAnimationNone];
        };
        cell.addImage = ^(UITableViewCell *cell){
            weakSelf.selectDateIndexPath = [weakSelf.tableView indexPathForCell:cell];
            [UIActionSheet showImagePickerActionSheetWithDelegate:weakSelf
                                                    allowsEditing:YES
                                                      singleImage:YES
                                                numberOfSelection:1
                                                 onViewController:weakSelf];
        };
        cell.addView.hidden = (indexPath.section < self.dataArray.count - 1);
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section < self.dataArray.count - 1 ? 233: 277;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:NULL];
    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!pickedImage) {
        pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    if (pickedImage) {
        ASPiaoJuTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.selectDateIndexPath];
        [cell.addIV setImageWithURLString:nil placeholderImage:pickedImage];
        [self.imageDic setObject:pickedImage forKey:[NSString stringWithFormat:@"%d", self.selectDateIndexPath.section]];
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)selectedDate
{
    [self.view endEditing:YES];
    PaperModel *model = self.dataArray[self.selectDateIndexPath.section];
    model.exp = [self.datePicker.date timeIntervalSince1970];
    ASPiaoJuTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.selectDateIndexPath];
    cell.paperModel = model;
}

-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        self.dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

-(UIDatePicker *)datePicker
{
    if (!_datePicker) {
        self.datePicker = [[UIDatePicker alloc] init];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
    }
    return _datePicker;
}

-(UIToolbar *)toolBar
{
    if (!_toolBar) {
        self.toolBar = [[UIToolbar alloc] init];
        self.toolBar.backgroundColor = [UIColor grayColor];
        
        //屏幕宽度
        CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
        
        self.toolBar.frame = CGRectMake(0, 0, screenW, 40);
        
        //设置下一个跟Done item之间的间距  UIBarButtonSystemItemFlexibleSpace 此枚举为弹簧效果
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        //设置item（Done）
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(selectedDate)];
        
        //toolbar属性设置
        self.toolBar.items = @[flexibleItem, doneItem];
    }
    return _toolBar;
}

-(TieXianModel *)tieXianModel
{
    if (!_tieXianModel) {
        self.tieXianModel = [TieXianModel new];
        self.tieXianModel.name = USER.nickname;
        self.tieXianModel.phone = USER.phone;
    }
    return _tieXianModel;
}

-(NSMutableDictionary *)imageDic
{
    if (!_imageDic) {
        self.imageDic = [NSMutableDictionary dictionary];
    }
    return _imageDic;
}


- (IBAction)requsetClick:(id)sender {
    [self requestData];
}

-(void)requestData
{
    NSMutableArray *paperArray = [NSMutableArray array];
    [self.dataArray enumerateObjectsUsingBlock:^(PaperModel *  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        [paperArray addObject:[model toDictionary]];
    }];
    self.tieXianModel.list = paperArray;
    self.tieXianModel.id = @"123456";
    
    NSArray *sortedArray = [[self.imageDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    NSMutableDictionary *dictNew = [[NSMutableDictionary alloc] init];
    [sortedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [dictNew setObject:[self.imageDic objectForKey:obj] forKey:obj];
    }];
    
    NSDictionary *dic = [self.tieXianModel toDictionary];
    [UIView showHUDLoadingOnWindow:@"正在发送请求"];
    [AFNManager uploadImageDataParam:dictNew
                               toUrl:kResPathAppBaseUrl
                             withApi:kResPathAppBondElectricBuy
                        andDictParam:dic
                           modelName:nil
                        imageQuality:ImageQualityNormal
                    requestSuccessed:^(id responseObject) {
                        [UIView hideHUDLoadingOnWindow];
                    }
                      requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                          [UIView showResultThenHideOnWindow:errorMessage afterDelay:1.5];
                      }];
    
    
//    [AFNManager postDataWithAPI:kResPathAppBondElectricBuy andDictParam:dic modelName:nil requestSuccessed:^(id responseObject) {
//        [UIView hideHUDLoadingOnWindow];
//    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
//        [UIView showResultThenHideOnWindow:errorMessage afterDelay:1.5];
//    }];
}
@end
