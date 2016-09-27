//
//  BaseViewController.m
//  Base
//
//  Created by keen on 13-10-17.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import "BaseViewController.h"
#import "KLoadingView.h"

@interface BaseViewController () {
    KLoadingView    * loadingView;
    BOOL            needAddKeyBoardControl;
    BOOL            isAddKeyBoardControl;
    BOOL            isDidAppear;
    BOOL            hasLoadData;
}

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isFirstAppear = YES;
        keyboardHeight = DefaultKeyBoardHeight;
        needAddKeyBoardControl = NO;
        isAddKeyBoardControl = NO;
        hasLoadData = NO;
#ifdef __IPHONE_7_0
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
#endif
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    currentInputView = nil;
    [client cancel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.view.backgroundColor = kColorViewBkg;
    if (self.navigationController.viewControllers.count > 1) {
        [self addBarButtonItemBack];
    }
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
//}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [client cancel];
    client = nil;
    [[ThinkChat instance] cancelRequestTag:tagRequest];
    tagRequest = nil;
    isDidAppear = NO;
    [loadingView hide];
    if (isAddKeyBoardControl) {
        isAddKeyBoardControl = NO;
        [self unRegisterForKeyboardNotifications];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    isDidAppear = YES;
    if (loadingView) {
        [loadingView show];
    }
    if (needAddKeyBoardControl) {
        [self addKeyBoardControl];
    }
}

- (void)btnPressed:(id)sender {
    [self hideKeyBoard];
}

- (void)barButtonItemLeftPressed:(id)sender {
    
}

- (void)barButtonItemRightPressed:(id)sender {
    
}

- (void)popViewController {
    if (isDidAppear) {
        [self doPopViewController];
    } else {
        [self performSelector:@selector(doPopViewController) withObject:nil afterDelay:0.5];
    }
}

- (void)doPopViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushViewController:(id)con {
    if (con == nil) {
        return;
    }
    if (isDidAppear) {
        [self doPushViewController:con];
    } else {
        [self performSelector:@selector(doPushViewController:) withObject:con afterDelay:0.5];
    }
}

- (void)doPushViewController:(id)con {
    ((UIViewController*)con).hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:con animated:YES];
}

- (void)addBarButtonItemBack {
    [self addBarButtonItemBackWithAction:@selector(popViewController)];
}

- (void)addBarButtonItemBackWithAction:(SEL)action {
    [self addBarButtonItemNormalImageName:@"nav_back_n" hightLited:@"nav_back_d" action:action isRight:NO];
}

- (void)addBarButtonItemLeftNormalImageName:(NSString *)imgNameN hightLited:(NSString *)imgNameD {
    [self addBarButtonItemNormalImageName:imgNameN hightLited:imgNameD action:@selector(barButtonItemLeftPressed:) isRight:NO];
}

- (void)addBarButtonItemRightNormalImageName:(NSString *)imgNameN hightLited:(NSString *)imgNameD {
    [self addBarButtonItemNormalImageName:imgNameN hightLited:imgNameD action:@selector(barButtonItemRightPressed:) isRight:YES];
}

- (void)addBarButtonItemNormalImageName:(NSString *)strNameN hightLited:(NSString *)strNameD action:(SEL)action isRight:(BOOL)isRight {
    UIImage* imgN = [UIImage imageNamed:strNameN];
    UIImage* imgD = nil;
    if (strNameD) {
        imgD = [UIImage imageNamed:strNameD];
    }
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    btn.frame = CGRectMake(0, 0, imgN.size.width/2, imgN.size.height/2);
    [btn setImage:imgN forState:UIControlStateNormal];
    if (imgD) {
        [btn setImage:imgD forState:UIControlStateHighlighted];
    }
    
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * bbItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    if (isRight) {
        self.navigationItem.rightBarButtonItem = bbItem;
    } else {
        self.navigationItem.leftBarButtonItem = bbItem;
    }
}

//- (void)addBarButtonItemRightTitle:(NSString*)title action:(SEL)action {
//    [self addBarButtonItemTitle:title action:action isRight:YES];
//}
//
//- (void)addBarButtonItemLeftTitle:(NSString *)title action:(SEL)action {
//    [self addBarButtonItemTitle:title action:action isRight:NO];
//}
//
//- (void)addBarButtonItemTitle:(NSString*)title action:(SEL)action isRight:(BOOL)isR {
//    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIFont* font = [UIFont boldSystemFontOfSize:17];
//    CGSize size = [title sizeWithFont:font];
//    [btn setFrame:CGRectMake(0, 0, size.width + 20, 32)];
//    [btn.titleLabel setFont:font];
//    [btn setTitle:title forState:UIControlStateNormal];
//    [btn setTitleColor:kColorTitleBlue forState:UIControlStateNormal];
//    [btn setTitleColor:kColorTitleGray forState:UIControlStateHighlighted];
//    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem * bbItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
//    if (isR) {
//        self.navigationItem.rightBarButtonItem = bbItem;
//    } else {
//        self.navigationItem.leftBarButtonItem = bbItem;
//    }
//}

- (void)setLoading:(BOOL)bl {
    [self setLoading:bl content:@"请稍候..."];
}
- (void)setLoading:(BOOL)bl content:(NSString*)con {
    if (bl) {
        self.view.userInteractionEnabled = NO;
        if (loadingView == nil) {
            loadingView = [[KLoadingView alloc] initWithText:con animated:NO];
        }
        [loadingView show];
    } else if (loadingView) {
        self.view.userInteractionEnabled = YES;
        [loadingView hide];
        loadingView = nil;
    }
}

- (void)resignAllKeyboard:(UIView*)aView
{
    if([aView isKindOfClass:[UITextField class]] ||
       [aView isKindOfClass:[UITextView class]])
    {
        UITextField* tf = (UITextField*)aView;
        if([tf canResignFirstResponder])
            [tf resignFirstResponder];
    }
    
    for (UIView* pView in aView.subviews) {
        [self resignAllKeyboard:pView];
    }
}

+ (void)resignAllKeyboard:(UIView*)aView
{
    if([aView isKindOfClass:[UITextField class]] ||
       [aView isKindOfClass:[UITextView class]])
    {
        UITextField* tf = (UITextField*)aView;
        if([tf canResignFirstResponder])
            [tf resignFirstResponder];
    }
    
    for (UIView* pView in aView.subviews) {
        [self resignAllKeyboard:pView];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self resignAllKeyboard:self.view];
    [self hideKeyBoard];
}

#pragma mark - Request

- (void)loadDataIfNeeded {
    if (!hasLoadData) {
        hasLoadData = YES;
        [self sendRequest];
    }
}

- (BOOL)sendRequest {
    if (client) {
        return NO;
    }
    self.loading = YES;
    client = [[BaseClient alloc] initWithDelegate:self action:@selector(getResponse:obj:)];
    return YES;
}

- (BOOL)getResponse:(BaseClient*)sender obj:(NSObject*)obj {
    client = nil;
    self.loading = NO;
    if (sender.hasError) {
        [sender showAlert];
        return NO;
    }
    return YES;
}

#pragma keyBoard Control

- (void)addKeyBoardControl {
    needAddKeyBoardControl = YES;
    if (!isAddKeyBoardControl) {
        isAddKeyBoardControl = YES;
        [self registerForKeyboardNotifications];
    }
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(baseKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(baseKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//#ifdef __IPHONE_5_0
//    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    if (version >= 5.0) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(baseKeyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
//    }
//#endif
}

- (void)unRegisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
//#ifdef __IPHONE_5_0
//    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    if (version >= 5.0) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:UIKeyboardWillChangeFrameNotification
//                                                      object:nil];
//    }
//#endif
}

#pragma -
#pragma keyboard notification

- (void)baseKeyboardWillShow:(NSNotification*)notification {
    CGRect keyboardFrame;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardFrame];
    
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:[curve integerValue] animations:^(void){
        keyboardHeight = keyboardFrame.size.height;
        [self keyBoardWillShow:currentInputView];
    } completion:nil];
}

- (void)baseKeyboardWillHide:(NSNotification*)notification {
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:[curve integerValue] animations:^(void){
        [self keyBoardWillHide:currentInputView];
    } completion:nil];
}

- (void)keyBoardWillShow:(id)sender {
    
}

- (void)keyBoardWillHide:(id)sender {
    
}

- (void)hideKeyBoard {
    [currentInputView resignFirstResponder];
    currentInputView = nil;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)sender {
    currentInputView = sender;
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)sender {
    currentInputView = sender;
    return YES;
}

@end
