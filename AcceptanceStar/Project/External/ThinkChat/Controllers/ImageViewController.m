//
//  ImageViewController.m
//  guphoto
//
//  Created by kiwi on 5/13/13.
//  Copyright (c) 2013 xizue. All rights reserved.
//

#import "ImageViewController.h"
#import "ImageProgressQueue.h"

static ImageViewController * imageViewController = nil;

@interface ImageViewController () {
    CGRect screenFrame;
    CGFloat hw;
    CGFloat std_hw;
    
    CGRect startFrame;
    NSString * imageURL;
    
    NSString * preURL;
    
    UIView * superView;
    CGRect contentFrame;
}
@property (nonatomic, strong) ImageProgress * progress;
@property (nonatomic, readonly) CGRect startFrame;

@end

@implementation ImageViewController
@synthesize progress;

+ (void)showWithFrameStart:(CGRect)fra supView:(UIView*)supv pic:(NSString*)pic preview:(NSString*)pre {
    imageViewController = nil;
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    window.userInteractionEnabled = NO;
    imageViewController = [[ImageViewController alloc] initWithFrameStart:fra supView:supv pic:pic preview:pre];
    [window addSubview:imageViewController.view];
    [imageViewController viewDidAppear:YES];

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        usleep(10000);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [imageViewController viewDidAppear:YES];
//        });
//    });
}

- (id)initWithFrameStart:(CGRect)fra supView:(UIView*)supv pic:(NSString*)pic preview:(NSString*)pre {
    if (self = [super initWithNibName:@"ImageViewController" bundle:nil]) {
        // Custom initialization
        superView = supv;
        contentFrame = fra;
        imageURL = pic;
        if ([pre isKindOfClass:[NSString class]] && pre.length > 10) {
            preURL = pre;
        } else {
            preURL = pic;
        }
        self.wantsFullScreenLayout = YES;
    }
    return self;
}

- (void)dealloc {
    [progress cancelDownload];
    imageURL = nil;
    preURL = nil;
    scrollView = nil;
    indicatorView = nil;
    btnSave = nil;
    superView = nil;
    self.progress = nil;
}

- (CGRect)startFrame {
    return [superView convertRect:contentFrame toView:[UIApplication sharedApplication].keyWindow];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor clearColor];
    self.view.frame = [UIScreen mainScreen].bounds;
    scrollView.backgroundColor = [UIColor blackColor];
    
    scrollView.hidden = NO;
    UIImageView * imgV = (UIImageView*)[scrollView viewWithTag:63];
    imgV.height = self.view.height;
    imgV.centerY = scrollView.height/2;
    
    if (preURL.length > 0) {
        ImageProgress * pro = [[ImageProgress alloc] initWithUrl:preURL delegate:nil];
        if (pro.loaded) {
            imgV.image = pro.image;
        }
        pro = nil;
    } else {
        UIImage * img = [UIImage imageWithContentsOfFile:preURL];
        if ([img isKindOfClass:[UIImage class]]) {
            imgV.image = img;
        }
    }
    
    btnSave.alpha = 0;
    self.view.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.hidden = NO;
    scrollView.userInteractionEnabled = NO;
    scrollView.frame = self.startFrame;
    [UIView beginAnimations:@"SHOW" context:nil];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationEnd:finished:context:)];
    scrollView.frame = self.view.bounds;
    btnSave.alpha = 1;
    [UIView commitAnimations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)back {
#if __IPHONE_7_0
    if ([UIDevice currentDevice].systemVersion.intValue < 7) {
#endif
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
#if __IPHONE_7_0
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
#endif
    self.view.userInteractionEnabled = NO;
    if (scrollView.zoomScale > 1.0) {
        [scrollView setZoomScale:1.0 animated:YES];
        [self performSelector:@selector(backAnimation) withObject:nil afterDelay:0.3];
    } else {
        [self performSelector:@selector(backAnimation)];
    }
}

- (void)doubleTap{
    if (scrollView.zoomScale > 1.0) {
        [scrollView setZoomScale:1.0 animated:YES];
    } else {
        [scrollView setZoomScale:scrollView.maximumZoomScale animated:YES];
    }
}

- (void)singleTap {
    [self back];
}

- (IBAction)btnSave:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否将图片保存到相册?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    [alert show];
}

- (void)backAnimation {
    UIImageView * imgV = (UIImageView*)[scrollView viewWithTag:63];
    imgV.frame = self.view.bounds;
    [UIView beginAnimations:@"HIDE" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationEnd:finished:context:)];
    scrollView.frame = self.startFrame;
    btnSave.alpha = 0;
    [UIView commitAnimations];
}

- (void)animationEnd:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
    if ([animationID isEqualToString:@"SHOW"]) {
        UIWindow * window = [UIApplication sharedApplication].keyWindow;
        window.userInteractionEnabled = YES;
#if __IPHONE_7_0
        if ([UIDevice currentDevice].systemVersion.intValue < 7) {
#endif
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
#if __IPHONE_7_0
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        }
#endif
        UITapGestureRecognizer * doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [scrollView addGestureRecognizer:doubleTapGesture];
        UITapGestureRecognizer * singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
        singleTapGesture.numberOfTapsRequired = 1;
        [scrollView addGestureRecognizer:singleTapGesture];
        [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
        scrollView.userInteractionEnabled = YES;
        [NSThread detachNewThreadSelector:@selector(imageLoadThread) toTarget:self withObject:nil];
    } else if ([animationID isEqualToString:@"HIDE"]) {
        [self.view removeFromSuperview];
        imageViewController = nil;
    }
}

//- (void)kwAlertView:(KWAlertView*)sender didDismissWithButtonIndex:(NSInteger)index {
//    if (sender.index == 1 && index == 1) {
//        UIImageView * imgV = (UIImageView*)[scrollView viewWithTag:63];
//        UIImageWriteToSavedPhotosAlbum(imgV.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//    }
//}

- (void)alertView:(UIAlertView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    }
    UIImageView * imgV = (UIImageView*)[scrollView viewWithTag:63];
    UIImageWriteToSavedPhotosAlbum(imgV.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage*)img didFinishSavingWithError:(NSError*)error contextInfo:(void*)context {
    NSString * msg;
    KAlertType ty;
    if (error == nil) {
        msg = @"保存成功";
        ty = KAlertTypeCheck;
    } else {
        msg = [error localizedFailureReason];
        ty = KAlertTypeError;
    }
    [KAlertView showType:ty text:msg for:1.0 animated:YES];
}

#pragma mark -
#pragma mark - ImageProgress

- (void)imageLoadThread {
    @autoreleasepool {
        if (imageURL.length > 0) {
            ImageProgress * pro = [[ImageProgress alloc] initWithUrl:imageURL delegate:self];
            [self performSelectorOnMainThread:@selector(imageLoadOnMain:) withObject:pro waitUntilDone:YES];
        } else {
            UIImage * img = [UIImage imageWithContentsOfFile:preURL];
            if ([img isKindOfClass:[UIImage class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateImage:img];
                });
            }
        }
    }
}

- (void)imageLoadOnMain:(ImageProgress*)pro {
    self.view.userInteractionEnabled = YES;
    if (pro.loaded) {
        UIImage * img = pro.image;
        [self updateImage:img];
    } else {
        UIImageView * imgV = (UIImageView*)[scrollView viewWithTag:63];
        imgV.alpha = 0.3;
        [indicatorView startAnimating];
        self.progress = pro;
        [pro startDownload];
    }
    pro = nil;
}

#pragma mark -
#pragma mark - ImageProgressDelegate

- (void)imageProgress:(ImageProgress*)sender completed:(BOOL)bl {
    if (bl) {
        UIImage * img = sender.image;
        [self updateImage:img];
    }
    [indicatorView stopAnimating];
    self.progress = nil;
}

#pragma mark -
#pragma mark - Scroll View Zoom

- (void)updateImage:(UIImage*)img {
    if (img) {
        screenFrame = self.view.bounds;
        UIImageView * imgV = (UIImageView*)[scrollView viewWithTag:63];
        imgV.image = img;
        imgV.alpha = 1;
        std_hw = screenFrame.size.height/screenFrame.size.width;
        CGFloat kw = screenFrame.size.width;
        CGFloat kh = screenFrame.size.height;
        hw = img.size.height/img.size.width;
        CGFloat contentWidth = kw;
        CGFloat contentHeight = kh;
        
        if (hw > std_hw) {
            contentWidth = contentHeight/hw;
            [imgV setFrame:CGRectMake((kw-contentWidth)/2, 0, contentWidth, contentHeight)];
        } else if (hw < std_hw) {
            contentHeight = contentWidth*hw;
            [imgV setFrame:CGRectMake(0, (kh-contentHeight)/2, contentWidth, contentHeight)];
        }
        
        CGFloat biggerTime = img.size.width/kw;
        if (img.size.height/kh > biggerTime) {
            biggerTime = img.size.height/kh;
        }
        biggerTime += 0.8;
        if (biggerTime < 1.5) {
            biggerTime = 1.5;
        }
        scrollView.maximumZoomScale = biggerTime;
        scrollView.userInteractionEnabled = YES;
    } else {
        [self back];
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)sender {
    return [scrollView viewWithTag:63];
}

- (void)scrollViewDidZoom:(UIScrollView*)sender {
    if (sender.zoomScale > 1) {
        if (![UIApplication sharedApplication].statusBarHidden) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }
        btnSave.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.2 animations:^{
            btnSave.alpha = 0;
        }];
    } else {
        if ([UIApplication sharedApplication].statusBarHidden) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        }
        btnSave.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.2 animations:^{
            btnSave.alpha = 1;
        }];
    }
    
    UIImageView * imgView = (UIImageView*)[scrollView viewWithTag:63];
    CGRect frame = imgView.frame;
    
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
    
    [imgView setFrame:frame];
}

@end
