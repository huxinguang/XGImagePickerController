//
//  RootViewController.m
//  MyApp
//
//  Created by huxinguang on 2018/9/11.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "RootViewController.h"
#import "PickerMacro.h"

@interface RootViewController ()

@end

@implementation RootViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
//    [self configNavigationBarBackgroundColor:[UIColor whiteColor]];//加上这行可设置导航栏背景色，去掉黑线
    [self configWindowLevel];
    [self configTitleView];
    [self configLeftBarButtonItem];
    [self configRightBarButtonItem];
}

- (void)configWindowLevel{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        window.windowLevel = UIWindowLevelNormal;
    });
}

- (void)configTitleView{
    self.titleView = [[XGTitleView alloc]initWithFrame:CGRectMake(0, 0, kAppNavigationTitleViewMaxWidth, kAppNavigationTitleViewHeight) style:XGTitleViewStyleNormal];
    self.navigationItem.titleView = self.titleView;
}

//若不要返回按钮或者想替换成其他按钮可重写此方法
- (void)configLeftBarButtonItem{
    XGBarButtonConfiguration *config = [[XGBarButtonConfiguration alloc]init];
    config.type = XGBarButtonTypeBack;
    config.normalImageName = @"navi_back";
    self.leftBarButton = [[XGBarButton alloc]initWithConfiguration:config];
    [self.leftBarButton addTarget:self action:@selector(onLeftBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.leftBarButton];
}

- (void)configRightBarButtonItem{
    
}

- (void)onLeftBarButtonClick{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 修改导航栏背景色

-(void)configNavigationBarBackgroundColor:(UIColor *)barBackgroundColor{
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        NSArray *subviews =self.navigationController.navigationBar.subviews;
        for (id viewObj in subviews) {
            if ([UIDevice currentDevice].systemVersion.doubleValue >= 10) {
                //iOS10,改变了状态栏的类为_UIBarBackground
                NSString *classStr = [NSString stringWithUTF8String:object_getClassName(viewObj)];
                if ([classStr isEqualToString:@"_UIBarBackground"]) {
                    UIImageView *imageView=(UIImageView *)viewObj;
                    imageView.hidden=YES;
                }
            }else{
                //iOS9以及iOS9之前使用的是_UINavigationBarBackground
                NSString *classStr = [NSString stringWithUTF8String:object_getClassName(viewObj)];
                if ([classStr isEqualToString:@"_UINavigationBarBackground"]) {
                    UIImageView *imageView=(UIImageView *)viewObj;
                    imageView.hidden=YES;
                }
            }
        }
        UIImageView *imageView = [self.navigationController.navigationBar viewWithTag:kNavigationBarImageViewTag];
        if (!imageView) {
            imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, -20, self.view.frame.size.width, 64)];
            imageView.tag = kNavigationBarImageViewTag;
            [imageView setBackgroundColor:barBackgroundColor];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController.navigationBar insertSubview:imageView atIndex:0];
            });
        }else{
            [imageView setBackgroundColor:barBackgroundColor];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController.navigationBar sendSubviewToBack:imageView];
            });
        }
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end

