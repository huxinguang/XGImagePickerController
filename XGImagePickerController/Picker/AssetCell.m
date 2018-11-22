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
                _timeLength.text = [self getNewTimeFromSecond:(NSInteger)model.asset.duration];
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

- (NSString *)getNewTimeFromSecond:(int)seconds {
    NSString *newTime;
    if (seconds < 10) {
        newTime = [NSString stringWithFormat:@"00:0%d",seconds];
    } else if (seconds < 60) {
        newTime = [NSString stringWithFormat:@"00:%d",seconds];
    } else {
        int min = seconds / 60;
        int sec = seconds - (min * 60);
        if (sec < 10) {
            if (min < 10) {
                newTime = [NSString stringWithFormat:@"0%d:0%d",min,sec];
            }else{
                newTime = [NSString stringWithFormat:@"%d:0%d",min,sec];
            }
        } else {
            if (min < 10) {
                newTime = [NSString stringWithFormat:@"0%d:%d",min,sec];
            }else{
                newTime = [NSString stringWithFormat:@"%d:%d",min,sec];
            }
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

