//
//  ImageViewController.h
//  guphoto
//
//  Created by kiwi on 5/13/13.
//  Copyright (c) 2013 xizue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController <UIAlertViewDelegate>{
    IBOutlet UIScrollView * scrollView;
    IBOutlet UIActivityIndicatorView * indicatorView;
    IBOutlet UIButton     * btnSave;
}

+ (void)showWithFrameStart:(CGRect)fra supView:(UIView*)supv pic:(NSString*)pic preview:(NSString*)pre;

@end
