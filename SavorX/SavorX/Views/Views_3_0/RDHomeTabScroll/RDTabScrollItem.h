//
//  RDTabScrollItem.h
//  小热点切换
//
//  Created by 郭春城 on 2017/6/29.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDHotelItemModel.h"

@protocol RDTabScrollViewDelegate <NSObject>

- (void)RDTabScrollViewPhotoButtonDidClicked;
- (void)RDTabScrollViewTVButtonDidClicked;

@end

@interface RDTabScrollItem : UIView

- (instancetype)initWithFrame:(CGRect)frame info:(RDHotelItemModel *)model index:(NSInteger)index total:(NSInteger)total;

- (void)configWithInfo:(RDHotelItemModel *)model index:(NSInteger)index total:(NSInteger)total;

@end
