//
//  VideoCollectionViewCell.h
//  SavorX
//
//  Created by 郭春城 on 16/8/11.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCollectionViewCell : UICollectionViewCell

- (void)getInfoFromAsset:(PHAsset *)asset; //通过PHAsset获取信息
- (void)getInfoFromAVAsset:(AVAsset *)asset; //通过AVAsset获取信息

@end
