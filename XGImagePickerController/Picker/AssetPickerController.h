//
//  AssetPickerController.h
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "PickerMacro.h"
#import "AssetPickerManager.h"

#define kItemMargin 4                                                                                                 //item间距
#define kItemsAtEachLine 3                                                                                            //每行显示多少个
#define kBottomConfirmBtnHeight 49                                                                                    //底部确定按钮的高度
#define kBottomConfirmBtnTitleFontSize 16                                                                             //确定按钮字体大小
#define kAlbumTableViewMarginTopBottom 10                                                                             //相册列表上下边距
#define kAlbumTableViewRowHeight 60                                                                                   //相册列表cell高度
#define kContainerViewMaxHeight (kAppScreenHeight-kAppStatusBarAndNavigationBarHeight-kBottomConfirmBtnHeight)/2      //相册列表最大高度
#define kTitleViewTextImageDistance 0                                                                                 //标题和三角形距离
#define kTitleViewArrowSize CGSizeMake(7.0, 7.0)                                                                      //三角图片大小
#define kTitleViewTitleFont [UIFont boldSystemFontOfSize:16]                                                          //标题字体大小

@class AlbumModel;
@class NavTitleView;
@class AssetModel;
@protocol AssetPickerControllerDelegate;
@class AssetPickerOptions;

@interface AssetPickerController : RootViewController

@property (nonatomic, weak) id<AssetPickerControllerDelegate> delegate;
@property (nonatomic, strong) AssetPickerOptions *pickerOptions;


-(instancetype)initWithOptions:(AssetPickerOptions *)options delegate:(id<AssetPickerControllerDelegate>)delegate;

@end

@protocol AssetPickerControllerDelegate <NSObject>
@optional

- (void)assetPickerController:(AssetPickerController *)picker didFinishPickingAssets:(NSArray<AssetModel *> *)assets;
- (void)assetPickerControllerDidCancel:(AssetPickerController *)picker;

@end

@interface AssetPickerOptions: NSObject
@property (nonatomic, assign) NSInteger maxAssetsCount;                              //最大可选数量
@property (nonatomic, assign) BOOL videoPickable;                                    //是否可选视频
@property (nonatomic, strong) NSMutableArray<AssetModel *> *pickedAssetModels;       //已选asset
@end


@interface NavTitleView : UIView
@property (nonatomic, strong) UIButton *titleBtn;
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, assign) CGFloat titleBtnWidth;
@property (nonatomic, assign) CGSize intrinsicContentSize;
@property (nonatomic, strong) NSLayoutConstraint *titleBtn_width;

@end

