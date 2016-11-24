//
//  ASSearchECell.m
//  AcceptanceStar
//
//  Created by Jinjin on 2016/11/24.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "ASSearchECell.h"

@implementation ASSearchECell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.backgroundColor = [UIColor whiteColor];
    self.inputField.delegate = (id<UITextFieldDelegate>)self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.textChange){
        self.textChange (text);
    }
    return YES;
}
@end
