//
//  SelectedAssetCell.m
//  XGImagePickerController
//
//  Created by huxinguang on 2018/11/14.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "SelectedAssetCell.h"
#import "AssetModel.h"

@implementation SelectedAssetCell

- (void)setModel:(AssetModel *)model{
    if (_model == model) {
        return;
    }
    _model = model;
    if (_model.isPlaceholder) {
        self.imgView.image = [UIImage imageNamed:@"Add"];
    }else{
        
    }
    
}

@end
