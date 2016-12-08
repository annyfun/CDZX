//
//  ASJiaoYiDatingItemView.m
//  AcceptanceStar
//
//  Created by Jinjin on 2016/11/22.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "ASJiaoYiDatingItemView.h"

@implementation ASJiaoYiDatingItemView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)loadData:(ElectricModel *)model{

    self.countLabel.layer.cornerRadius = 10;
    self.countLabel.clipsToBounds = YES;
    self.countLabel.text = [NSString stringWithFormat:@"%zd",model.buy_num];
    self.countLabel.hidden = model.buy_num==0;
    
    self.categoryLabel.text = [NSString stringWithFormat:@"%zd类",model.rt];
    self.categoryLabel.hidden = model.rt<=0;
    
    [self.headImageView setImageWithURLString:model.pic];
    self.titleLabel.text = model.company;
    
    NSString *public = [NSString stringWithFormat:@"%@上传",[self distanceTimeWithBeforeTime:model.date]];
    NSString *type = model.itype;
    NSString *price = [NSString stringWithFormat:@"%@万起",model.price];
    NSString *date = [NSString stringWithFormat:@"期限%zd天起",model.days];
    
    self.rat1.text = [NSString stringWithFormat:@"一类利率%@%%",model.rt_1];
    self.rat2.text = [NSString stringWithFormat:@"二类利率%@%%",model.rt_2];
    self.rat3.text = [NSString stringWithFormat:@"三类利率%@%%",model.rt_3];
    self.rat4.text = [NSString stringWithFormat:@"四类利率%@%%",model.rt_4];
    
    NSString *string = [NSString stringWithFormat:@"%@ | %@\n%@ | %@",public,type,price,date];
    self.infoLabel.text = string;
}

- (NSString *)distanceTimeWithBeforeTime:(NSDate *)beTime{
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    double distanceTime = now - [beTime timeIntervalSince1970];
    NSString * distanceStr;
    
    NSDate * beDate = beTime;
    NSDateFormatter * df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"HH:mm"];
    NSString * timeStr = [df stringFromDate:beDate];
    
    [df setDateFormat:@"dd"];
    NSString * nowDay = [df stringFromDate:[NSDate date]];
    NSString * lastDay = [df stringFromDate:beDate];
    
    if (distanceTime < 60) {//小于一分钟
        distanceStr = @"刚刚";
    }
    else if (distanceTime <60*60) {//时间小于一个小时
        distanceStr = [NSString stringWithFormat:@"%ld分钟前",(long)distanceTime/60];
    }
    else if(distanceTime <24*60*60 && [nowDay integerValue] == [lastDay integerValue]){//时间小于一天
        distanceStr = [NSString stringWithFormat:@"今天 %@",timeStr];
    }
    else if(distanceTime<24*60*60*2 && [nowDay integerValue] != [lastDay integerValue]){
        
        if ([nowDay integerValue] - [lastDay integerValue] ==1 || ([lastDay integerValue] - [nowDay integerValue] > 10 && [nowDay integerValue] == 1)) {
            distanceStr = [NSString stringWithFormat:@"昨天 %@",timeStr];
        }
        else{
            [df setDateFormat:@"MM-dd HH:mm"];
            distanceStr = [df stringFromDate:beDate];
        }
        
    }
    else if(distanceTime <24*60*60*365){
        [df setDateFormat:@"MM-dd HH:mm"];
        distanceStr = [df stringFromDate:beDate];
    }
    else{
        [df setDateFormat:@"yyyy-MM-dd HH:mm"];
        distanceStr = [df stringFromDate:beDate];
    }
    return distanceStr;
}


@end
