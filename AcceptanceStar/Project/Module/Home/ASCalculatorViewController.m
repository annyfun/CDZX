//
//  ASCalculatorViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/9/15.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASCalculatorViewController.h"
#import "CaculatorUtility.h"

#define kTopHeight  (64+108)
#define kPadHeight  (SCREEN_HEIGHT-kTopHeight)
#define kPadTopHeight 35

@interface ASCalculatorViewController ()
    
    @property (weak, nonatomic) IBOutlet UILabel *display;
    @property (assign, nonatomic) BOOL isNew;
    
    @property (assign, nonatomic) BOOL isPadHidden;
    
    @property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnHeight;
    
    @property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnViewHeight;
    @property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomC;
@end

@implementation ASCalculatorViewController
- (IBAction)hiddenPress:(id)sender {
    
    self.isPadHidden = !self.isPadHidden;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat bottom = self.isPadHidden?-(self.btnViewHeight.constant-self.btnHeight.constant):0;
        self.bottomC.constant = bottom;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isNew = YES;
    self.display.text = self.params[kParamNumber];
    if (isEmpty(self.display.text)) {
        self.display.text = @"0";
    }
    self.navigationItem.title = @"银行承兑贴现计算器";
    
    self.btnViewHeight.constant = kPadHeight;
    
    self.view.backgroundColor = RGB(188, 200, 173);
}

- (IBAction)digitPressed:(UIButton *)sender {
    if (self.isNew) {
        self.display.text = @"";
    }
    self.isNew = NO;
    
    
    NSString *text = [NSString stringWithFormat:@"%zd",sender.tag];
    if ([@"0" isEqualToString:self.display.text]) {
        self.display.text = text;
    }
    else {
        self.display.text = [self.display.text stringByAppendingString:text];
    }
}
    
- (IBAction)operationPressed:(UIButton *)sender {
    /*
     tag
     
     0 /
     1 *
     2 +
     3 -
     
     */
    NSString *operation = nil;
    if (sender.tag==0) {
        operation = @"/";
    }else if (sender.tag==1) {
        operation = @"*";
    }
    else if (sender.tag==2) {
        operation = @"+";
    }
    else if (sender.tag==3) {
        operation = @"-";
    }
    
    if (self.isNew) {
        self.display.text = @"";
    }
    self.isNew = NO;
    if ([@"0" isEqualToString:self.display.text]) {
        self.display.text = operation;
    }
    else {
        self.display.text = [self.display.text stringByAppendingString:operation];
    }
}
    
- (IBAction)zeroPressed {
    self.isNew = YES;
    self.display.text = @"0";
}
    
    
- (IBAction)deletePressed:(id)sender {
    if (isNotEmpty(self.display.text) && ! [@"0" isEqualToString:self.display.text]) {
        self.display.text = [NSString removeLastCharOfString:self.display.text];
    }
    if (isEmpty(self.display.text)) {
        self.display.text = @"0";
    }
}
    
    
- (IBAction)equalR {
    self.isNew = YES;
    self.display.text = [NSString stringWithFormat:@"%@", [CaculatorUtility calcComplexFormulaString:self.display.text]];
}

@end
