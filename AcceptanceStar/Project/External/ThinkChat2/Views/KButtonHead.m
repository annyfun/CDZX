//
//  KButtonHead.m
//  HomeBridge
//
//  Created by keen on 14-7-14.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "KButtonHead.h"

@interface KButtonHead () {
    CGFloat titleOffSet;
    CGFloat imageSize;
}

@end

@implementation KButtonHead

@synthesize editing;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)_init {
    titleOffSet = 20.0;
    imageSize = 20.0;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    [self setTitleColor:kColorTitleBlack forState:UIControlStateNormal];
    [self setTitleColor:kColorTitleGray forState:UIControlStateHighlighted];
}

- (void)setEditing:(BOOL)value {
    editing = value;
    if (editing) {
        [self setImage:[UIImage imageNamed:@"btn_icon_delete_n"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"btn_icon_delete_d"] forState:UIControlStateHighlighted];
    } else {
        [self setImage:nil forState:UIControlStateNormal];
        [self setImage:nil forState:UIControlStateHighlighted];
    }
}

- (CGRect)contentRectForBounds:(CGRect)bounds {
    if (bounds.size.height - 20 > bounds.size.width) {
        return CGRectMake(0,
                          ceilf((bounds.size.height - (bounds.size.width + titleOffSet))/2.0),
                          bounds.size.width,
                          bounds.size.width);
    }
    return bounds;
}

- (CGRect)backgroundRectForBounds:(CGRect)bounds {
    return CGRectMake(ceilf((bounds.size.width - (bounds.size.height - titleOffSet))/2.0),
                      0,
                      bounds.size.height - titleOffSet,
                      bounds.size.height - titleOffSet);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake(ceilf(contentRect.size.width - imageSize - (contentRect.size.width - (contentRect.size.height - titleOffSet))/2.0),
                      0,
                      imageSize,
                      imageSize);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0, contentRect.size.height - titleOffSet, contentRect.size.width, titleOffSet);
}

@end
