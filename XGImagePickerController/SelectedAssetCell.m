//
//  SelectedAssetCell.m
//  XGImagePickerController
//
//  Created by huxinguang on 2018/11/14.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "SelectedAssetCell.h"
#import "AssetModel.h"
#import "AssetPickerManager.h"
#import "UIView+XGAdd.h"

@implementation SelectedAssetCell

-(void)awakeFromNib{
    [super awakeFromNib];
    
}

- (void)setModel:(AssetModel *)model{
    _model = model;
    if (_model.isPlaceholder) {
        self.imgView.image = [UIImage imageNamed:@"Add"];
        self.playBtn.hidden = YES;
    }else{
        [[AssetPickerManager manager] getPhotoWithAsset:_model.asset photoWidth:self.frame.size.width completion:^(UIImage *photo, NSDictionary *info) {
            self.imgView.image = photo;
        }];
        if (_model.asset.mediaType == PHAssetMediaTypeVideo) {
            self.playBtn.hidden = NO;
        }else{
            self.playBtn.hidden = YES;
        }
    }
    
}



@end
