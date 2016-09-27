//
//  AudioMsgPlayer.h
//  BusinessMate
//
//  Created by keen on 13-6-26.
//  Copyright (c) 2013年 xizue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol AudioMsgPlayerDelegate <NSObject>

- (void)audioMsgPlayerDidFinishPlaying:(id)sender;

@end

@interface AudioMsgPlayer : NSObject <AVAudioPlayerDelegate>

+ (void)playWithURL:(NSString*)url delegate:(id)del;
+ (void)cancel;

@end
