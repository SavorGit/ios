//
//  PhotoManyCollectionViewCell.h
//  SavorX
//
//  Created by 郭春城 on 17/2/13.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoManyCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) BOOL hasEdit;
@property (nonatomic, assign) NSInteger Orientation;

@property (nonatomic, copy) NSString * firstText;
@property (nonatomic, copy) NSString * secondText;
@property (nonatomic, copy) NSString * thirdText;

- (void)setCellRealImage:(UIImage *)image;
- (void)setCellEditImage:(UIImage *)image;

- (UIImage *)getCellRealImage;
- (UIImage *)getCellEditImage;

@end
