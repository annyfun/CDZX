//
//  ASPiaoJuTableViewCell.h
//  AcceptanceStar
//
//  Created by lcyu on 2016/11/22.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASPiaoJuTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *addView;
@property (weak, nonatomic) IBOutlet UITextField *expDateTF;
@property (weak, nonatomic) IBOutlet UIImageView *addIV;
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;
@property (nonatomic, strong) PaperModel *paperModel;
@property (nonatomic, copy) void(^addClickBlock)();
@property (nonatomic, copy) void(^clickDateBlock)(UITableViewCell *cell);
@property (nonatomic, copy) void(^priceChangeBlock)(NSInteger price);
@property (nonatomic, copy) void(^addImage)(UITableViewCell *cell);
@end
