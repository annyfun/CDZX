//
//  ASSearchEViewController.m
//  AcceptanceStar
//
//  Created by Jinjin on 2016/11/24.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "ASSearchEViewController.h"
#import "ASSearchECell.h"

@interface ASSearchEViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataSource;

@property (strong, nonatomic) NSDictionary *rateData;
@property (strong, nonatomic) NSDictionary *amountData;

@property (nonatomic,strong) NSString *rateKey;
@property (nonatomic,strong) NSString *amountKey;
@property (nonatomic,strong) NSString *daysKey;
@end

@implementation ASSearchEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"筛选";
    self.amountData = @{@"500万以上":@"500-",
                      @"500万以下":@"0-500",
                      };
    
    self.rateData = @{@"一类行利率从低到高":@"rt_1",
                      @"二类行利率从低到高":@"rt_2",
                      @"三类行利率从低到高":@"rt_3",
                      @"四类行利率从低到高":@"rt_4"};
    
    self.rateKey = self.params[@"ASRate"];
    self.amountKey = self.params[@"ASAmount"];
    self.daysKey = self.params[@"ASDays"];
    
    self.dataSource = [NSMutableArray array];
    [self.dataSource addObject:@[@"利率",[self rateValueToKey:self.rateKey]]];
    [self.dataSource addObject:@[@"金额",[self amountValueToKey:self.amountKey]]];
    [self.dataSource addObject:@[@"期限",self.daysKey?:@"0"]];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    self.tableView.backgroundColor = RGB(235, 235, 235);
    [self.tableView registerNib:[UINib nibWithNibName:@"ASSearchECell" bundle:nil] forCellReuseIdentifier:@"ASSearchECell"];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)suerBtnDidTap:(id)sender {

    void (^action)(NSString *rate,NSString *amount,NSString *days) = self.params[@"actionBlock"];
    if (action) {
        action(self.rateKey,self.amountKey,self.daysKey);
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSArray *data = self.dataSource[indexPath.row];
    ASSearchECell *cell = (ASSearchECell *)[tableView dequeueReusableCellWithIdentifier:@"ASSearchECell"];
    cell.backgroundColor = [UIColor whiteColor];
    cell.leftLabel.text = data[0];
    cell.rightLabel.text = data[1];
    
    BOOL dontShowInput = indexPath.row<2;
    
    cell.inputView.hidden = dontShowInput;
    cell.textChange = NULL;
    cell.selectionStyle = dontShowInput?UITableViewCellSelectionStyleGray:UITableViewCellSelectionStyleNone;
    cell.accessoryType = dontShowInput?UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;
    if (indexPath.row==2) {
        
        WEAKSELF
        cell.textChange = ^(NSString *new){
            
            blockSelf.daysKey = new;
            [blockSelf.dataSource replaceObjectAtIndex:2 withObject:@[@"期限",new?:@"0"]];
        };
        cell.rightLabel.text = nil;
        cell.inputField.text = [data[1] isEqualToString:@"0"]?nil:data[1];
        cell.inputField.placeholder = @"0";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WEAKSELF
    if (indexPath.row==0) {
        
        UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:@"利率"];
        [sheet bk_addButtonWithTitle:@"不限" handler:^{
            blockSelf.rateKey = nil;
            [blockSelf.dataSource replaceObjectAtIndex:0 withObject:@[@"利率",[blockSelf rateValueToKey:blockSelf.rateKey]]];
            [blockSelf.tableView reloadData];
        }];
        
        NSArray *keys = @[@"一类行利率从低到高",
                          @"二类行利率从低到高",
                          @"三类行利率从低到高",
                          @"四类行利率从低到高"];
        for (NSString *key in keys) {
         
            [sheet bk_addButtonWithTitle:key handler:^{
                
                blockSelf.rateKey = key;
                [blockSelf.dataSource replaceObjectAtIndex:0 withObject:@[@"利率",[blockSelf rateValueToKey:blockSelf.rateKey]]];
                [blockSelf.tableView reloadData];
            }];
        }
        
        [sheet bk_setCancelButtonWithTitle:@"取消" handler:NULL];
        [sheet showInView:self.view];
    }
    if (indexPath.row==1) {
        UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:@"金额"];
        [sheet bk_addButtonWithTitle:@"不限" handler:^{
            blockSelf.amountKey = nil;
            [blockSelf.dataSource replaceObjectAtIndex:1 withObject:@[@"金额",[blockSelf amountValueToKey:blockSelf.amountKey]]];
            [blockSelf.tableView reloadData];
        }];
        [self.amountData enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [sheet bk_addButtonWithTitle:key handler:^{
               
                blockSelf.amountKey = obj;
                [blockSelf.dataSource replaceObjectAtIndex:1 withObject:@[@"金额",[blockSelf amountValueToKey:blockSelf.amountKey]]];
                [blockSelf.tableView reloadData];
            }];
        }];
        [sheet bk_setCancelButtonWithTitle:@"取消" handler:NULL];
        [sheet showInView:self.view];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self.view endEditing:YES];
}


- (NSString *)rateValueToKey:(NSString *)value{
    
   __block NSString *ckey = @"不限";
    [self.rateData enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([value isEqualToString:obj]) {
            ckey = key;
            *stop = YES;
        }
    }];
    return ckey;
}

- (NSString *)amountValueToKey:(NSString *)value{
    
    __block NSString *ckey = @"不限";
    [self.amountData enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([value isEqualToString:obj]) {
            ckey = key;
            *stop = YES;
        }
    }];
    return ckey;
}
#pragma mark - Overwrite
- (BOOL)resetAutolayout{
    return NO;
}
@end
