//
//  XG_AssetCell.m
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "XG_AssetCell.h"
#import "XG_AssetModel.h"
#import "UIView+XGAdd.h"
#import "XG_AssetPickerManager.h"
#import "XG_PickerMacro.h"

@interface XG_AssetCell ()
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *timeLength;
@property (weak, nonatomic) IBOutlet UIImageView *videoIcon;

@end

@implementation XG_AssetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.timeLength.font = [UIFont boldSystemFontOfSize:11];
    self.videoIcon.image = ImageWithFile(@"picker_video");
}

- (void)setModel:(XG_AssetModel *)model {
    _model = model;
    if (model.isPlaceholder) {
        _selectImageView.hidden = YES;
        _selectPhotoButton.hidden = YES;
        _bottomView.hidden = YES;
        
        self.imageView.image = ImageWithFile(@"picker_camera");
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
                _timeLength.text = [self getNewTimeFromSecond:(int)model.asset.duration];
                break;
            case PHAssetMediaTypeAudio:
                _selectImageView.hidden = YES;
                _selectPhotoButton.hidden = YES;
                _bottomView.hidden = YES;
                break;
            default:
                break;
        }
        
        [[XG_AssetPickerManager manager] getPhotoWithAsset:model.asset photoWidth:self.frame.size.width completion:^(UIImage *photo, NSDictionary *info) {
            self.imageView.image = photo;
        }];
        self.selectPhotoButton.selected = model.picked;
        self.selectImageView.image = model.picked ? ImageWithFile(@"picker_selected") : ImageWithFile(@"picker_unselected");
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
    self.selectImageView.image = sender.isSelected ? ImageWithFile(@"picker_selected") : ImageWithFile(@"picker_unselected");
    if (sender.isSelected) {
        [UIView showScaleAnimationWithLayer:_selectImageView.layer type:ScaleAnimationToBigger];
    }
}

@end

