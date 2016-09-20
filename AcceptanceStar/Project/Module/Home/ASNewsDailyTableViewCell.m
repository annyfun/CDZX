//
//  ASNewsDailyTableViewCell.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/30.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASNewsDailyTableViewCell.h"

@implementation ASNewsDailyTableViewCell

+ (CGFloat)HeightOfCell {
    return AUTOLAYOUT_LENGTH(130);
}

- (void)layoutDataModel:(PageIndexModel *)dataModel {
    self.titleLabel.text = dataModel.title;
    NSString *content = Trim(dataModel.content);
    content = [NSString replaceString:content byRegex:@"<([^>]*)>" to:@""];
    content = [NSString replaceString:content byRegex:@"&nbsp;" to:@""];
    self.summaryLabel.text = content;
    self.iconNewImageView.hidden =[[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"newsId_%@", dataModel.id]];   
}

@end
