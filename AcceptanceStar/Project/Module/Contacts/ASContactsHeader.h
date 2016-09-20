//
//  ASContactsHeader.h
//  AcceptanceStar
//
//  Created by yangshengchao on 15/9/4.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASContactsHeader : YSCBaseTableHeaderFooterView

@property (nonatomic, weak) IBOutlet UIImageView *arrowImageView;
@property (nonatomic, weak) IBOutlet UILabel *groupNameLabel;
@property (nonatomic, weak) IBOutlet UIView *markView;
@property (nonatomic, weak) IBOutlet UIImageView *markImageView;

- (void)resetSelected:(BOOL)selected;

@end
