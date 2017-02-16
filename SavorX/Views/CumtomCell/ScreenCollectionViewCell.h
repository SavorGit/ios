//
//  ScreenCollectionViewCell.h
//  SavorX
//
//  Created by 郭春城 on 16/10/27.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScreenCollectionViewCell : UICollectionViewCell

//设置图片与标题
- (void)setImageNamed:(NSString *)imageName andTitle:(NSString *)title andContent:(NSString *)content;

@end
