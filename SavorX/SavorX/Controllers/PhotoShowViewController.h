//
//  PhotoShowViewController.h
//  SavorX
//
//  Created by 郭春城 on 16/8/9.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "BaseViewController.h"
#import <Photos/Photos.h>

/**
 *	热点儿相片预览页，预览当前相册的相片
 */
@interface PhotoShowViewController : BaseViewController

@property (nonatomic, strong) PHFetchResult * result;
@property (nonatomic, strong) NSIndexPath * indexPath; //记录当前下标

@end
