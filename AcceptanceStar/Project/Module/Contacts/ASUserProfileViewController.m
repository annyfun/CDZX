//
//  ASUserProfileViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/9/5.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASUserProfileViewController.h"
#import "ChatViewController.h"

@interface ASUserProfileViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UIImageView *genderImageView;
@property (nonatomic, weak) IBOutlet UILabel *nickNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *ageLabel;
@property (nonatomic, weak) IBOutlet UILabel *signLabel;

@property (nonatomic, weak) IBOutlet UILabel *positionLabel;//职务 type
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;//业务所在地：province+city
@property (nonatomic, weak) IBOutlet UIView *groupView;
@property (nonatomic, weak) IBOutlet UILabel *groupNameLabel;//所在分组 sgid

@property (nonatomic, weak) IBOutlet UIButton *sendMsgButton;//发消息
@property (nonatomic, weak) IBOutlet UIButton *addFriendButton;//加为好友

@property (nonatomic, strong) UserModel *user;

@end

@implementation ASUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title  =@"详细资料";
    if (self.params[kParamModel]) {
        self.user = self.params[kParamModel];
    }
    else {
        [self refreshUserInfo];
    }
    [self.sendMsgButton makeRoundWithRadius:5];
    [self.addFriendButton makeRoundWithRadius:5];
    [self layoutUserInfo];
    [self initBlocks];
}
- (void)initBlocks {
    WEAKSELF
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"icon_more1"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        UIActionSheet *actionSheet = [UIActionSheet new];
        [actionSheet bk_addButtonWithTitle:@"举报" handler:^{
            [blockSelf pushViewController:@"ASJuBaoViewController" withParams:@{@"fuid" : Trim(blockSelf.user.userId)}];
        }];
        [actionSheet bk_addButtonWithTitle:@"备注" handler:^{
            UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"添加备注"];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField *textField = [alertView textFieldAtIndex:0];
            textField.placeholder = @"请输入备注名称";
            textField.text = Trim(blockSelf.user.remark);
            [alertView bk_addButtonWithTitle:@"确定" handler:^{
                if (isEmpty(textField.text)) {
                    [blockSelf showAlertVieWithMessage:@"备注不能为空！"];
                    return ;
                }
                else {
                    [blockSelf showHUDLoading:@"正在修改备注"];
                    [AFNManager postDataWithAPI:kResPathAppUserAddRemark
                                   andDictParam:@{@"fuid" : Trim(blockSelf.user.userId),
                                                  @"remark" : Trim(textField.text)}
                                      modelName:nil
                               requestSuccessed:^(id responseObject) {
                                   blockSelf.user.remark = Trim(textField.text);
                                   [blockSelf layoutUserInfo];
                                   [blockSelf showResultThenHide:@"修改成功"];
                    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                        [blockSelf hideHUDLoading];
                        [blockSelf showAlertVieWithMessage:errorMessage];
                    }];
                }
            }];
            [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
            [alertView show];
        }];
        if (blockSelf.user.isfriend) {
            [actionSheet bk_addButtonWithTitle:@"删除好友" handler:^{
                [blockSelf deleteFriend];
            }];
        }
        [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [actionSheet showInView:blockSelf.view];
    }];
    //移动好友
    [self.groupView bk_whenTapped:^{
        YSCResultBlock block = ^(NSObject *object){
            blockSelf.groupNameLabel.text = [NSString stringWithFormat:@"%@", object];
        };
        [blockSelf pushViewController:@"ASGroupManageViewController"
                           withParams:@{kParamTitle : @"移动好友",
                                        kParamBlock : block,
                                        @"groupName" : Trim(blockSelf.user.sgid),
                                        @"fuid" : Trim(blockSelf.user.userId)}];
    }];
}
- (void)refreshUserInfo {
    WEAKSELF
    [self showHUDLoading:@"正在下载用户详情"];
    [AFNManager getDataWithAPI:kResPathAppUserDetail
                  andDictParam:@{@"fuid" : Trim(self.params[kParamUserId])}
                     modelName:ClassOfObject(UserModel)
              requestSuccessed:^(id responseObject) {
                  [blockSelf hideHUDLoading];
                  if ( [NSObject isNotEmpty:responseObject] && [responseObject isKindOfClass:[UserModel class]]) {
                      blockSelf.user = responseObject;
                      [blockSelf layoutUserInfo];
                  }
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    [blockSelf hideHUDLoading];
                    [blockSelf showAlertVieWithMessage:errorMessage];
                }];
}
- (void)layoutUserInfo {
    [self.avatarImageView setImageWithURLString:self.user.headsmall placeholderImageName:@"default_head_user"];
    if (isNotEmpty(self.user.remark)) {
        self.nickNameLabel.text = [NSString stringWithFormat:@"%@(%@)(星星号:%@)", Trim(self.user.remark), Trim(self.user.nickname), self.user.userId];
    }
    else {
        self.nickNameLabel.text = [NSString stringWithFormat:@"%@(星星号:%@)", Trim(self.user.nickname), self.user.userId];
    }
    if ([@"女" isEqualToString:self.user.sex]) {
        self.genderImageView.image = [UIImage imageNamed:@"gender_female1"];
    }
    else {
        self.genderImageView.image = [UIImage imageNamed:@"gender_male1"];
    }
    self.ageLabel.text = [NSString stringWithFormat:@"%ld", (long)self.user.age];
    self.signLabel.text = Trim(self.user.sign);
    self.positionLabel.text = Trim(self.user.type);
    self.locationLabel.text = [NSString stringWithFormat:@"%@%@", self.user.province, self.user.city];
   
    self.groupView.hidden = !self.user.isfriend;
    self.addFriendButton.hidden = self.user.isfriend;
    self.groupNameLabel.text = Trim(self.user.sgid);
}

- (void)deleteFriend {
    WEAKSELF
    [self showHUDLoading:@"正在删除好友"];
    [AFNManager postDataWithAPI:kResPathAppUserDeleteFriend
                   andDictParam:@{@"fuid" : Trim(self.user.userId)}
                      modelName:nil requestSuccessed:^(id responseObject) {
                          [blockSelf showResultThenBack:@"删除成功"];
                          if (blockSelf.block) {
                              blockSelf.block(nil);
                          }
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [blockSelf hideHUDLoading];
        [blockSelf showAlertVieWithMessage:errorMessage];
    }];
}

#pragma mark - 按钮事件

- (IBAction)sendMsgButtonClicked:(id)sender {
    User *user = [self.user createUser];
    ChatViewController *chatVC = [[ChatViewController alloc] initWithUser:user];
    [self.navigationController pushViewController:chatVC animated:YES];
}
- (IBAction)addFriendButtonClicked:(id)sender {
    WEAKSELF
    [self showHUDLoading:@"正在申请加好友"];
    [AFNManager postDataWithAPI:kResPathAppUserApplyAddFriend
                   andDictParam:@{@"fuid" : Trim(self.user.userId)}
                      modelName:nil
               requestSuccessed:^(id responseObject) {
                   [blockSelf showResultThenHide:@"申请发送成功"];
               } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                   [blockSelf hideHUDLoading];
                   [blockSelf showAlertVieWithMessage:errorMessage];
               }];
}

@end
