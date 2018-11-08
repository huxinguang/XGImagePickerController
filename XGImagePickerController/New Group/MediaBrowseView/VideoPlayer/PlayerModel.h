//
//  PlayerModel.h
//  MyApp
//
//  Created by huxinguang on 2018/10/19.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayerModel : NSObject
// 视频的URL，本地路径or网络路径http
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) AVPlayerItem *playerItem;
// 跳到seekTime处播放
@property (nonatomic, assign) double seekTime;
@property (nonatomic, strong) NSIndexPath *indexPath;
// 视频尺寸
@property (nonatomic, assign) CGSize presentationSize;
// 是否是适合竖屏播放的资源，w：h<1的资源，一般是手机竖屏（人像模式）拍摄的视频资源
@property (nonatomic, assign) BOOL verticalVideo;

@end
