//
//  XG_AlbumModel.h
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XG_AssetModel.h"

@class PHFetchResult;
@interface XG_AlbumModel : NSObject
@property (nonatomic, strong) NSString *name;                             //相册名称
@property (nonatomic, assign) BOOL isSelected;                            //选中状态 默认NO
@property (nonatomic, strong) PHFetchResult *result;
@property (nonatomic, strong) NSMutableArray<XG_AssetModel *> *assetArray;   //资源数组
@end
