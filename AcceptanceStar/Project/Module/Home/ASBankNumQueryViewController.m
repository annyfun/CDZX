//
//  ASBankNumQueryViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/30.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASBankNumQueryViewController.h"
#import "YSCPickerView.h"
#import "AppDelegate.h"

@interface ASBankNumQueryViewController ()
@property (weak, nonatomic) IBOutlet UIView *bankView;
@property (weak, nonatomic) IBOutlet UILabel *bankNameLabel;
@property (weak, nonatomic) IBOutlet UIView *provinceView;
@property (weak, nonatomic) IBOutlet UILabel *provinceLabel;
@property (weak, nonatomic) IBOutlet UIView *cityView;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UITextField *keywordTextField;

@property (strong, nonatomic) YSCPickerView *yscPickerView;
@property (assign, nonatomic) NSInteger pickerIndex;
@property (weak, nonatomic) IBOutlet UIButton *queryButton;
@property (strong, nonatomic) NSMutableArray *bankArray;
@property (strong, nonatomic) NSMutableArray *bankModelArray;
@property (strong, nonatomic) NSMutableArray *provinceArray;
@property (strong, nonatomic) NSMutableArray *cityArray;
@end

@implementation ASBankNumQueryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"行号查询";
    self.bankArray = [NSMutableArray array];
    self.bankModelArray = [NSMutableArray array];
    [UIView makeRoundForView:self.queryButton withRadius:5];
    self.provinceArray = [NSMutableArray array];
    self.cityArray = [NSMutableArray array];
    for (ASProvinceModel *m in [AppDelegate instance].provinceArray) {
        [self.provinceArray addObject:m.State];
    }
    
    [self initPicerView];
    [self initBlocks];
    [self refreshBanck];
}
- (void)refreshBanck {
    WEAKSELF
    [self showHUDLoading:@"查询银行列表"];
    [AFNManager getDataWithAPI:kResPathAppBankList
                  andDictParam:nil
                     modelName:ClassOfObject(BankModel)
              requestSuccessed:^(id responseObject) {
                  [blockSelf hideHUDLoading];
                  NSArray *array = responseObject;
                  [blockSelf.bankModelArray removeAllObjects];
                  [blockSelf.bankModelArray addObjectsFromArray:array];
                  [blockSelf.bankArray removeAllObjects];
                  for (BankModel *model in array) {
                      [blockSelf.bankArray addObject:model.bankName];
                  }
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    [blockSelf showResultThenHide:errorMessage];
                }];
}
- (void)initPicerView {
    self.yscPickerView = [YSCPickerView CreateYSCPickerView];
    [self.yscPickerView setPickerType:YSCPickerTypeCustom];
    WEAKSELF
    self.yscPickerView.selectingBlock = ^(id selectingObject) {
        NSArray *indexArray = (NSArray *)selectingObject;
        NSInteger index = [indexArray[0] integerValue];
        if (1 == blockSelf.pickerIndex) {
            blockSelf.bankNameLabel.text = blockSelf.bankArray[index];
        }
        else if (2 == blockSelf.pickerIndex) {
            blockSelf.provinceLabel.text = blockSelf.provinceArray[index];
            blockSelf.cityLabel.text = @"请选择城市";
            //初始化city数组
            [blockSelf.cityArray removeAllObjects];
            ASProvinceModel *mp = [AppDelegate instance].provinceArray[index];
            for (ASCityModel *cm in mp.Cities) {
                [blockSelf.cityArray addObject:cm.city];
            }
        }
        else {
            blockSelf.cityLabel.text = blockSelf.cityArray[index];
        }
    };
    self.yscPickerView.completionShowBlock = ^{

    };
    self.yscPickerView.completionHideBlock = ^{

    };
}
- (void)initBlocks {
    WEAKSELF
    [self.bankView bk_whenTapped:^{
        [blockSelf hideKeyboard];
        blockSelf.pickerIndex = 1;
        blockSelf.yscPickerView.customDataArray = @[blockSelf.bankArray];
        if ([blockSelf.bankArray containsObject:blockSelf.bankNameLabel.text]) {
            [blockSelf.yscPickerView showPickerView:@[@([blockSelf.bankArray indexOfObject:blockSelf.bankNameLabel.text])]];
        }
        else {
            [blockSelf.yscPickerView showPickerView:@[@(0)]];
        }
    }];
    [self.provinceView bk_whenTapped:^{
        [blockSelf hideKeyboard];
        blockSelf.pickerIndex = 2;
        blockSelf.yscPickerView.customDataArray = @[blockSelf.provinceArray];
        if ([blockSelf.provinceArray containsObject:blockSelf.provinceLabel.text]) {
            [blockSelf.yscPickerView showPickerView:@[@([blockSelf.provinceArray indexOfObject:blockSelf.provinceLabel.text])]];
        }
        else {
            [blockSelf.yscPickerView showPickerView:@[@(0)]];
        }
    }];
    [self.cityView bk_whenTapped:^{
        [blockSelf hideKeyboard];
        blockSelf.pickerIndex = 3;
        if ([blockSelf.provinceArray containsObject:blockSelf.provinceLabel.text]) {
            blockSelf.yscPickerView.customDataArray = @[blockSelf.cityArray];
            if ([blockSelf.cityArray containsObject:blockSelf.cityLabel.text]) {
                [blockSelf.yscPickerView showPickerView:@[@([blockSelf.cityArray indexOfObject:blockSelf.cityLabel.text])]];
            }
            else {
                [blockSelf.yscPickerView showPickerView:@[@(0)]];
            }
        }
        else {
            [blockSelf showResultThenHide:@"请先选择省份"];
        }
    }];
}
- (IBAction)queryButtonClicked:(id)sender {
    NSString *bankName = Trim(self.bankNameLabel.text);
    if ([@"请选择" isEqualToString:bankName]) {
        bankName = @"";
    }
    NSString *province = Trim(self.provinceLabel.text);
    NSString *city = Trim(self.cityLabel.text);
    if ([@"请选择城市" isEqualToString:city]) {
        city = @"";
    }
    NSString *keyword = Trim(self.keywordTextField.text);
    if (isEmpty(bankName)) {
        [self showResultThenHide:@"请选择银行"];
        return;
    }
    if (isEmpty(city)) {
        [self showResultThenHide:@"请选择城市"];
        return;
    }
    
    [self pushViewController:@"ASBankQueryResultViewController"
                  withParams:@{kParamParams : @{kParamCity : city,
                                                kParamAddress : keyword,
                                                @"bank" : bankName
                                                }}];
}

@end
