//
//  ASJiaoYiDatingCell.m
//  AcceptanceStar
//
//  Created by Jinjin on 2016/11/22.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "ASJiaoYiDatingCell.h"
#import "ASJiaoYiDatingItemView.h"

@implementation ASJiaoYiDatingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSeparatorStyleNone;
    
    [self.itemView1 addSubview:self.view1];
    [self.itemView2 addSubview:self.view2];
    
    [self.view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.itemView1);
    }];
    [self.view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.itemView2);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self.contentView addGestureRecognizer:tap];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didTap:(UITapGestureRecognizer *)sender {
    
    CGPoint loc = [sender locationInView:self.contentView];
    
    if (CGRectContainsPoint(self.itemView1.frame, loc)) {
        if (self.didTap) {
            self.didTap(self.tag*2);
        }
    }
    else if (CGRectContainsPoint(self.itemView2.frame, loc)) {
        if (self.didTap) {
            self.didTap(self.tag*2+1);
        }
    }
}


- (void)loadData:(NSArray *)array{
    
    self.itemView1.hidden = YES;
    self.itemView2.hidden = YES;
    
    if (array.count>0) {
        self.itemView1.hidden = NO;
        [self.view1 loadData:array[0]];
    }
    
    if (array.count>1) {
        self.itemView2.hidden = NO;
        [self.view2 loadData:array[1]];
    }
}

- (ASJiaoYiDatingItemView *)view1{
    if (_view1==nil) {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ASJiaoYiDatingItemView class])
                                                          owner:self
                                                        options:nil];
        
        _view1 = [ nibViews objectAtIndex:0];
    }
    
    return _view1;
}

- (ASJiaoYiDatingItemView *)view2{
    if (_view2==nil) {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ASJiaoYiDatingItemView class])
                                                          owner:self
                                                        options:nil];
        
        _view2 = [ nibViews objectAtIndex:0];
    }
    
    return _view2;
}
@end
