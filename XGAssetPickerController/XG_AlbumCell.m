//
//  XG_AlbumCell.m
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "XG_AlbumCell.h"
#import "XG_AssetPickerManager.h"
#import "XG_PickerMacro.h"

@implementation XG_AlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(XG_AlbumModel *)model{
    _model = model;
    self.albumNameLabel.text = [NSString stringWithFormat:@"%@(%d)",model.name,(int)model.result.count];
    if (model.result.count > 0) {
        [[XG_AssetPickerManager manager] getPostImageWithAlbumModel:model completion:^(UIImage *postImage) {
            self.imgView.image = postImage;
        }];
    }else{
        self.imgView.image = ImageWithFile(@"picker_album_placeholder");
    }
    
    if (model.isSelected) {
        self.contentView.backgroundColor = [UIColor colorWithRed:240.0/255 green:252.0/255 blue:255.0/255 alpha:1.0];
    }else{
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
}

-(void)prepareForReuse{
    self.imgView.image = nil;
    [super prepareForReuse];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
