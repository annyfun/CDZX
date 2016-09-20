//
//  MemberCell.h
//  HomeBridge
//
//  Created by keen on 14-7-14.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "BaseTableViewCell.h"

@class KButtonHead;

@protocol MemberCellDelegate <NSObject>

- (NSInteger)numberOfItemsInCell;
- (NSString*)titleOfItemAtIndex:(NSInteger)index;
- (UIImage*)imageNormalOfItemAtIndex:(NSInteger)index;
- (UIImage*)imageHighlightedOfItemAtIndex:(NSInteger)index;

- (BOOL)canEditItemAtIndex:(NSInteger)index;
- (BOOL)shouldHideItemAtIndex:(NSInteger)index;

- (void)memberCell:(id)sender didPressAtIndex:(NSInteger)index;

@end

@interface MemberCell : BaseTableViewCell

@property (nonatomic, assign) BOOL  editing;

+ (CGFloat)heightWithItemCount:(NSInteger)count;

- (void)updateImage:(UIImage*)img atIndex:(NSInteger)index;

@end
