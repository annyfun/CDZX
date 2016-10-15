//
//  SimpleHeadCell.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-11.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "BaseHeadCell.h"

@interface SimpleHeadCell : BaseHeadCell {
    IBOutlet UILabel* labTitle;
    IBOutlet UILabel* labNumber;
    IBOutlet UILabel* labDetail;
}


@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* number;
@property (nonatomic, strong) NSString* detail;

@end
