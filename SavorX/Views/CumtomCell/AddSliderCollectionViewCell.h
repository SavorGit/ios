//
//  AddSliderCollectionViewCell.h
//  SavorX
//
//  Created by 郭春城 on 16/11/9.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "PhotoListCollectionViewCell.h"

@class AddSliderCollectionViewCell;
@protocol ADDSliderCollectionViewCellDelegate <NSObject>

- (void)SliderCollectionViewCellDidClicked:(AddSliderCollectionViewCell *)cell;

@end

@interface AddSliderCollectionViewCell : PhotoListCollectionViewCell

@property (nonatomic, assign) id<ADDSliderCollectionViewCellDelegate> delegate;

@end
