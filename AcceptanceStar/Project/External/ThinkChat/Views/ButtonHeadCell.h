//
//  ButtonHeadCell.h
//  ThinkChatDemo
//
//  Created by keen on 14-8-25.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "SimpleHeadCell.h"

@protocol ButtonHeadDelegate <NSObject>

- (void)ButtonHeadCellDidPressedButton:(id)sender;

@end

@interface ButtonHeadCell : SimpleHeadCell {
    IBOutlet UIButton*  btnInCell;
}

@property (nonatomic, strong) NSString* titleButton;
@property (nonatomic, strong) UIImage*  bkgImage;

@end
