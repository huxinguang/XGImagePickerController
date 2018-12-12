//
//  XG_MediaBrowseView.h
//  MyApp
//
//  Created by huxinguang on 2018/10/30.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XG_PickerMacro.h"
#import "XG_AssetModel.h"
#import "XG_AssetCell.h"

@interface XG_MediaBrowseView : UIView

@property (nonatomic, readonly) NSArray<XG_AssetModel *> *items;
@property (nonatomic, readonly) NSInteger currentPage;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithItems:(NSArray<XG_AssetModel *> *)items;

- (void)presentCellImageAtIndexPath:(NSIndexPath *)indexpath
                 FromCollectionView:(UICollectionView *)collectV
                        toContainer:(UIView *)toContainer
                           animated:(BOOL)animated
                         completion:(void (^)(void))completion;

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion;

@end
