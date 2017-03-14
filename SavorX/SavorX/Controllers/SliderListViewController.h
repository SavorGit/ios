//
//  SliderListViewController.h
//  SavorX
//
//  Created by 郭春城 on 16/10/31.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "BaseViewController.h"

@protocol SliderListDelegate <NSObject>

- (void)sliderListDidBeChange;

@end

/**
 *	小热点幻灯片详情，主要用于展示某一幻灯片下所有的幻灯片，具有添加，删除，预览，投屏功能
 */
@interface SliderListViewController : BaseViewController

@property (nonatomic, assign) id<SliderListDelegate> delegate;
@property (nonatomic, strong) NSDictionary * infoDict;
@property (nonatomic, strong) NSArray * systemResults; //系统相册集合

@end
