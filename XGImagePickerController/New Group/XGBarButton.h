//
//  XGBarButton.h
//  MyApp
//
//  Created by huxinguang on 2018/9/11.
//  Copyright © 2018年 huxinguang. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,XGBarButtonType) {
    XGBarButtonTypeBack,
    XGBarButtonTypeImage,
    XGBarButtonTypeText
};

@interface XGBarButtonConfiguration : NSObject

@property (nonatomic, copy)NSString *normalImageName;
@property (nonatomic, copy)NSString *selectedImageName;
@property (nonatomic, copy)NSString *highlightedImageName;
@property (nonatomic, copy)NSString *titleString;
@property (nonatomic, strong)UIFont *titleFont;
@property (nonatomic, strong)UIColor *normalColor;
@property (nonatomic, strong)UIColor *selectedColor;
@property (nonatomic, strong)UIColor *disabledColor;
@property (nonatomic, strong)UIColor *highlightedColor;
@property (nonatomic, assign)XGBarButtonType type;

@end


@interface XGBarButton : UIButton

@property (nonatomic, strong)XGBarButtonConfiguration *configuration;

- (instancetype)initWithConfiguration:(XGBarButtonConfiguration *)config;

@end
