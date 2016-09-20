//
//  KLoadingView.h
//  iMRadioII
//
//  Created by kiwi on 4/19/13.
//  Copyright (c) 2013 xizue.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KLoadingView : UIView {
    BOOL animated;
    UIActivityIndicatorView * indicatorView;
}
@property (nonatomic, strong) NSString * text;

+ (KLoadingView*)showText:(NSString*)txt animated:(BOOL)ani;
- (id)initWithText:(NSString*)txt animated:(BOOL)ani;
- (void)show;
- (void)hide;

@end
