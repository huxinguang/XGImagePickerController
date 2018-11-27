//
//  XG_MediaCell.h
//  MyApp
//
//  Created by huxinguang on 2018/10/30.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImage.h"
#import "XG_PlayerManager.h"

@class XG_AssetModel;
@class BottomBar;
@interface XG_MediaCell : UICollectionViewCell

@property (nonatomic, strong) XG_AssetModel *item;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *mediaContainerView;//用于动画
@property (nonatomic, strong) FLAnimatedImageView *imageView;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) BottomBar *bottomBar;
@property (nonatomic, assign) BOOL sliderIsSliding;

- (void)resizeSubviewSize;
- (void)showOrHidePlayerControls;
- (void)pauseAndResetPlayer;
- (void)pausePlayer;

@end

@protocol BottomBarDelegate;
@interface BottomBar: UIView
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, weak) id<BottomBarDelegate> delegate;
@end

@protocol BottomBarDelegate<NSObject>
- (void)sliderDidSlide;
- (void)slideDidEndWithValue:(float)value;
@end





