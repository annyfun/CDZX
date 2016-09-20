//
//  BaseTableViewCell.h
//  Base
//
//  Created by keen on 13-10-19.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LayOutSubViewInCell)();

@interface BaseTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL hideLine;
@property (nonatomic, assign) id   delegate;
@property (nonatomic, strong) NSIndexPath * indexPath;
@property (nonatomic, assign) BOOL isGrouped;
@property (nonatomic, copy)   LayOutSubViewInCell   layOutBlock;

+ (CGFloat)heightWithItem:(id)item;

- (void)initialiseCell;
- (void)setSeparatorLastOne:(BOOL)lastOne leftInset:(CGFloat)left;
- (void)update:(LayOutSubViewInCell)block;

@end
