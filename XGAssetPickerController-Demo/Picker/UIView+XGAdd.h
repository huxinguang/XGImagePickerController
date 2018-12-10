//
//  UIView+XGAdd.h
//  XGAssetPickerController
//
//  Created by huxinguang on 2018/11/8.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ScaleAnimationToBigger,
    ScaleAnimationToSmaller,
} ScaleAnimationType;

@interface UIView (XGAdd)

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize  size;

+ (void)showScaleAnimationWithLayer:(CALayer *)layer type:(ScaleAnimationType)type;

@end
