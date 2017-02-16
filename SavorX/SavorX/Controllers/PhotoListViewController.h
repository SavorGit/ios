//
//  PhotoListViewController.h
//  SavorX
//
//  Created by 郭春城 on 16/8/9.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "BaseViewController.h"
#import <Photos/Photos.h>

/**
 *	热点儿相片展示页，展示某一相册下所有的图片
 */
@interface PhotoListViewController : BaseViewController

@property (nonatomic, strong) PHFetchResult * PHAssetSource; //该相册所有的照片信息

@end
