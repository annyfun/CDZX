//
//  ASHomeCollectionReusableView.h
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/28.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

@interface ASHomeCollectionViewCell : YSCBaseCollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *lineBottomLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineRightLabel;

@end
