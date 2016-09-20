//
//  ASFriendCircleViewController.m
//  AcceptanceStar
//
//  Created by yangshengchao on 15/5/29.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "ASMomentsViewController.h"
#import "LZAlbumTableViewCell.h"
#import "LZAlbumOperationView.h"
#import "LZAlbumReplyView.h"

@interface ASMomentsViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate,ZYQAssetPickerControllerDelegate, LZAlbumTableViewCellDelegate,MCAlbumOperationViewDelegate,MCAlbumReplyViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *headerBgImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView  *avatarImageView;

@property (nonatomic,strong) LZAlbumOperationView *albumOperationView;
@property (nonatomic,strong) LZAlbumReplyView *albumReplyView;
@property (nonatomic,strong) NSIndexPath *selectedIndexPath;
@property (nonatomic,strong) NSMutableArray *lcAlbums;
@property (nonatomic,strong) NSIndexPath *commentSelectedIndexPath;

@end

@implementation ASMomentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSAssert(self.params[kParamUserId], @"userId为空");
    
    self.albumOperationView = [LZAlbumOperationView initialOperationView];
    self.albumOperationView.albumOperationViewDelegate = self;
    self.albumReplyView = [[LZAlbumReplyView alloc] initWithFrame:CGRectZero];
    self.albumReplyView.albumReplyViewDelegate = self;
    [self.view addSubview:self.albumReplyView];
    
    WeakSelfType blockSelf = self;
    self.title = @"朋友圈";
    //判断是否有发布朋友圈的入口
    if (ISLOGGED && [USERID isEqualToString:Trim(self.params[kParamUserId])]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"icon_share"] style:UIBarButtonItemStylePlain handler:^(id sender) {
            [blockSelf pushViewController:@"ASCreateMomentViewController"];
        }];
        //更换朋友圈背景图片
        self.headerBgImageView.userInteractionEnabled = YES;
        [self.headerBgImageView bk_whenTapped:^{
            [UIView showImagePickerActionSheetWithDelegate:blockSelf allowsEditing:YES singleImage:YES numberOfSelection:1 onViewController:blockSelf];
        }];
    }
    [self.headerBgImageView setImageWithURLString:self.params[@"facepic"]];
    self.nickNameLabel.text = Trim(self.params[kParamNickName]);
    [self.avatarImageView setImageWithURLString:self.params[@"headsmall"]];

    [self.headerView resetFontSizeOfView];
    [self.headerView resetConstraintOfView];
    self.headerView.height = AUTOLAYOUT_LENGTH(340);
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    
    addNObserver(@selector(refreshMoments), @"ASMomentsViewController_refreshMoments");
}
- (void)refreshMoments {
    [self.tableView.header beginRefreshing];
}

//点赞
-(void)albumOperationView:(LZAlbumOperationView *)albumOperationView didClickOfType:(MCAlbumOperationType)operationType {
    if (ISLOGGED) {
        if(MCAlbumOperationTypeLike == operationType) {
            LZAlbum *album = self.dataArray[self.selectedIndexPath.row];
            NSMutableArray *array = (NSMutableArray *)album.albumShareLikes;
            WEAKSELF
            if (NO == [array containsObject:USER.nickname]) {
                [self showHUDLoading:@"正在点赞"];
                [AFNManager getDataWithAPI:kResPathAppMomentsLike
                              andDictParam:@{@"pid" : Trim(album.pid)}
                                 modelName:nil
                          requestSuccessed:^(id responseObject) {
                              [blockSelf showResultThenHide:@"点赞成功"];
                              [array addObject:Trim(USER.nickname)];
                              [blockSelf.tableView reloadRowsAtIndexPaths:@[blockSelf.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                              
                          } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                              [blockSelf showResultThenHide:@"点赞失败"];
                          }];
            }
        }
        else {
            [self.albumReplyView show];
        }
    }
    [albumOperationView dismiss];
}

//发布评论
-(void)albumReplyView:(LZAlbumReplyView *)albumReplyView didReply:(NSString *)text{
    if (ISLOGGED) {
        LZAlbum *album = self.dataArray[self.selectedIndexPath.row];
        NSMutableArray *array = (NSMutableArray *)album.albumShareComments;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"content"] = Trim(text);
        params[@"pid"] = Trim(album.pid);
        if (self.commentSelectedIndexPath && self.commentSelectedIndexPath.row < [array count]) {
            LZAlbumComment *comment = array[self.commentSelectedIndexPath.row];
            params[@"parent_id"] = Trim(comment.userId);
        }
        
        WEAKSELF
        [self showHUDLoading:@"正在评论"];
        [AFNManager postDataWithAPI:kResPathAppMomentsReview
                      andDictParam:params
                         modelName:nil
                  requestSuccessed:^(id responseObject) {
                      [blockSelf showResultThenHide:@"评论成功"];
                      LZAlbumComment *temp = [LZAlbumComment new];
                      temp.userId = USERID;
                      temp.commentUsername = USER.nickname;
                      temp.commentContent = text;
                      [array addObject:temp];
                      [blockSelf.tableView reloadRowsAtIndexPaths:@[blockSelf.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                  }
                    requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                        [blockSelf showResultThenHide:@"评论失败"];
                    }];
    }
    [self.albumReplyView finishReply];
}

#pragma mark - 重写基类方法

- (NSArray *)preProcessData:(NSArray *)anArray {
    NSMutableArray *array = [NSMutableArray array];
    for (MomentsIndexModel *moment in anArray) {
        LZAlbum *data = [LZAlbum new];
        data.pid = moment.id;
        data.username = moment.userName;
        data.avatarUrl = moment.userAvatar;
        data.albumShareContent = moment.text;
        data.albumShareTimestamp = [NSDate dateFromTimeStamp:moment.date];
        
        NSMutableArray* photoUrls=[NSMutableArray array];
        if ([moment.pic isKindOfClass:[NSArray class]]) {
            [photoUrls addObjectsFromArray:(NSArray *)moment.pic];
        }
        data.albumSharePhotos = photoUrls;
        
        NSMutableArray* likeNames = [NSMutableArray array];
        if ([moment.like_user isKindOfClass:[NSArray class]]) {
            for (LikesUserModel *model in moment.like_user) {
                [likeNames addObject:model.nickName];
            }
        }
        data.albumShareLikes = likeNames;
        
        NSMutableArray* albumComments = [NSMutableArray array];
        if ([moment.review isKindOfClass:[NSArray class]]) {
            for(ReviewModel* comment in (NSArray *)moment.review){
                LZAlbumComment* albumComment = [[LZAlbumComment alloc] init];
                albumComment.userId = comment.pid;
                albumComment.commentUsername = comment.nickName;
                albumComment.commentContent = comment.content;
                [albumComments addObject:albumComment];
            }
        }
        data.albumShareComments = albumComments;
        [array addObject:data];
    }
    return array;
}
- (NSString *)methodWithPath {
    return kResPathAppMomentsIndex;
}
- (NSDictionary *)dictParamWithPage:(NSInteger)page {
//    return @{@"uid" : Trim(self.params[kParamUserId]),
//             kParamPage : @(page),
//             kParamPageSize : @(kDefaultPageSize)};
    
    return @{
             kParamPage : @(page),
             kParamPageSize : @(kDefaultPageSize)};

    
}
- (Class)modelClassOfData {
    return ClassOfObject(MomentsIndexModel);
}
- (NSString *)hintStringWhenNoData {
    return @"没有朋友圈消息";
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellIdentifer=@"albumTableViewCellIdentifier";
    LZAlbumTableViewCell* albumTableViewCell= [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if(albumTableViewCell==nil){
        albumTableViewCell=[[LZAlbumTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    albumTableViewCell.albumTableViewCellDelegate = self;
    albumTableViewCell.indexPath = indexPath;
    albumTableViewCell.currentAlbum = self.dataArray[indexPath.row];
    return albumTableViewCell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [LZAlbumTableViewCell calculateCellHeightWithAlbum:self.dataArray[indexPath.row]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.albumReplyView dismiss];
}

#pragma mark - Cell Delegate

-(void)didCommentButtonClick:(UIButton *)button indexPath:(NSIndexPath *)indexPath{
    if(self.albumOperationView.shouldShowed==YES){
        [self.albumOperationView dismiss];
        return;
    }
    CGRect rectInTablew=[self.tableView rectForRowAtIndexPath:indexPath];
    CGFloat originY=rectInTablew.origin.y+button.frame.origin.y;
    CGRect targeRect=CGRectMake(button.frame.origin.x, originY, CGRectGetWidth(button.frame), CGRectGetHeight(button.frame));
    self.commentSelectedIndexPath=nil;
    self.selectedIndexPath=indexPath;
    [self.albumOperationView showAtView:self.tableView rect:targeRect];
}
-(void)didSelectCommentAtCellIndexPath:(NSIndexPath *)cellIndexPath commentIndexPath:(NSIndexPath *)commentIndexPath{
    self.commentSelectedIndexPath=commentIndexPath;
    self.selectedIndexPath=cellIndexPath;
    [self.albumReplyView show];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if ( ! pickedImage) {
        pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    //处理获得的图片对象
    if (pickedImage) {
        pickedImage = [YSCImageUtils resizeImage:pickedImage toSize:CGSizeMake(640, 310)];
        [self uploadBgImage:pickedImage];
    }
    else {
        [self showResultThenHide:@"未选择图片"];
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}
- (void)uploadBgImage:(UIImage *)image {
    WEAKSELF
    [self showHUDLoading:@"正在上传背景图"];
    [AFNManager uploadImageDataParam:@{@"facepic" : image} toUrl:kResPathAppBaseUrl withApi:kResPathAppMomentsFacePic andDictParam:nil modelName:[UserModel class] imageQuality:ImageQualityHigh requestSuccessed:^(id responseObject) {
        [blockSelf showResultThenHide:@"上传成功"];
        blockSelf.headerBgImageView.image = image;
        UserModel *userModel = (UserModel *)responseObject;
        if ([userModel isKindOfClass:[UserModel class]]) {
            [LOGIN resetUser:userModel];
        }
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [blockSelf hideHUDLoading];
        [blockSelf showAlertVieWithMessage:errorMessage];
    }];
}

@end
