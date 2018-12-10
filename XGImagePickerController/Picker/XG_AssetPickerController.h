//
//  XG_AssetPickerController.h
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XG_RootViewController.h"
#import "XG_PickerMacro.h"
#import "XG_AssetPickerManager.h"
#import "XG_AssetModel.h"

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

@class XG_AlbumModel;
@class NavTitleView;
@class XG_AssetModel;
@protocol XG_AssetPickerControllerDelegate;
@class XG_AssetPickerOptions;

@interface XG_AssetPickerController : XG_RootViewController

@property (nonatomic, weak) id<XG_AssetPickerControllerDelegate> delegate;
@property (nonatomic, strong) XG_AssetPickerOptions *pickerOptions;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithOptions:(XG_AssetPickerOptions *)options delegate:(id<XG_AssetPickerControllerDelegate>)delegate;

@end

@protocol XG_AssetPickerControllerDelegate <NSObject>
@required
- (void)assetPickerController:(XG_AssetPickerController *)picker didFinishPickingAssets:(NSArray<XG_AssetModel *> *)assets;
@optional
- (void)assetPickerControllerDidCancel:(XG_AssetPickerController *)picker;

@end

@interface XG_AssetPickerOptions: NSObject
@property (nonatomic, assign) NSInteger maxAssetsCount;                              //最大可选数量
@property (nonatomic, assign) BOOL videoPickable;                                    //是否可选视频
@property (nonatomic, strong) NSMutableArray<XG_AssetModel *> *pickedAssetModels;       //已选asset
@end


@interface NavTitleView : UIView
@property (nonatomic, strong) UIButton *titleBtn;
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, assign) CGFloat titleBtnWidth;
@property (nonatomic, assign) CGSize intrinsicContentSize;
@property (nonatomic, strong) NSLayoutConstraint *titleBtn_width;

@end

