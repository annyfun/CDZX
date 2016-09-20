//
//  ChatViewController.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-8.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "ChatViewController.h"
#import "TCSession.h"
#import "TCMessage.h"
#import "ChatViewController.h"
#import "MessageLeftCell.h"
#import "MessageRightCell.h"
#import "UIImage+Rotate_Flip.h"
#import "UIImage+Resize.h"
#import "TCSession.h"
#import "TCMessage.h"
#import "TCUser.h"
#import "User.h"
#import "TCGroup.h"
#import "AppDelegate.h"
#import "TalkingRecordView.h"
#import "AudioMsgPlayer.h"
#import "KAlertView.h"
#import "ImageViewController.h"
#import "EmotionInputView.h"
#import "MapViewController.h"
#import "GroupDetailController.h"
#import "UserDetailController.h"
#import "SessionDetailController.h"
#import "ASUserProfileViewController.h"

#define kTagChatActionSheetCellFail     1   // 是否重新发送

@interface KButtonChat : UIButton

@end

@implementation KButtonChat

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0, 0, contentRect.size.width, contentRect.size.width);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0, contentRect.size.width, contentRect.size.width, contentRect.size.height - contentRect.size.width);
}

@end

@interface ChatViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BaseMessageCellDelegate, EmotionInputViewDelegate, MapViewDelegate> {
    IBOutlet UIView*        contentView;        // 包含 消息列表 + 发消息控制
    IBOutlet UIView*        footerView;         // 发消息控制界面
    IBOutlet UIImageView*   imgViewBkgFooter;   // 发消息控制界面背景
    IBOutlet UIButton*      btnAdd;             // 添加(多类型消息)
    IBOutlet UIButton*      btnTalk;            // 按住说话
    IBOutlet UIButton*      btnType;            // 语音与文字输入切换
    IBOutlet UIButton*      btnSend;            // 发送
    IBOutlet UITextView*    tvInput;            // 文本输入
    IBOutlet UIView*        chooseView;         // 消息类型选择
    IBOutlet UIImageView*   imgViewChooseBkg;   // 消息类型选择背景
    IBOutlet UIButton*      btnPic;             // 图片
    IBOutlet UIButton*      btnCam;             // 相机
    IBOutlet UIButton*      btnLoc;             // 位置
    IBOutlet UIButton*      btnEmo;             // 表情
    
    IBOutlet UITextField*   tfHide;             // 隐式输入框
    
    TalkingRecordView*      recordView;
    EmotionInputView*       emojiView;
    
    
    NSString*   identifierMessageRight;
    NSString*   identifierMessageLeft;
    
    BOOL        shouldScrollToBottom;
}

@property (nonatomic, strong) TCSession*    session;
@property (nonatomic, strong) NSIndexPath*  audioIndex;     // 播放音频的消息位置
@property (nonatomic, strong) NSIndexPath*  failIndex;      // 重发失败消息位置
@property (nonatomic, assign) BOOL          isTypeIn;       // yes:文字输入 no:录音
@property (nonatomic, strong) NSString*     addressString;
@property (nonatomic, strong) NSString*     copyedText;     //需要拷贝的文字内容

@end

@implementation ChatViewController

@synthesize session;
@synthesize audioIndex;
@synthesize failIndex;
@synthesize isTypeIn;
@synthesize addressString;

- (id)initWithSession:(TCSession *)item {
    self = [super initWithNibName:@"ChatViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.session = item;
        [self _init];
    }
    return self;
}
- (id)initWithGroup:(TCGroup *)itemG {
    TCSession* itemS = [[TCSession alloc] init];
    itemS.ID = itemG.ID;
    if (itemG.type == forTCGroupType_Group) {
        itemS.typeChat = forChatTypeGroup;
    } else if (itemG.type == forTCGroupType_Temp) {
        itemS.typeChat = forChatTypeRoom;
    }
    itemS.name = itemG.name;
    itemS.head = itemG.headImgUrlS;
    return [self initWithSession:itemS];
}
- (id)initWithUser:(User *)itemU {
    TCSession* itemS = [[TCSession alloc] init];
    itemS.ID = itemU.ID;
    itemS.typeChat = forChatTypeUser;
    itemS.name = itemU.nickName;
    itemS.head = itemU.headImgUrlS;
    return [self initWithSession:itemS];
}
- (void)_init {
    self.isTypeIn = YES;
    hasMore = NO;
    [contentArr addObjectsFromArray:[[ThinkChat instance] getMessageListTimeLineWithID:session.ID typeChat:session.typeChat sinceRowID:0 maxRowID:0 count:0 page:0]];
    
    [[AppDelegate instance] hasReadSessionID:session.ID typeChat:session.typeChat];

    if (contentArr.count >= defaultSizeInt) {
        hasMore = YES;
    }
    
    identifierMessageRight = @"MessageRightCell";
    identifierMessageLeft = @"MessageLeftCell";
    shouldRefreshIfDropDown = YES;
}
- (void)dealloc {
    [recordView recordCancel];
    recordView = nil;
    emojiView = nil;
    
    // data
    self.session = nil;
    self.audioIndex = nil;
    self.failIndex = nil;
    self.addressString = nil;
    
    // view
    contentView = nil;
    footerView = nil;
    imgViewBkgFooter = nil;
    btnAdd = nil;
    btnTalk = nil;
    btnType = nil;
    btnSend = nil;
    tvInput = nil;
    chooseView = nil;
    imgViewChooseBkg = nil;
    btnPic = nil;
    btnCam = nil;
    btnLoc = nil;
    btnEmo = nil;
    tfHide = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = session.name;
    [self addBarButtonItemBackWithAction:@selector(barButtonItemLeftPressed:)];
    if (forChatTypeUser == self.session.typeChat || forTCGroupType_Group == self.session.typeChat ||
        forChatTypeGroup == self.session.typeChat ) {
        [self addBarButtonItemRightNormalImageName:@"username_icon" hightLited:@"username_icon"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessage:) name:kNotifyReceivedMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearSession:) name:kNotifyClearSession object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitGroup:) name:kNotifyQuitGroup object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editGroup:) name:kNotifyEditGroup object:nil];

    btnPic.titleLabel.textAlignment = NSTextAlignmentCenter;
    btnCam.titleLabel.textAlignment = NSTextAlignmentCenter;
    btnLoc.titleLabel.textAlignment = NSTextAlignmentCenter;
    btnEmo.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    UIImage* imgBkgSend = [[UIImage imageNamed:@"talk_bkg_send.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:5];
    [btnSend setBackgroundImage:imgBkgSend forState:UIControlStateNormal];
    
    [self addKeyBoardControl];
    
    UINib* nibFile = nil;
    nibFile = [UINib nibWithNibName:identifierMessageRight bundle:nil];
    [listView registerNib:nibFile forCellReuseIdentifier:identifierMessageRight];
    nibFile = [UINib nibWithNibName:identifierMessageLeft bundle:nil];
    [listView registerNib:nibFile forCellReuseIdentifier:identifierMessageLeft];
    
    recordView = [[TalkingRecordView alloc] initWithFrame:CGRectMake(80, (self.view.height-160)/2, self.view.width-160, 160) del:self];
    [self.view addSubview:recordView];
    recordView.hidden = YES;
    tfHide.inputView = chooseView;
    imgViewBkgFooter.backgroundColor = RGBCOLOR(234, 234, 234);
    imgViewBkgFooter.layer.borderWidth = 0.5;
    imgViewBkgFooter.layer.borderColor = kColorTitleLightGray.CGColor;
    
    btnTalk.layer.cornerRadius = kCornerRadiusInput;
    btnAdd.clipsToBounds = YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scrollToBottom];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [AudioMsgPlayer cancel];
}
- (void)barButtonItemLeftPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)barButtonItemRightPressed:(id)sender {
    [self hideKeyBoard];
    id con = nil;
    if (session.typeChat == forChatTypeGroup) {//进入群详细资料
        con = [[GroupDetailController alloc] initWithGroup:session.group];
        [self pushViewController:con];
    } else { //进入个人资料详情
        ASUserProfileViewController *userProfile = (ASUserProfileViewController *)[UIResponder createBaseViewController:@"ASUserProfileViewController"];
        userProfile.params = @{kParamUserId : self.session.ID};
        [self pushViewController:userProfile];
    }
}
- (void)btnPressed:(id)sender {
    if (sender == btnEmo) {
        if (emojiView == nil) {
            emojiView = [[EmotionInputView alloc] initWithDelegate:self];
        }
        tvInput.inputView = emojiView;
        self.isTypeIn = YES;
    } else if (sender == btnAdd) {
        if ([tfHide isFirstResponder]) {
            [tfHide resignFirstResponder];
        } else {
            [tfHide becomeFirstResponder];
        }
    } else {
        [self hideKeyBoard];
        
        if (sender == btnType) {
            // 语音与文本切换
            self.isTypeIn = !isTypeIn;
        } else if (sender == btnSend) {
            // 发送
            if (tvInput.text.length > 0) {
                if (tvInput.text.length > 140) {
                    [Globals showAlertTitle:nil msg:@"文本内容不能超过140个字"];
                    return;
                }
                TCMessage* itemM = [self newMessage];
                itemM.typeFile = forFileText;
                itemM.body = [[TCTextMessageBody alloc] init];
                itemM.bodyText.content = [EmotionInputView encodeMessageEmoji:tvInput.text];
                [self sendMessage:itemM];
                [tvInput setText:nil];
            }
        } else if (sender == btnPic) {
            // 相册
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            if ([picker.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
                [picker.navigationBar setBarTintColor:kColorNavBkg];
            } else {
                [picker.navigationBar setTintColor:kColorNavBkg];
            }
            [picker.navigationBar setTitleTextAttributes:@{UITextAttributeTextColor:kColorNavTitle,UITextAttributeTextShadowOffset:[NSNumber numberWithFloat:0.0]}];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.001);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                UIView * superView = nil;
                superView = picker.navigationBar;
                if ([superView isKindOfClass:[UIView class]]) {
                    for(id cc in [superView subviews]) {
                        if([cc isKindOfClass:[UIButton class]]) {
                            UIButton * btn = (UIButton *)cc;
                            btn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
                            [btn setTitle:@"取消"  forState:UIControlStateNormal];
                            [btn.titleLabel setShadowOffset:CGSizeZero];
                            [btn setTitleColor:kColorTitleBlue forState:UIControlStateNormal];
                            [btn setTitleColor:kColorTitleGray forState:UIControlStateHighlighted];
                            [btn setBackgroundImage:nil forState:UIControlStateNormal];
                            [btn setBackgroundImage:nil forState:UIControlStateHighlighted];
                        }
                    }
                }
            });
            
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            [self presentModalViewController:picker animated:YES];
        } else if (sender == btnCam) {
            // 相机
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            if ([picker.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
                [picker.navigationBar setBarTintColor:kColorNavBkg];
            } else {
                [picker.navigationBar setTintColor:kColorNavBkg];
            }
            [picker.navigationBar setTitleTextAttributes:@{UITextAttributeTextColor:kColorNavTitle,UITextAttributeTextShadowOffset:[NSNumber numberWithFloat:0.0]}];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.001);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                UIView * superView = nil;
                superView = picker.navigationBar;
                if ([superView isKindOfClass:[UIView class]]) {
                    for(id cc in [superView subviews]) {
                        if([cc isKindOfClass:[UIButton class]]) {
                            UIButton * btn = (UIButton *)cc;
                            btn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
                            [btn setTitle:@"取消"  forState:UIControlStateNormal];
                            [btn.titleLabel setShadowOffset:CGSizeZero];
                            [btn setTitleColor:kColorTitleBlue forState:UIControlStateNormal];
                            [btn setTitleColor:kColorTitleGray forState:UIControlStateHighlighted];
                            [btn setBackgroundImage:nil forState:UIControlStateNormal];
                            [btn setBackgroundImage:nil forState:UIControlStateHighlighted];
                        }
                    }
                }
            });
            
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentModalViewController:picker animated:YES];
        } else if (sender == btnLoc) {
            // 位置
            id con = [[MapViewController alloc] initWithDelegate:self];
            [self pushViewController:con];
        }
    }
}
- (void)setIsTypeIn:(BOOL)value {
    isTypeIn = value;
    btnTalk.hidden = isTypeIn;
    if (isTypeIn) {
        [tvInput becomeFirstResponder];
        [btnType setImage:[UIImage imageNamed:@"talk_btn_voice"] forState:UIControlStateNormal];
    } else {
        [btnType setImage:[UIImage imageNamed:@"talk_btn_type"] forState:UIControlStateNormal];
    }
}
- (void)scrollToBottom {
    NSInteger section  = [self numberOfSectionsInTableView:listView] - 1;
    if (section >= 0) {
        NSInteger row = [self tableView:listView numberOfRowsInSection:section] -1;
        if (row >= 0) {
            NSIndexPath * indxPath= [NSIndexPath indexPathForRow:row inSection:section];
            [listView scrollToRowAtIndexPath:indxPath atScrollPosition:UITableViewScrollPositionBottom  animated:YES];
        }
    }
}

#pragma mark - Request
- (void)refreshDataList {
    [refreshControl performSelector:@selector(endRefreshing)
                         withObject:nil afterDelay:0
                            inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    [self performSelector:@selector(updateListAfterAddMore) withObject:nil afterDelay:0.25];
}
- (void)updateListAfterAddMore {
    if (hasMore) {
        hasMore = NO;
        TCMessage* itemM = [contentArr firstObject];
        NSArray* arr = [[ThinkChat instance] getMessageListTimeLineWithID:session.ID typeChat:session.typeChat sinceRowID:0 maxRowID:itemM.rowID count:0 page:0];
        if (arr.count >= defaultSizeInt) {
            hasMore = YES;
        }
        if (arr.count > 0) {
            NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, arr.count)];
            [contentArr insertObjects:arr atIndexes:indexSet];
            
            CGFloat marginBottom = listView.contentSize.height;
            [listView reloadData];
            CGFloat offSetY = listView.contentSize.height - marginBottom;
            [listView setContentOffset:CGPointMake(0, offSetY) animated:NO];
        }
    }
}

#pragma mark - Notify Group Quit
- (void)quitGroup:(NSNotification*)sender {
    TCGroup* itemG = sender.object;
    if (((itemG.type == forTCGroupType_Group &&
          session.typeChat == forChatTypeGroup) || (
                                                    itemG.type == forTCGroupType_Temp &&
                                                    session.typeChat == forChatTypeRoom)) && [
                                                                                              itemG.ID isEqualToString:session.ID]) {
        if (!itemG.isLeave) {
            [Globals showAlertTitle:@"你已被管理员移除" msg:nil];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
- (void)editGroup:(NSNotification*)sender {
    TCGroup* itemG = sender.object;
    if (((itemG.type == forTCGroupType_Group &&
          session.typeChat == forChatTypeGroup) || (
                                                    itemG.type == forTCGroupType_Temp &&
                                                    session.typeChat == forChatTypeRoom)) && [
                                                                                              itemG.ID isEqualToString:session.ID]) {
        session.name = itemG.name;
        session.head = itemG.headImgUrlS;
        
        self.navigationItem.title = session.name;
    }
}

#pragma mark - Messages
- (void)receivedMessage:(NSNotification*)sender {
    TCMessage * msg = sender.object;
    if (msg.typeChat == session.typeChat && [msg.withID isEqualToString:session.ID]) {
        if (!msg.isRead) {
            // 在聊天界面收到消息,标记为已读,更新数据库
            msg.isRead = YES;
            [[AppDelegate instance] hasReadSessionID:session.ID typeChat:session.typeChat];
        }
        if (msg.isSendByMe) {
            for (NSInteger i = contentArr.count - 1; i >= 0; i--) {
                TCMessage* itemM = [contentArr objectAtIndex:i];
                if ([itemM.tag isEqualToString:msg.tag]) {
                    [contentArr removeObject:itemM];
                    [contentArr insertObject:msg atIndex:i];
                    [listView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:i]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    break;
                }
            }
        } else {
            [contentArr addObject:msg];
            BOOL shouldScroll = NO;
            if (listView.contentOffset.y + listView.frame.size.height >= listView.contentSize.height) {
                shouldScroll = YES;
            }
            [listView insertSections:[NSIndexSet indexSetWithIndex:contentArr.count - 1] withRowAnimation:UITableViewRowAnimationBottom];
            if (shouldScroll) {
                [self scrollToBottom];
            }
        }
    }
}
- (void)clearSession:(NSNotification*)sender {
    TCSession* itemS = sender.object;
    if ([itemS.ID isEqualToString:session.ID] && itemS.typeChat == session.typeChat) {
        [contentArr removeAllObjects];
        [listView reloadData];
    }
}
- (TCMessage*)newMessage {
    TCMessage* itemM = [TCMessage newMessage];
    
    itemM.from.name = [BaseEngine currentBaseEngine].user.nickName;
    itemM.from.head = [BaseEngine currentBaseEngine].user.headImgUrlL;
    
    itemM.to.ID = session.ID;
    itemM.to.name = session.name;
    itemM.to.head = session.head;
    [itemM.to copyExtendFrom:session];
    itemM.typeChat  = session.typeChat;
    
    return itemM;
}
- (void)sendMessage:(TCMessage*)itemM {
    [itemM.from setExtendValue:@"从哪儿来的?" forKey:@"from扩展"];
    [itemM.to setExtendValue:@"到哪儿去?" forKey:@"to扩展"];
    [itemM.body setExtendValue:@"消息体的扩展" forKey:@"body扩展"];
    [itemM setExtendValue:@"消息本身的扩展" forKey:@"msg扩展"];
    
    
    [contentArr addObject:itemM];
    [listView insertSections:[NSIndexSet indexSetWithIndex:contentArr.count - 1] withRowAnimation:UITableViewRowAnimationBottom];
    [self scrollToBottom];
    [[AppDelegate instance] sendMessage:itemM];
}

#pragma mark - KeyBoardControl
- (void)keyBoardWillShow:(id)sender {
    CGRect frame = self.view.bounds;
    frame.size.height -= keyboardHeight;
    contentView.frame = frame;
    [self scrollToBottom];
}
- (void)keyBoardWillHide:(id)sender {
    contentView.frame = self.view.bounds;
    if (shouldScrollToBottom) {
        shouldScrollToBottom = NO;
        [self scrollToBottom];
    }
    tvInput.inputView = nil;
}

#pragma mark - UIActionSheetDelegate
- (void)showActionSheetWithTitle:(NSString*)strTitle buttonTitles:(NSArray*)arrTitles tag:(int)tag {
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:strTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSString* str in arrTitles) {
        [sheet addButtonWithTitle:str];
    }
    [sheet addButtonWithTitle:@"取消"];
    sheet.cancelButtonIndex = arrTitles.count;
    sheet.tag = tag;
    [sheet showInView:self.view];
    
}
- (void)actionSheet:(UIActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString* strTitle = [sender buttonTitleAtIndex:buttonIndex];
    if ([strTitle isEqualToString:@"取消"]) {
        return;
    }
    if (sender.tag == kTagChatActionSheetCellFail) { // 重新发送
        TCMessage* itemM = [contentArr objectAtIndex:failIndex.section];
        [[AppDelegate instance] sendMessage:itemM];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage * imgGet = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    if (imgGet) {
        imgGet = [UIImage rotateImage:imgGet];
        
        UIImage* imgL = [imgGet resizeImageGreaterThan:1024];
        NSData* dataL = UIImageJPEGRepresentation(imgL, 0.4);
        NSString * pathL = [NSString stringWithFormat:@"%@/tmp/IMG%.0f.jpg", NSHomeDirectory(), [NSDate timeIntervalSinceReferenceDate] * 1000];
        [dataL writeToFile:pathL atomically:YES];
        
        UIImage* imgS = [imgL resizeImageGreaterThan:200];
        NSData* dataS = UIImageJPEGRepresentation(imgS, 0.4);
        NSString * pathS = [NSString stringWithFormat:@"%@/tmp/IMG%.0f.jpg", NSHomeDirectory(), [NSDate timeIntervalSinceReferenceDate] * 1000];
        [dataS writeToFile:pathS atomically:YES];
        
        TCMessage* itemM = [self newMessage];
        
        itemM.body = [[TCImageMessageBody alloc] init];
        itemM.typeFile = forFileImage;
        itemM.bodyImage.imgUrlL = pathL;
        itemM.bodyImage.imgUrlS = pathS;
        itemM.bodyImage.imgWidth = imgS.size.width;
        itemM.bodyImage.imgHeight = imgS.size.height;
        
        [self sendMessage:itemM];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - Audio
- (IBAction)btnTalkTouchBegin:(id)sender {
    [self actionBarTalkStateChanged:TalkStateTalking];
}
- (IBAction)btnTalkTouchCancel:(id)sender {
    [self actionBarTalkStateChanged:TalkStateNone];
}
- (IBAction)btnTalkTouchEnd:(id)sender {
    [self actionBarTalkFinished];
}
- (IBAction)btnTalkDragInside:(id)sender {
    [self actionBarTalkStateChanged:TalkStateTalking];
}
- (IBAction)btnTalkDragOutside:(id)sender {
    [self actionBarTalkStateChanged:TalkStateCanceling];
}
- (void)actionBarTalkStateChanged:(TalkState)sts {
    if (sts == TalkStateTalking) {
        recordView.hidden = NO;
    } else if (sts == TalkStateCanceling) {
        recordView.hidden = NO;
    } else {
        recordView.hidden = YES;
    }
    recordView.state = sts;
}
- (void)actionBarTalkFinished {
    recordView.hidden = YES;
    [recordView recordEnd];
}

#pragma mark - TalkingRecordViewDelegate
- (void)recordView:(TalkingRecordView*)sender didFinish:(NSString*)path duration:(NSTimeInterval)du {
    TCDemoLog(@"record did finish %@, duration: %.0f", path, du);
    if (du > 60.0) {
        [KAlertView showType:KAlertTypeError text:@"录音时间过长" for:1.0 animated:YES];
    } else if (du > 2.0) {
        TCMessage* itemM = [self newMessage];
        
        itemM.body = [[TCVoiceMessageBody alloc] init];
        itemM.typeFile = forFileVoice;
        itemM.bodyVoice.voiceTime = du;
        itemM.bodyVoice.voiceUrl = path;
        
        [self sendMessage:itemM];
    } else {
        [KAlertView showType:KAlertTypeError text:@"录音时间过短" for:1.0 animated:YES];
    }
}

#pragma mark - EmotionInputViewDelegate
- (void)emotionInputView:(id)sender output:(NSString *)str {
    tvInput.text = [NSString stringWithFormat:@"%@%@",tvInput.text,[EmotionInputView emojiText4To5:str]];
}

#pragma mark - BaseMessageCellDelegate
- (void)baseMessageCellDidPressContent:(BaseMessageCell*)sender {
    [self hideKeyBoard];
    NSIndexPath* indexPath = [listView indexPathForCell:sender];
    TCMessage* itemM = [contentArr objectAtIndex:indexPath.section];
    if (itemM.typeFile == forFileVoice) {
        if (audioIndex && audioIndex.section == indexPath.section && audioIndex.row == indexPath.row) {
            [AudioMsgPlayer cancel];
        } else {
            if (audioIndex) {
                BaseMessageCell * cell = (BaseMessageCell*)[listView cellForRowAtIndexPath:audioIndex];
                cell.playing = NO;
            }
            self.audioIndex = indexPath;
            sender.playing = YES;
            
            [AudioMsgPlayer playWithURL:itemM.bodyVoice.voiceUrl delegate:self];
        }
    } else if (itemM.typeFile == forFileImage && itemM.state != forMessageStateHavent) {
        [ImageViewController showWithFrameStart:sender.contentFrame supView:sender pic:itemM.bodyImage.imgUrlL preview:itemM.bodyImage.imgUrlS];
    } else if (itemM.typeFile == forFileLocation) {
        self.addressString = itemM.bodyLocation.address;
        MapViewController* con = [[MapViewController alloc] initWithDelegate:self];
        con.location = LocationMake(itemM.bodyLocation.lat, itemM.bodyLocation.lng);
        con.readOnly = YES;
        [self pushViewController:con];
    }
}
- (void)baseMessageCellDidPressHead:(id)sender {
    NSIndexPath* indexPath = [listView indexPathForCell:sender];
    TCMessage* itemM = [contentArr objectAtIndex:indexPath.section];
    if (!itemM.isSendByMe) {
        id con = [[UserDetailController alloc] initWithUser:[User objectWithTCUser:itemM.from]];
        [self pushViewController:con];
    }
}
- (void)baseMessageCellDidLongPress:(id)sender {
    BaseMessageCell *cell = sender;
    if (cell.message.typeFile == forFileText) {
        self.copyedText = [EmotionInputView decodeMessageEmoji:cell.message.contentFormat];
        UIMenuItem *copyed = [[UIMenuItem alloc] initWithTitle:@"复制"action:@selector(copyed:)];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        menu.arrowDirection = UIMenuControllerArrowDefault;
        [menu setMenuItems:[NSArray arrayWithObjects:copyed, nil]];
        [menu setTargetRect:cell.contentFrame inView:cell.contentView];
        [menu setMenuVisible:YES animated:YES];
    }
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return action == @selector(copyed:);
}
- (void)copyed:(id)sender {
    [[UIPasteboard generalPasteboard] setString:Trim(self.copyedText)];
    [self resignFirstResponder];
}
- (void)baseMessageCellDidPressFail:(id)sender {
    [self hideKeyBoard];
    self.failIndex = [listView indexPathForCell:sender];
    [self showActionSheetWithTitle:@"是否重新发送消息?" buttonTitles:@[@"重新发送"] tag:kTagChatActionSheetCellFail];
}
- (void)audioMsgPlayerDidFinishPlaying:(AudioMsgPlayer*)sender {
    //播放结束时执行的动作
    TCDemoLog(@"audioMsgPlayerDidFinishPlaying");
    if (audioIndex) {
        BaseMessageCell * cell = (BaseMessageCell*)[listView cellForRowAtIndexPath:audioIndex];
        cell.playing = NO;
        self.audioIndex = nil;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
    return contentArr.count;
}
- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCMessage* itemM = [contentArr objectAtIndex:indexPath.section];
    return [BaseMessageCell heightWithItem:itemM];
}
- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseMessageCell* cell = nil;
    TCMessage* itemM = [contentArr objectAtIndex:indexPath.section];
    if (itemM.isSendByMe) {
        cell = [sender dequeueReusableCellWithIdentifier:identifierMessageRight];
    } else {
        cell = [sender dequeueReusableCellWithIdentifier:identifierMessageLeft];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.message = itemM;
    
    if (audioIndex && indexPath.section == audioIndex.section && indexPath.row == audioIndex.row) {
        cell.playing = YES;
    } else {
        cell.playing = NO;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    [self hideKeyBoard];
}

#pragma mark - ImageControl
- (NSInteger)baseTableView:(UITableView *)sender numberOfImagesAtIndexPath:(NSIndexPath *)indexPath {
    TCMessage* itemM = [contentArr objectAtIndex:indexPath.section];
    if (itemM.typeFile == forFileImage) {
        return 2;
    } else {
        return 1;
    }
}
- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    TCMessage* itemM = [contentArr objectAtIndex:indexPath.section];
    if (index == 0) {
        return itemM.from.head;
    } else if (index == 1) {
        if (itemM.typeFile == forFileImage) {
            return itemM.bodyImage.imgUrlS;
        }
    }
    return nil;
}
- (void)baseTableView:(UITableView *)sender loadImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    BaseMessageCell* cell = (BaseMessageCell*)[sender cellForRowAtIndexPath:indexPath];
    if (index == 0) {
        cell.imgHead = image;
    } else if (index == 1) {
        TCMessage* itemM = [contentArr objectAtIndex:indexPath.section];
        if (itemM.typeFile == forFileImage) {
            cell.imgContent = image;
        }
    }
}

#pragma mark - MyLocationControllerDelegate
- (void)mapViewControllerSetLocation:(Location)loc content:(NSString *)con city:(NSString *)city {
    TCMessage* itemM = [self newMessage];
    
    itemM.body = [[TCLocationMessageBody alloc] init];
    itemM.typeFile = forFileLocation;
    itemM.bodyLocation.lat = loc.lat;
    itemM.bodyLocation.lng = loc.lng;
    itemM.bodyLocation.address = con;
    
    [self sendMessage:itemM];
}
- (NSString*)getCurrentSetLocationString {
    return addressString;
}

@end
