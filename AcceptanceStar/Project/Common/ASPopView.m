//
//  ASPopView.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/7/20.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASPopView.h"

@implementation ASPopView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    [self resetConstraintOfView];
    [self resetFontSizeOfView];

    YSCBaseViewController *viewController = (YSCBaseViewController *)[UIView currentViewController];
    WEAKSELF
    [self.sortView bk_whenTapped:^{
        blockSelf.hidden = YES;
        [viewController pushViewController:@"ASPriceSortViewController" withParams:@{kParamPriceType : @(blockSelf.priceType)}];
    }];
    [self.buyView bk_whenTapped:^{
        blockSelf.hidden = YES;
        if (ISLOGGED) {
            [viewController pushViewController:@"ASBuySubmitViewController"];
        }
        else {
            [viewController presentViewController:@"ASLoginViewController"];
        }
    }];
    [self.sellView bk_whenTapped:^{
        blockSelf.hidden = YES;
        if (ISLOGGED) {
            [viewController pushViewController:@"ASSellBuyViewController"];
        }
        else {
            [viewController presentViewController:@"ASLoginViewController"];
        }
    }];
    [self.quotePriceView bk_whenTapped:^{
        blockSelf.hidden = YES;
        if (ISLOGGED) {
            [viewController pushViewController:@"ASQuotePriceSubmitViewController"];
        }
        else {
            [viewController presentViewController:@"ASLoginViewController"];
        }
    }];
    [self.reSellView bk_whenTapped:^{
        blockSelf.hidden = YES;
        if (ISLOGGED) {
            [viewController pushViewController:@"ASReSaleSubmitViewController"];
        }
        else {
            [viewController presentViewController:@"ASLoginViewController"];
        }
    }];
    [self.rePurchaseView bk_whenTapped:^{
        blockSelf.hidden = YES;
        if (ISLOGGED) {
            [viewController pushViewController:@"ASRePurchaseSubmitViewController"];
        }
        else {
            [viewController presentViewController:@"ASLoginViewController"];
        }
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (NO == CGRectContainsPoint(blockSelf.containerView.bounds, location)) {
            blockSelf.hidden = YES;
        }
    }];
    [self addGestureRecognizer:tap];
}

+ (instancetype)CreatePaymentView:(PriceType)priceType {
    ASPopView *view = FirstViewInXib(@"ASPopView");
    view.priceType = priceType;
    view.width = SCREEN_WIDTH;
    view.height = SCREEN_HEIGHT;
    [KeyWindow addSubview:view];
    return view;
}

@end
