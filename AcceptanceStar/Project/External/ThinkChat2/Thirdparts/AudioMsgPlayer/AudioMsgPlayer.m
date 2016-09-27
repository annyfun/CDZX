//
//  AudioMsgPlayer.m
//  BusinessMate
//
//  Created by keen on 13-6-26.
//  Copyright (c) 2013年 xizue. All rights reserved.
//

#import "AudioMsgPlayer.h"

static AudioMsgPlayer * sharedPlayer = nil;

@interface AudioMsgPlayer () {
    NSMutableArray * contentArray;
    AVAudioPlayer * player;
    id delegate;
}
@property (nonatomic, strong) NSString * currentTag;

@end

@implementation AudioMsgPlayer
@synthesize currentTag;

+ (void)playWithURL:(NSString*)url delegate:(id)del {
    AudioMsgPlayer* amPlayer = [AudioMsgPlayer sharedAudioMsgPlayer];
    [amPlayer playWithURL:url delegate:del];
}

+ (AudioMsgPlayer*)sharedAudioMsgPlayer {
    if (sharedPlayer == nil) {
        sharedPlayer = [[AudioMsgPlayer alloc] init];
    }
    return sharedPlayer;
}

+ (void)cancel {
    AudioMsgPlayer* amPlayer = [AudioMsgPlayer sharedAudioMsgPlayer];
    [amPlayer cancel];
}

- (id)init {
    if (self = [super init]) {
        contentArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    if (player) {
        [player stop];
        player = nil;
    }
    delegate = nil;
    contentArray = nil;
    self.currentTag = nil;
}

- (void)cancel {
    self.currentTag = nil;
    if (player) {
        [player stop];
        player = nil;
    }
    [self callBackWith:nil];
    delegate = nil;
}

- (void)playWithURL:(NSString*)url delegate:(id)del {
    NSString* urlTag = [url md5Hex];
    self.currentTag = urlTag;
    delegate = del;
    
    if (player) {
        [player stop];
        player = nil;
    }
    
    NSString * path = [self pathWithURL:url];
    NSData * data = [NSData dataWithContentsOfFile:path];
    if ([data isKindOfClass:[NSData class]] && data.length > 500) {
        // 播放
        [self playWithData:data];
    } else {
        // 下载
        BOOL needDownload = YES;
        for (NSString* tag in contentArray) {
            if ([urlTag isEqualToString:tag]) {
                needDownload = NO;
                break;
            }
        }
        if (needDownload) {
            [contentArray addObject:urlTag];
            [NSThread detachNewThreadSelector:@selector(downLoadInThread:) toTarget:self withObject:url];
        }
    }
}

- (void)downLoadInThread:(NSString*)url {
    if ([url hasPrefix:@"http"]) {
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        if (data) {
            // 下载成功
            [data writeToFile:[self pathWithURL:url] atomically:YES];
            [self performSelectorOnMainThread:@selector(downLoadDidInMainThread:) withObject:url waitUntilDone:YES];
        } else {
            // 下载失败
            [self performSelectorOnMainThread:@selector(failToDownloadInMainThread:) withObject:url waitUntilDone:YES];
        }
    } else {
        // 下载失败
        [self performSelectorOnMainThread:@selector(failToDownloadInMainThread:) withObject:url waitUntilDone:YES];
    }
}

- (void)downLoadDidInMainThread:(NSString*)url {
    NSString* urlTag = [url md5Hex];
    for (NSString* tag in contentArray) {
        if ([urlTag isEqualToString:tag]) {
            [contentArray removeObject:tag];
            break;
        }
    }
    if ([currentTag isEqualToString:urlTag]) {
        // 播放
        NSData* data = [NSData dataWithContentsOfFile:[self pathWithURL:url]];
        if ([data isKindOfClass:[NSData class]] && data.length > 500) {
            // 播放
            [self playWithData:data];
        } else {
            // 下载成功,但是读取文件失败
            [self callBackWith:nil];
        }
    }
}

- (void)failToDownloadInMainThread:(NSString*)url {
    NSString* urlTag = [url md5Hex];
    for (NSString* tag in contentArray) {
        if ([urlTag isEqualToString:tag]) {
            [contentArray removeObject:tag];
            break;
        }
    }
    [self callBackWith:nil];
}

- (NSString*)pathWithURL:(NSString*)url {
    if ([url hasPrefix:@"http"]) {
        return [NSString stringWithFormat:@"%@/Library/Cache/Audios/%@.mp3",NSHomeDirectory(),[url md5Hex]];
    } else {
        return url;
    }
}

- (void)callBackWith:(id)info {
    [delegate performSelector:@selector(audioMsgPlayerDidFinishPlaying:) withObject:info];
    delegate = nil;
}

- (void)playWithData:(NSData*)data {    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSError * error = nil;
    player = [[AVAudioPlayer alloc] initWithData:data error:&error];
    if (error != nil) {
        TCDemoLog(@"AVAudioPlayer initWithError : %@", error);
        player = nil;
        [self callBackWith:nil];
    } else {
        player.delegate = self;
        [player prepareToPlay];
        [player play];
    }
}

#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)sender successfully:(BOOL)flag{
    //播放结束时执行的动作
    TCDemoLog(@"audioPlayerDidFinishPlaying : %d",flag?1:0);
    player = nil;
    [self callBackWith:nil];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer*)sender error:(NSError*)error{
    //解码错误执行的动作
    TCDemoLog(@"audioPlayerDecodeErrorDidOccur : %@",error);
    player = nil;
    [self callBackWith:nil];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)sender withFlags:(NSUInteger)flags {
    TCDemoLog(@"audioPlayerEndInterruption");
}

@end
