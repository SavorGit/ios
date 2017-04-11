//
//  PhotoSliderViewController.h
//  SavorX
//
//  Created by 郭春城 on 16/9/5.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "BaseViewController.h"
#import <Photos/Photos.h>

/**
 *	小热点相册中的幻灯片播放页
 */
@interface PhotoSliderViewController : BaseViewController

@property (nonatomic, assign) NSInteger timeLong;
@property (nonatomic, strong) NSArray<PHAsset *> * PHAssetSource;//需要展示的图片集合

- (void)shouldRelease;
- (void)stopScreenImage:(BOOL)fromHomeType;

@end
