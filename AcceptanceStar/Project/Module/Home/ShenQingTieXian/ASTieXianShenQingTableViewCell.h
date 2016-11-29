//
//  ASTieXianShenQingTableViewCell.h
//  AcceptanceStar
//
//  Created by lcyu on 2016/11/24.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASTieXianShenQingTableViewCell : UITableViewCell
@property (nonatomic, strong) TieXianModel *tieXianModel;

- (void)bindReciveE:(TieXianModel *)model;
@end
