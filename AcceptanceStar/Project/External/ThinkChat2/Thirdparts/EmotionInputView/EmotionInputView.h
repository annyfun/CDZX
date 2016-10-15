//
//  EmotionInputView.h
//  BusinessMate
//
//  Created by kiwi on 6/8/13.
//  Copyright (c) 2013 xizue. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EmotionInputViewDelegate <NSObject>

- (void)emotionInputView:(id)sender output:(NSString*)str;

@end

@interface EmotionInputView : UIView

@property (nonatomic, assign) id <EmotionInputViewDelegate> delegate;

- (id)initWithDelegate:(id<EmotionInputViewDelegate>)del;

+ (NSString*)encodeMessageEmoji:(NSString*)msg;

+ (NSString*)decodeMessageEmoji:(NSString*)msg;

+ (NSString *)emojiText5To4:(NSString *)text;

+ (NSString *)emojiText4To5:(NSString *)text;

@end
