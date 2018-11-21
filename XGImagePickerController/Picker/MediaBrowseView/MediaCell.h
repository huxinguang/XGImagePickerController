//
//  MediaCell.h
//  MyApp
//
//  Created by huxinguang on 2018/10/30.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImage.h"
#import "PlayerManager.h"

@class AssetModel;
@class BottomBar;
@interface MediaCell : UICollectionViewCell

@property (nonatomic, strong) AssetModel *item;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *mediaContainerView;//用于动画
@property (nonatomic, strong) FLAnimatedImageView *imageView;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) PlayerManager *playerManager;
@property (nonatomic, strong) BottomBar *bottomBar;

- (void)resizeSubviewSize;
- (void)showOrHidePlayerControls;
- (void)pauseAndResetPlayer;
- (void)pausePlayer;

@end

@interface BottomBar: UIView
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@end


