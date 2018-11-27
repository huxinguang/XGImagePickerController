//
//  XG_BarButton.h
//  MyApp
//
//  Created by huxinguang on 2018/9/11.
//  Copyright © 2018年 huxinguang. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,XG_BarButtonType) {
    XG_BarButtonTypeBack,
    XG_BarButtonTypeImage,
    XG_BarButtonTypeText
};

@interface XG_BarButtonConfiguration : NSObject

@property (nonatomic, copy)NSString *normalImageName;
@property (nonatomic, copy)NSString *selectedImageName;
@property (nonatomic, copy)NSString *highlightedImageName;
@property (nonatomic, copy)NSString *titleString;
@property (nonatomic, strong)UIFont *titleFont;
@property (nonatomic, strong)UIColor *normalColor;
@property (nonatomic, strong)UIColor *selectedColor;
@property (nonatomic, strong)UIColor *disabledColor;
@property (nonatomic, strong)UIColor *highlightedColor;
@property (nonatomic, assign)XG_BarButtonType type;

@end


@interface XG_BarButton : UIButton

@property (nonatomic, strong)XG_BarButtonConfiguration *configuration;

- (instancetype)initWithConfiguration:(XG_BarButtonConfiguration *)config;

@end
