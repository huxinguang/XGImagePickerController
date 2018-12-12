//
//  MyPlayer.m
//  XGAssetPickerController
//
//  Created by huxinguang on 2018/11/8.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "XG_PlayerManager.h"

/*
   ReadMe:
 
 1. 关于 CMTime
 
 typedef struct
 {
    CMTimeValue    value;     // 帧数
    CMTimeScale    timescale; // 每秒播放的帧数（帧率）
    CMTimeFlags    flags;
    CMTimeEpoch    epoch;
 } CMTime
 
 举个栗子：CMTimeMake(90, 30) 表示时长为3秒，帧率为30fps的视频
 

 2. 为什么要用CMTime?
    Several Apple frameworks, including some parts of AVFoundation, represent time as a floating-point NSTimeInterval value that represents seconds. In many cases, this provides a natural way of thinking about and representing time, but it’s often problematic when performing timed media operations. It’s important to maintain sample-accurate timing when working with media, and floating-point imprecisions can often result in timing drift(时间漂移). To resolve these imprecisions(不精确), AVFoundation represents time using the Core Media framework’s CMTime data type.
 
    总结来说就是：保证精度
 
 3. 关于 AVAsset
 
 An instance of AVAsset can model local file-based media, such as a QuickTime movie or an MP3 audio file, but can also represent an asset progressively downloaded from a remote host or streamed using HTTP Live Streaming (HLS).
 
 AVAsset provides a level of independence from the media’s location. You create an asset instance by initializing it with the media’s URL. This could be a local URL, such as one contained within your app bundle or elsewhere on the file system, or it could also be a resource such as an HLS stream hosted on a remote server.
 

 */


static void *PlayerStatusObservationContext = &PlayerStatusObservationContext;

@interface XG_PlayerManager()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, assign) CMTime chaseTime;
@property (nonatomic, strong) id timeObserverToken;

@end

@implementation XG_PlayerManager

static XG_PlayerManager *manager = nil;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XG_PlayerManager alloc]init];
    });
    return manager;
}

//初始化播放器和切换item都调用此方法
- (void)playWithItem:(AVPlayerItem *)item onLayer:(CALayer *)superlayer{
    if (item == nil || item == self.playerItem) {
        return;
    }
    self.playerItem = item;
    if (self.player) {
        if (self.playerLayer.superlayer != superlayer) {
            [self.playerLayer removeFromSuperlayer];
            self.playerLayer.frame = superlayer.bounds;
            [superlayer insertSublayer:self.playerLayer atIndex:0];
        }
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
        [self.player play];
    }else{
        self.player = [[AVPlayer alloc]initWithPlayerItem:self.playerItem];
        if(self.loopPlay){
            self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        }else{
            self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        }
        if (@available(iOS 10.0, *)) {
            self.player.automaticallyWaitsToMinimizeStalling = YES;
        } else {
            // Fallback on earlier versions
        }
        self.player.usesExternalPlaybackWhileExternalScreenIsActive=YES;
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = superlayer.bounds;
        //To play the visual component of an asset, you need a view containing an AVPlayerLayer layer to which the output of an AVPlayer object can be directed.
        [superlayer insertSublayer:self.playerLayer atIndex:0];
//        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self createTimer];
        [self.player play];
        
    }
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem{
    if (_playerItem == playerItem) {
        return;
    }
    /*
     Important: You should register for KVO change notifications and unregister from KVO change notifications on the main thread. This avoids the possibility of receiving a partial notification if a change is being made on another thread. AV Foundation invokes observeValueForKeyPath:ofObject:change:context: on the main thread, even if the change operation is made on another thread.
     */
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [self performSelectorOnMainThread:@selector(removeKVO) withObject:nil waitUntilDone:YES];
        _playerItem = nil;
    }
    _playerItem = playerItem;
    if (_playerItem) {
        [self performSelectorOnMainThread:@selector(addKVO) withObject:nil waitUntilDone:YES];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playerItemDidReachEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    }
}

- (void)addKVO{
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:PlayerStatusObservationContext];
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:PlayerStatusObservationContext];
    [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options: NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:PlayerStatusObservationContext];
    [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options: NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:PlayerStatusObservationContext];
}

- (void)removeKVO{
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

- (void)play{
    if (self.player.currentItem) {
        [self.player play];
    }
}

- (void)pause{
    if (self.player.currentItem) {
        [self.player pause];
    }
}

- (void)resetPlayer{
    if (self.player.currentItem) {
        [self.player pause];
        [self.player seekToTime:kCMTimeZero];
        [self.playerLayer removeFromSuperlayer];
        [self.player replaceCurrentItemWithPlayerItem:nil];
    }
}

- (void)createTimer{
    __weak typeof(self) weakSelf = self;
    if(self.timeObserverToken == nil){
        self.timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC)  queue:dispatch_get_main_queue() usingBlock:^(CMTime time)
                                   {
                                       // 只有在“播放状态”下才会调用
                                       if ([weakSelf.delegate respondsToSelector:@selector(playerDidPlayToTime:totalTime:)]) {
                                           [weakSelf.delegate playerDidPlayToTime:weakSelf.playerItem.currentTime totalTime:weakSelf.playerItem.duration];
                                       }
                                       
                                       
                                   }];
    }
}

- (void)seekSmoothlyToTime:(CMTime)newChaseTime{
    [self.player pause];
    if (CMTIME_COMPARE_INLINE(newChaseTime, >=, kCMTimeZero) && CMTIME_COMPARE_INLINE(newChaseTime, <=, self.player.currentItem.duration) && CMTIME_COMPARE_INLINE(newChaseTime, !=, self.chaseTime)){
        self.chaseTime = newChaseTime;
        if (!self.isSeekInProgress){
           [self trySeekToChaseTime];
        }
    }
}

- (void)trySeekToChaseTime{
    if (self.player.status == AVPlayerItemStatusUnknown){
        // wait until item becomes ready (KVO player.currentItem.status)
    }else if (self.player.status == AVPlayerItemStatusReadyToPlay){
        [self actuallySeekToTime];
    }
}

- (void)actuallySeekToTime{
    self.isSeekInProgress = YES;
    CMTime seekTimeInProgress = self.chaseTime;
    //Important: Calling the seekToTime:toleranceBefore:toleranceAfter: method with small or zero-valued tolerances may incur additional decoding delay, which can impact your app’s seeking behavior.
    [self.player seekToTime:seekTimeInProgress toleranceBefore:kCMTimeZero
              toleranceAfter:kCMTimeZero completionHandler:
     ^(BOOL finished)
     {
         if (CMTIME_COMPARE_INLINE(seekTimeInProgress, ==, self.chaseTime)){
             if (finished) {
                 self.isSeekInProgress = NO;
                 [self.player play];
             }
         }else{
             [self trySeekToChaseTime];
         }
         
     }];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != PlayerStatusObservationContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    __weak typeof (self) weakSelf = self;
    if ([keyPath isEqualToString:@"status"])
    {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status){
            case AVPlayerItemStatusUnknown:
            {
                
            }
                break;
            case AVPlayerItemStatusReadyToPlay:
            {
                /*
                 There are two ways to ensure that the value of duration is accessed only after it becomes available:
                 
                 1. Wait until the status of the player item is AVPlayerItem.Status.readyToPlay.
                 
                 2. Register for key-value observation of the property, requesting the initial value. If the initial value is reported as indefinite, the player item will notify you of the availability of its duration via key-value observing as soon as its value becomes known.
                 */
                if ([self.delegate respondsToSelector:@selector(playerReadyToPlay:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.delegate playerReadyToPlay:weakSelf];
                    });
                }
            }
                break;
                
            case AVPlayerItemStatusFailed:
            {
                if ([self.delegate respondsToSelector:@selector(playerDidFailToPlay:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.delegate playerDidFailToPlay:weakSelf];
                    });
                }
                NSError *error = [self.player.currentItem error];
                if (error) {
                    NSLog(@"AVPlayerItemStatusFailed error = %@",[error localizedDescription]);
                }
            }
                break;
        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        NSArray<NSValue *> *loadedTimeRanges = self.playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        Float64 rangeStart = CMTimeGetSeconds(timeRange.start);
        Float64 rangeDuration = CMTimeGetSeconds(timeRange.duration);
        Float64 rangeEnd = rangeStart + rangeDuration;
        float progress = rangeEnd/CMTimeGetSeconds(self.playerItem.duration);
        if ([self.delegate respondsToSelector:@selector(playerDidLoadToProgress:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.delegate playerDidLoadToProgress:progress];
            });
        }
    }
    else if ([keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        if ([self.delegate respondsToSelector:@selector(playerPlaybackBufferEmpty)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.delegate playerPlaybackBufferEmpty];
            });
        }
    }
    else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        if ([self.delegate respondsToSelector:@selector(playerPlaybackLikelyToKeepUp)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.delegate playerPlaybackLikelyToKeepUp];
            });
        }
    }
    
}

- (void)playerItemDidReachEnd{
    
    if ([self.delegate respondsToSelector:@selector(playerDidFinishPlay:)]) {
        [self.delegate playerDidFinishPlay:self];
    }
    /*
     The item is played only once. After playback, the player’s head is set to the end of the item, and further invocations of the play method will have no effect. To position the playhead back at the beginning of the item, you can register to receive an AVPlayerItemDidPlayToEndTimeNotification from the item. In the notification’s callback method, invoke seekToTime: with the argument kCMTimeZero.
     */
    [self.player seekToTime:kCMTimeZero];
}

-(void)dealloc{
    [self.player removeTimeObserver:self.timeObserverToken];
    self.timeObserverToken = nil;
    [self.playerLayer removeFromSuperlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerItem cancelPendingSeeks];
    [self.playerItem.asset cancelLoading];
    [self removeKVO];
    
}



@end
