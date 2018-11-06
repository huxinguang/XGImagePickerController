//
//  Macro.h
//  MyApp
//
//  Created by huxinguang on 2018/9/10.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

//=========================================通用宏==============================================
#define kAppScreenWidth ([UIScreen mainScreen].bounds.size.width)//屏幕宽度
#define kAppScreenHeight ([UIScreen mainScreen].bounds.size.height)//屏幕高度
#define kAppStatusBarHeight (IS_iPhoneX ? 44.f : 20.f) // status bar height.
#define kAppNavigationBarHeight 44.f //Navigation bar height.
#define kAppTabbarHeight        (IS_iPhoneX ? (49.f+34.f) : 49.f)// Tabbar height.
#define kAppTabbarSafeBottomMargin        (IS_iPhoneX ? 34.f : 0.f)// Tabbar safe bottom margin.
#define kAppStatusBarAndNavigationBarHeight  (IS_iPhoneX ? 88.f : 64.f)// Status bar & navigation bar height.
#define IS_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)//判断是否iPhone X

//=========================================导航栏(自定义部分)=====================================
#define kAppNavigationTitleViewTitleFontSize 16
#define kAppNavigationTitleViewMaxWidth 220.f
#define kAppNavigationTitleViewHeight 44.f

//===========================================颜色===============================================
#define kAppThemeColor [UIColor colorWithRed:36/255.0 green:160/255.0 blue:252/255.0 alpha:1] //app主题色  0x24A0FC
#define kAppNavigationTopPageTitleColor [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] //一级页面导航栏标题颜色

#endif /* Macro_h */
