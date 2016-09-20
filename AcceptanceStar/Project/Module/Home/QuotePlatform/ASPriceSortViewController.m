//
//  ASPriceSortViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/6/7.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASPriceSortViewController.h"
#import "ASPriceSortCell.h"
#import "YSCPickerView.h"

typedef NS_ENUM(NSInteger, SortItemType) {
    SortItemTypeAddress = 0,
    SortItemTypeCustomPicker,
    SortItemTypeAlertValue,
    SortItemTypeDateTime
};

@interface SortItemModel : BaseDataModel
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, assign) SortItemType type;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) NSInteger cid;
+ (instancetype)CreateByTitle:(NSString *)title value:(NSString *)value array:(NSArray *)array type:(SortItemType)type key:(NSString *)key;
- (NSDictionary *)builderParams;
@end
@implementation SortItemModel
+ (instancetype)CreateByTitle:(NSString *)title value:(NSString *)value array:(NSArray *)array type:(SortItemType)type key:(NSString *)key {
    SortItemModel *model = [SortItemModel new];
    model.title = title;
    model.value = value;
    model.array = array;
    model.type = type;
    model.key = key;
    return model;
}
- (NSDictionary *)builderParams {
    if (SortItemTypeAddress == self.type) {
        return @{self.key : @(self.cid)};
    }
    else if (SortItemTypeCustomPicker == self.type) {
        if ([self.array containsObject:self.value]) {
            NSInteger index = [self.array indexOfObject:self.value];
            if ([@"发布时间" isEqualToString:self.title]) {
                if (1 == index) {
                    index = 0;
                }
                else if (2 == index) {
                    index = 3;
                }
                else if (3 == index) {
                    index = 7;
                }
                else if (4 == index) {
                    index = 30;
                }
                return @{self.key : @(index)};
            }
            else if ([@"票面金额" isEqualToString:self.title]) {
                if (1 == index) {
                    return @{self.key : @"500-"};
                }
                else if(2 == index) {
                    return @{self.key : @"0-500"};
                }
            }
            else if ([@"报价利率" isEqualToString:self.title]) {
                if (1 == index) {
                    return @{self.key : @"0-4"};
                }
                else if(2 == index) {
                    return @{self.key : @"4-4.4"};
                }
                else if (3 == index) {
                    return @{self.key : @"4.5-5"};
                }
                else if(4 == index) {
                    return @{self.key : @"5-"};
                }
            }
            else {
                return @{self.key : @(index)};
            }
        }
    }
    else if (SortItemTypeAlertValue == self.type) {
        if ([self.value floatValue] > 0) {
            return @{self.key : self.value};
        }
    }
    else if (SortItemTypeDateTime == self.type) {
        return @{self.key : self.value};
    }
    return @{};
}
@end

@interface ASPriceSortViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) PriceType priceType;

@property (nonatomic, strong) YSCPickerView *yscPickerView;
@property (assign, nonatomic) NSInteger selectIndex;
@property (nonatomic, strong) RegionModel *selectRegion;
@property (nonatomic, strong) NSDate *selectDate;

//数据源
@property (nonatomic, strong) NSArray *ticketPropertyArray;//票据属性
@property (nonatomic, strong) NSArray *bankTypeArray;//承兑行类型
@property (nonatomic, strong) NSArray *directionArray;//方向
@property (nonatomic, strong) NSArray *typeArray;//类型

@property (nonatomic, strong) NSArray *priceArray;
@property (nonatomic, strong) NSArray *rateArray;
@property (nonatomic, strong) NSArray *dateArray;

@end

@implementation ASPriceSortViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initPicerView];
    [self initArrayData];
    self.dataArray = [NSMutableArray array];
    self.priceType = [self.params[kParamPriceType] integerValue];
    
    [self.tableView registerNib:[ASPriceSortCell NibNameOfCell] forCellReuseIdentifier:kCellIdentifier];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.submitButton makeRoundWithRadius:5];
}
- (void)initArrayData {
    self.ticketPropertyArray = @[@"不限",@"纸银",@"电银",@"纸商",@"电商"];//@[@"纸质票",@"电子票"];//属性
    self.bankTypeArray = @[@"不限",@"国股",@"大商",@"小商",@"其他"];//承兑行类型
    self.directionArray = @[@"不限",@"买入", @"卖出"];//方向
    self.typeArray = @[@"不限",@"纸银国股",@"纸银大商",@"纸银小商",@"纸银其他",@"电银国股",@"电银大商",@"电银小商",@"电银其他",@"商业汇票"];
    
    self.priceArray = @[@"不限",@"大票(>=500万)",@"小票(<=500万)"];
    self.rateArray = @[@"不限",@"利率<=4‰",@"4‰<利率<=4.5‰",@"4.5‰<利率<5‰",@"利率>=5‰"];
    self.dateArray = @[@"不限",@"今天",@"最近3天",@"最近7天",@"最近30天"];
}
- (void)initPicerView {
    self.yscPickerView = [YSCPickerView CreateYSCPickerView];
    WEAKSELF
    self.yscPickerView.selectingBlock = ^(id selectingObject) {
        SortItemModel *item = blockSelf.dataArray[blockSelf.selectIndex];
        if ([selectingObject isKindOfClass:[NSArray class]]) {
            NSArray *indexArray = (NSArray *)selectingObject;
            NSInteger index = [indexArray[0] integerValue];
            item.value = item.array[index];
        }
        else if ([selectingObject isKindOfClass:[NSDate class]]) {
            blockSelf.selectDate = selectingObject;
            item.value = [blockSelf.selectDate stringWithFormat:DateFormat1];
        }
        else if ([selectingObject isKindOfClass:[RegionModel class]]) {
            blockSelf.selectRegion = selectingObject;
            item.value = blockSelf.selectRegion.city;
            item.cid = blockSelf.selectRegion.cid;
        }
        [blockSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:blockSelf.selectIndex inSection:0]]
                                   withRowAnimation:UITableViewRowAnimationNone];
    };
    self.yscPickerView.completionShowBlock = ^{
    };
    self.yscPickerView.completionHideBlock = ^{
    };
}
- (void)setPriceType:(PriceType)priceType {
    _priceType = priceType;
    if (PriceTypeBuy == priceType) {
        self.title = @"买票信息筛选";
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"区域" value:@"不限" array:@[] type:SortItemTypeAddress key:@"city"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"票据属性" value:@"不限" array:self.ticketPropertyArray type:SortItemTypeCustomPicker key:@"attr"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"承兑行类型" value:@"不限" array:self.bankTypeArray type:SortItemTypeCustomPicker key:@"class"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"票面金额" value:@"不限" array:self.priceArray type:SortItemTypeCustomPicker key:@"price"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"报价利率" value:@"不限" array:self.rateArray type:SortItemTypeCustomPicker key:@"rate"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"发布时间" value:@"不限" array:self.dateArray type:SortItemTypeCustomPicker key:@"date"]];
    }
    else if (PriceTypeSell == priceType) {
        self.title = @"卖票信息筛选";
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"区域" value:@"不限" array:@[] type:SortItemTypeAddress key:@"city"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"票据属性" value:@"不限" array:self.ticketPropertyArray type:SortItemTypeCustomPicker key:@"attr"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"承兑行类型" value:@"不限" array:self.bankTypeArray type:SortItemTypeCustomPicker key:@"class"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"票面金额" value:@"不限" array:self.priceArray type:SortItemTypeCustomPicker key:@"price"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"发布时间" value:@"不限" array:self.dateArray type:SortItemTypeCustomPicker key:@"date"]];
    }
    else if (PriceTypeQuotePrice == priceType) {
        self.title = @"机构报价信息筛选";
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"区域" value:@"不限" array:@[] type:SortItemTypeAddress key:@"city"]];
//        [self.dataArray addObject:[SortItemModel CreateByTitle:@"国股" value:@"不限" array:@[] type:SortItemTypeAlertValue key:@"gg_r"]];
//        [self.dataArray addObject:[SortItemModel CreateByTitle:@"大商" value:@"不限" array:@[] type:SortItemTypeAlertValue key:@"ds_r"]];
//        [self.dataArray addObject:[SortItemModel CreateByTitle:@"小商" value:@"不限" array:@[] type:SortItemTypeAlertValue key:@"xs_r"]];
//        [self.dataArray addObject:[SortItemModel CreateByTitle:@"其他" value:@"不限" array:@[] type:SortItemTypeAlertValue key:@"qt_r"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"票据属性" value:@"不限" array:self.ticketPropertyArray type:SortItemTypeCustomPicker key:@"attr"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"发布时间" value:@"不限" array:self.dateArray type:SortItemTypeCustomPicker key:@"date"]];
    }
    else if (PriceTypeReSale == priceType) {
        self.title = @"转贴信息筛选";
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"区域" value:@"不限" array:@[] type:SortItemTypeAddress key:@"city"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"方向" value:@"不限" array:self.directionArray type:SortItemTypeCustomPicker key:@"action"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"票据属性" value:@"不限" array:self.ticketPropertyArray type:SortItemTypeCustomPicker key:@"attr"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"税行类型" value:@"不限" array:self.typeArray type:SortItemTypeCustomPicker key:@"kind"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"票面金额" value:@"不限" array:self.priceArray type:SortItemTypeCustomPicker key:@"price"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"发布时间" value:@"不限" array:self.dateArray type:SortItemTypeCustomPicker key:@"date"]];
    }
    else if (PriceTypeRePurchase == priceType) {
        self.title = @"回购信息筛选";
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"区域" value:@"不限" array:@[] type:SortItemTypeAddress key:@"city"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"方向" value:@"不限" array:self.directionArray type:SortItemTypeCustomPicker key:@"action"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"票据属性" value:@"不限" array:self.ticketPropertyArray type:SortItemTypeCustomPicker key:@"attr"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"税行类型" value:@"不限" array:self.typeArray type:SortItemTypeCustomPicker key:@"kind"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"票面金额" value:@"不限" array:self.priceArray type:SortItemTypeCustomPicker key:@"price"]];
        [self.dataArray addObject:[SortItemModel CreateByTitle:@"发布时间" value:@"不限" array:self.dateArray type:SortItemTypeCustomPicker key:@"date"]];
    }
}

- (IBAction)submitButtonClicked:(id)sender {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    for (SortItemModel *item in self.dataArray) {
        [params addEntriesFromDictionary:[item builderParams]];
    }
    [LOGIN resetSortParams:params];
    if (PriceTypeBuy == self.priceType) {
        postN(kNotificationRefreshBuyList);
    }
    else if (PriceTypeSell == self.priceType) {
        postN(kNotificationRefreshSellList);
    }
    else if (PriceTypeQuotePrice == self.priceType) {
        postN(kNotificationRefreshQuotePriceList);
    }
    else if (PriceTypeReSale == self.priceType) {
        postN(kNotificationRefreshReSaleList);
    }
    else if (PriceTypeRePurchase == self.priceType) {
        postN(kNotificationRefreshRePurchaseList);
    }
    [self backViewController];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AUTOLAYOUT_LENGTH(90);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASPriceSortCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    SortItemModel *item = self.dataArray[indexPath.row];
    cell.leftLabel.text = item.title;
    cell.rightLabel.text = item.value;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectIndex = indexPath.row;
    SortItemModel *item = self.dataArray[self.selectIndex];
    if (SortItemTypeCustomPicker == item.type) {
        self.yscPickerView.customDataArray = @[item.array];
        [self.yscPickerView setPickerType:YSCPickerTypeCustom];
        if ([item.array containsObject:item.value]) {
            [self.yscPickerView showPickerView:@[@([item.array indexOfObject:item.value])]];
        }
        else {
            [self.yscPickerView showPickerView:@[@(0)]];
        }
    }
    else if (SortItemTypeAddress == item.type) {
        WEAKSELF
        YSCObjectResultBlock block = ^(NSObject *object, NSError *error) {
            ASCityModel *city = (ASCityModel *)object;
            item.cid = city.id;
            item.value = city.city;
            [tableView reloadData];
        };
        
        [blockSelf pushViewController:@"ASCitySelectionViewController"
                           withParams:@{kParamBlock : block,
                                        kParamIndex : @(item.cid)}];
    }
    else if (SortItemTypeAlertValue == item.type) {
        WEAKSELF
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:[NSString stringWithFormat:@"请输入 %@", item.title]];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.text = [NSString stringWithFormat:@"%.2f", [item.value floatValue]];
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        [alertView bk_addButtonWithTitle:@"确定" handler:^{
            item.value = Trim(textField.text);
            [blockSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [alertView show];
    }
    else if (SortItemTypeDateTime == item.type) {
        [self.yscPickerView setPickerType:YSCPickerTypeDateTime];
        [self.yscPickerView showPickerView:self.selectDate];
    }
}

@end
