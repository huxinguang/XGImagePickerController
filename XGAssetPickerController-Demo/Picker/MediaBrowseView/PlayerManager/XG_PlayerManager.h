//
//  MyPlayer.h
//  XGAssetPickerController
//
//  Created by huxinguang on 2018/11/8.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol XG_PlayerManagerDelegate;

@interface XG_PlayerManager : NSObject

@property (nonatomic, assign) BOOL loopPlay;
@property (nonatomic, weak) id<XG_PlayerManagerDelegate> delegate;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, assign) BOOL isSeekInProgress;

+ (instancetype)shareInstance;
- (void)playWithItem:(AVPlayerItem *)item onLayer:(CALayer *)superlayer;
- (void)resetPlayer;
- (void)play;
- (void)pause;
- (void)seekSmoothlyToTime:(CMTime)newChaseTime;

@end


@protocol XG_PlayerManagerDelegate<NSObject>
@optional
- (void)playerReadyToPlay:(XG_PlayerManager *)manager;
- (void)playerDidLoadToProgress:(float)progress;
- (void)playerDidPlayToTime:(CMTime)currentTime totalTime:(CMTime)totalTime;
- (void)playerPlaybackBufferEmpty;
- (void)playerPlaybackLikelyToKeepUp;
- (void)playerDidFinishPlay:(XG_PlayerManager *)manager;
- (void)playerDidFailToPlay:(XG_PlayerManager *)manager;

@end
