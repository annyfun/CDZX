//
//  ImageProgressQueue.h
//  wenxuan
//
//  Created by kiwi on 1/29/13.
//  Copyright (c) 2013 xizue.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageProgress, ImageProgressQueue;

@protocol ImageProgressDelagete <NSObject>
@optional
- (void)imageProgress:(ImageProgress*)sender completed:(BOOL)bl;
@end

@interface ImageProgress : NSObject <NSURLConnectionDelegate> {
    NSString * path;
}
@property (nonatomic, assign) id <ImageProgressDelagete> delegate;
@property (nonatomic, readonly) BOOL loaded;
@property (nonatomic, assign) int tag;
@property (nonatomic, strong) NSString * imageURLString;
@property (nonatomic, strong) NSMutableData * activeDownload;
@property (nonatomic, strong) NSURLConnection * imageConnection;
@property (nonatomic, strong) NSIndexPath * indexPath;
@property (nonatomic, strong) UIImage * image;

- (id)initWithUrl:(NSString *)_url delegate:(id)del;
- (void)startDownload;
- (void)cancelDownload;

@end



@protocol ImageProgressQueueDelagete <NSObject>
@optional
- (void)imageProgressCompleted:(UIImage*)img indexPath:(NSIndexPath*)indexPath;
- (void)imageProgressCompleted:(UIImage*)img indexPath:(NSIndexPath*)indexPath tag:(int)tag;
@end

@interface ImageProgressQueue : NSObject <ImageProgressDelagete> {
    NSMutableArray * queue;
}
@property (nonatomic, assign) id <ImageProgressQueueDelagete> delegate;
@property (nonatomic, strong) ImageProgress * operation;

- (id)initWithDelegate:(id)del;
- (void)addOperation:(ImageProgress*)op;
- (void)cancelOperations;

@end
