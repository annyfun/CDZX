//
//  BaseHeadCell.h
//  Base
//
//  Created by keen on 13-11-5.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import "BaseTableViewCell.h"

@protocol BaseHeadCellDelegate <NSObject>

- (void)baseHeadCellDidTapHeader:(id)sender;

@end

@interface BaseHeadCell : BaseTableViewCell {
    IBOutlet UIImageView* imgViewHead;
}

@property (nonatomic, strong) UIImage *     imgHead;
@property (nonatomic, assign) NSInteger     cornerRadius;

@end
