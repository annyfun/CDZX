//
//  ContentRight.m
//  HomeBridge
//
//  Created by keen on 14-7-1.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "ContentRight.h"
#import "EmotionInputView.h"

@implementation ContentRight

+ (CGFloat)heightWithItem:(TCMessage*)item {
    CGFloat height = 0.0;
    
    // 泡泡外围固定边距
    CGFloat offSetWidth  = kMessageRightMarginsLeft + kMessageRightMarginsRight;
    CGFloat offSetHeight = kMessageRightMarginsTop + kMessageRightMarginsBottom;
    
    if (item.typeFile == forFileText) {
        // 文本消息
        offSetWidth  += kMessageTextIndent * 2;
        offSetHeight += kMessageTextIndent * 2;

        NSString* strContent = nil;
        strContent = [EmotionInputView decodeMessageEmoji:item.contentFormat];
        UIFont* font = [UIFont systemFontOfSize:kMessageTextFontSize];
        CGFloat width = kMessageMaxWidth - offSetWidth;
        CGSize size = [strContent sizeWithFont:font maxWidth:width maxNumberLines:0];
        height = size.height + offSetHeight;
    } else if (item.typeFile == forFileImage) {
        // 图片消息
        offSetWidth  += kMessageImageIndent * 2;
        offSetHeight += kMessageImageIndent * 2;
        
        CGFloat width = kMessageMaxWidth - offSetWidth;
        if (width > item.imgWidthHalf) {
            height = item.imgHeightHalf + offSetHeight;
        } else {
            height = ceilf(width * item.imgHeightHalf / item.imgWidthHalf) + offSetHeight;
        }
    } else if (item.typeFile == forFileVoice) {
        // 音频消息
        offSetHeight += kMessageAudioIndent * 2;
        
        height = kMessageAudioHeight + offSetHeight;
    } else if (item.typeFile == forFileLocation) {
        // 位置消息
        offSetWidth  += kMessageImageIndent * 2;
        offSetHeight += kMessageImageIndent * 2;
        
        CGFloat width = kMessageMaxWidth - offSetWidth;
        if (width > item.imgWidthHalf) {
            height = item.imgHeightHalf + offSetHeight;
        } else {
            height = ceilf(width * item.imgHeightHalf / item.imgWidthHalf) + offSetHeight;
        }
    }
    
    return height;
}

+ (CGFloat)widthWithItem:(TCMessage*)item {
    CGFloat width = 0.0;
    
    // 泡泡外围固定边距
    CGFloat offSetWidth  = kMessageRightMarginsLeft + kMessageRightMarginsRight;
    CGFloat offSetHeight = kMessageRightMarginsTop + kMessageRightMarginsBottom;
    
    if (item.typeFile == forFileText) {
        // 文本消息
        offSetWidth  += kMessageTextIndent * 2;
        offSetHeight += kMessageTextIndent * 2;
        
        NSString* strContent = nil;
        strContent = [EmotionInputView decodeMessageEmoji:item.contentFormat];
        UIFont* font = [UIFont systemFontOfSize:kMessageTextFontSize];
        width = kMessageMaxWidth - offSetWidth;
        CGSize size = [strContent sizeWithFont:font maxWidth:width maxNumberLines:0];
        width = size.width + offSetWidth;
    } else if (item.typeFile == forFileImage) {
        // 图片消息
        offSetWidth  += kMessageImageIndent * 2;
        
        width = kMessageMaxWidth - offSetWidth;
        if (width > item.imgWidthHalf) {
            width = item.imgWidthHalf;
            width += offSetWidth;
        } else {
            width = kMessageMaxWidth - offSetWidth;
        }
    } else if (item.typeFile == forFileVoice) {
        // 音频消息
        offSetWidth  += kMessageTextIndent + kMessageAudioIndent;

        width = ceilf(kMessageAudioLength + item.bodyVoice.voiceTime * 5);
        if (width > kMessageMaxWidth - offSetWidth) {
            width = kMessageMaxWidth - offSetWidth;
        }
    } else if (item.typeFile == forFileLocation) {
        // 位置消息
        offSetWidth  += kMessageImageIndent * 2;
        
        width = kMessageMaxWidth - offSetWidth;
        if (width > item.imgWidthHalf) {
            width = item.imgWidthHalf;
            width += offSetWidth;
        } else {
            width = kMessageMaxWidth - offSetWidth;
        }
    }
    return width;
}

- (void)_init {
    UIImage* img = [[UIImage imageNamed:@"talk_bkg_msg_r"] stretchableImageWithLeftCapWidth:7 topCapHeight:14];
    [self setBackgroundImage:img forState:UIControlStateNormal];
    
    NSMutableArray* imgArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < 3; i++) {
        UIImage* img = [UIImage imageNamed:[NSString stringWithFormat:@"talk_r_voice%d",i]];
        [imgArr addObject:img];
    }
    self.imageView.animationImages = imgArr;
}


@end
