//
//  XG_MediaCell.m
//  MyApp
//
//  Created by huxinguang on 2018/10/30.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "XG_MediaCell.h"
#import "XG_PickerMacro.h"
#import "UIView+XGAdd.h"
#import "XG_AssetPickerManager.h"
#import "XG_AssetModel.h"


@interface XG_MediaCell()<UIScrollViewDelegate,XG_PlayerManagerDelegate,BottomBarDelegate>

@end

@implementation XG_MediaCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews{
    [self.contentView addSubview:self.scrollView];
    [self.scrollView addSubview:self.mediaContainerView];
    [self.mediaContainerView addSubview:self.imageView];
    [self.mediaContainerView addSubview:self.playBtn];
    [self.contentView addSubview:self.bottomBar];
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = self.contentView.bounds;
        _scrollView.bouncesZoom = YES;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

-(UIView *)mediaContainerView{
    if (!_mediaContainerView) {
        _mediaContainerView = [UIView new];
        _mediaContainerView.clipsToBounds = YES;
    }
    return _mediaContainerView;
}

- (FLAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [FLAnimatedImageView new];
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

- (UIButton *)playBtn{
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:ImageWithFile(@"player_play") forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

-(BottomBar *)bottomBar{
    if (!_bottomBar) {
        _bottomBar = [[BottomBar alloc]initWithFrame:CGRectMake(0, kAppScreenHeight-30-kAppTabbarSafeBottomMargin, kAppScreenWidth, 30)];
        _bottomBar.delegate = self;
    }
    return _bottomBar;
}

#pragma mark - Setter

- (void)setItem:(XG_AssetModel *)item{
    _item = item;
    if (item.asset.mediaType == PHAssetMediaTypeVideo) {
        self.playBtn.hidden = NO;
    }else{
        self.playBtn.hidden = YES;
    }
    self.bottomBar.hidden = YES;
    self.bottomBar.rightTimeLabel.text = [self getNewTimeFromSecond:item.asset.duration];
    [self.scrollView setZoomScale:1.0 animated:NO];
    self.scrollView.maximumZoomScale = 1.0;
    __weak typeof (self) weakSelf = self;
    [[XG_AssetPickerManager manager]getPhotoWithAsset:item.asset completion:^(id photo, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (item.asset.mediaType == PHAssetMediaTypeImage) {
                weakSelf.scrollView.maximumZoomScale = 3;
            }
            if (photo) {
                if (@available(iOS 11.0, *)) {
                    if (item.asset.playbackStyle == PHAssetPlaybackStyleImageAnimated) {
                        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:photo];
                        weakSelf.imageView.animatedImage = image;
                        [weakSelf resizeSubviewSize];
                        return;
                    }
                }
                weakSelf.imageView.image = photo;
                [weakSelf resizeSubviewSize];
            }
        });
    }];
   
    [self resizeSubviewSize];
    
}

- (void)resizeSubviewSize {
    _mediaContainerView.origin = CGPointZero;
    _mediaContainerView.width = self.width;
    
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > self.height / self.width) {
        _mediaContainerView.height = floor(image.size.height / (image.size.width / self.width));
    } else {
        CGFloat height = image.size.height / image.size.width * self.width;
        if (height < 1 || isnan(height)) height = self.height;
        height = floor(height);
        _mediaContainerView.height = height;
        _mediaContainerView.centerY = self.height / 2;
    }
    if (_mediaContainerView.height > self.height && _mediaContainerView.height - self.height <= 1) {
        _mediaContainerView.height = self.height;
    }
    self.scrollView.contentSize = CGSizeMake(self.width, MAX(_mediaContainerView.height, self.height));
    [self.scrollView scrollRectToVisible:self.scrollView.bounds animated:NO];
    
    if (_mediaContainerView.height <= self.height) {
        self.scrollView.alwaysBounceVertical = NO;
    } else {
        self.scrollView.alwaysBounceVertical = YES;
    }

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.imageView.frame = _mediaContainerView.bounds;
    self.playBtn.size = CGSizeMake(42, 42);
    self.playBtn.center = self.imageView.center;
    [CATransaction commit];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.mediaContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    self.mediaContainerView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - player

- (void)playAction{
    self.bottomBar.hidden = NO;
    self.playBtn.hidden = YES;
    /*
     在这里设置代理，解决cell复用引起的部分视频播放时slider进度和播放时间不更新的问题
     */
    [XG_PlayerManager shareInstance].delegate = self;
    __weak typeof (self) weakSelf = self;
    [[XG_AssetPickerManager manager]getVideoWithAsset:self.item.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        if (playerItem) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[XG_PlayerManager shareInstance] playWithItem:playerItem onLayer:weakSelf.imageView.layer];
            });
        }
    }];
}

- (void)showOrHidePlayerControls{
    if (self.item.asset.mediaType == PHAssetMediaTypeImage) {
        return;
    }
}

- (void)pauseAndResetPlayer{
    self.playBtn.hidden = NO;
    self.bottomBar.leftTimeLabel.text = @"00:00";
    self.bottomBar.hidden = YES;
    self.bottomBar.slider.value = 0;
    self.sliderIsSliding = NO;
    [XG_PlayerManager shareInstance].delegate = nil;//一定要在这里置为nil
    [[XG_PlayerManager shareInstance] resetPlayer];
    
}

- (void)pausePlayer{
    self.playBtn.hidden = NO;
    self.bottomBar.hidden = YES;
    [[XG_PlayerManager shareInstance] pause];
}

#pragma mark - XG_PlayerManagerDelegate

- (void)playerDidFinishPlay:(XG_PlayerManager *)manager{
    self.playBtn.hidden = NO;
    self.bottomBar.hidden = YES;
    self.bottomBar.slider.value = 0.0;
    self.bottomBar.leftTimeLabel.text = @"00:00";
    self.sliderIsSliding = NO;
    [manager resetPlayer];
}

- (void)playerDidPlayToTime:(CMTime)currentTime totalTime:(CMTime)totalTime{
    if (!self.sliderIsSliding) {
        self.bottomBar.leftTimeLabel.text = [self getNewTimeFromSecond:CMTimeGetSeconds(currentTime)];
        self.bottomBar.slider.value = CMTimeGetSeconds(currentTime)/CMTimeGetSeconds(totalTime);
    }
}

- (NSString *)getNewTimeFromSecond:(int)seconds {
    NSString *newTime;
    if (seconds < 10) {
        newTime = [NSString stringWithFormat:@"00:0%d",seconds];
    } else if (seconds < 60) {
        newTime = [NSString stringWithFormat:@"00:%d",seconds];
    } else {
        int min = seconds / 60;
        int sec = seconds - (min * 60);
        if (sec < 10) {
            if (min < 10) {
                newTime = [NSString stringWithFormat:@"0%d:0%d",min,sec];
            }else{
                newTime = [NSString stringWithFormat:@"%d:0%d",min,sec];
            }
        } else {
            if (min < 10) {
                newTime = [NSString stringWithFormat:@"0%d:%d",min,sec];
            }else{
                newTime = [NSString stringWithFormat:@"%d:%d",min,sec];
            }
        }
    }
    return newTime;
}

#pragma mark - BottomBarDelegate

- (void)sliderDidSlide{
    self.sliderIsSliding = YES;
}

- (void)slideDidEndWithValue:(float)value{
    CMTime duration = [XG_PlayerManager shareInstance].playerItem.duration;
    Float64 totalSeconds = CMTimeGetSeconds(duration);
    Float64 currentSeconds = totalSeconds*value;
    CMTimeScale timescale = [XG_PlayerManager shareInstance].playerItem.currentTime.timescale;
    CMTime current = CMTimeMake(currentSeconds*timescale, timescale);
    [[XG_PlayerManager shareInstance] seekSmoothlyToTime:current];
    self.sliderIsSliding = NO;
}

@end

@implementation BottomBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
        [self addSubview:self.leftTimeLabel];
        [self addSubview:self.slider];
        [self addSubview:self.rightTimeLabel];
        [self addConstraints];
    }
    return self;
}

- (void)addConstraints{
    self.leftTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.slider.translatesAutoresizingMaskIntoConstraints = NO;
    self.rightTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [NSLayoutConstraint constraintWithItem:self.leftTimeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0],
                                              [NSLayoutConstraint constraintWithItem:self.leftTimeLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
                                              [NSLayoutConstraint constraintWithItem:self.leftTimeLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:60],
                                              [NSLayoutConstraint constraintWithItem:self.leftTimeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0],
                                              [NSLayoutConstraint constraintWithItem:self.slider attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.leftTimeLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:0],
                                              [NSLayoutConstraint constraintWithItem:self.slider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20],
                                              [NSLayoutConstraint constraintWithItem:self.slider attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0],
                                              [NSLayoutConstraint constraintWithItem:self.slider attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.rightTimeLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
                                              [NSLayoutConstraint constraintWithItem:self.rightTimeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0],
                                              [NSLayoutConstraint constraintWithItem:self.rightTimeLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0],
                                              [NSLayoutConstraint constraintWithItem:self.rightTimeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0],
                                              [NSLayoutConstraint constraintWithItem:self.rightTimeLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.leftTimeLabel attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]
                                              ]];
    
}

-(UILabel *)leftTimeLabel{
    if (!_leftTimeLabel) {
        _leftTimeLabel = [UILabel new];
        _leftTimeLabel.font = [UIFont systemFontOfSize:12];
        _leftTimeLabel.textColor = [UIColor whiteColor];
        _leftTimeLabel.textAlignment = NSTextAlignmentCenter;
        _leftTimeLabel.text = @"00:00";
    }
    return _leftTimeLabel;
}

-(UISlider *)slider{
    if (!_slider) {
        _slider = [UISlider new];
        _slider.value = 0.0;
        _slider.minimumValue = 0.0;
        _slider.maximumValue = 1.0;
        _slider.minimumTrackTintColor = [UIColor colorWithRed:36/255.0 green:160/255.0 blue:252/255.0 alpha:1];
        _slider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        _slider.backgroundColor = [UIColor clearColor];
        [_slider setThumbImage:ImageWithFile(@"dot") forState:UIControlStateNormal];
        [_slider addTarget:self action:@selector(slideDidEnd:) forControlEvents:UIControlEventTouchUpInside];
        [_slider addTarget:self action:@selector(sliderDidSlide:)  forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

-(UILabel *)rightTimeLabel{
    if (!_rightTimeLabel) {
        _rightTimeLabel = [UILabel new];
        _rightTimeLabel.font = [UIFont systemFontOfSize:12];
        _rightTimeLabel.textColor = [UIColor whiteColor];
        _rightTimeLabel.textAlignment = NSTextAlignmentCenter;
        _rightTimeLabel.text = @"00:00";
    }
    return _rightTimeLabel;
}

- (void)slideDidEnd:(UISlider *)slider{
    if ([self.delegate respondsToSelector:@selector(slideDidEndWithValue:)]) {
        [self.delegate slideDidEndWithValue:slider.value];
    }
}

- (void)sliderDidSlide:(UISlider *)slider{
    if ([self.delegate respondsToSelector:@selector(sliderDidSlide)]) {
        [self.delegate sliderDidSlide];
    }
}



@end

