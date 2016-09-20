//
//  ASPopView.h
//  AcceptanceStar
//
//  Created by yangshengchao on 15/7/20.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASPopView : UIView

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIView *sortView;
@property (nonatomic, weak) IBOutlet UIView *buyView;
@property (nonatomic, weak) IBOutlet UIView *sellView;
@property (nonatomic, weak) IBOutlet UIView *quotePriceView;
@property (nonatomic, weak) IBOutlet UIView *reSellView;
@property (nonatomic, weak) IBOutlet UIView *rePurchaseView;

@property (nonatomic, assign) PriceType priceType;
+ (instancetype)CreatePaymentView:(PriceType)priceType;
@end
