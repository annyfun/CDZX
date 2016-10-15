//
//  UploadPreViewController.h
//  XAddrBook
//
//  Created by NigasMone on 13-8-28.
//  Copyright (c) 2013年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol UploadPreViewControllerDelegate <NSObject>
@optional
- (void)previewImageDid:(BaseViewController*)sender image:(UIImage*)img;
@end

@interface UploadPreViewController : BaseViewController {
    CGRect screenFrame;
}

@property (nonatomic, assign) IBOutlet UIImageView * imageView;
@property (nonatomic, assign) IBOutlet UIScrollView * scrollView;
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, assign) id <UploadPreViewControllerDelegate> delegate;

- (id)initWithImage:(UIImage*)img delegate:(id)del;

@end
