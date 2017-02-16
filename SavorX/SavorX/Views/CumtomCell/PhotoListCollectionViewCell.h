//
//  PhotoListCollectionViewCell.h
//  SavorX
//
//  Created by 郭春城 on 16/10/20.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoListCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView * bgImageView; //背景图
@property (nonatomic, strong) UIImageView * selectImageView; //选择图

- (void)setSelectedStatus:(BOOL)isSelected; //设置选中状态
- (void)changeSelectedTo:(BOOL)selected; //改变选中状态

@end
