//
//  ViewController.m
//  XGImagePickerController
//
//  Created by huxinguang on 2018/11/6.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "ViewController.h"
#import "AssetPickerController.h"

@interface ViewController ()<AssetPickerControllerDelegate>

@property (nonatomic, strong) NSArray<AssetModel *> *assets;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)btnAction:(id)sender {
    @weakify(self)
    [[AssetPickerManager manager] handleAuthorizationWithCompletion:^(AuthorizationStatus aStatus) {
        @strongify(self)
        if (!self) return;
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (aStatus == AuthorizationStatusAuthorized) {
                [self showAssetPickerController];
            }else{
                [self showAlert];
            }
        });
    }];
}

- (void)showAssetPickerController{
    AssetPickerOptions *options = [[AssetPickerOptions alloc]init];
    options.maxAssetsCount = 9;
    options.videoPickable = YES;
    options.pickedAssetModels = [self.assets mutableCopy];
    AssetPickerController *photoPickerVc = [[AssetPickerController alloc] initWithOptions:options delegate:self];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:photoPickerVc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showAlert{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"未开启相册权限，是否去设置中开启？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
    [alert show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
