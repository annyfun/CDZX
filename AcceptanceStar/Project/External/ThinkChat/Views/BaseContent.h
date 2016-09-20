//
//  BaseContent.h
//  HomeBridge
//
//  Created by keen on 14-7-1.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCMessage.h"

#define kMessageMaxWidth            200
#define kMessageTextFontSize        14

// 缩进
#define kMessageTextIndent          8   // 文本缩进
#define kMessageImageIndent         2   // 图片缩进
#define kMessageAudioIndent         8   // 音频缩进

#define kMessageAudioHeight         20  // 音频播放图标大小
#define kMessageAudioLength         66  // 音频内容初始长度

#define kMessageImageCornerRadius   3   // 图片圆角

// 边距
#define kMessageRightMarginsTop     0
#define kMessageRightMarginsLeft    0
#define kMessageRightMarginsBottom  0
#define kMessageRightMarginsRight   7

#define kMessageLeftMarginsTop      0
#define kMessageLeftMarginsLeft     7
#define kMessageLeftMarginsBottom   0
#define kMessageLeftMarginsRight    0

@interface BaseContent : UIButton

@property (nonatomic, assign) CGRect        frameContent;
@property (nonatomic, strong) TCMessage*    message;

+ (CGFloat)heightWithItem:(id)item;
+ (CGFloat)widthWithItem:(id)item;

- (void)_init;

@end
