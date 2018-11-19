//
//  SelectedAssetCell.h
//  XGImagePickerController
//
//  Created by huxinguang on 2018/11/14.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AssetModel;

@interface SelectedAssetCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (nonatomic, strong) AssetModel *model;
@end
