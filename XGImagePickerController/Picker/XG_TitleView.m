//
//  XG_TitleView.m
//  MyApp
//
//  Created by huxinguang on 2018/9/11.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "XG_TitleView.h"
#import "XG_PickerMacro.h"

@interface XG_TitleView()
@property (nonatomic, assign) XG_TitleViewStyle style;
@end

@implementation XG_TitleView


- (instancetype)initWithFrame:(CGRect)frame style:(XG_TitleViewStyle)style{
    if (self = [super initWithFrame:frame]) {
        self.style = style;
        [self buildSubViews];
    }
    return self;
}

- (void)buildSubViews{
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:kAppNavigationTitleViewTitleFontSize];
    self.titleLabel.frame = CGRectMake(0, 0, kAppNavigationTitleViewMaxWidth, kAppNavigationTitleViewHeight);
    self.titleLabel.textColor = kAppNavigationTopPageTitleColor;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLabel];
}

- (void)setTitleString:(NSString *)titleString{
    if (titleString && titleString.length > 0) {
        self.titleLabel.text = titleString;
        [self.titleLabel sizeToFit];
        CGRect titleLabelFrame = self.titleLabel.frame;
        titleLabelFrame.origin.y = (kAppNavigationTitleViewHeight - titleLabelFrame.size.height)/2;
        if (titleLabelFrame.size.width > kAppNavigationTitleViewMaxWidth) {
            titleLabelFrame.size.width = kAppNavigationTitleViewMaxWidth;
        }
        self.titleLabel.frame = titleLabelFrame;
        // 设置titleview居中显示
        CGFloat screenWidth = 0;
        if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait){
            screenWidth = kAppScreenWidth;
        }else{
            screenWidth = kAppScreenHeight;
        }
        self.frame = CGRectMake((screenWidth - titleLabelFrame.size.width)/2, self.frame.origin.y, titleLabelFrame.size.width, kAppNavigationTitleViewHeight);
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
