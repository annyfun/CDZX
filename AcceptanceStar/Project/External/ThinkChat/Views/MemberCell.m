//
//  MemberCell.m
//  HomeBridge
//
//  Created by keen on 14-7-14.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "MemberCell.h"
#import "KButtonHead.h"
#import "User.h"

#define kMemberCellOffSetX 10
#define kMemberCellOffSetY 10

#define kMemberCellSizeWidth 75
#define kMemberCellSizeHeight 75

#define kMemberCellOffSetRow 5

@interface MemberCell () {
    NSMutableArray* contentArr;
}

@end

@implementation MemberCell

@synthesize editing;

+ (CGFloat)heightWithItemCount:(NSInteger)count {
    CGFloat cellHeight = kMemberCellSizeHeight + kMemberCellOffSetY * 2;
    cellHeight += (count - 1) / 4 * (kMemberCellSizeHeight + kMemberCellOffSetRow);
    return cellHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setEditing:(BOOL)value {
    editing = value;
    
    for (int i = 0; i < contentArr.count; i++) {
        KButtonHead* btn = [contentArr objectAtIndex:i];
        if ([self.delegate canEditItemAtIndex:i]) {
            btn.editing = editing;
        }
        if ([self.delegate shouldHideItemAtIndex:i]) {
            btn.hidden = editing;
        }
    }
}

- (void)updateImage:(UIImage *)img atIndex:(NSInteger)index {
    KButtonHead* btn = [contentArr objectAtIndex:index];
    [btn setBackgroundImage:img forState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.contentView removeAllSubviews];
    if (contentArr == nil) {
        contentArr = [[NSMutableArray alloc] init];
    }
    [contentArr removeAllObjects];
    
    for (int i = 0; i < [self.delegate numberOfItemsInCell]; i++) {
        CGFloat x = i % 4 * kMemberCellSizeWidth + kMemberCellOffSetX;
        CGFloat y = i / 4 * kMemberCellSizeHeight + kMemberCellOffSetY;
        if (i >= 4) {
            y += i/4 * kMemberCellOffSetRow;
        }
        CGRect frameBtn = CGRectMake(x, y, kMemberCellSizeWidth, kMemberCellSizeHeight);
        KButtonHead* btn = [[KButtonHead alloc] initWithFrame:frameBtn];
        if ([self.delegate canEditItemAtIndex:i]) {
            btn.editing = editing;
        }
        if ([self.delegate shouldHideItemAtIndex:i]) {
            btn.hidden = editing;
        }
        btn.tag = i;
        [btn setBackgroundImage:[self.delegate imageNormalOfItemAtIndex:i] forState:UIControlStateNormal];
        [btn setBackgroundImage:[self.delegate imageHighlightedOfItemAtIndex:i] forState:UIControlStateHighlighted];
        [btn setTitle:[self.delegate titleOfItemAtIndex:i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btn];
        
        [contentArr addObject:btn];
    }
}

- (void)btnPressed:(KButtonHead*)sender {
    if ([self.delegate respondsToSelector:@selector(memberCell:didPressAtIndex:)]) {
        [self.delegate memberCell:self didPressAtIndex:sender.tag];
    }
}

@end
