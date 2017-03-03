//
//  PhotoCollectionViewCell.h
//  SavorX
//
//  Created by 郭春城 on 17/3/1.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) BOOL isChoosed;
@property (nonatomic, assign) PHAssetMediaType mediaType;

- (void)reloadViewWithAsset:(PHAsset *)asset andIsChoose:(BOOL)isChoose;

- (void)photoDidBeSelected:(BOOL)select;

@end
