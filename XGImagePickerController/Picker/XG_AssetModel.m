//
//  XG_AssetModel.m
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "XG_AssetModel.h"

@implementation XG_AssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset videoPickable:(BOOL)videoPickable{
    XG_AssetModel *model = [[XG_AssetModel alloc] init];
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
/*
 如果自定义的类需要实现浅拷贝，则在实现copyWithZone:方法时返回自身，
 而需要深拷贝时，在copyWithZone:方法中创建一个新的实例对象返回即
 */
- (id)copyWithZone:(NSZone *)zone {
    XG_AssetModel *item = [self.class new];
    return item;
}


@end


