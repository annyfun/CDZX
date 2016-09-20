//
//  TalkingRecordView.h
//  BusinessMate
//
//  Created by kiwi on 6/20/13.
//  Copyright (c) 2013 xizue. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum TalkState {
    TalkStateNone = 0,
    TalkStateTalking = 1,
    TalkStateCanceling = 2
}TalkState;

@class TalkingRecordView;

@protocol TalkingRecordViewDelegate <NSObject>
@optional
- (void)recordView:(TalkingRecordView*)sender didFinish:(NSString*)path duration:(NSTimeInterval)du;
@end

@interface TalkingRecordView : UIView

@property (nonatomic, assign) id <TalkingRecordViewDelegate> delegate;
@property (nonatomic, assign) int state;
@property (nonatomic, strong) NSString * audioFileSavePath;

- (id)initWithFrame:(CGRect)frame del:(id)del;
- (void)recordCancel;
- (void)recordEnd;

@end
