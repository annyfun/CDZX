//
//  GroupModifyController.m
//  ThinkChatDemo
//
//  Created by keen on 14-8-12.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "GroupModifyController.h"
#import "SingleTextFieldController.h"
#import "SingleTextViewController.h"
#import "UploadPreViewController.h"
#import "UIImage+Rotate_Flip.h"
#import "TCGroup.h"

@interface GroupModifyController () <SingleTextFieldDelegate, SingleTextViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, TCResultNoneDelegate> {
    IBOutlet UIView*    footerView;
    IBOutlet UIButton*  btnCreate;
}

@property (nonatomic, strong) TCGroup*    group;

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) UIImage*  headImage;
@property (nonatomic, strong) NSString* detail;

@end

@implementation GroupModifyController

@synthesize group;

@synthesize name;
@synthesize headImage;
@synthesize detail;

- (id)initWithGroup:(TCGroup *)item
{
    self = [super initWithNibName:@"GroupModifyController" bundle:nil];
    if (self) {
        // Custom initialization
        self.group = item;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"编辑群组";
    
    [btnCreate setBackgroundImage:[UIImage imageWithColor:kColorBtnBkgBlue] forState:UIControlStateNormal];
    [btnCreate setTitleColor:kColorWhite forState:UIControlStateNormal];
    btnCreate.layer.cornerRadius = kCornerRadiusButton;
    btnCreate.clipsToBounds = YES;
    
    listView.tableFooterView = footerView;
}

- (void)dealloc {
    footerView = nil;
    btnCreate = nil;
    
    self.name = nil;
    self.headImage = nil;
    self.detail = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnPressed:(id)sender {
    if (sender == btnCreate) {
        if (name && detail) {
            [self sendRequest];
        } else {
            [WCAlertView showAlertWithTitle:@"提示" message:@"名称与描述不能为空" customizationBlock:nil completionBlock:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        }
    }
}

#pragma mark - Request

- (BOOL)sendRequest {
    if ([super sendRequest]) {
        tagRequest = [[ThinkChat instance] modifyGroup:group.ID name:name headImage:headImage description:detail extend:nil delegate:self];
        return YES;
    }
    return NO;
}

#pragma mark - TCResultNoneDelegate

- (void)tcResultNoneError:(TCError *)itemE {
    [super getResponse:nil obj:nil];
    if (itemE == nil) {
        
    } else {
        [KAlertView showType:KAlertTypeError text:itemE.message for:1.5 animated:YES];
    }
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        return 44;
    } else {
        CGFloat height = 44.0;
        NSString* strDisplay = nil;
        if (indexPath.row == 0) {
            if (name) {
                strDisplay = name;
            }
        } else if (indexPath.row == 2) {
            if (detail) {
                strDisplay = detail;
            }
        }
        if (strDisplay) {
            height = [strDisplay sizeWithFont:[UIFont systemFontOfSize:14] maxWidth:200 maxNumberLines:0].height + 20;
        }
        
        if (height < 44) {
            height = 44;
        }
        return height;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * CellIdentifier = nil;
    
    if (indexPath.row == 1) {
        CellIdentifier = @"CellImage";
    } else {
        CellIdentifier = @"Cell";
    }
    
    BaseTableViewCell* cell = [listView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    cell.detailTextLabel.text = nil;
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"群名称";
        if (name) {
            cell.detailTextLabel.text = name;
        } else {
            cell.detailTextLabel.text = @"请填写群名称";
        }
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"群头像";
        if (headImage) {
            cell.imageView.image = headImage;
        }
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"群描述";
        if (detail) {
            cell.detailTextLabel.text = detail;
        } else {
            cell.detailTextLabel.text = @"请填写群描述";
        }
    }
    
    return cell;
}

// Header

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 25;
    }
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [[UIView alloc] init];
    }
    return nil;
}

// Footer

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 25;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(BaseTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    
    if (indexPath.row == 1) {
        [cell update:^{
            cell.textLabel.frame = CGRectMake(10, 2, 70, 40);
            CGRect frame = cell.contentView.frame;
            CGRect frameImg = CGRectMake(frame.size.width - frame.size.height, 4, frame.size.height - 8, frame.size.height - 8);
            cell.imageView.frame = frameImg;
        }];
    } else {
        [cell update:^{
            cell.textLabel.frame = CGRectMake(10, 2, 70, 40);
            cell.detailTextLabel.frame = CGRectMake(10 + 70 + 8, 2, 200, cell.contentView.height-4);
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    id con = nil;
    
    if (indexPath.row == 0) {
        // 名称
        con = [[SingleTextFieldController alloc] initWithTitle:@"群名称" placeHolder:@"请输入群名称" delegate:self];
    } else if (indexPath.row == 1) {
        // 头像
        UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
        [sheet showInView:self.view];
    } else if (indexPath.row == 2) {
        // 描述
        con = [[SingleTextViewController alloc] initWithTitle:@"群描述" placeHolder:@"请输入群描述" delegate:self];
    }
    [self pushViewController:con];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2) {
		return;
	}
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
	if (buttonIndex == 1) {
		picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	} else {//buttonIndex == 0
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
	[self presentModalViewController:picker animated:YES];
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
        self.headImage = img;
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
    self.detail = text;
    [listView reloadData];
}

@end
