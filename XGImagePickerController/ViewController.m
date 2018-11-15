//
//  ViewController.m
//  XGImagePickerController
//
//  Created by huxinguang on 2018/11/6.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "ViewController.h"
#import "AssetPickerController.h"
#import "SelectedAssetCell.h"
#import "AssetModel.h"

#define kCollectionViewSectionInsetLeftRight 4
#define kItemCountAtEachRow 3
#define kMinimumInteritemSpacing 4
#define kMinimumLineSpacing 4

@interface ViewController ()<AssetPickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<AssetModel *> *assets;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    CGFloat itemWH = (self.view.frame.size.width - (kItemCountAtEachRow-1)*kMinimumInteritemSpacing - 2*kCollectionViewSectionInsetLeftRight)/kItemCountAtEachRow;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    layout.minimumInteritemSpacing = kMinimumInteritemSpacing;
    layout.minimumLineSpacing = kMinimumLineSpacing;
    layout.sectionInset = UIEdgeInsetsMake(0, kCollectionViewSectionInsetLeftRight, 0, kCollectionViewSectionInsetLeftRight);
    self.collectionView.collectionViewLayout = layout;
}

-(NSArray<AssetModel *> *)assets{
    if (!_assets) {
        AssetModel *model = [[AssetModel alloc]init];
        model.isPlaceholder = YES;
        _assets = @[model];
    }
    return _assets;
}


- (void)openAlbum{
    __weak typeof (self) weakSelf = self;
    [[AssetPickerManager manager] handleAuthorizationWithCompletion:^(AuthorizationStatus aStatus) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (aStatus == AuthorizationStatusAuthorized) {
                [strongSelf showAssetPickerController];
            }else{
                [strongSelf showAlert];
            }
        });
    }];
}

- (void)showAssetPickerController{
    AssetPickerOptions *options = [[AssetPickerOptions alloc]init];
    options.maxAssetsCount = 9;
    options.videoPickable = YES;
    NSMutableArray<AssetModel *> *array = [self.assets mutableCopy];
    [array removeLastObject];//去除占位model
    options.pickedAssetModels = array;
    AssetPickerController *photoPickerVc = [[AssetPickerController alloc] initWithOptions:options delegate:self];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:photoPickerVc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showAlert{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"未开启相册权限，是否去设置中开启？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
    [alert show];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.assets.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SelectedAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SelectedAssetCell class]) forIndexPath:indexPath];
    cell.model = self.assets[indexPath.item];
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    AssetModel *model = self.assets[indexPath.item];
    if (model.isPlaceholder) {
        [self openAlbum];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
