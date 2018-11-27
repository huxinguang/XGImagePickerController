//
//  XG_MediaBrowseView.m
//  MyApp
//
//  Created by huxinguang on 2018/10/30.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "XG_MediaBrowseView.h"
#import "XG_MediaCell.h"
#import "UIView+XGAdd.h"

@interface XG_MediaBrowseView()<UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>
@property (nonatomic, weak) UIView *fromView;
@property (nonatomic, weak) UIView *toContainerView;
@property (nonatomic, strong) UIView *blackBackground;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger fromItemIndex;
@property (nonatomic, strong) UICollectionView *fromCollectionView;
@property (nonatomic, assign) BOOL isPresented;


@end

@implementation XG_MediaBrowseView

- (instancetype)initWithItems:(NSArray<XG_AssetModel *> *)items{
    self = [super init];
    if (items.count == 0) return nil;
    self.backgroundColor = [UIColor clearColor];
    self.frame = [UIScreen mainScreen].bounds;
    self.clipsToBounds = YES;
    _items = items;
    [self setupSubViews];
    [self addGesture];
    
    return self;
}

- (void)setupSubViews{
    [self addSubview:self.blackBackground];
    [self addSubview:self.collectionView];
}

#pragma mark - Getter & Setter

- (UIView *)blackBackground{
    if (!_blackBackground) {
        _blackBackground = [UIView new];
        _blackBackground.frame = self.bounds;
        _blackBackground.backgroundColor = [UIColor blackColor];
        _blackBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _blackBackground;
}

-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = [UIScreen mainScreen].bounds.size;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[XG_MediaCell class] forCellWithReuseIdentifier:NSStringFromClass([XG_MediaCell class])];
    }
    return _collectionView;
}

- (NSInteger)currentPage{
    NSInteger page = self.collectionView.contentOffset.x / self.collectionView.width + 0.5;
    if (page >= _items.count) page = (NSInteger)_items.count - 1;
    if (page < 0) page = 0;
    return page;
}

#pragma mark - Gesture

- (void)addGesture{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    singleTap.delegate = self;
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
    doubleTap.delegate = self;
    doubleTap.numberOfTapsRequired = 2;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:doubleTap];
    
}

- (void)onSingleTap:(UITapGestureRecognizer *)gesture{
    XG_MediaCell *cell = [self currentCell];
    if (cell.item.asset.mediaType == PHAssetMediaTypeVideo && cell.playBtn.hidden) {
        [cell pauseAndResetPlayer];
        return;
    }
    [self dismissAnimated:YES completion:nil];
}

- (void)onDoubleTap:(UITapGestureRecognizer *)gesture{
    if (!_isPresented) return;
    XG_MediaCell *cell = [self currentCell];
    if (cell.item.asset.mediaType == PHAssetMediaTypeVideo) {
        [cell pausePlayer];
        return;
    }
    if (cell.scrollView.zoomScale > 1) {
        [cell.scrollView setZoomScale:1 animated:YES];
    } else {
        CGPoint touchPoint = [gesture locationInView:cell.imageView];
        CGFloat newZoomScale = cell.scrollView.maximumZoomScale;
        CGFloat xsize = self.width / newZoomScale;
        CGFloat ysize = self.height / newZoomScale;
        [cell.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)presentCellImageAtIndexPath:(NSIndexPath *)indexpath
                 FromCollectionView:(UICollectionView *)collectV
                        toContainer:(UIView *)toContainer
                           animated:(BOOL)animated
                         completion:(void (^)(void))completion{
    if (!toContainer) return;
    
    _fromCollectionView = collectV;
    XG_AssetCell *assetCell = (XG_AssetCell *)[_fromCollectionView cellForItemAtIndexPath:indexpath];
    _fromView = assetCell.imageView;
    _toContainerView = toContainer;
    _fromItemIndex = indexpath.item;
    
    self.size = _toContainerView.size;
    [_toContainerView addSubview:self];

    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_fromItemIndex-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
    [self.collectionView layoutIfNeeded];//关键，否则下面获取的cell是nil
    
    [UIView setAnimationsEnabled:YES];
    
    XG_MediaCell *cell = [self currentCell];
    CGRect fromFrame = [_fromView convertRect:_fromView.bounds toView:cell.mediaContainerView];
    
    cell.mediaContainerView.clipsToBounds = NO;
    cell.imageView.frame = fromFrame;
    
    float oneTime = animated ? 0.3 : 0;
    self.collectionView.userInteractionEnabled = NO;
    [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        cell.imageView.frame = cell.mediaContainerView.bounds;
    }completion:^(BOOL finished) {
        cell.mediaContainerView.clipsToBounds = YES;
        cell.imageView.clipsToBounds = YES;
        self.isPresented = YES;
        self.collectionView.userInteractionEnabled = YES;
        if (completion) completion();
    }];
    
}


- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [[NSNotificationCenter defaultCenter]postNotificationName:kShowStatusBarNotification object:nil];
    [UIView setAnimationsEnabled:YES];
    self.blackBackground.alpha = 0;
    NSInteger currentPage = self.currentPage;
    XG_MediaCell *cell = [self currentCell];
    cell.imageView.clipsToBounds = YES;

    UIView *fromView = nil;
    if (self.fromItemIndex-1 == currentPage) {
        fromView = self.fromView;
    } else {
        XG_AssetCell *assetCell = (XG_AssetCell *)[_fromCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentPage+1 inSection:0]];
        fromView = assetCell.imageView;
    }
    
    self.isPresented = NO;
    BOOL isFromImageClipped = fromView.layer.contentsRect.size.height < 1;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (isFromImageClipped) {
        CGRect frame = cell.mediaContainerView.frame;
        cell.mediaContainerView.layer.anchorPoint = CGPointMake(0.5, 0);
        cell.mediaContainerView.frame = frame;
    }
    [CATransaction commit];
    
    if (fromView == nil) {
        [UIView animateWithDuration:animated ? 0.25 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 0.0;
            [self.collectionView.layer setValue:@0.95 forKeyPath:@"transform.scale"];
            self.collectionView.alpha = 0;
        }completion:^(BOOL finished) {
            [self.collectionView.layer setValue:@1 forKeyPath:@"transform.scale"];
            [self removeFromSuperview];
            if (completion) completion();
        }];
        return;
    }
    
    if (isFromImageClipped) {
        CGPoint off = cell.scrollView.contentOffset;
        off.y = 0 - cell.scrollView.contentInset.top;
        [cell.scrollView setContentOffset:off animated:NO];
    }
    
    [UIView animateWithDuration:animated ? 0.3 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
        if (isFromImageClipped) {
            CGRect fromFrame = [fromView convertRect:fromView.bounds toView:cell];
            CGFloat scale = fromFrame.size.width / cell.mediaContainerView.width * cell.scrollView.zoomScale;
            CGFloat height = fromFrame.size.height / fromFrame.size.width * cell.mediaContainerView.width;
            if (isnan(height)) height = cell.mediaContainerView.height;
            
            cell.mediaContainerView.height = height;
            cell.mediaContainerView.center = CGPointMake(CGRectGetMidX(fromFrame), CGRectGetMinY(fromFrame));
            [cell.mediaContainerView.layer setValue:@(scale) forKeyPath:@"transform.scale"];
            
        } else {
            CGRect fromFrame = [fromView convertRect:fromView.bounds toView:cell.mediaContainerView];
            cell.mediaContainerView.clipsToBounds = NO;
            cell.imageView.contentMode = fromView.contentMode;
            cell.imageView.frame = fromFrame;
        }
    }completion:^(BOOL finished) {
        self.alpha = 0;
        cell.mediaContainerView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        [self removeFromSuperview];
        if (completion) completion();
    }];

}


- (XG_MediaCell *)currentCell{
    return (XG_MediaCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0]];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    XG_MediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([XG_MediaCell class]) forIndexPath:indexPath];
    cell.item = self.items[indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    NSArray <NSIndexPath *> *indexPaths = [_fromCollectionView indexPathsForVisibleItems];
    NSIndexPath *indexP = [NSIndexPath indexPathForItem:indexPath.item + 1 inSection:0];
    if (![indexPaths containsObject:indexP]) {
        [_fromCollectionView scrollToItemAtIndexPath:indexP atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    XG_MediaCell *cell = [self currentCell];
    if (cell.item.asset.mediaType == PHAssetMediaTypeVideo) {
        NSInteger currentPage = self.currentPage;
        if(targetContentOffset->x != scrollView.frame.size.width*currentPage){
            [cell pauseAndResetPlayer];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate
#pragma mark - resolve collectionView & slider conflict
// 方案一
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (CGRectContainsPoint([self currentCell].bottomBar.frame, [touch locationInView:self])) {
        self.collectionView.scrollEnabled = NO;
        return NO;
    }
    self.collectionView.scrollEnabled = YES;
    return YES;
}

// 方案二
//-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
//    if (CGRectContainsPoint([self currentCell].bottomBar.frame, point)) {
//        self.collectionView.scrollEnabled = NO;
//        return YES;
//    }
//    self.collectionView.scrollEnabled = YES;
//    return YES;
//}

// 方案三
//-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//    if (CGRectContainsPoint([self currentCell].bottomBar.frame, point)) {
//        self.collectionView.scrollEnabled = NO;
//        return [super hitTest:point withEvent:event];
//    }
//    self.collectionView.scrollEnabled = YES;
//    return [super hitTest:point withEvent:event];
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
