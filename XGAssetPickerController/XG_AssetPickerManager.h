//
//  XG_AssetPickerManager.h
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger,XG_AuthorizationStatus) {
    XG_AuthorizationStatusNotDetermined = 0,
    XG_AuthorizationStatusRestricted,
    XG_AuthorizationStatusDenied,
    XG_AuthorizationStatusAuthorized
};

@class XG_AlbumModel,XG_AssetModel;
@interface XG_AssetPickerManager : NSObject

@property(nonatomic, strong) PHFetchResult<PHAssetCollection *> *smartAlbums;   //系统自带相册
@property(nonatomic, strong) PHFetchResult<PHCollection *> *userCollections;    //其他app相册或用户创建的相册

+ (instancetype)manager;
- (void)handleAuthorizationWithCompletion:(void (^)(XG_AuthorizationStatus aStatus))completion;
// 获取相册数组(get albums)
- (void)getAllAlbums:(BOOL)allowPickingVideo completion:(void (^)(NSArray<XG_AlbumModel *> *models))completion;
// 获取Asset (get assets)
- (void)getPostImageWithAlbumModel:(XG_AlbumModel *)model completion:(void (^)(UIImage *postImage))completion;
- (void)getPhotoWithAsset:(PHAsset *)asset completion:(void (^)(id photo,NSDictionary *info))completion;
- (void)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
// 获取视频(get video)
- (void)getVideoWithAsset:(PHAsset *)asset completion:(void (^)(AVPlayerItem * playerItem, NSDictionary * info))completion;

@end

