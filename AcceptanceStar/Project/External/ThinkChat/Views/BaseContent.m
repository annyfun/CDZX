//
//  BaseContent.m
//  HomeBridge
//
//  Created by keen on 14-7-1.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "BaseContent.h"
#import "ContentLeft.h"
#import "ContentRight.h"
#import "EmotionInputView.h"

@implementation BaseContent

@synthesize message;
@synthesize frameContent;

+ (CGFloat)heightWithItem:(id)item {
    CGFloat height = 0.0;
    
    return height;
}

+ (CGFloat)widthWithItem:(id)item {
    CGFloat width = 0.0;
    
    return width;
}

- (void)dealloc {
    message = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.imageView.animationDuration = 1.5;
    self.imageView.animationRepeatCount = 0;

    [self _init];
}

- (void)_init {
    
}

- (void)setMessage:(TCMessage *)item {
    message = item;
    
    CGFloat pointX  = 0.0;
    CGFloat pointY  = 0.0;
    CGFloat width   = 0.0;
    CGFloat height  = 0.0;
    if (message.isSendByMe) {
        pointX = kMessageRightMarginsLeft;
        pointY = kMessageRightMarginsTop;
        width = [ContentRight widthWithItem:message] - kMessageRightMarginsLeft - kMessageRightMarginsRight;
        height = [ContentRight heightWithItem:message] - kMessageRightMarginsTop - kMessageRightMarginsBottom;
    } else {
        pointX = kMessageLeftMarginsLeft;
        pointY = kMessageLeftMarginsTop;
        width = [ContentLeft widthWithItem:message] - kMessageLeftMarginsLeft - kMessageLeftMarginsRight;
        height = [ContentLeft heightWithItem:message] - kMessageLeftMarginsTop - kMessageLeftMarginsBottom;
    }
    self.frameContent = CGRectMake(pointX, pointY, width, height);
    
    self.titleLabel.numberOfLines = 0;

    self.titleLabel.font = [UIFont systemFontOfSize:kMessageTextFontSize];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    [self setTitle:nil forState:UIControlStateNormal];
    [self setTitle:nil forState:UIControlStateHighlighted];
    [self setImage:nil forState:UIControlStateNormal];
    [self setImage:nil forState:UIControlStateHighlighted];

    if (message.typeFile == forFileText) {
        [self setTitle:[EmotionInputView decodeMessageEmoji:message.contentFormat] forState:UIControlStateNormal];
    } else if (message.typeFile == forFileImage) {
        self.imageView.layer.cornerRadius = kMessageImageCornerRadius;
        [self setImage:[UIImage imageNamed:@"default_image_none"] forState:UIControlStateNormal];
    } else if (message.typeFile == forFileVoice) {
        self.imageView.layer.cornerRadius = 0;
        NSString* title = [NSString stringWithFormat:@"%.0f\"",message.bodyVoice.voiceTime];
        [self setTitle:title forState:UIControlStateNormal];
        if (message.isSendByMe) {
            [self setImage:[UIImage imageNamed:@"talk_r_voice"] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"talk_r_voice"] forState:UIControlStateHighlighted];
        } else {
            self.titleLabel.textAlignment = NSTextAlignmentRight;
            [self setImage:[UIImage imageNamed:@"talk_l_voice"] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"talk_l_voice"] forState:UIControlStateHighlighted];
        }
    } else if (message.typeFile == forFileLocation) {
        self.imageView.layer.cornerRadius = kMessageImageCornerRadius;
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.font = [UIFont systemFontOfSize:10];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitle:message.bodyLocation.address forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"location_msg"] forState:UIControlStateNormal];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (message == nil) {
        return;
    }
    
    CGRect frameTitle = CGRectZero;
    CGRect frameImage = CGRectZero;
    
    CGFloat pointX  = frameContent.origin.x;
    CGFloat pointY  = frameContent.origin.y;
    CGFloat width   = frameContent.size.width;
    CGFloat height  = frameContent.size.height;
    
    if (message.typeFile == forFileText) {
        // 文本消息,上下左右缩进就ok了
        pointX += kMessageTextIndent;
        pointY += kMessageTextIndent;
        width  -= kMessageTextIndent * 2;
        height -= kMessageTextIndent * 2;
        frameTitle = CGRectMake(pointX, pointY, width, height);
    } else if (message.typeFile == forFileImage) {
        // 图片消息,上下左右缩进就ok了
        pointX += kMessageImageIndent;
        pointY += kMessageImageIndent;
        width  -= kMessageImageIndent * 2;
        height -= kMessageImageIndent * 2;
        frameImage = CGRectMake(pointX, pointY, width, height);
    } else if (message.typeFile == forFileVoice) {
        if (message.isSendByMe) {
            // 自己发的音频消息, 时长居左,图片居右
            pointX += kMessageTextIndent;
            pointY += kMessageTextIndent;
            width  -= kMessageTextIndent * 2 + height;
            height -= kMessageTextIndent * 2;
            frameTitle = CGRectMake(pointX, pointY, width, height);
            
            pointX  = frameContent.origin.x;
            pointY  = frameContent.origin.y;
            width   = frameContent.size.width;
            height  = frameContent.size.height;
            
            pointX += kMessageAudioIndent + (width - height);
            width = height;
            pointY += kMessageAudioIndent;
            width  -= kMessageAudioIndent * 2;
            height -= kMessageAudioIndent * 2;
            
            frameImage = CGRectMake(pointX, pointY, width, height);
        } else {
            // 别人发的音频消息, 时长居右,图片居左
            pointX += kMessageTextIndent + height;
            pointY += kMessageTextIndent;
            width  -= kMessageTextIndent * 2 + height;
            height -= kMessageTextIndent * 2;
            frameTitle = CGRectMake(pointX, pointY, width, height);
            
            pointX  = frameContent.origin.x;
            pointY  = frameContent.origin.y;
            width   = frameContent.size.height;
            height  = frameContent.size.height;
            
            pointX += kMessageAudioIndent;
            pointY += kMessageAudioIndent;
            width  -= kMessageAudioIndent * 2;
            height -= kMessageAudioIndent * 2;
            
            frameImage = CGRectMake(pointX, pointY, width, height);
        }
    } else if (self.message.typeFile == forFileLocation) {
        // 地址消息,图片部分与 图片消息 一致. 文本居下.
        pointX += kMessageImageIndent;
        pointY += kMessageImageIndent;
        width  -= kMessageImageIndent * 2;
        height -= kMessageImageIndent * 2;
        frameImage = CGRectMake(pointX, pointY, width, height);
        
        CGFloat offSetTitle = 26.0;
        CGFloat offSet = 3.0;
        pointX += offSet;
        pointY += height - offSetTitle;
        height = offSetTitle;
        width  -= offSet * 2;
        frameTitle = CGRectMake(pointX, pointY, width, height);
    }
    
    self.titleLabel.frame = frameTitle;
    self.imageView.frame = frameImage;
}

@end
