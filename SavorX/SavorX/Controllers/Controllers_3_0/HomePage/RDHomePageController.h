//
//  RDHomePageController.h
//  小热点3.0
//
//  Created by 郭春城 on 2017/6/16.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "WMPageController.h"
#import "CreateWealthModel.h"

@interface RDHomePageController : WMPageController

//收到节目的推送，跳转至相关的页面
- (void)didReceiveRemoteNotification:(CreateWealthModel *)model;

@end
