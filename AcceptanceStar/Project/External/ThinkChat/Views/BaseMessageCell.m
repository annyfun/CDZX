//
//  BaseMessageCell.m
//  DaMi
//
//  Created by keen on 14-5-12.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "BaseMessageCell.h"
#import "TCMessage.h"

@implementation BaseMessageCell

@synthesize delegate;
@synthesize message;
@synthesize imgContent;
@synthesize imgHead;
@synthesize playing;
@synthesize contentFrame;

+ (CGFloat)heightWithItem:(TCMessage*)item {
    CGFloat height = 0.0;
    if (item.isSendByMe) {
        height = [ContentRight heightWithItem:item];
    } else {
        height = [ContentLeft heightWithItem:item];
    }

    height += 30 + 20;
    
    return height;
}

- (void)dealloc {
    message = nil;
    imgContent = nil;
    imgHead = nil;
    
    imgViewHead = nil;
    labTime = nil;
    btnContent = nil;
    btnFail = nil;
    actView = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIImageView* bkgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    bkgView.backgroundColor = RGBCOLOR(241, 241, 241);
    self.selectedBackgroundView = bkgView;
    bkgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    bkgView.backgroundColor = RGBCOLOR(241, 241, 241);
    self.backgroundView = bkgView;

    UILongPressGestureRecognizer* longGesture = [[UILongPressGestureRecognizer alloc] init];
    [longGesture addTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:longGesture];
    longGesture = nil;
    
    UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headTapped:)];
    [imgViewHead addGestureRecognizer:recognizer];
    recognizer = nil;
    imgViewHead.userInteractionEnabled = YES;
    
    labTime.textColor = kColorWhite;
    labTime.backgroundColor = RGBCOLOR(218, 218, 218);
    labTime.layer.cornerRadius = 3.0;
    labTime.clipsToBounds = YES;
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan && [self becomeFirstResponder]) {
        if ([delegate respondsToSelector:@selector(baseMessageCellDidLongPress:)]) {
            [delegate baseMessageCellDidLongPress:self];
        }
    }
}

- (void)headTapped:(UITapGestureRecognizer*)recognizer {
    if ([self.delegate respondsToSelector:@selector(baseMessageCellDidPressHead:)]) {
        [self.delegate performSelector:@selector(baseMessageCellDidPressHead:) withObject:self];
    }
}

- (IBAction)btnPressed:(id)sender {
    if (sender == btnContent) {
        if ([delegate respondsToSelector:@selector(baseMessageCellDidPressContent:)]) {
            [delegate baseMessageCellDidPressContent:self];
        }
    } else if (sender == btnFail) {
        if ([delegate respondsToSelector:@selector(baseMessageCellDidPressFail:)]) {
            [delegate baseMessageCellDidPressFail:self];
        }
    }
}

- (void)setMessage:(TCMessage *)item {
    message = item;

    if (message.state == forMessageStateHavent) {
        [actView startAnimating];
    } else {
        [actView stopAnimating];
    }
    
    if (message.state == forMessageStateError) {
        btnFail.hidden = NO;
    } else {
        btnFail.hidden = YES;
    }
    
    btnContent.message = message;
    labTime.text = [Globals timeStringWith:message.time];
    nickName.text = item.from.name;
    [self layoutSubviews];
}

- (void)setImgContent:(UIImage *)img {
    imgContent = img;
    
    [btnContent setImage:imgContent forState:UIControlStateNormal];
}

- (void)setImgHead:(UIImage *)img {
    imgHead = img;
    
    imgViewHead.image = imgHead;
}

- (void)setPlaying:(BOOL)value {
    if (message.typeFile == forFileVoice) {
        if (value) {
            [btnContent.imageView startAnimating];
        } else {
            [btnContent.imageView stopAnimating];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resignFirstResponder];
    CGSize size = [labTime.text sizeWithFont:labTime.font maxWidth:200 maxNumberLines:1];
    labTime.width = size.width + 8;
    labTime.centerX = self.contentView.frame.size.width/2.0;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
