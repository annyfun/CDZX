//
//  BaseMessageCell.h
//  DaMi
//
//  Created by keen on 14-5-12.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentLeft.h"
#import "ContentRight.h"


@protocol BaseMessageCellDelegate <NSObject>

- (void)baseMessageCellDidPressContent:(id)sender;

@optional
- (void)baseMessageCellDidPressHead:(id)sender;
- (void)baseMessageCellDidPressFail:(id)sender;
- (void)baseMessageCellDidPressMenu:(id)sender;
- (void)baseMessageCellDidLongPress:(id)sender;

@end

@class TCMessage;

@interface BaseMessageCell : UITableViewCell {
    IBOutlet UIImageView*   imgViewHead;
    IBOutlet UILabel*       labTime;
    IBOutlet BaseContent*   btnContent;
    IBOutlet UIButton*      btnFail;
    IBOutlet UIActivityIndicatorView*   actView;
    IBOutlet UILabel*       nickName;
}

@property (nonatomic, assign) id        delegate;
@property (nonatomic, strong) TCMessage*  message;
@property (nonatomic, strong) UIImage*  imgContent;
@property (nonatomic, strong) UIImage*  imgHead;
@property (nonatomic, assign) BOOL      playing;
@property (nonatomic, assign) CGRect    contentFrame;

+ (CGFloat)heightWithItem:(id)item;

@end
