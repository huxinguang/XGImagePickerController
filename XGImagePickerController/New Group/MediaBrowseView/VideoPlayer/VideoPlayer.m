//
//  VideoPlayer.h
//  MyApp
//
//  Created by huxinguang on 2018/10/19.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "VideoPlayer.h"

// 整个屏幕代表的时间
#define TotalScreenTime 90
#define LeastDistance 15

static void *PlayViewCMTimeValue = &PlayViewCMTimeValue;
static void *PlayViewStatusObservationContext = &PlayViewStatusObservationContext;

@interface VideoPlayer () <UIGestureRecognizerDelegate>
// 顶部&底部操作工具栏
@property (nonatomic, retain) UIImageView *topView,*bottomView;
// 是否初始化了播放器
@property (nonatomic, assign) BOOL isInitPlayer;
// 用来判断手势是否移动过
@property (nonatomic, assign) BOOL hasMoved;
// 总时间
@property (nonatomic, assign) CGFloat totalTime;
// 记录触摸开始时的视频播放的时间
@property (nonatomic, assign) CGFloat touchBeginValue;
// 记录触摸开始亮度
@property (nonatomic, assign) CGFloat touchBeginLightValue;
// 记录触摸开始的音量
@property (nonatomic, assign) CGFloat touchBeginVoiceValue;
// 记录touch开始的点
@property (nonatomic, assign) CGPoint touchBeginPoint;
// 手势控制的类型,用来判断当前手势是在控制进度?声音?亮度?
@property (nonatomic, assign) GestureControlType controlType;
// 格式化时间（懒加载防止多次重复初始化）
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
// 监听播放起状态的监听者
@property (nonatomic, strong) id playbackTimeObserver;
// 视频进度条的单击手势&播放器的单击手势
@property (nonatomic, strong) UITapGestureRecognizer *progressTap,*singleTap;
// 是否正在拖曳进度条
@property (nonatomic, assign) BOOL isDragingSlider;
// BOOL值判断操作栏是否隐藏
@property (nonatomic, assign) BOOL isHiddenTopAndBottomView;
// BOOL值判断操作栏是否隐藏
@property (nonatomic, assign) BOOL hiddenStatusBar;
// 是否被系统暂停
@property (nonatomic, assign) BOOL isPauseBySystem;
// 播放器状态
@property (nonatomic, assign) VideoPlayerState state;
// VideoPlayer内部一个UIView，所有的控件统一管理在此view中
@property (nonatomic, strong) UIView *contentView;
// 已播放时长 + 总时长
@property (nonatomic, strong) UILabel *leftTimeLabel,*rightTimeLabel;
// 控制全屏和播放暂停按钮
@property (nonatomic, strong) UIButton *playOrPauseBtn,*backBtn;
// 进度滑块&声音滑块
@property (nonatomic, strong) UISlider *progressSlider,*volumeSlider;
// 显示缓冲进度和底部的播放进度
@property (nonatomic, strong) UIProgressView *loadingProgress,*bottomProgress;
// 当前播放的item
@property (nonatomic, retain) AVPlayerItem *currentItem;
// playerLayer,可以修改frame
@property (nonatomic, retain) AVPlayerLayer *playerLayer;
// 播放器player
@property (nonatomic, retain) AVPlayer *player;
// 播放资源路径URL
@property (nonatomic, strong) NSURL *videoURL;
// 播放资源
@property (nonatomic, strong) AVURLAsset *urlAsset;
// 跳到time处播放
@property (nonatomic, assign) double seekTime;
// 视频填充模式
@property (nonatomic, copy) NSString *videoGravity;
@end


@implementation VideoPlayer
/*
 SomeObject *obj = [[SomeObject alloc] init];
 代码调用过程如下：
 
 1. 动态查找到 SomeObject 的 init 方法
 2. 调用 super init 方法
 3. super init 方法内部执行的是 [super initWithFrame:CGRectZero]
 4. 然后 super 会发现 SomeObject 实现了 initWithFrame 方法
 5. 转而执行 [SomeObject initWithFrame:CGRectZero]
 6. 最后再执行 init 其余部分
 
 关键点：OC 里面的 super 实际上是让某个类自己去调用父类的方法, 而不是父类去调用某方法。方法动态调用过程中的顺序是按照继承关系从下到上。
 
 */

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        [self initVideoPlayer];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initVideoPlayer];
    }
    return self;
}
-(instancetype)initWithPlayerModel:(PlayerModel *)playerModel{
    self = [super init];
    if (self) {
        self.playerModel = playerModel;
    }
    return self;
}
+(instancetype)playerWithModel:(PlayerModel *)playerModel{
    VideoPlayer *player = [[VideoPlayer alloc]initWithPlayerModel:playerModel];
    return player;
}
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    }
    return _dateFormatter;
}
- (NSString *)videoGravity {
    if (!_videoGravity) _videoGravity = AVLayerVideoGravityResizeAspect;
    return _videoGravity;
}

-(void)initVideoPlayer{
    [UIApplication sharedApplication].idleTimerDisabled=YES;//不自动锁屏
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error: &setCategoryErr];
    [[AVAudioSession sharedInstance]setActive: YES error: &activationErr];
    //Videoplayer内部的一个view，用来管理子视图
    self.contentView = [UIView new];
    self.contentView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.contentView];
    self.backgroundColor = [UIColor blackColor];
    
    //topView
    self.topView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"top_shadow"]];
    self.topView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.topView];
    
    //bottomView
    self.bottomView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bottom_shadow"]];
    self.bottomView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.bottomView];
    
    //playOrPauseBtn
    self.playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playOrPauseBtn addTarget:self action:@selector(PlayOrPause:) forControlEvents:UIControlEventTouchUpInside];
    [self.playOrPauseBtn setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
    [self.playOrPauseBtn setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateSelected];
    [self.bottomView addSubview:self.playOrPauseBtn];
    self.playOrPauseBtn.selected = YES;//默认状态，即默认是不自动播放
    
    MPVolumeView *volumeView = [[MPVolumeView alloc]init];
    for (UIControl *view in volumeView.subviews) {
        if ([view.superclass isSubclassOfClass:[UISlider class]]) {
            self.volumeSlider = (UISlider *)view;
        }
    }
    self.loadingProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.loadingProgress.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    self.loadingProgress.trackTintColor = [UIColor clearColor];
    [self.bottomView addSubview:self.loadingProgress];
    [self.loadingProgress setProgress:0.0 animated:NO];
    [self.bottomView sendSubviewToBack:self.loadingProgress];
    
    //slider
    self.progressSlider = [UISlider new];
    self.progressSlider.minimumValue = 0.0;
    self.progressSlider.maximumValue = 1.0;
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"dot"] forState:UIControlStateNormal];
    self.progressSlider.minimumTrackTintColor = self.tintColor?self.tintColor:[UIColor blueColor];
    self.progressSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    self.progressSlider.backgroundColor = [UIColor clearColor];
    self.progressSlider.value = 0.0;//指定初始值
    //进度条的拖拽事件
    [self.progressSlider addTarget:self action:@selector(stratDragSlide:)  forControlEvents:UIControlEventValueChanged];
    
    //进度条的点击事件
    [self.progressSlider addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventTouchUpInside];
    
    //给进度条添加单击手势
    self.progressTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
    self.progressTap.delegate = self;
    [self.progressSlider addGestureRecognizer:self.progressTap];
    [self.bottomView addSubview:self.progressSlider];
    
    self.bottomProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.bottomProgress.trackTintColor    = [UIColor clearColor];
    self.bottomProgress.progressTintColor = self.tintColor?self.tintColor:[UIColor blueColor];
    self.bottomProgress.alpha = 0;
    [self.contentView addSubview:self.bottomProgress];
    
    //leftTimeLabel显示左边的时间进度
    self.leftTimeLabel = [UILabel new];
    self.leftTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.leftTimeLabel.textColor = [UIColor whiteColor];
    self.leftTimeLabel.font = [UIFont systemFontOfSize:11];
    [self.bottomView addSubview:self.leftTimeLabel];
    self.leftTimeLabel.text = [self convertTime:0.0];//设置默认值
    
    //rightTimeLabel显示右边的总时间
    self.rightTimeLabel = [UILabel new];
    self.rightTimeLabel.textAlignment = NSTextAlignmentRight;
    self.rightTimeLabel.textColor = [UIColor whiteColor];
    self.rightTimeLabel.font = [UIFont systemFontOfSize:11];
    [self.bottomView addSubview:self.rightTimeLabel];
    self.rightTimeLabel.text = [self convertTime:0.0];//设置默认值

    //backBtn
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.backBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateSelected];
    [self.backBtn addTarget:self action:@selector(closeTheVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.backBtn];
    
    //添加子控件的默认约束
    [self addUIControlConstraints];
    
    // 单击的 Recognizer
    self.singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
    self.singleTap.numberOfTapsRequired = 1; // 单击
    self.singleTap.numberOfTouchesRequired = 1;
    self.singleTap.delegate = self;
    [self.contentView addGestureRecognizer:self.singleTap];

    // 双击的 Recognizer
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTouchesRequired = 1;
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delegate = self;
    // 解决点击当前view时候响应其他控件事件
    [self.singleTap setDelaysTouchesBegan:YES];
    [doubleTap setDelaysTouchesBegan:YES];
    [self.singleTap requireGestureRecognizerToFail:doubleTap];//双击的时候不会走单击事件
    [self.contentView addGestureRecognizer:doubleTap];
}
#pragma mark - Gesture Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
        if ([touch.view isKindOfClass:[UIControl class]]) {
            return NO;
        }
    return YES;
}
// 添加控件的约束
-(void)addUIControlConstraints{
//    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
//    }];
//
//    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self.contentView);
//    }];
//    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.equalTo(self.contentView);
//        make.height.mas_equalTo(IS_X_Series?90:70);
//    }];
//    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.equalTo(self.contentView);
//        make.height.mas_equalTo(50);
//    }];
//    [self.lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView).offset(15);
//        make.centerY.mas_equalTo(self.contentView);
//    }];
//    [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.bottomView);
//        make.left.equalTo(self.bottomView).offset(10);
//    }];
//    [self.leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.bottomView).offset(50);
//        make.top.equalTo(self.bottomView.mas_centerY).with.offset(8);
//    }];
//    [self.rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.bottomView).offset(-50);
//        make.top.equalTo(self.bottomView.mas_centerY).with.offset(8);
//    }];
//    [self.loadingProgress mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.leftTimeLabel.mas_left).offset(4);
//        make.right.equalTo(self.rightTimeLabel.mas_right).offset(-4);
//        make.centerY.equalTo(self.bottomView);
//    }];
//    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.leftTimeLabel.mas_left).offset(4);
//        make.right.equalTo(self.rightTimeLabel.mas_right).offset(-4);
//        make.centerY.equalTo(self.bottomView).offset(-1);
//        make.height.mas_equalTo(30);
//    }];
//    [self.bottomProgress mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.mas_offset(0);
//        make.bottom.mas_offset(0);
//    }];
//    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.bottomView);
//        make.right.equalTo(self.bottomView).offset(-10);
//    }];
//    [self.rateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.topView);
//        make.right.equalTo(self.topView).offset(-10);
//        make.size.mas_equalTo(CGSizeMake(60, 30));
//    }];
//    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.topView).offset(10);
//        make.size.mas_equalTo(CGSizeMake(self.backBtn.currentImage.size.width, self.backBtn.currentImage.size.height));
//        make.centerY.equalTo(self.titleLabel);
//    }];
//    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.backBtn.mas_right).offset(50);
//        make.right.equalTo(self.topView).offset(-50);
//        make.center.equalTo(self.topView);
//        make.top.equalTo(self.topView);
//    }];
//    [self.loadFailedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self.contentView);
//    }];
}

// tell UIKit that you are using AutoLayout
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints{
//    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
//    }];
//    [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.equalTo(self.contentView);
//        make.height.mas_equalTo(IS_X_Series?90:70);
//    }];
//    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.equalTo(self.contentView);
//        make.height.mas_equalTo(50);
//    }];
//    [self.lockBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView).offset(15);
//        make.centerY.mas_equalTo(self.contentView);
//    }];
//    [self.playOrPauseBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.bottomView);
//        make.left.equalTo(self.bottomView).offset(10);
//    }];
//    [self.leftTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.bottomView).offset(50);
//        make.top.equalTo(self.bottomView.mas_centerY).with.offset(8);
//    }];
//    [self.rightTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.bottomView).offset(-50);
//        make.top.equalTo(self.bottomView.mas_centerY).with.offset(8);
//    }];
//    [self.loadingProgress mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.leftTimeLabel.mas_left).offset(4);
//        make.right.equalTo(self.rightTimeLabel.mas_right).offset(-4);
//        make.centerY.equalTo(self.bottomView);
//    }];
//    [self.progressSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.leftTimeLabel.mas_left).offset(4);
//        make.right.equalTo(self.rightTimeLabel.mas_right).offset(-4);
//        make.centerY.equalTo(self.bottomView).offset(-1);
//        make.height.mas_equalTo(30);
//    }];
//    [self.bottomProgress mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.mas_offset(0);
//        make.bottom.mas_offset(0);
//    }];
//    [self.fullScreenBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.bottomView);
//        make.right.equalTo(self.bottomView).offset(-10);
//    }];
//    [self.backBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.topView).offset(8);
//        make.size.mas_equalTo(CGSizeMake(self.backBtn.currentImage.size.width+6, self.backBtn.currentImage.size.height+4));
//        make.centerY.equalTo(self.titleLabel);
//    }];

    //according to apple super should be called at end of method
    [super updateConstraints];
}

#pragma mark - layoutSubviews
-(void)layoutSubviews{
    [super layoutSubviews];
    self.playerLayer.frame = self.contentView.bounds;
}

#pragma mark - 进入后台
- (void)appDidEnterBackground:(NSNotification*)note{
        if (self.state==VideoPlayerStateFinished) {
            return;
        }else if (self.state==VideoPlayerStateStopped) {//如果已经人为的暂停了
            self.isPauseBySystem = NO;
        }else if(self.state==VideoPlayerStatePlaying){
            self.isPauseBySystem = YES;
            [self pause];
            self.state = VideoPlayerStatePause;
        }
}
-(void)setTintColor:(UIColor *)tintColor{
    _tintColor = tintColor;
    self.progressSlider.minimumTrackTintColor = self.tintColor;
    self.bottomProgress.progressTintColor = self.tintColor;
}

#pragma mark - 进入前台
- (void)appWillEnterForeground:(NSNotification*)note{
        if (self.state==VideoPlayerStateFinished) {

        }else if(self.state==VideoPlayerStateStopped){
            return;
        }else if(self.state==VideoPlayerStatePause){
            if (self.isPauseBySystem) {
                self.isPauseBySystem = NO;
                [self play];
            }
        }else if(self.state==VideoPlayerStatePlaying){

        }
}
// 视频进度条的点击事件
- (void)actionTapGesture:(UITapGestureRecognizer *)sender {
    CGPoint touchLocation = [sender locationInView:self.progressSlider];
    CGFloat value = (self.progressSlider.maximumValue - self.progressSlider.minimumValue) * (touchLocation.x/self.progressSlider.frame.size.width);
    [self.progressSlider setValue:value animated:YES];
    self.bottomProgress.progress = self.progressSlider.value;

    [self.player seekToTime:CMTimeMakeWithSeconds(self.progressSlider.value, self.currentItem.currentTime.timescale)];
    if (self.player.rate != 1.f) {
        self.playOrPauseBtn.selected = NO;
        [self.player play];
    }
}

#pragma mark - 全屏按钮点击func
-(void)fullScreenAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(videoPlayer:clickedFullScreenButton:)]) {
        [self.delegate videoPlayer:self clickedFullScreenButton:sender];
    }
}

#pragma mark - 关闭按钮点击func
-(void)closeTheVideo:(UIButton *)sender{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(videoPlayer:clickedCloseButton:)]) {
        [self.delegate videoPlayer:self clickedCloseButton:sender];
    }
}
// 获取视频长度
- (double)duration{
    AVPlayerItem *playerItem = self.player.currentItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        return CMTimeGetSeconds([[playerItem asset] duration]);
    }else{
        return 0.f;
    }
}
// 获取视频当前播放的时间
- (double)currentTime{
    if (self.player) {
        return CMTimeGetSeconds([self.player currentTime]);
    }else{
        return 0.0;
    }
}

#pragma mark - PlayOrPause
- (void)PlayOrPause:(UIButton *)sender{
    if (self.state==VideoPlayerStateStopped||self.state==VideoPlayerStateFailed) {
        [self play];
    } else if(self.state==VideoPlayerStatePlaying){
        [self pause];
    }else if(self.state ==VideoPlayerStateFinished){
    
    }else if(self.state==VideoPlayerStatePause){

    }
    if ([self.delegate respondsToSelector:@selector(videoPlayer:clickedPlayOrPauseButton:)]) {
        [self.delegate videoPlayer:self clickedPlayOrPauseButton:sender];
    }
}
//播放
-(void)play{
    if (self.isInitPlayer == NO) {
        [self creatVideoPlayerAndReadyToPlay];
        self.playOrPauseBtn.selected = NO;
    }else{
        if (self.state==VideoPlayerStateStopped||self.state ==VideoPlayerStatePause) {
            self.state = VideoPlayerStatePlaying;
            self.playOrPauseBtn.selected = NO;
            [self.player play];
        }else if(self.state ==VideoPlayerStateFinished){
            NSLog(@"fffff");
        }
    }
}
//暂停
-(void)pause{
    if (self.state==VideoPlayerStatePlaying) {
        self.state = VideoPlayerStateStopped;
    }
    [self.player pause];
    self.playOrPauseBtn.selected = YES;
}



-(void)setPrefersStatusBarHidden:(BOOL)prefersStatusBarHidden{
    _prefersStatusBarHidden = prefersStatusBarHidden;
}

#pragma mark - 单击手势方法
- (void)handleSingleTap:(UITapGestureRecognizer *)sender{

    if (self.delegate&&[self.delegate respondsToSelector:@selector(videoPlayer:singleTaped:)]) {
        [self.delegate videoPlayer:self singleTaped:sender];
    }
    [self dismissControlView];
    [UIView animateWithDuration:0.5 animations:^{
        if (self.bottomView.alpha == 0.0) {
            [self showControlView];
        }else{
            [self hiddenControlView];
        }
    } completion:^(BOOL finish){
        
    }];
}

#pragma mark - 双击手势方法
- (void)handleDoubleTap:(UITapGestureRecognizer *)doubleTap{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(videoPlayer:doubleTaped:)]) {
        [self.delegate videoPlayer:self doubleTaped:doubleTap];
    }
    [self PlayOrPause:self.playOrPauseBtn];
    [self showControlView];
}

-(void)setCurrentItem:(AVPlayerItem *)playerItem{
    if (_currentItem==playerItem) {
        return;
    }
    if (_currentItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
        [_currentItem removeObserver:self forKeyPath:@"status"];
        [_currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [_currentItem removeObserver:self forKeyPath:@"duration"];
        [_currentItem removeObserver:self forKeyPath:@"presentationSize"];
        _currentItem = nil;
    }
    _currentItem = playerItem;
    if (_currentItem) {
        [_currentItem addObserver:self
                           forKeyPath:@"status"
                              options:NSKeyValueObservingOptionNew
                              context:PlayViewStatusObservationContext];
        
        [_currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:PlayViewStatusObservationContext];
        // 缓冲区空了，需要等待数据
        [_currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options: NSKeyValueObservingOptionNew context:PlayViewStatusObservationContext];
        // 缓冲区有足够数据可以播放了
        [_currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options: NSKeyValueObservingOptionNew context:PlayViewStatusObservationContext];
        
        [_currentItem addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:PlayViewStatusObservationContext];
        
        [_currentItem addObserver:self forKeyPath:@"presentationSize" options:NSKeyValueObservingOptionNew context:PlayViewStatusObservationContext];

        
        
        
        [self.player replaceCurrentItemWithPlayerItem:_currentItem];
        // 添加视频播放结束通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
    }
}
//设置静音
- (void)setMuted:(BOOL)muted{
    _muted = muted;
    self.player.muted = muted;
}
//设置playerLayer的填充模式
- (void)setPlayerLayerGravity:(VideoPlayerLayerGravity)playerLayerGravity {
    _playerLayerGravity = playerLayerGravity;
    switch (playerLayerGravity) {
        case VideoPlayerLayerGravityResize:
            self.playerLayer.videoGravity = AVLayerVideoGravityResize;
            self.videoGravity = AVLayerVideoGravityResize;
            break;
        case VideoPlayerLayerGravityResizeAspect:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            self.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case VideoPlayerLayerGravityResizeAspectFill:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            self.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
        default:
            break;
    }
}

//重写playerModel的setter方法，处理自己的逻辑
-(void)setPlayerModel:(PlayerModel *)playerModel{    
    if (_playerModel==playerModel) {
        return;
    }
    _playerModel = playerModel;
    self.isPauseBySystem = NO;
    self.seekTime = playerModel.seekTime;
    if(playerModel.playerItem){
        self.currentItem = playerModel.playerItem;
    }else{
        self.videoURL = playerModel.videoURL;
    }
    if (self.isInitPlayer) {
        self.state = VideoPlayerStateBuffering;
    }else{
        self.state = VideoPlayerStateStopped;

    }
}
-(void)creatVideoPlayerAndReadyToPlay{
    self.isInitPlayer = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    //设置player的参数
    if(self.currentItem){
        self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
    }else{
        self.urlAsset = [AVURLAsset assetWithURL:self.videoURL];
        self.currentItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
        self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
    }
    if(self.loopPlay){
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    }else{
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    }
    //ios10新添加的属性，如果播放不了，可以试试打开这个代码
    if ([self.player respondsToSelector:@selector(automaticallyWaitsToMinimizeStalling)]) {
        self.player.automaticallyWaitsToMinimizeStalling = YES;
    }
    self.player.usesExternalPlaybackWhileExternalScreenIsActive=YES;
    //AVPlayerLayer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    //VideoPlayer视频的默认填充模式，AVLayerVideoGravityResizeAspect
    self.playerLayer.frame = self.contentView.layer.bounds;
    self.playerLayer.videoGravity = self.videoGravity;
    [self.contentView.layer insertSublayer:self.playerLayer atIndex:0];
    self.state = VideoPlayerStateBuffering;
    //监听播放状态
    [self initTimer];
    [self.player play];
}

-(void)setBackBtnStyle:(BackBtnStyle)backBtnStyle{
    _backBtnStyle = backBtnStyle;
    if (backBtnStyle==BackBtnStylePop) {
        [self.backBtn setImage:[UIImage imageNamed:@"player_icon_nav_back"] forState:UIControlStateNormal];
        [self.backBtn setImage:[UIImage imageNamed:@"player_icon_nav_back"] forState:UIControlStateSelected];
    }else if(backBtnStyle==BackBtnStyleClose){
        [self.backBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [self.backBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateSelected];
    }else{
        [self.backBtn setImage:nil forState:UIControlStateNormal];
        [self.backBtn setImage:nil forState:UIControlStateSelected];
    }
}
-(void)setIsHiddenTopAndBottomView:(BOOL)isHiddenTopAndBottomView{
    _isHiddenTopAndBottomView = isHiddenTopAndBottomView;
    self.prefersStatusBarHidden = isHiddenTopAndBottomView;
}
-(void)setLoopPlay:(BOOL)loopPlay{
    _loopPlay = loopPlay;
    if(self.player){
        if(loopPlay){
            self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        }else{
            self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        }
    }
}

#pragma mark - 播放完成
- (void)moviePlayDidEnd:(NSNotification *)notification {
    if (self.delegate&&[self.delegate respondsToSelector:@selector(videoPlayerFinishedPlay:)]) {
        [self.delegate videoPlayerFinishedPlay:self];
    }
    [self.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            [self showControlView];
            if(!self.loopPlay){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.state = VideoPlayerStateFinished;
                    self.bottomProgress.progress = 0;
                    self.playOrPauseBtn.selected = YES;
                });
            }
        }
    }];
}
//显示操作栏view
-(void)showControlView{
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomView.alpha = 1.0;
        self.topView.alpha = 1.0;
        self.bottomProgress.alpha = 0.f;
        self.isHiddenTopAndBottomView = NO;
        if (self.delegate&&[self.delegate respondsToSelector:@selector(videoPlayer:isHiddenTopAndBottomView:)]) {
            [self.delegate videoPlayer:self isHiddenTopAndBottomView:self.isHiddenTopAndBottomView];
        }
    } completion:^(BOOL finish){

    }];
}

-(void)hiddenLockBtn{
    self.prefersStatusBarHidden = self.hiddenStatusBar = YES;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(videoPlayer:singleTaped:)]) {
        [self.delegate videoPlayer:self singleTaped:self.singleTap];
    }
}
//隐藏操作栏view
-(void)hiddenControlView{
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomView.alpha = 0.0;
        self.topView.alpha = 0.0;
        self.bottomProgress.alpha = 0.f;
        self.isHiddenTopAndBottomView = YES;
        if (self.delegate&&[self.delegate respondsToSelector:@selector(videoPlayer:isHiddenTopAndBottomView:)]) {
            [self.delegate videoPlayer:self isHiddenTopAndBottomView:self.isHiddenTopAndBottomView];
        }
    } completion:^(BOOL finish){
        
    }];
}

#pragma mark--开始拖曳sidle
- (void)stratDragSlide:(UISlider *)slider{
    self.isDragingSlider = YES;
}

#pragma mark - 播放进度
- (void)updateProgress:(UISlider *)slider{
    self.isDragingSlider = NO;
    [self.player seekToTime:CMTimeMakeWithSeconds(slider.value, self.currentItem.currentTime.timescale)];
}

-(void)dismissControlView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoDismissControlView) object:nil];
    [self performSelector:@selector(autoDismissControlView) withObject:nil afterDelay:5.0];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    /* AVPlayerItem "status" property value observer. */
    if (context == PlayViewStatusObservationContext){
        if ([keyPath isEqualToString:@"status"]) {
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            switch (status){
                case AVPlayerItemStatusUnknown:{
                    [self.loadingProgress setProgress:0.0 animated:NO];
                    self.state = VideoPlayerStateBuffering;
                }
                    break;
                case AVPlayerItemStatusReadyToPlay:{
                      /* Once the AVPlayerItem becomes ready to play, i.e.
                     [playerItem status] == AVPlayerItemStatusReadyToPlay,
                     its duration can be fetched from the item. */
                    if (self.state==VideoPlayerStateStopped||self.state==VideoPlayerStatePause) {
                      
                    }else{
                        //5s dismiss controlView
                        [self dismissControlView];
                        self.state=VideoPlayerStatePlaying;
                    }
                    if (self.delegate&&[self.delegate respondsToSelector:@selector(videoPlayerReadyToPlay:VideoPlayerStatus:)]) {
                        [self.delegate videoPlayerReadyToPlay:self playerStatus:VideoPlayerStatePlaying];
                    }
                    if (self.seekTime) {
                        [self seekToTimeToPlay:self.seekTime];
                    }
                    if (self.muted) {
                        self.player.muted = self.muted;
                    }
                    if (self.state==VideoPlayerStateStopped||self.state==VideoPlayerStatePause) {
                        
                    }else{
                    
                    }
                }
                    break;
                    
                case AVPlayerItemStatusFailed:{
                    self.state = VideoPlayerStateFailed;
                    if (self.delegate&&[self.delegate respondsToSelector:@selector(videoPlayerFailedPlay:playerStatus:)]) {
                        [self.delegate videoPlayerFailedPlay:self playerStatus:VideoPlayerStateFailed];
                    }
                    NSError *error = [self.player.currentItem error];
                    if (error) {
                    }
                    NSLog(@"视频加载失败===%@",error.description);
                }
                    break;
            }
        }else if ([keyPath isEqualToString:@"duration"]) {
            if ((CGFloat)CMTimeGetSeconds(self.currentItem.duration) != self.totalTime) {
                self.totalTime = (CGFloat) CMTimeGetSeconds(self.currentItem.asset.duration);
                
                if (!isnan(self.totalTime)) {
                    self.progressSlider.maximumValue = self.totalTime;
                }else{
                    self.totalTime = MAXFLOAT;
                }
                if (self.state==VideoPlayerStateStopped||self.state==VideoPlayerStatePause) {
                   
                }else{
                    self.state = VideoPlayerStatePlaying;
                }
            }
        }else if ([keyPath isEqualToString:@"presentationSize"]) {
            self.playerModel.presentationSize = self.currentItem.presentationSize;
            if (self.delegate&&[self.delegate respondsToSelector:@selector(videoPlayerGotVideoSize:videoSize:)]) {
                [self.delegate videoPlayerGotVideoSize:self videoSize:self.playerModel.presentationSize];
            }
        }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            // 计算缓冲进度
            NSTimeInterval timeInterval = [self availableDuration];
            CMTime duration             = self.currentItem.duration;
            CGFloat totalDuration       = CMTimeGetSeconds(duration);
            // 缓冲颜色
            self.loadingProgress.progressTintColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7];
            [self.loadingProgress setProgress:timeInterval / totalDuration animated:NO];
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            // 当缓冲是空的时候
            if (self.currentItem.playbackBufferEmpty) {
                NSLog(@"%s VideoPlayerStateBuffering",__FUNCTION__);
                [self loadedTimeRanges];
            }
        }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            // 当缓冲好的时候
            if (self.currentItem.playbackLikelyToKeepUp && self.state == VideoPlayerStateBuffering){
                NSLog(@"55555%s VideoPlayerStatePlaying",__FUNCTION__);
                if (self.state==VideoPlayerStateStopped||self.state==VideoPlayerStatePause) {
                    
                }else{
                    self.state = VideoPlayerStatePlaying;
                }
            }
        }
    }
}
// 缓冲回调
- (void)loadedTimeRanges{
    if (self.state==VideoPlayerStatePause) {
        
    }else{
        self.state = VideoPlayerStateBuffering;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.state==VideoPlayerStatePlaying||self.state==VideoPlayerStateFinished) {
            
        }else{
            [self play];
        }
    });
}


#pragma mark - autoDismissControlView
-(void)autoDismissControlView{
    [self hiddenControlView];//隐藏操作栏
}
#pragma mark - 定时器
-(void)initTimer{
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver =  [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC)  queue:dispatch_get_main_queue() /* If you pass NULL, the main queue is used. */
        usingBlock:^(CMTime time){
        [weakSelf syncScrubber];
    }];
}
- (void)syncScrubber{

    CMTime playerDuration = [self playerItemDuration];
    CGFloat totalTime = (CGFloat)CMTimeGetSeconds(playerDuration);

   
    long long nowTime = self.currentItem.currentTime.value/self.currentItem.currentTime.timescale;
    self.leftTimeLabel.text = [self convertTime:nowTime];
    self.rightTimeLabel.text = [self convertTime:self.totalTime];
    
    
    if (isnan(totalTime)) {
        self.rightTimeLabel.text = @"";
        NSLog(@"NaN");
    }
    if (CMTIME_IS_INVALID(playerDuration)){

        
    }
    
    
        if (self.isDragingSlider==YES) {//拖拽slider中，不更新slider的值
            
        }else if(self.isDragingSlider==NO){
            CGFloat value = (self.progressSlider.maximumValue - self.progressSlider.minimumValue) * nowTime / self.totalTime + self.progressSlider.minimumValue;
            self.progressSlider.value = value;
            [self.bottomProgress setProgress:nowTime/(self.totalTime) animated:YES];
        }
}
//seekTime跳到time处播放
- (void)seekToTimeToPlay:(double)seekTime{
    if (self.player&&self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        if (seekTime>=self.totalTime) {
            seekTime = 0.0;
        }
        if (seekTime<0) {
            seekTime=0.0;
        }
//        int32_t timeScale = self.player.currentItem.asset.duration.timescale;
        //currentItem.asset.duration.timescale计算的时候严重堵塞主线程，慎用
        /* A timescale of 1 means you can only specify whole seconds to seek to. The timescale is the number of parts per second. Use 600 for video, as Apple recommends, since it is a product of the common video frame rates like 50, 60, 25 and 24 frames per second*/
        __weak typeof(self) weakSelf = self;

        [self.player seekToTime:CMTimeMakeWithSeconds(seekTime, self.currentItem.currentTime.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            weakSelf.seekTime = 0;
        }];
    }
}
- (CMTime)playerItemDuration{
    AVPlayerItem *playerItem = self.currentItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        return([playerItem duration]);
    }
    return(kCMTimeInvalid);
}
- (NSString *)convertTime:(float)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    if (second/3600 >= 1) {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
    } else {
        [[self dateFormatter] setDateFormat:@"mm:ss"];
    }
    return [[self dateFormatter] stringFromDate:d];
}
//计算缓冲进度
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [_currentItem loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark - touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //这个是用来判断, 如果有多个手指点击则不做出响应
    UITouch * touch = (UITouch *)touches.anyObject;
    if (touches.count > 1 || [touch tapCount] > 1 || event.allTouches.count > 1) {
        return;
    }
//    这个是用来判断, 手指点击的是不是本视图, 如果不是则不做出响应
    if (![[(UITouch *)touches.anyObject view] isEqual:self.contentView] &&  ![[(UITouch *)touches.anyObject view] isEqual:self]) {
        return;
    }
    [super touchesBegan:touches withEvent:event];

    //触摸开始, 初始化一些值
    self.hasMoved = NO;
    self.touchBeginValue = self.progressSlider.value;
    //位置
    self.touchBeginPoint = [touches.anyObject locationInView:self];
    //亮度
    self.touchBeginLightValue = [UIScreen mainScreen].brightness;
    //声音
    self.touchBeginVoiceValue = self.volumeSlider.value;
}


NSString * calculateTimeWithTimeFormatter(long long timeSecond){
    NSString * theLastTime = nil;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%.2lld", timeSecond];
    }else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%.2lld:%.2lld", timeSecond/60, timeSecond%60];
    }else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%.2lld:%.2lld:%.2lld", timeSecond/3600, timeSecond%3600/60, timeSecond%60];
    }
    return theLastTime;
}
//重置播放器
-(void )resetVideoPlayer{
    self.currentItem = nil;
    self.isInitPlayer = NO;
    self.bottomProgress.progress = 0;
    _playerModel = nil;
    self.seekTime = 0;
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 暂停
    [self pause];
    self.progressSlider.value = 0;
    self.bottomProgress.progress = 0;
    self.loadingProgress.progress = 0;
    self.leftTimeLabel.text = self.rightTimeLabel.text = [self convertTime:0.0];//设置默认值
    // 移除原来的layer
    [self.playerLayer removeFromSuperlayer];
    // 替换PlayerItem为nil
    [self.player replaceCurrentItemWithPlayerItem:nil];
    // 把player置为nil
    self.player = nil;
}
-(void)dealloc{
    NSLog(@"VideoPlayer dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.player pause];
    [self.player removeTimeObserver:self.playbackTimeObserver];
    
    //移除观察者
    [_currentItem removeObserver:self forKeyPath:@"status"];
    [_currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [_currentItem removeObserver:self forKeyPath:@"duration"];
    [_currentItem removeObserver:self forKeyPath:@"presentationSize"];
    _currentItem = nil;

    [self.playerLayer removeFromSuperlayer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
    self.playOrPauseBtn = nil;
    self.playerLayer = nil;
    [UIApplication sharedApplication].idleTimerDisabled=NO;
}

//获取当前的旋转状态
+(CGAffineTransform)getCurrentDeviceOrientation{
    //状态条的方向已经设置过,所以这个就是你想要旋转的方向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //根据要进行旋转的方向来计算旋转的角度
    if (orientation ==UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    }else if (orientation ==UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    }else if(orientation ==UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

@end
