//
//  XG_TitleView.h
//  MyApp
//
//  Created by huxinguang on 2018/9/11.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,XG_TitleViewStyle) {
    XG_TitleViewStyleNormal,
    XG_TitleViewStyleSegement
};

@protocol XG_TitleViewDelegate<NSObject>
- (void)onTitleClick;
@end

@interface XG_TitleView : UIView
@property (nonatomic, weak) id<XG_TitleViewDelegate> delegate;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, copy) NSString *titleString;


- (instancetype)initWithFrame:(CGRect)frame style:(XG_TitleViewStyle)style;

@end
