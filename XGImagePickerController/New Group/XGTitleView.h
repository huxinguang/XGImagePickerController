//
//  XGTitleView.h
//  MyApp
//
//  Created by huxinguang on 2018/9/11.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,XGTitleViewStyle) {
    XGTitleViewStyleNormal,
    XGTitleViewStyleSegement
};

@protocol XGTitleViewDelegate<NSObject>
- (void)onTitleClick;
@end

@interface XGTitleView : UIView
@property (nonatomic, weak) id<XGTitleViewDelegate> delegate;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, copy) NSString *titleString;


- (instancetype)initWithFrame:(CGRect)frame style:(XGTitleViewStyle)style;

@end
