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
    
    @property (strong, nonatomic) NSMutableArray *values;

@property (strong, nonatomic) NSString *cString;
@property (strong, nonatomic) NSString *oString;

    @property (strong, nonatomic) UIScrollView *scrollView;
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
    
    self.display.font = [UIFont systemFontOfSize:30];
    
    self.navigationItem.title = @"银行承兑贴现计算器";
    
    self.btnViewHeight.constant = kPadHeight;
    
    self.view.backgroundColor = RGB(188, 200, 173);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 108, SCREEN_WIDTH, kPadHeight-35)];
    [self.view insertSubview:self.scrollView atIndex:0];
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.scrollView addGestureRecognizer:press];
}
    
    - (void)longPress:(UILongPressGestureRecognizer *)ges{
        if (ges.state==UIGestureRecognizerStateBegan) {
            
            [self becomeFirstResponder];
            CGPoint point = [ges locationInView:self.scrollView];
            
            __block UILabel *view = nil;
            [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (CGRectContainsPoint(obj.frame, point)) {
                    view = obj;
                    *stop = YES;
                }
            }];
            
            if (view) {
                self.cString = view.text;
                
                CGRect frame = view.frame;
                frame.origin.x = SCREEN_WIDTH-80;
                frame.size.width = 80;
                
                UIMenuItem *flag = [[UIMenuItem alloc] initWithTitle:@"复制"action:@selector(flag:)];
                UIMenuController *menu = [UIMenuController sharedMenuController];
                [menu setMenuItems:[NSArray arrayWithObjects:flag, nil]];
                [menu setTargetRect:frame inView:view.superview];
                [menu setMenuVisible:YES animated:YES];
            }
        }
    }

    - (BOOL)canBecomeFirstResponder{
        return YES;
    }
    
- (void)flag:(id)sender {
    [UIPasteboard generalPasteboard].string = self.cString;
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
    
    self.isNew = NO;
    
    if (!self.oString) {
        self.display.text = [self.display.text stringByAppendingString:operation];
        self.oString = operation;
    }else{
        NSRange location = [self.display.text rangeOfString:self.oString?:@""];
        if (location.location==NSNotFound){
            self.display.text = [self.display.text stringByAppendingString:operation];
            self.oString = operation;
        }
        
        else{
            if ([[self.display.text substringFromIndex:self.display.text.length-1] isEqualToString:self.oString]) {
                self.display.text = [self.display.text stringByReplacingOccurrencesOfString:self.oString withString:operation];
                self.oString = operation;
            }else{
                [self equalR];
                self.isNew = NO;
                self.display.text = [self.display.text stringByAppendingString:operation];
                self.oString = operation;
            }
        }
    }
}
    
- (IBAction)zeroPressed {
    self.isNew = YES;
    self.oString = nil;
    self.display.text = @"0";
}

- (IBAction)dotPressed {
    
    NSRange location = [self.display.text rangeOfString:self.oString?:@""];
    NSString *subString = self.display.text;
    if ((location.location!=NSNotFound) && (location.length<self.display.text.length)) {
        subString = [subString substringFromIndex:location.location];
    }
    location = [subString rangeOfString:@"."];
    if (location.location==NSNotFound){
        self.isNew = NO;
        
        if ([[self.display.text substringFromIndex:self.display.text.length-1] isEqualToString:self.oString]) {
            
            self.display.text = [self.display.text stringByAppendingString:@"0."];
        }else{
            
            self.display.text = [self.display.text stringByAppendingString:@"."];
        }
    }
}




- (IBAction)deletePressed:(id)sender {
    if (isNotEmpty(self.display.text) && ! [@"0" isEqualToString:self.display.text]) {
        self.display.text = [NSString removeLastCharOfString:self.display.text];
    }
    if (isEmpty(self.display.text)) {
        self.display.text = @"0";
    }
    
    NSRange location = [self.display.text rangeOfString:self.oString?:@""];
    if (location.location==NSNotFound) {
        self.oString = nil;
    }
    
}
    
    
- (IBAction)equalR {
    self.isNew = YES;
    
    self.oString = nil;
    NSString *string = self.display.text;
    
    NSString *result = [NSString stringWithFormat:@"%@", [CaculatorUtility calcComplexFormulaString:string]];
    
    self.display.text = result;
    
    
    if(nil==self.values)
    self.values = [@[] mutableCopy];
    
    if (string && result) {
        NSString *r = [NSString stringWithFormat:@"%@\n=%@",string,result];
        self.values.count?[self.values insertObject:r atIndex:0]:[self.values addObject:r];
        
        if (self.values.count>20) {
            [self.values removeLastObject];
        }
        
        [self reloadHis];
    }
}
    
    
    - (void)reloadHis{
        
        [self.scrollView removeAllSubviews];
        
        CGFloat height = 70;
        [self.values enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, idx*height, SCREEN_WIDTH-30, height)];
            label.textColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentRight;
            label.font = [UIFont systemFontOfSize:24];
            label.text = obj;
            label.numberOfLines = 0;
            
            [self.scrollView addSubview:label];
        }];
        
        self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, self.values.count * height);
    }
    
    @end
