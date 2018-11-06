//
//  AssetModel.m
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "AssetModel.h"

@implementation AssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset videoPickable:(BOOL)videoPickable{
    AssetModel *model = [[AssetModel alloc] init];
    model.asset = asset;
    model.picked = NO;
    model.number = 0;
    switch (asset.mediaType) {
        case PHAssetMediaTypeUnknown:
            model.selectable = NO;
            break;
        case PHAssetMediaTypeImage:
            model.selectable = YES;
            break;
        case PHAssetMediaTypeVideo:
            if (videoPickable) {
                model.selectable = YES;
            }else{
                model.selectable = NO;
            }
            break;
        case PHAssetMediaTypeAudio:
            model.selectable = NO;
            break;
        default:
            break;
    }

    return model;
}


@end


