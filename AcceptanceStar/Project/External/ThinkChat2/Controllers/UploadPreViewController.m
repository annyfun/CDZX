//
//  UploadPreViewController.m
//  XAddrBook
//
//  Created by NigasMone on 13-8-28.
//  Copyright (c) 2013年 NigasMone. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UploadPreViewController.h"
#import "UIImage+Resize.h"

#define IMG_Width 273
#define IMG_Height 416

@interface UploadPreViewController ()<UIScrollViewDelegate> {
    UIButton * btnDel;
    CGFloat imageScale;
    CGFloat imageMinScale;
    CGFloat hw;
    CGFloat std_hw;
    BOOL defaultHidden;
}

@end

@implementation UploadPreViewController
@synthesize imageView;
@synthesize scrollView;
@synthesize image;
@synthesize delegate;

- (id)initWithImage:(UIImage*)img delegate:(id)del {
    if (self = [super initWithNibName:@"UploadPreViewController" bundle:nil]) {
        // Custom initialization
        self.image = img;delegate = del;
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
    return self;
}

- (void)dealloc {
    btnDel = nil;
    image = nil;
    self.imageView = nil;
    self.scrollView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"裁剪图片";
    self.view.backgroundColor = RGBCOLOR(221, 221, 221);
    self.view.clipsToBounds = YES;
    [self addBarButtonItemRightNormalImageName:@"nav_ok_n" hightLited:@"nav_ok_d"];
    self.scrollView.zoomScale = 1.0;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.showsHorizontalScrollIndicator =
    self.scrollView.showsVerticalScrollIndicator = NO;
    scrollView.clipsToBounds = NO;
    screenFrame = scrollView.frame;
    screenFrame.origin = CGPointZero;
    CGFloat kw = screenFrame.size.width;
    CGFloat kh = screenFrame.size.height;
    hw = self.image.size.height/self.image.size.width;
    CGFloat contentWidth = kw;
    CGFloat contentHeight = kh;
    
    std_hw = screenFrame.size.height/screenFrame.size.width;
    imageScale = self.image.size.width/kw;
    if (self.image.size.height/kh > imageScale) {
        imageScale = self.image.size.height/kh;
    }
    imageScale += 0.8;
    if (imageScale < 5.) {
        imageScale = 5.;
    }
    
    self.imageView.image = self.image;
    if (hw > std_hw) {
        contentWidth = contentHeight/hw;
        [imageView setFrame:CGRectMake((kw-contentWidth)/2, 0, contentWidth, contentHeight)];
        imageMinScale = kw / contentWidth;
    } else if (hw < std_hw) {
        contentHeight = contentWidth*hw;
        [imageView setFrame:CGRectMake(0, (kh-contentHeight)/2, contentWidth, contentHeight)];
        imageMinScale = kh / contentHeight;
    } else{
        [imageView setFrame:CGRectMake(0, 0, kw, kh)];
        imageMinScale = 1.0f;
    }
    if (imageScale < imageMinScale + 0.8) {
        imageScale = imageMinScale + 0.8;
    }
    self.scrollView.maximumZoomScale = imageScale;
    
    UITapGestureRecognizer * doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapGesture];
    
    defaultHidden = self.navigationController.navigationBarHidden;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [scrollView setZoomScale:imageMinScale animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:defaultHidden animated:animated];
}

- (UIImage*)image {
    return image;
}

- (void)setImage:(UIImage*)img {
    image = img;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)sender {
    return imageView;
}

- (void)scrollViewDidZoom:(UIScrollView*)sender {
    CGRect frame = imageView.frame;
    
    if (hw > std_hw) {
        frame.origin.x = (screenFrame.size.width-frame.size.width)/2;
        if (frame.origin.x < 0) {
            frame.origin.x = 0;
        }
    } else if (hw < std_hw) {
        frame.origin.y = (screenFrame.size.height-frame.size.height)/2;
        if (frame.origin.y < 0) {
            frame.origin.y = 0;
        }
    }
    
    [imageView setFrame:frame];
}

- (UIImage*)getShotImage {
    CGPoint point = scrollView.contentOffset;
    CGSize scrollSize = scrollView.frame.size;
    CGSize viewSize = imageView.frame.size;
    CGFloat perX = point.x / viewSize.width; // 起始x点比例
    CGFloat perY = point.y / viewSize.height; // 起始y点比例
    CGFloat perW = scrollSize.width / viewSize.width; // 长度比例
    CGFloat perH = scrollSize.height / viewSize.height; // 高度比例
    CGRect rect = CGRectMake(perX * image.size.width, perY * image.size.height, perW * image.size.width, perH * image.size.height);
    UIImage * croppedImage = [self.imageView.image croppedImage:rect];
    CGSize newSize = CGSizeMake(300, 300);
    croppedImage = [croppedImage resizeImageGreaterThan:newSize.width];
//    UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil);
    return croppedImage;
}

- (void)doubleTap {
    if (scrollView.zoomScale > imageMinScale) {
        [scrollView setZoomScale:imageMinScale animated:YES];
    } else {
        [scrollView setZoomScale:scrollView.maximumZoomScale animated:YES];
    }
}

- (void)barButtonItemRightPressed:(id)sender {
    self.image = [self getShotImage];
    if ([delegate respondsToSelector:@selector(previewImageDid:image:)]) {
        [delegate previewImageDid:self image:self.image];
    }
}

@end
