//
//  GCCScreenImage.h
//  GCCToolCreate
//
//  Created by 郭春城 on 16/4/8.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

//截屏工具类
@interface GCCScreenImage : NSObject

/**
 *  window全屏截图
 *
 *  @return 得到截图
 */
+ (UIImage *)screenFullWindow;

/**
 *  对某个UIView或者其子类进行截图
 *
 *  @param view 所需截图的对象
 *
 *  @return 得到截图
 */
+ (UIImage *)screenView:(UIView *)view;

/**
 *  保存图片到相册
 *
 *  @param image 需要保存的图片
 */
+ (void)saveImage:(UIImage *)image;

@end
