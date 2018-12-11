//
//  XG_BarButton.m
//  MyApp
//
//  Created by huxinguang on 2018/9/11.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "XG_BarButton.h"
#import "XG_PickerMacro.h"
@implementation XG_BarButtonConfiguration

@end

@implementation XG_BarButton

- (instancetype)initWithConfiguration:(XG_BarButtonConfiguration *)config{
    if (self = [super init]) {
        self.configuration = config;
    }
    return self;
}

- (void)setConfiguration:(XG_BarButtonConfiguration *)configuration{
    if (!configuration) {
        return;
    }
    switch (configuration.type) {
        case XG_BarButtonTypeBack:
            if (configuration.normalImageName) {
                [self setImage:ImageWithFile(configuration.normalImageName) forState:UIControlStateNormal];
            }
            break;
        case XG_BarButtonTypeImage:
            if (configuration.normalImageName) {
                [self setImage:ImageWithFile(configuration.normalImageName) forState:UIControlStateNormal];
            }
            if (configuration.selectedImageName) {
                [self setImage:ImageWithFile(configuration.normalImageName) forState:UIControlStateSelected];
            }
            if (configuration.highlightedImageName) {
                [self setImage:ImageWithFile(configuration.highlightedImageName) forState:UIControlStateHighlighted];
            }
            break;
        case XG_BarButtonTypeText:
            [self setTitle:configuration.titleString ? configuration.titleString: @""forState:UIControlStateNormal];
            self.titleLabel.font = configuration.titleFont;
            if (configuration.normalColor) {
                [self setTitleColor:configuration.normalColor forState:UIControlStateNormal];
            }
            if (configuration.selectedColor) {
                [self setTitleColor:configuration.selectedColor forState:UIControlStateSelected];
            }
            if (configuration.highlightedColor) {
                [self setTitleColor:configuration.highlightedColor forState:UIControlStateHighlighted];
            }
            if (configuration.disabledColor) {
                [self setTitleColor:configuration.disabledColor forState:UIControlStateDisabled];
            }
            break;
        default:
            break;
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
