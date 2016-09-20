//
//  KLoadingView.m
//  iMRadioII
//
//  Created by kiwi on 4/19/13.
//  Copyright (c) 2013 xizue.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KLoadingView.h"

#define KLoadingTWidth 100
#define KLoadingTag 9696

@implementation KLoadingView
@synthesize text;

+ (KLoadingView*)showText:(NSString*)txt animated:(BOOL)ani {
    KLoadingView * loadingV = [[KLoadingView alloc] initWithText:txt animated:ani];
    [loadingV show];
    return loadingV;
}

- (id)initWithText:(NSString*)txt animated:(BOOL)ani {
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    CGFloat height = 0;
    if (txt) {
        CGSize size = [txt sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(KLoadingTWidth, 400)];
        height += size.height+3;
    }
    height += 50;
    CGRect frame = CGRectMake(90, (window.frame.size.height-height)/2, 140, height);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7];
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 0;
        self.layer.cornerRadius = 8;
        self.text = txt;
        animated = ani;
        UIActivityIndicatorView * act = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        act.center = CGPointMake(70, 25);
        [act startAnimating];
        [self addSubview:act];
        indicatorView = act;
        act = nil;
    }
    return self;
}

- (void)dealloc {
    self.text = nil;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [[UIColor whiteColor] set];
    UIFont * font = [UIFont systemFontOfSize:16];
    CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(KLoadingTWidth, 400)];
    CGRect txtRect = CGRectMake((self.frame.size.width-size.width)/2, 38, size.width, size.height);
    [text drawInRect:txtRect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
}

- (void)show {
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    self.tag = KLoadingTag;
    self.alpha = 0;
    [window addSubview:self];
    if (animated) {
        [UIView beginAnimations:@"SHOW" context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationEnd:finished:context:)];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
    }
    self.alpha = 1;
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)hide {
    if (self.tag == KLoadingTag) {
        self.tag = 0;
        if (animated) {
            [UIView beginAnimations:@"HIDE" context:NULL];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(animationEnd:finished:context:)];
            [UIView setAnimationDuration:0.2];
            [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
        }
        self.alpha = 0;
        if (animated) {
            [UIView commitAnimations];
        } else {
            [self removeFromSuperview];
        }
    }
}

- (void)animationEnd:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
    if ([animationID isEqualToString:@"HIDE"]) {
        [self removeFromSuperview];
    }
}

@end
