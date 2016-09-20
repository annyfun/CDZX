//
//  ASCalculatorViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/9/15.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASCalculatorViewController.h"
#import "CaculatorUtility.h"

@interface ASCalculatorViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *displayViewHeight;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *btnViewHeights;//100 / 120
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *btnViewTops;//10 / 20

@property (weak, nonatomic) IBOutlet UILabel *display;
@property (assign, nonatomic) BOOL isNew;

@end

@implementation ASCalculatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isNew = YES;
    self.display.text = self.params[kParamNumber];
    if (isEmpty(self.display.text)) {
        self.display.text = @"0";
    }
    self.navigationItem.title = @"银行承兑贴现计算器";
    if ([UIDevice currentDeviceType] < DeviceTypeiPhone640x1136) {
        for (NSLayoutConstraint *constraint in self.btnViewHeights) {
            constraint.constant = AUTOLAYOUT_LENGTH(100);
        }
        for (NSLayoutConstraint *constraint in self.btnViewTops) {
            constraint.constant = AUTOLAYOUT_LENGTH(10);
        }
        self.displayViewHeight.constant = AUTOLAYOUT_LENGTH(300);
    }
}

- (IBAction)digitPressed:(UIButton *)sender {
    if (self.isNew) {
        self.display.text = @"";
    }
    self.isNew = NO;
    if ([@"0" isEqualToString:self.display.text]) {
        self.display.text = sender.currentTitle;
    }
    else {
        self.display.text = [self.display.text stringByAppendingString:sender.currentTitle];
    }
}
- (IBAction)operationPressed:(UIButton *)sender {
    NSString *operation = sender.currentTitle;
    if ([@"÷" isEqualToString:operation]) {
        operation = @"/";
    }
    else if ([@"x" isEqualToString:operation]) {
        operation = @"*";
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
