//
//  TextInput.m
//  FamiliarMen
//
//  Created by kiwi on 14-1-17.
//  Copyright (c) 2014年 xizue. All rights reserved.
//

#import "TextInput.h"

@implementation KTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = kCornerRadiusInput;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.clipsToBounds = YES;
        self.textColor = [UIColor blackColor];
//        [self setBackground:[Globals getImageInput:forImageInputWhite]];
    }
    return self;
}

//控制清除按钮的位置
-(CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + bounds.size.width - bounds.size.height, bounds.origin.y, bounds.size.height, bounds.size.height);
}

//控制placeHolder的位置
-(CGRect)placeholderRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x+10, bounds.origin.y, bounds.size.width -10, bounds.size.height);
    return inset;
}
//控制显示文本的位置
-(CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectZero;
    if (self.clearButtonMode != UITextFieldViewModeNever) {
        inset = CGRectMake(bounds.origin.x+10, bounds.origin.y, bounds.size.width - bounds.size.height - 10, bounds.size.height);
    } else {
        inset = CGRectMake(bounds.origin.x+10, bounds.origin.y, bounds.size.width - 20, bounds.size.height);
    }
    return inset;
}
//控制编辑文本的位置
-(CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectZero;
    if (self.clearButtonMode != UITextFieldViewModeNever) {
        inset = CGRectMake(bounds.origin.x+10, bounds.origin.y, bounds.size.width - bounds.size.height - 10, bounds.size.height);
    } else {
        inset = CGRectMake(bounds.origin.x+10, bounds.origin.y, bounds.size.width - 20, bounds.size.height);
    }
    return inset;
}
//控制左视图位置
- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x +10, bounds.origin.y, bounds.size.width-250, bounds.size.height);
    return inset;
}

//控制placeHolder的颜色、字体
- (void)drawPlaceholderInRect:(CGRect)rect
{
    //CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    //    [[UIColor darkGrayColor] setFill];
//    [kColorTitleGray setFill];
    [[UIColor grayColor] setFill];
    [[self placeholder] drawInRect:CGRectMake(0, (rect.size.height - self.font.lineHeight)/2, rect.size.width, rect.size.height) withFont:self.font];
}

@end



@interface KTextView ()

@property (nonatomic, strong) UIColor* textColor;

- (void) beginEditing:(NSNotification*) notification;
- (void) endEditing:(NSNotification*) notification;

@end

@implementation KTextView

@synthesize placeholder;
@synthesize textColor;

- (id) initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self awakeFromNib];
    }
    return self;
}

- (void)dealloc {
    [self removeobserver];
    
    self.placeholder = nil;
}

//当用nib创建时会调用此方法
- (void)awakeFromNib {
    
    CGRect frame = self.frame;
    self.frame = CGRectInset(frame, 1, 2);
    
    UIImageView* bkgView = [[UIImageView alloc] initWithFrame:frame];
    [bkgView setImage:[UIImage imageWithColor:[UIColor whiteColor]]];
    bkgView.layer.cornerRadius = kCornerRadiusInput;
    bkgView.layer.borderWidth = 1.0;
    bkgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bkgView.clipsToBounds = YES;
    bkgView.autoresizingMask = self.autoresizingMask;
    [self.superview insertSubview:bkgView belowSubview:self];
    
    self.backgroundColor = kColorClear;
    
    NSString* tmpString = [NSString stringWithString:[super text]];
    super.text = nil;
    self.placeholder = tmpString;
    
    textColor = [UIColor blackColor];
}
-(void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginEditing:) name:UITextViewTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEditing:) name:UITextViewTextDidEndEditingNotification object:self];
}
-(void)removeobserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Setter/Getters
- (void) setPlaceholder:(NSString *)aPlaceholder {
    placeholder = aPlaceholder;
    [self endEditing:nil];
}

- (NSString *) text {
    NSString* text = [super text];
    if ([text isEqualToString:placeholder]) return @"";
    return text;
}

- (void) beginEditing:(NSNotification*) notification {
    NSString* supText = [NSString stringWithString:[super text]];
    if ([supText isEqualToString:placeholder]) {
        super.text = nil;
        //字体颜色
        [super setTextColor:textColor];
    }
    
}

- (void) endEditing:(NSNotification*) notification {
    if ([[super text] isEqualToString:@""] || [super text] == nil) {
        if (placeholder) {
            super.text = placeholder;
        }
        //注释颜色
        [super setTextColor:[UIColor grayColor]];
    }
}

@end
