//
//  DemandViewController.h
//  SavorX
//
//  Created by 郭春城 on 16/8/10.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "BaseViewController.h"
#import "HSVodModel.h"

/**
 *	小热点点播界面，绑定机顶盒的情况下，点击当期视频会进入此界面
 */
@interface DemandViewController : BaseViewController

@property (nonatomic, strong) HSVodModel * model;

- (void)shouldRelease;

- (void)quitScreenAciton;
@end
