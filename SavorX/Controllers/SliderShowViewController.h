//
//  SliderShowViewController.h
//  SavorX
//
//  Created by 郭春城 on 16/11/9.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "BaseViewController.h"

/**
 *	热点儿幻灯片预览界面，主要用于预览幻灯片
 */
@interface SliderShowViewController : BaseViewController

@property (nonatomic, strong) NSDictionary * infoDict;
@property (nonatomic, strong) NSArray * PHAssetSource;
@property (nonatomic, strong) NSIndexPath * indexPath; //记录当前下标

@end
