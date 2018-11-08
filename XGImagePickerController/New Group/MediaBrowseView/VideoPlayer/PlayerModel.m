//
//  PlayerModel.m
//  MyApp
//
//  Created by huxinguang on 2018/10/19.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "PlayerModel.h"

@implementation PlayerModel
-(void)setPresentationSize:(CGSize)presentationSize{
    _presentationSize = presentationSize;
    if (presentationSize.width/presentationSize.height<1) {
        self.verticalVideo = YES;
    }
}
@end
