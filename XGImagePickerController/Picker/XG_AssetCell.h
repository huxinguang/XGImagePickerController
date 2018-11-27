//
//  XG_AssetCell.h
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XG_AssetModel;
@interface XG_AssetCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *selectPhotoButton;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (nonatomic, strong) XG_AssetModel *model;
@property (nonatomic, copy) void (^didSelectPhotoBlock)(BOOL);

@end


