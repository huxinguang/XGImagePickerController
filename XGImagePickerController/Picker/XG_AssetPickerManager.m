//
//  XG_AssetPickerManager.m
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "XG_AssetPickerManager.h"
#import "XG_AssetModel.h"
#import "XG_AlbumModel.h"

@interface XG_AssetPickerManager ()

@end

@implementation XG_AssetPickerManager

+ (instancetype)manager {
    static XG_AssetPickerManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

-(PHFetchResult<PHAssetCollection *> *)smartAlbums{
    if (!_smartAlbums) _smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    return _smartAlbums;
}

- (PHFetchResult<PHCollection *> *)userCollections{
    if (!_userCollections) _userCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    return _userCollections;
}

- (void)handleAuthorizationWithCompletion:(void (^)(XG_AuthorizationStatus aStatus))completion{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusNotDetermined:{
                    completion(XG_AuthorizationStatusNotDetermined);
                }
                    break;
                case PHAuthorizationStatusRestricted:{
                    completion(XG_AuthorizationStatusRestricted);
                }
                    break;
                case PHAuthorizationStatusDenied:{
                    completion(XG_AuthorizationStatusDenied);
                }
                    break;
                case PHAuthorizationStatusAuthorized:{
                    completion(XG_AuthorizationStatusAuthorized);
                }
                    break;
                default:
                    break;
            }
        });
        
    }];
}

#pragma mark - Get Albums

- (void)getAllAlbums:(BOOL)videoPickable completion:(void (^)(NSArray<XG_AlbumModel *> *))completion{
    NSMutableArray *albumArr = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    if (!videoPickable) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    // smartAlbums
    [self.smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //不同相册的同一张照片，所对应的PHAsset实例的localIdentifier是一样的，但对应的PHAsset实例并不是同一个
        PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsInAssetCollection:obj options:option];
        if (fetchResult.count > 0) {
            //把“相机胶卷”放在第一位
            //Project中如果添加了Chinese（simplified）,那么在真机（语言为中文）运行时，localizedTitle就是中文
            if ([obj.localizedTitle isEqualToString:@"相机胶卷"] || [obj.localizedTitle isEqualToString:@"Camera Roll"]) {
                [albumArr insertObject:[self modelWithResult:fetchResult name:obj.localizedTitle videoPickable:videoPickable] atIndex:0];
            }else{
                [albumArr addObject:[self modelWithResult:fetchResult name:obj.localizedTitle videoPickable:videoPickable]];
            }
        }
    }];
    // userCollections
    [self.userCollections enumerateObjectsUsingBlock:^(PHCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollection *collection = (PHAssetCollection *)obj;
        PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        if (fetchResult.count > 0) {
            [albumArr addObject:[self modelWithResult:fetchResult name:obj.localizedTitle videoPickable:videoPickable]];
        }
    }];
    
    if (completion) completion(albumArr);
}

#pragma mark - Get Photo

- (void)getPhotoWithAsset:(PHAsset *)asset completion:(void (^)(id, NSDictionary *))completion {
    if (@available(iOS 11.0, *)) {
        if (asset.playbackStyle == PHAssetPlaybackStyleImageAnimated) {
            [self getDataWithAsset:asset completion:completion];
            return;
        }
    }
    [self getPhotoWithAsset:asset photoWidth:[UIScreen mainScreen].bounds.size.width completion:completion];
}

- (void)getDataWithAsset:(PHAsset *)asset completion:(void (^)(id, NSDictionary *))completion{
    //动图(Aninated)
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if (completion) completion(imageData,info);
    }];
    
}

- (void)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *, NSDictionary *))completion {
    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGFloat multiple = [UIScreen mainScreen].scale;
    CGFloat pixelWidth = photoWidth * multiple;
    CGFloat pixelHeight = pixelWidth / aspectRatio;

    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(pixelWidth, pixelHeight) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined) {
            if (completion) completion(result,info);
        }
    }];
}

- (void)getPostImageWithAlbumModel:(XG_AlbumModel *)model completion:(void (^)(UIImage *))completion {
    [self getPhotoWithAsset:[model.result firstObject] photoWidth:60 completion:^(UIImage *photo, NSDictionary *info) {
        if (completion) completion(photo);
    }];
}

#pragma mark - Get Video

- (void)getVideoWithAsset:(PHAsset *)asset completion:(void (^)(AVPlayerItem * _Nullable, NSDictionary * _Nullable))completion {
    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        if (completion) completion(playerItem,info);
    }];
}

#pragma mark - Private Method

- (XG_AlbumModel *)modelWithResult:(PHFetchResult *)result name:(NSString *)name videoPickable:(BOOL)videoPickable{
    XG_AlbumModel *model = [[XG_AlbumModel alloc] init];
    model.result = result;
    model.name = name;
    
    NSMutableArray *assetArr = [NSMutableArray array];
    for (PHAsset *asset in result) {
        [assetArr addObject:[XG_AssetModel modelWithAsset:asset videoPickable:videoPickable]];
    }
    model.assetArray = assetArr;
    return model;
}


@end

