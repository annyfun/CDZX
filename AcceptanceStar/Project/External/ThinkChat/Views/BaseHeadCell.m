//
//  BaseHeadCell.m
//  Base
//
//  Created by keen on 13-11-5.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BaseHeadCell.h"

@interface BaseHeadCell () {
}

@end

@implementation BaseHeadCell
@synthesize imgHead;
@synthesize cornerRadius;

- (void)initialiseCell {
    [super initialiseCell];
    
    self.cornerRadius = kCornerRadiusHead;
}

- (void)dealloc {
    self.imgHead = nil;
    imgViewHead = nil;
}

- (void)setImgHead:(UIImage *)img {
    imgHead = img;
    imgViewHead.image = imgHead;
}

- (void)setCornerRadius:(NSInteger)value {
    cornerRadius = value;
    if (cornerRadius > 0) {
        imgViewHead.layer.masksToBounds = YES;
        imgViewHead.layer.borderWidth = 0;
        imgViewHead.layer.cornerRadius = cornerRadius;
        imgViewHead.clipsToBounds = YES;
    }
}

- (void)setDelegate:(id)del {
    [super setDelegate:del];
    
    if (self.delegate) {
        if (!imgViewHead.userInteractionEnabled) {
            UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headTapped:)];
            [imgViewHead addGestureRecognizer:recognizer];
            imgViewHead.userInteractionEnabled = YES;
            imgViewHead.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
}

- (void)headTapped:(UITapGestureRecognizer*)recognizer {
    if ([self.delegate respondsToSelector:@selector(baseHeadCellDidTapHeader:)]) {
        [self.delegate performSelector:@selector(baseHeadCellDidTapHeader:) withObject:self];
    }
}

@end
