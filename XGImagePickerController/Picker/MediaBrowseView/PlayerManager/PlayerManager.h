//
//  MyPlayer.h
//  XGImagePickerController
//
//  Created by huxinguang on 2018/11/8.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol PlayerManagerDelegate;

@interface PlayerManager : NSObject

@property (nonatomic, assign) BOOL loopPlay;
@property (nonatomic, weak) id<PlayerManagerDelegate> delegate;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, assign) BOOL isSeekInProgress;

+ (instancetype)shareInstance;
- (void)playWithItem:(AVPlayerItem *)item onLayer:(CALayer *)superlayer;
- (void)pauseAndResetPlayer;
- (void)play;
- (void)pause;
- (void)seekSmoothlyToTime:(CMTime)newChaseTime;

@end


@protocol PlayerManagerDelegate<NSObject>
@optional
- (void)playerReadyToPlay:(PlayerManager *)manager;
- (void)playerDidLoadToProgress:(float)progress;
- (void)playerDidPlayToTime:(CMTime)currentTime totalTime:(CMTime)totalTime;
- (void)playerPlaybackBufferEmpty;
- (void)playerPlaybackLikelyToKeepUp;
- (void)playerDidFinishPlay:(PlayerManager *)manager;
- (void)playerDidFailToPlay:(PlayerManager *)manager;


@end
