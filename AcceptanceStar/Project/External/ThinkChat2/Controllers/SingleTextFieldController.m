//
//  SingleTextFieldController.m
//  HomeBridge
//
//  Created by keen on 14-7-3.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "SingleTextFieldController.h"
#import "TCGroup.h"
#import "TCSession.h"
#import "AppDelegate.h"

@interface SingleTextFieldController () <TCResultGroupDelegate> {
    IBOutlet UITextField*   tfInput;
    SingleTextFieldType     typeInput;
    GroupType               typeGroup;
}

@property (nonatomic, strong) NSString* navTitle;
@property (nonatomic, strong) NSString* placeHolder;
@property (nonatomic, assign) id <SingleTextFieldDelegate> delegate;
@property (nonatomic, strong) TCSession*    session;

@end

@implementation SingleTextFieldController

@synthesize navTitle;
@synthesize placeHolder;
@synthesize delegate;
@synthesize session;

- (id)initWithTitle:(NSString *)strTitle placeHolder:(NSString *)strPlaceHolder delegate:(id<SingleTextFieldDelegate>)del
{
    self = [super initWithNibName:@"SingleTextFieldController" bundle:nil];
    if (self) {
        // Custom initialization
        self.navTitle = strTitle;
        self.placeHolder = strPlaceHolder;
        self.delegate = del;
    }
    return self;
}

- (id)initWithSession:(TCSession *)itemS type:(SingleTextFieldType)theType {
    self = [super initWithNibName:@"SingleTextFieldController" bundle:nil];
    if (self) {
        // Custom initialization
        self.session = itemS;
        typeInput = forSingleTextFieldEditSession;
        
        self.navTitle = session.name;
        self.placeHolder = @"请输入新的会话名称";
    }
    return self;
}

- (void)dealloc {
    self.navTitle = nil;
    self.placeHolder = nil;
    self.session = nil;
    
    tfInput = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = navTitle;
    tfInput.placeholder = placeHolder;
    
    [self addBarButtonItemRightNormalImageName:@"nav_ok_n" hightLited:@"nav_ok_d"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [tfInput becomeFirstResponder];
}

- (void)barButtonItemRightPressed:(id)sender {
    if (tfInput.text.length == 0) {
        [Globals showAlertTitle:nil msg:placeHolder];
        return;
    }
    if ([delegate respondsToSelector:@selector(singleTextField:inputString:)]) {
        [delegate singleTextField:self inputString:tfInput.text];
        self.delegate = nil;
    }
    if (typeInput == forSingleTextFieldSimpleInput) {
        [self popViewController];
    } else if (typeInput == forSingleTextFieldEditSession) {
        if ([tfInput.text isEqualToString:session.name]) {
            [Globals showAlertTitle:@"无效的名称" msg:@"新会话名称与原会话名称一致"];
            return;
        }
        [self sendRequest];
    }
}

#pragma mark - Request

- (BOOL)sendRequest {
    if ([super sendRequest]) {
        if (typeInput == forSingleTextFieldEditSession) {
            tagRequest = [[ThinkChat instance] modifyConversation:session.ID newName:tfInput.text delegate:self];
        }
        return YES;
    }
    return NO;
}

- (BOOL)getResponse:(BaseClient *)sender obj:(NSDictionary *)obj {
    if ([super getResponse:sender obj:obj]) {
        return YES;
    }
    return NO;
}

#pragma mark - TCResultGroupDelegate

- (void)tcResultGroup:(TCGroup *)itemG error:(TCError *)itemE {
    [super getResponse:nil obj:nil];
    if (itemE == nil) {
        TCGroup* itemG = session.group;
        itemG.name = tfInput.text;
        [[AppDelegate instance] editGroup:itemG];
        [self popViewController];
    } else {
        [KAlertView showType:KAlertTypeError text:itemE.message for:1.5 animated:YES];
    }
}

@end
