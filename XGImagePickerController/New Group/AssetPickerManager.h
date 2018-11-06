//
//  AssetPickerManager.h
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger,AuthorizationStatus) {
    AuthorizationStatusNotDetermined = 0,
    AuthorizationStatusRestricted,
    AuthorizationStatusDenied,
    AuthorizationStatusAuthorized
};

@class AlbumModel,AssetModel;
@interface AssetPickerManager : NSObject

@property(nonatomic, strong) PHFetchResult<PHAssetCollection *> *smartAlbums;   //系统自带相册
@property(nonatomic, strong) PHFetchResult<PHCollection *> *userCollections;    //其他app相册或用户创建的相册

+ (instancetype)manager;

- (void)handleAuthorizationWithCompletion:(void (^)(AuthorizationStatus aStatus))completion;

// 获取相册数组
- (void)getAllAlbums:(BOOL)allowPickingVideo completion:(void (^)(NSArray<AlbumModel *> *models))completion;

// 获取Asset数组
- (void)getAssetsFromFetchResult:(id)result allowPickingVideo:(BOOL)allowPickingVideo completion:(void (^)(NSArray<AssetModel *> *models))completion;

// 获取照片
- (void)getPostImageWithAlbumModel:(AlbumModel *)model completion:(void (^)(UIImage *postImage))completion;
- (void)getPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
- (void)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info))completion;

// 获取视频
- (void)getVideoWithAsset:(PHAsset *)asset completion:(void (^)(AVPlayerItem * playerItem, NSDictionary * info))completion;

// 获取一组照片的大小
- (void)getPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *totalBytes))completion;

@end

