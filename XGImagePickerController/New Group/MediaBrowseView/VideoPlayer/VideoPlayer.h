//
//  VideoPlayer.h
//  MyApp
//
//  Created by huxinguang on 2018/10/19.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PlayerModel.h"

// 播放器的几种状态
typedef NS_ENUM(NSInteger, VideoPlayerState) {
    VideoPlayerStateFailed,        // 播放失败
    VideoPlayerStateBuffering,     // 缓冲中
    VideoPlayerStatePlaying,       // 播放中
    VideoPlayerStateStopped,       // 暂停播放
    VideoPlayerStateFinished,      // 完成播放
    VideoPlayerStatePause,         // 打断播放
};
// playerLayer的填充模式（默认：等比例填充，直到一个维度到达区域边界）
typedef NS_ENUM(NSInteger, VideoPlayerLayerGravity) {
    VideoPlayerLayerGravityResize,           // 非均匀模式，两个维度完全填充至整个视图区域
    VideoPlayerLayerGravityResizeAspect,     // 等比例填充，直到一个维度到达区域边界
    VideoPlayerLayerGravityResizeAspectFill  // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
};
// 枚举值，包含播放器左上角的返回按钮的类型
typedef NS_ENUM(NSInteger, BackBtnStyle){
    BackBtnStyleNone,   // 什么都没有
    BackBtnStyleClose,  // 关闭（X）
    BackBtnStylePop     // pop箭头<-
};

//手势操作的类型
typedef NS_ENUM(NSInteger,GestureControlType) {
    GestureControlTypeDefault, // 无任何操作
    GestureControlTypeProgress,// 视频进度调节操作
    GestureControlTypeVoice,   // 声音调节操作
    GestureControlTypeLight    // 屏幕亮度调节操作
} ;



@class VideoPlayer;
@protocol VideoPlayerDelegate <NSObject>
@optional
// 点击播放暂停按钮代理方法
-(void)videoPlayer:(VideoPlayer *)player clickedPlayOrPauseButton:(UIButton *)playOrPauseBtn;
// 点击关闭按钮代理方法
-(void)videoPlayer:(VideoPlayer *)player clickedCloseButton:(UIButton *)backBtn;
// 点击全屏按钮代理方法
-(void)videoPlayer:(VideoPlayer *)player clickedFullScreenButton:(UIButton *)fullScreenBtn;
// 点击锁定按钮的方法
-(void)videoPlayer:(VideoPlayer *)player clickedLockButton:(UIButton *)lockBtn;
// 单击VideoPlayer的代理方法
-(void)videoPlayer:(VideoPlayer *)player singleTaped:(UITapGestureRecognizer *)singleTap;
// 双击VideoPlayer的代理方法
-(void)videoPlayer:(VideoPlayer *)player doubleTaped:(UITapGestureRecognizer *)doubleTap;
// VideoPlayer的的操作栏隐藏和显示
-(void)videoPlayer:(VideoPlayer *)player isHiddenTopAndBottomView:(BOOL )isHidden;
// 播放失败的代理方法
-(void)videoPlayerFailedPlay:(VideoPlayer *)player playerStatus:(VideoPlayerState)state;
// 准备播放的代理方法
-(void)videoPlayerReadyToPlay:(VideoPlayer *)player playerStatus:(VideoPlayerState)state;
// 播放器已经拿到视频的尺寸大小
-(void)videoPlayerGotVideoSize:(VideoPlayer *)player videoSize:(CGSize )presentationSize;
// 播放完毕的代理方法
-(void)videoPlayerFinishedPlay:(VideoPlayer *)player;
@end


@interface VideoPlayer : UIView
/**
 * 播放器对应的model
 */
@property (nonatomic,strong) PlayerModel *playerModel;
/**
 * 返回按钮的样式
 */
@property (nonatomic, assign) BackBtnStyle backBtnStyle;

/**
 * 播放器着色
 */
@property (nonatomic,strong) UIColor *tintColor;

@property (nonatomic,assign,readonly) BOOL prefersStatusBarHidden;
/**
 * 播放器的代理
 */
@property (nonatomic, weak) id <VideoPlayerDelegate> delegate;

/**
 * 是否开启后台播放模式
 */
@property (nonatomic,assign) BOOL enableBackgroundMode;

/**
 * 是否静音
 */
@property (nonatomic,assign) BOOL muted;
/**
 * 是否循环播放（不循环则意味着需要手动触发第二次播放）
 */
@property (nonatomic,assign) BOOL loopPlay;

/**
 * 设置playerLayer的填充模式
 */
@property (nonatomic, assign) VideoPlayerLayerGravity playerLayerGravity;

/**
 自定义实例化方法初始化方式（-方法）

 @param playerModel 播放model
 @return 播放器实例
 */
-(instancetype)initWithPlayerModel:(PlayerModel *)playerModel;

/**
 自定义类方法+初始化方式（+方法）

 @param playerModel 播放model
 @return 播放器实例
 */
+(instancetype)playerWithModel:(PlayerModel *)playerModel;

/**
 * 播放
 */
- (void)play;

/**
 * 暂停
 */
- (void)pause;

/**
 * 获取正在播放的时间点
 */
- (double)currentTime;

/**
 * 重置播放器,然后切换下一个播放资源
 */
- (void)resetVideoPlayer;

/**
 * 获取当前的旋转状态
 */
+ (CGAffineTransform)getCurrentDeviceOrientation;


/**
 * 获取视频某一帧的图片
 */
+ (UIImage *)firstFrameImageForVideo:(NSURL *)videoURL;

@end

