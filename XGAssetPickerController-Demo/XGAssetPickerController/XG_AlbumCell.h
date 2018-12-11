//
//  XG_AlbumCell.h
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XG_AlbumModel.h"

@interface XG_AlbumCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;

@property (nonatomic, strong) XG_AlbumModel *model;
@end
