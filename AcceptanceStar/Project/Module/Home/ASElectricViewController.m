//
//  ASElectricViewController.m
//  AcceptanceStar
//
//  Created by Jinjin on 2016/11/22.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "ASElectricViewController.h"
#import "YSCTableViewCell.h"
#import "ASElectricCell.h"
#import "UITableView+FDTemplateLayoutCell.h"

@interface ASElectricViewController ()
@property (weak, nonatomic) IBOutlet UIView *otherView;
@property (weak, nonatomic) IBOutlet UIView *myView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *dataSource;
@end

@implementation ASElectricViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ASElectricCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
 
    
    ElectricModel *model = self.params[kParamModel];
    self.dataSource = [NSMutableArray array];
    
    ;
    
    
    [self.dataSource addObject:@[@"发布机构",model.company?:@""]];
    [self.dataSource addObject:@[@"单张票面",[NSString stringWithFormat:@"%@万元起",model.price?:@""]]];
    [self.dataSource addObject:@[@"期限",[NSString stringWithFormat:@"%zd天起",model.days]]];
    [self.dataSource addObject:@[@"一类银行",[NSString stringWithFormat:@"月利率%@%%",model.rt_1?:@""]]];
    [self.dataSource addObject:@[@"二类银行",[NSString stringWithFormat:@"月利率%@%%",model.rt_2?:@""]]];
    [self.dataSource addObject:@[@"三类银行",[NSString stringWithFormat:@"月利率%@%%",model.rt_3?:@""]]];
    [self.dataSource addObject:@[@"四类银行",[NSString stringWithFormat:@"月利率%@%%",model.rt_4?:@""]]];
    [self.dataSource addObject:@[@"发布时间",[model.date stringWithFormat:@"yyyy-MM-dd hh:mm"]]];
    [self.dataSource addObject:@[@"备注信息",@"这里填什么字段？这里填什么字段？这里填什么字段？这里填什么字段？这里填什么字段？"]];
    [self.dataSource addObject:@[@"银行简介",@"这里填什么字段？这里填什么字段？这里填什么字段？这里填什么字段？这里填什么字段？"]];
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
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [tableView fd_heightForCellWithIdentifier:kCellIdentifier
                                    cacheByIndexPath:indexPath
                                       configuration:^(ASElectricCell *cell) {
                                           
                                           NSArray *data = self.dataSource[indexPath.row];
                                           cell.leftLabel.text = data[0];
                                           cell.rightLabel.text = nil;
                                           cell.detailLabel.text = nil;
                                           if (indexPath.row<8) {
                                               cell.rightLabel.text = data[1];
                                           }else{
                                               cell.detailLabel.text = data[1];
                                           }
                                           
                                       }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSArray *data = self.dataSource[indexPath.row];
    ASElectricCell *cell = (ASElectricCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.leftLabel.text = data[0];
    cell.rightLabel.text = nil;
    cell.detailLabel.text = nil;
    if (indexPath.row<8) {
        cell.rightLabel.text = data[1];
    }else{
        cell.detailLabel.text = data[1]?[NSString stringWithFormat:@"%@\n",data[1]]:nil;
    }
    return cell;
}


#pragma mark - Event Methods
- (IBAction)shenQingDidTap:(id)sender {
}


#pragma mark - Overwrite
- (BOOL)resetAutolayout{
    return NO;
}

@end
