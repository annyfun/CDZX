//
//  ASJiaoYiDatingItemView.h
//  AcceptanceStar
//
//  Created by Jinjin on 2016/11/22.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASJiaoYiDatingItemView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *rat1;
@property (weak, nonatomic) IBOutlet UILabel *rat2;
@property (weak, nonatomic) IBOutlet UILabel *rat3;
@property (weak, nonatomic) IBOutlet UILabel *rat4;

- (void)loadData:(ElectricModel *)model;
@end
