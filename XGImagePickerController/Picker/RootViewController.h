//
//  RootViewController.h
//  MyApp
//
//  Created by huxinguang on 2018/9/11.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XGBarButton.h"
#import "XGTitleView.h"

@interface RootViewController : UIViewController
@property (nonatomic, strong) XGTitleView *titleView;
@property (nonatomic, strong) XGBarButton *leftBarButton;
@property (nonatomic, strong) XGBarButton *rightBarButton;
@property (nonatomic, assign) BOOL isStatusBarHidden;


- (void)configTitleView;

- (void)configLeftBarButtonItem;

- (void)configRightBarButtonItem;

- (void)onLeftBarButtonClick;

@end





