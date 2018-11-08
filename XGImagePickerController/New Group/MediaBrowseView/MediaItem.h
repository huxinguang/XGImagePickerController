//
//  MediaItem.h
//  MyApp
//
//  Created by huxinguang on 2018/10/30.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,MediaItemType) {
    MediaItemTypeImage,
    MediaItemTypeVideo
};

@interface MediaItem : NSObject
@property (nonatomic, strong) UIView *thumbView;  // 缩略图, 用于动画坐标计算
@property (nonatomic, assign) CGSize largeMediaSize;
@property (nonatomic, strong) NSURL *largeMediaURL;
@property (nonatomic, assign) MediaItemType mediaType;
@property (nonatomic, readonly) UIImage *thumbImage;
@property (nonatomic, readonly) BOOL thumbClippedToTop;
@end
