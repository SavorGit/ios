//
//  WebViewController.h
//  SavorX
//
//  Created by 郭春城 on 16/8/8.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "BaseViewController.h"
#import "HSVodModel.h"
#import "GCCPlayerView.h"

/**
 *	热点儿H5加载页面，在未绑定机顶盒时阅读当期文章，或者在发现页阅读历史文章用于展示文章的页面
 */
@interface WebViewController : BaseViewController

@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) HSVodModel * model;
@property (nonatomic, strong) GCCPlayerView * playView; //播放器

@end
