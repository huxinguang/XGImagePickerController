//
//  MediaCell.m
//  MyApp
//
//  Created by huxinguang on 2018/10/30.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "MediaCell.h"
#import "PickerMacro.h"
#import "UIView+XGAdd.h"
#import "AssetPickerManager.h"
#import "AssetModel.h"


@interface MediaCell()<UIScrollViewDelegate>

@end

@implementation MediaCell

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
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = self.contentView.bounds;
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 3;
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

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [FLAnimatedImageView new];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

#pragma mark - Setter

- (void)setItem:(AssetModel *)item{
    if (_item == item) return;
    _item = item;
    
    [self.scrollView setZoomScale:1.0 animated:NO];
    self.scrollView.maximumZoomScale = 1.0;
    __weak typeof (self) weakSelf = self;
    [[AssetPickerManager manager]getPhotoWithAsset:item.asset completion:^(UIImage *photo, NSDictionary *info) {
        weakSelf.scrollView.maximumZoomScale = 3;
        if (photo) {
            weakSelf.imageView.image = photo;
            [weakSelf resizeSubviewSize];
        }
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
    _imageView.frame = _mediaContainerView.bounds;
    [CATransaction commit];
}


-(void)layoutSubviews{
    [super layoutSubviews];

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



@end
