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
#import <UIView+FDCollapsibleConstraints.h>
typedef NS_ENUM(NSInteger, OperateType)
{
    OperateTypeEdit,
    OperateTypeShow
};

@interface ASShenQingTieXianViewController ()<UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ZYQAssetPickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) NSIndexPath *selectDateIndexPath;
@property (nonatomic, strong) TieXianModel *tieXianModel;
@property (nonatomic, strong) NSMutableDictionary *imageDic;
@property (nonatomic, assign) OperateType operateType;
@property (nonatomic, assign) TieXianType tieXianType;
@end

@implementation ASShenQingTieXianViewController

-(id)initWithTieXianModel:(TieXianModel *)model tieXianType:(TieXianType)tieXianType;
{
    if (self = [super initWithNibName:NSStringFromClass([ASShenQingTieXianViewController class]) bundle:nil]) {
        self.tieXianModel = model;
        self.operateType = OperateTypeShow;
        self.tieXianType = tieXianType;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ASPiaoJuTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ASPiaoJuTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ASInfoTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ASInfoTableViewCell class])];
    self.centerView.fd_collapsed = YES;
    if (self.operateType == OperateTypeEdit) {
        [self.dataArray addObject:[PaperModel new]];
    }
    else{
        self.bottomView.fd_collapsed = YES;
        [self requestDetailData];
        if (self.tieXianType == TieXianTypeReceivedApply) {
            self.tableView.allowsMultipleSelection = YES;
            self.centerView.fd_collapsed = NO;
        }
    }
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
        cell.userInteractionEnabled = self.operateType == OperateTypeEdit;
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
        cell.addView.hidden = self.operateType == OperateTypeEdit ?  (indexPath.section < self.dataArray.count - 1) : YES;
        cell.contentView.userInteractionEnabled = self.operateType == OperateTypeEdit;
        cell.selectionStyle = self.tieXianType == TieXianTypeReceivedApply ? UITableViewCellSelectionStyleGray: UITableViewCellSelectionStyleNone;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PaperModel *paperModel = self.dataArray[indexPath.section];
    paperModel.selected = YES;
    self.tieXianModel.totalPrice += paperModel.price;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:self.dataArray.count]] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PaperModel *paperModel = self.dataArray[indexPath.section];
    paperModel.selected = NO;
    self.tieXianModel.totalPrice -= paperModel.price;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:self.dataArray.count]] withRowAnimation:UITableViewRowAnimationNone];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.operateType == OperateTypeEdit ? (indexPath.section < self.dataArray.count - 1 ? 233: 277) : 233;
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
        self.operateType = OperateTypeEdit;
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

- (IBAction)passClick:(id)sender {
    [self requestDataWithPassOrNo:YES comment:nil idString:self.selectedIds];
}

- (IBAction)noPassClick:(id)sender {
    WeakSelfType ws = self;
    UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"未通过审核理由" message:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert bk_setCancelButtonWithTitle:@"取消" handler:^{
        
    }];
    [alert bk_addButtonWithTitle:@"拒绝申请" handler:^{
        UITextField *tf=[alert textFieldAtIndex:0];
        
        [ws requestDataWithPassOrNo:NO comment:tf.text idString:ws.selectedIds];
    }];
    [alert show];
}

-(NSString *)selectedIds
{
    __block NSString *str = @"";
    [self.dataArray enumerateObjectsUsingBlock:^(PaperModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.selected) {
            str = [str stringByAppendingFormat:@"%@,", obj.id];
        }
    }];
    return str;
}

-(void)requestDataWithPassOrNo:(bool)passOrNo comment:(NSString *)comment idString:(NSString *)idString{
    if ([idString isEqualToString:@""]) {
        UIAlertView *tips = [[UIAlertView alloc] initWithTitle:@"未选择操作数据。" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [tips show];
        return;
    }
    
    //贴现申请ID列表：id以,分隔
    //通过 或 不通过
    [UIView showHUDLoadingOnWindow:@"处理中"];
    
    NSString *status = passOrNo?@"2":@"3";
    WeakSelfType blockSelf = self;
    [AFNManager getDataWithAPI:[@"/bond/bondorder_set/token" stringByAppendingPathComponent:TOKEN]
                  andDictParam:@{@"type":@"electric",
                                 @"status":status,
                                 @"comment":comment?:@" ",
                                 @"id":idString}
                     modelName:ClassOfObject(PaperModel)
              requestSuccessed:^(ElectricModel *responseObject) {
                  if (passOrNo) {
                      UIAlertView *success = [[UIAlertView alloc] initWithTitle:@"贴现申请已通过审核，请尽快联系企业完成贴现。" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
                      [success show];
                  }else{
                      [UIView showResultThenHideOnWindow:@"已拒绝申请" afterDelay:1.5];
                  }
                  [blockSelf requestDetailData];
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    
                    [UIView showResultThenHideOnWindow:errorMessage?:@"网络错误" afterDelay:1.5];
                }];
}

-(void)requestDetailData
{
    
    NSString *tieXianModelId = self.tieXianModel.orderNo?:@"";
    
    WeakSelfType blockSelf = self;
    [UIView showHUDLoadingOnWindow:@"加载中"];
    
    [AFNManager getDataWithAPI:[@"/bond/bondorder_buy_detail/token" stringByAppendingPathComponent:TOKEN]
                  andDictParam:@{@"order_no":tieXianModelId}
                     modelName:ClassOfObject(PaperModel)
              requestSuccessed:^(ElectricModel *responseObject) {
                  [UIView hideHUDLoadingOnWindow];
                  
                  if ([responseObject isKindOfClass:[NSArray class]]) {
                      
                      blockSelf.dataArray = [responseObject mutableCopy];
                  }
//                  self.tieXianModel.totalPrice = 0;
//                  [self.dataArray enumerateObjectsUsingBlock:^(PaperModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                      self.tieXianModel.totalPrice += obj.price;
//                  }];
                  [blockSelf.tableView reloadData];
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    
                    [UIView showResultThenHideOnWindow:errorMessage afterDelay:1.5];
                }];
}

-(void)requestData
{
    NSMutableArray *paperArray = [NSMutableArray array];
    [self.dataArray enumerateObjectsUsingBlock:^(PaperModel *  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        [paperArray addObject:[model toDictionary]];
    }];
    self.tieXianModel.list = paperArray;
    self.tieXianModel.id = self.electricId;
    
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
                        [UIView showResultThenHideOnWindow:@"申请成功" afterDelay:1.5];
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
