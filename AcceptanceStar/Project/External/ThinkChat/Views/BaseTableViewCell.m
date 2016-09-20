//
//  BaseTableViewCell.m
//  Base
//
//  Created by keen on 13-10-19.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface BaseTableViewCell () {
    BOOL    hasUpdate;
}

@end

@implementation BaseTableViewCell

@synthesize hideLine;
@synthesize delegate;
@synthesize indexPath;
@synthesize isGrouped;
@synthesize layOutBlock;

+ (CGFloat)heightWithItem:(id)item {
    return 0.0;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initialiseCell];
    }
    return self;
}


- (void)dealloc {
    self.indexPath = nil;
}

- (void)awakeFromNib {
    [self initialiseCell];
}

- (void)initialiseCell {
    self.backgroundColor = kColorClear;
    
    UIImageView* bkgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    bkgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    bkgView.backgroundColor = kColorCellBkgD;
    self.selectedBackgroundView = bkgView;

    bkgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    bkgView.backgroundColor = kColorCellBkgN;
    self.backgroundView = bkgView;
    
    self.textLabel.backgroundColor = kColorClear;
    self.textLabel.textColor = kColorTitle;
    self.textLabel.highlightedTextColor = kColorTitle;
    
    self.detailTextLabel.backgroundColor = kColorClear;
    self.detailTextLabel.textColor = kColorDetail;
    self.detailTextLabel.highlightedTextColor = kColorDetail;
    
    hideLine = NO;
}

- (void)setSeparatorLastOne:(BOOL)lastOne leftInset:(CGFloat)left {
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        if (lastOne) {
            self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } else {
            self.separatorInset = UIEdgeInsetsMake(0, left, 0, 0);
        }
    }
}

//- (void)setHideLine:(BOOL)bl {
//    hideLine = bl;
//    [self setNeedsDisplay];
//}

//- (void)drawRect:(CGRect)rect {
//    if (!hideLine) {
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGFloat offSet = 10.0;
//        CGRect rectangle = CGRectMake(offSet,rect.size.height-1,rect.size.width-offSet*2,1);
//        CGContextAddRect(context, rectangle);
//        UIColor* color = [Globals getColorGrayLine];
//        CGContextSetFillColorWithColor(context, color.CGColor);
//        CGContextFillRect(context, rectangle);
//        
//        //        rectangle = CGRectMake(0,rect.size.height-1,rect.size.width,1);
//        //        CGContextAddRect(context, rectangle);
//        //        CGContextSetFillColorWithColor(context, color.CGColor);
//        //        CGContextFillRect(context, rectangle);
//    }
//}

- (void)setIsGrouped:(BOOL)grouped {
    isGrouped = grouped;
}

- (void)setFrame:(CGRect)frame {
    if (isGrouped) {
//        if (systemVersionFloatValue >= 7) {
        CGFloat offSet = 10.0;
            frame.origin.x += offSet;
            frame.size.width -= offSet*2;
//        }
    }
    [super setFrame:frame];
}

- (void)setDelegate:(id)del {
    delegate = del;
}

- (void)update:(LayOutSubViewInCell)block {
    hasUpdate = YES;
    self.layOutBlock = block;
}

- (void)layoutSubviews {
    if (hasUpdate && !layOutBlock) {
        return;
    }
    [super layoutSubviews];
    if (layOutBlock != nil) {
        layOutBlock();
        self.layOutBlock = nil;
    }
    if (systemVersionFloatValue < 7.0) {
        self.textLabel.backgroundColor = kColorClear;
        self.textLabel.textColor = kColorTitle;
        self.textLabel.highlightedTextColor = kColorTitle;
        
        self.detailTextLabel.backgroundColor = kColorClear;
        self.detailTextLabel.textColor = kColorDetail;
        self.detailTextLabel.highlightedTextColor = kColorDetail;
    }
}

@end
