//
//  AssetCell.m
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "AssetCell.h"
#import "AssetModel.h"
#import "UIView+ScaleAnimation.h"
#import "AssetPickerManager.h"

@interface AssetCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *timeLength;

@end

@implementation AssetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.timeLength.font = [UIFont boldSystemFontOfSize:11];
}

- (void)setModel:(AssetModel *)model {
    _model = model;
    if (model.isPlaceholder) {
        _selectImageView.hidden = YES;
        _selectPhotoButton.hidden = YES;
        _bottomView.hidden = YES;
        
        self.imageView.image = [UIImage imageNamed:@"picker_camera"];
        self.numberLabel.hidden = YES;
    }else{
        switch (model.asset.mediaType) {
            case PHAssetMediaTypeUnknown:
                _selectImageView.hidden = YES;
                _selectPhotoButton.hidden = YES;
                _bottomView.hidden = YES;
                break;
            case PHAssetMediaTypeImage:
                _selectImageView.hidden = NO;
                _selectPhotoButton.hidden = NO;
                _bottomView.hidden = YES;
                break;
            case PHAssetMediaTypeVideo:
                if (model.selectable) {
                    _selectImageView.hidden = NO;
                    _selectPhotoButton.hidden = NO;
                }else{
                    _selectImageView.hidden = YES;
                    _selectPhotoButton.hidden = YES;
                }
                _bottomView.hidden = NO;
                _timeLength.text = [self getNewTimeFromDurationSecond:(NSInteger)model.asset.duration];
                break;
            case PHAssetMediaTypeAudio:
                _selectImageView.hidden = YES;
                _selectPhotoButton.hidden = YES;
                _bottomView.hidden = YES;
                break;
            default:
                break;
        }
        
        [[AssetPickerManager manager] getPhotoWithAsset:model.asset photoWidth:self.frame.size.width completion:^(UIImage *photo, NSDictionary *info) {
            self.imageView.image = photo;
        }];
        self.selectPhotoButton.selected = model.picked;
        self.selectImageView.image = model.picked ? [UIImage imageNamed:@"picker_selected"] : [UIImage imageNamed:@"picker_unselected"];
        self.numberLabel.text = self.selectPhotoButton.selected ? [NSString stringWithFormat:@"%d",self.model.number] : @"";
        self.numberLabel.hidden = NO;
    }
}

- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}

- (IBAction)selectPhotoButtonClick:(UIButton *)sender {
    if (self.didSelectPhotoBlock) {
        self.didSelectPhotoBlock(sender.isSelected);
    }
    self.selectImageView.image = sender.isSelected ? [UIImage imageNamed:@"picker_selected"] : [UIImage imageNamed:@"picker_unselected"];
    if (sender.isSelected) {
        [UIView showScaleAnimationWithLayer:_selectImageView.layer type:ScaleAnimationToBigger];
    }
}

@end

