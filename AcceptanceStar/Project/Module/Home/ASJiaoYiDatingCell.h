//
//  ASJiaoYiDatingCell.h
//  AcceptanceStar
//
//  Created by Jinjin on 2016/11/22.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASJiaoYiDatingItemView.h"

typedef void(^DidTapItemAtIndex)(NSInteger index);

@interface ASJiaoYiDatingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *itemView1;
@property (weak, nonatomic) IBOutlet UIView *itemView2;


@property (copy, nonatomic) DidTapItemAtIndex didTap;

@property (strong,nonatomic) ASJiaoYiDatingItemView *view1;
@property (strong,nonatomic) ASJiaoYiDatingItemView *view2;

- (void)loadData:(NSArray *)array;
@end
