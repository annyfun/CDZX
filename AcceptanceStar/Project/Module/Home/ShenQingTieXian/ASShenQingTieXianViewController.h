//
//  ASShenQingTieXianViewController.h
//  AcceptanceStar
//
//  Created by lcyu on 2016/11/22.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, TieXianType) {
    TieXianTypeApply,
    TieXianTypeReceivedApply
};
@interface ASShenQingTieXianViewController : UIViewController
-(id)initWithTieXianModel:(TieXianModel *)model tieXianType:(TieXianType)tieXianType;
@property (nonatomic, strong) NSString *electricId;
@end
