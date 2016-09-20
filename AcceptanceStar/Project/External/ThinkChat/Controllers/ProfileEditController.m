//
//  ProfileEditController.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-18.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "ProfileEditController.h"
#import "UploadPreViewController.h"
#import "UIImage+Rotate_Flip.h"
#import "SingleTextFieldController.h"
#import "SingleTextViewController.h"
#import "User.h"

@interface ProfileEditController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SingleTextFieldDelegate, SingleTextViewDelegate>

@property (nonatomic, strong) User*     user;
@property (nonatomic, strong) UIImage*  imgHead;
@property (nonatomic, strong) UIImage*  imgOriginal;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* sign;
@property (nonatomic, assign) Gender    gender;

@end

@implementation ProfileEditController

@synthesize user;
@synthesize imgHead;
@synthesize imgOriginal;
@synthesize name;
@synthesize sign;
@synthesize gender;

- (id)initWithUser:(User *)item
{
    self = [super initWithNibName:@"ProfileEditController" bundle:nil];
    if (self) {
        // Custom initialization
        self.user = item;
        self.gender = user.gender;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"编辑资料";
    
    [self addBarButtonItemRightNormalImageName:@"nav_ok_n" hightLited:@"nav_ok_d"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)barButtonItemRightPressed:(id)sender {
    if (imgHead == nil && name == nil && sign == nil && gender == user.gender) {
        [WCAlertView showAlertWithTitle:@"提示" message:@"未做任何修改" customizationBlock:nil completionBlock:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        return;
    }
    [self sendRequest];
}

- (NSString*)genderString {
    NSString* genderString = nil;
    if (gender == male) {
        genderString = @"男";
    } else if (gender == female) {
        genderString = @"女";
    } else if (gender == genderNo) {
        genderString = @"保密";
    }
    return genderString;
}

#pragma mark - Request

- (BOOL)sendRequest {
    if ([super sendRequest]) {
        [client modifyUserHead:imgHead nickName:name gender:gender sign:sign];
        return YES;
    }
    return NO;
}

- (BOOL)getResponse:(BaseClient *)sender obj:(NSDictionary *)obj {
    if ([super getResponse:sender obj:obj]) {
        NSDictionary* dic = [obj objectForKey:@"data"];
        [user updateWithJsonDic:dic];
        [[BaseEngine currentBaseEngine] saveAuthorizeData];
        [KAlertView showType:KAlertTypeCheck text:@"修改成功" for:1.0 animated:YES];
        [self popViewController];
        return YES;
    }
    return NO;
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 100;
    } else {
        CGFloat height = 44.0;
        NSString* strDisplay = nil;
        
        if (indexPath.row == 0) {
            if (name) {
                strDisplay = name;
            } else {
                strDisplay = user.nickName;
            }
        } else if (indexPath.row == 1) {
            strDisplay = user.genderString;
        } else if (indexPath.row == 2) {
            if (sign) {
                strDisplay = sign;
            } else {
                strDisplay = user.sign;
            }
        }
        
        
        if (strDisplay) {
            height = [strDisplay sizeWithFont:[UIFont systemFontOfSize:14] maxWidth:190 maxNumberLines:0].height + 20;
        }
        
        if (height < 44) {
            height = 44;
        }
        return height;
    }
    
    return 44;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * CellIdentifier = @"Cell";
    
    BaseTableViewCell* cell = [listView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = nil;
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    cell.imageView.image = nil;
    
    if (indexPath.section == 0) {
        if (imgHead) {
            cell.imageView.image = imgHead;
        }else if (imgOriginal) {
            cell.imageView.image = imgOriginal;
        } else {
            cell.imageView.image = kImageDefaultHeadUser;
        }
    } else if (indexPath.row == 0) {
        cell.textLabel.text = @"昵称";
        if (name) {
            cell.detailTextLabel.text = name;
        } else {
            cell.detailTextLabel.text = user.nickName;
        }
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"性别";
        cell.detailTextLabel.text = [self genderString];
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"个性签名";
        if (sign) {
            cell.detailTextLabel.text = sign;
        } else {
            cell.detailTextLabel.text = user.sign;
        }
    }
    
    return cell;
}

// Header

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(BaseTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        // 头像
        [cell update:^{
            CGRect frame = cell.contentView.frame;
            CGRect frameImg = CGRectMake(10, 4, frame.size.height - 8, frame.size.height - 8);
            cell.imageView.frame = frameImg;
        }];
    } else {
        [cell update:^{
            cell.textLabel.frame = CGRectMake(10, 2, 70, 40);
            cell.detailTextLabel.frame = CGRectMake(100, 2, 190, cell.contentView.height-4);
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    id con = nil;

    if (indexPath.section == 0) {
        UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
        sheet.tag = 1;
        [sheet showInView:self.view];
    } else {
        if (indexPath.row == 0) {
            con = [[SingleTextFieldController alloc] initWithTitle:@"昵称" placeHolder:@"请输入昵称" delegate:self];
        } else if (indexPath.row == 1) {
            UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女",@"保密", nil];
            sheet.tag = 2;
            [sheet showInView:self.view];
        } else if (indexPath.row == 2) {
            con = [[SingleTextViewController alloc] initWithTitle:@"个性签名" placeHolder:@"请输入个性签名" delegate:self];
        }
    }
    
    [self pushViewController:con];
}

#pragma mark - ImageControl

- (NSInteger)baseTableView:(UITableView *)sender numberOfImagesAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (imgOriginal == nil) {
            return 1;
        }
    }
    return 0;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    return user.headImgUrlL;
}

- (void)baseTableView:(UITableView *)sender loadImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index {
    self.imgOriginal = image;
    [listView reloadData];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString* strTitle = [sender buttonTitleAtIndex:buttonIndex];
    if ([strTitle isEqualToString:@"取消"]) {
        return;
    }
    
    if (sender.tag == 1) {
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
        if ([strTitle isEqualToString:@"相册"]) {
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        } else {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        [self presentModalViewController:picker animated:YES];
    } else if (sender.tag == 2) {
        if ([strTitle isEqualToString:@"男"]) {
            self.gender = male;
        } else if ([strTitle isEqualToString:@"女"]) {
            self.gender = female;
        } else if ([strTitle isEqualToString:@"保密"]) {
            self.gender = genderNo;
        }
        [listView reloadData];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage * img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    img = [UIImage rotateImage:img];
    UploadPreViewController * con = [[UploadPreViewController alloc] initWithImage:img delegate:self];
    [picker pushViewController:con animated:YES];
}

#pragma mark - UploadPreViewControllerDelegate

- (void)previewImageDid:(BaseViewController*)sender image:(UIImage*)img {
    [sender dismissViewControllerAnimated:YES completion:^{
        self.imgHead = img;
        [listView reloadData];
    }];
}

#pragma mark - SingleTextFieldDelegate

- (void)singleTextField:(id)sender inputString:(NSString *)text {
    self.name = text;
    [listView reloadData];
}

#pragma mark - SingleTextViewDelegate

- (void)singleTextView:(id)sender inputString:(NSString *)text {
    self.sign = text;
    [listView reloadData];
}

@end
