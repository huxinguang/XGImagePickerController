//
//  XG_RootViewController.h
//  MyApp
//
//  Created by huxinguang on 2018/9/11.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XG_BarButton.h"
#import "XG_TitleView.h"

@interface XG_RootViewController : UIViewController
@property (nonatomic, strong) XG_TitleView *titleView;
@property (nonatomic, strong) XG_BarButton *leftBarButton;
@property (nonatomic, strong) XG_BarButton *rightBarButton;
@property (nonatomic, assign) BOOL isStatusBarHidden;


- (void)configTitleView;

- (void)configLeftBarButtonItem;

- (void)configRightBarButtonItem;

- (void)onLeftBarButtonClick;

@end





