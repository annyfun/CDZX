//
//  SingleTextViewController.m
//  HomeBridge
//
//  Created by keen on 14-7-3.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "SingleTextViewController.h"
#import "TextInput.h"
#import "User.h"

@interface SingleTextViewController () {
    IBOutlet KTextView* tvInput;
    SingleTextViewType  typeInput;
}

@property (nonatomic, strong) NSString* navTitle;
@property (nonatomic, strong) NSString* placeHolder;
@property (nonatomic, strong) User*     user;
@property (nonatomic, assign) id <SingleTextViewDelegate> delegate;


@end

@implementation SingleTextViewController

@synthesize navTitle;
@synthesize placeHolder;
@synthesize user;
@synthesize delegate;

- (id)initWithTitle:(NSString *)strTitle placeHolder:(NSString *)strPlaceHolder delegate:(id<SingleTextViewDelegate>)del
{
    self = [super initWithNibName:@"SingleTextViewController" bundle:nil];
    if (self) {
        // Custom initialization
        typeInput = forSingleTextViewSimpleInput;
        self.navTitle = strTitle;
        self.placeHolder = strPlaceHolder;
        self.delegate = del;
    }
    return self;
}

- (id)initWithType:(SingleTextViewType)theType {
    self = [super initWithNibName:@"SingleTextViewController" bundle:nil];
    if (self) {
        // Custom initialization
        typeInput = theType;
        if (typeInput == forSingleTextViewFeedBack) {
            self.navTitle = @"意见反馈";
            self.placeHolder = @"请填写反馈内容";
            self.delegate = nil;
        }
    }
    return self;
}

- (id)initWithUser:(User *)item {
    self = [super initWithNibName:@"SingleTextViewController" bundle:nil];
    if (self) {
        // Custom initialization
        typeInput = forSingleTextViewReportUser;
        self.user = item;
        self.navTitle = @"举报";
        self.placeHolder = @"请输入举报内容";
        self.delegate = nil;
    }
    return self;
}

- (void)dealloc {
    self.navTitle = nil;
    self.placeHolder = nil;
    self.user = nil;
    
    tvInput = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = navTitle;
    tvInput.placeholder = placeHolder;
    
    [self addBarButtonItemRightNormalImageName:@"nav_ok_n" hightLited:@"nav_ok_d"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [tvInput addObserver];
    [tvInput becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [tvInput removeobserver];
}

- (void)barButtonItemRightPressed:(id)sender {
    if (tvInput.text.length == 0) {
        [Globals showAlertTitle:nil msg:placeHolder];
        return;
    }
    if ([delegate respondsToSelector:@selector(singleTextView:inputString:)]) {
        [delegate singleTextView:self inputString:tvInput.text];
        self.delegate = nil;
    }
    
    if (typeInput == forSingleTextViewSimpleInput) {
        [self popViewController];
    } else if (typeInput == forSingleTextViewFeedBack) {
        [self sendRequest];
    } else if (typeInput == forSingleTextViewReportUser) {
        [self sendRequest];
    }
}

#pragma mark - Request

- (BOOL)sendRequest {
    if ([super sendRequest]) {
        if (typeInput == forSingleTextViewFeedBack) {
            [client feedback:tvInput.text];
        } else if (typeInput == forSingleTextViewReportUser) {
            [client reportUser:user.ID reason:tvInput.text];
        }
        return YES;
    }
    return NO;
}

- (BOOL)getResponse:(BaseClient *)sender obj:(NSDictionary *)obj {
    if ([super getResponse:sender obj:obj]) {
        [KAlertView showType:KAlertTypeCheck text:sender.errorMessage for:1.5 animated:YES];
        [self popViewController];
        return YES;
    }
    return NO;
}

@end
