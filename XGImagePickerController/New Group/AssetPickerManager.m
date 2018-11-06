//
//  AssetPickerManager.m
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "AssetPickerManager.h"
#import "AssetModel.h"
#import "AlbumModel.h"

@interface AssetPickerManager ()

@end

@implementation AssetPickerManager

+ (instancetype)manager {
    static AssetPickerManager *manager;
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

- (void)handleAuthorizationWithCompletion:(void (^)(AuthorizationStatus aStatus))completion{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusNotDetermined:{
                completion(AuthorizationStatusNotDetermined);
            }
                break;
            case PHAuthorizationStatusRestricted:{
                completion(AuthorizationStatusRestricted);
            }
                break;
            case PHAuthorizationStatusDenied:{
                completion(AuthorizationStatusDenied);
            }
                break;
            case PHAuthorizationStatusAuthorized:{
                completion(AuthorizationStatusAuthorized);
            }
                break;
            default:
                break;
        }
    }];
}

#pragma mark - Get Album

- (void)getAllAlbums:(BOOL)videoPickable completion:(void (^)(NSArray<AlbumModel *> *))completion{
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

#pragma mark - Get Asset

- (void)getAssetsFromFetchResult:(id)result allowPickingVideo:(BOOL)allowPickingVideo completion:(void (^)(NSArray<AssetModel *> *))completion {
    NSMutableArray *assetArr = [NSMutableArray array];
    for (PHAsset *asset in result) {
        [assetArr addObject:[AssetModel modelWithAsset:asset videoPickable:allowPickingVideo]];
    }
    if (completion) completion(assetArr);
}

- (void)getPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *totalBytes))completion {
    __block NSInteger dataLength = 0;
    for (NSInteger i = 0; i < photos.count; i++) {
        AssetModel *model = photos[i];
        [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            if (model.asset.mediaType != PHAssetMediaTypeVideo) dataLength += imageData.length;
            if (i >= photos.count - 1) {
                NSString *bytes = [self getBytesFromDataLength:dataLength];
                if (completion) completion(bytes);
            }
        }];
    }
}

- (NSString *)getBytesFromDataLength:(NSInteger)dataLength {
    NSString *bytes;
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%0.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%0.0fK",dataLength/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%zdB",dataLength];
    }
    return bytes;
}

#pragma mark - Get Photo

- (void)getPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *, NSDictionary *))completion {
    [self getPhotoWithAsset:asset photoWidth:[UIScreen mainScreen].bounds.size.width completion:completion];
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

- (void)getPostImageWithAlbumModel:(AlbumModel *)model completion:(void (^)(UIImage *))completion {
    [[AssetPickerManager manager] getPhotoWithAsset:[model.result firstObject] photoWidth:60 completion:^(UIImage *photo, NSDictionary *info) {
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

- (AlbumModel *)modelWithResult:(PHFetchResult *)result name:(NSString *)name videoPickable:(BOOL)videoPickable{
    AlbumModel *model = [[AlbumModel alloc] init];
    model.result = result;
    model.name = name;
    
    NSMutableArray *assetArr = [NSMutableArray array];
    for (PHAsset *asset in result) {
        [assetArr addObject:[AssetModel modelWithAsset:asset videoPickable:videoPickable]];
    }
    model.assetArray = assetArr;
    return model;
}


@end

