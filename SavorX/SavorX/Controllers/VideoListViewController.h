//
//  VideoListViewController.h
//  SavorX
//
//  Created by 郭春城 on 16/8/11.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "BaseViewController.h"

/**
 *	小热点视频列表页，用于展示系统相册中的视频列表
 */
@interface VideoListViewController : BaseViewController

@property (nonatomic, strong) PHFetchResult *results;

@end
