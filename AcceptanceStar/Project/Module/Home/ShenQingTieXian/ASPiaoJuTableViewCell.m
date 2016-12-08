//
//  ASPiaoJuTableViewCell.m
//  AcceptanceStar
//
//  Created by lcyu on 2016/11/22.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "ASPiaoJuTableViewCell.h"
@interface ASPiaoJuTableViewCell()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *bankNameTF;
@property (weak, nonatomic) IBOutlet UITextField *priceTF;
@property (weak, nonatomic) IBOutlet UITextField *expTF;
@property (weak, nonatomic) IBOutlet UITextField *ticketNoTF;

@end
@implementation ASPiaoJuTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.addView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addClick:)]];
    [self.bankNameTF addTarget:self action:@selector(tFDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.priceTF addTarget:self action:@selector(tFDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.ticketNoTF addTarget:self action:@selector(tFDidChange:)  forControlEvents:UIControlEventEditingChanged];
    self.expDateTF.delegate = self;
    WEAKSELF1
    [self.addIV bk_whenTapped:^{
        !weakSelf.addImage?:self.addImage(weakSelf);
    }];
}

-(void)setPaperModel:(PaperModel *)paperModel
{
    _paperModel = paperModel;
    self.bankNameTF.text = paperModel.bankName;
    self.ticketNoTF.text = paperModel.ticketNo;
    self.priceTF.text = paperModel.price ==0 ? nil: [NSString stringWithFormat:@"%zd", paperModel.price];
    self.expDateTF.text = [paperModel getExpDateString];
    [self.addIV setImageWithURLString:_paperModel.pic placeholderImage:[UIImage imageNamed:@"sqtx_add_image"]];
    if (paperModel.exp != 0) {
        self.expTF.text = [NSString stringWithFormat:@"%zd", [[NSDate dateWithTimeIntervalSince1970:paperModel.exp] daysAfterDate:[NSDate dateNow]]];
    }
    self.checkBtn.selected = _paperModel.selected;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addClick:(UITapGestureRecognizer *)sender {
    !self.addClickBlock?:self.addClickBlock();
}

- (void)tFDidChange:(UITextField *) sender {
    if (sender == self.bankNameTF) {
        self.paperModel.bankName = sender.text;
    } else if (sender == self.priceTF){
        self.paperModel.price = [sender.text integerValue];
        !self.priceChangeBlock?:self.priceChangeBlock([sender.text integerValue]);
    }else if (sender == self.ticketNoTF){
        self.paperModel.ticketNo = sender.text;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    !self.clickDateBlock?:self.clickDateBlock(self);
}
@end
