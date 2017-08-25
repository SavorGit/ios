//
//  DemandViewController.h
//  SavorX
//
//  Created by 郭春城 on 16/8/10.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "BaseViewController.h"
#import "CreateWealthModel.h"

/**
 *	小热点点播界面，绑定机顶盒的情况下，点击当期视频会进入此界面
 */
@interface DemandViewController : BaseViewController

- initWithModelSource:(NSMutableArray *)source categroy:(NSInteger)categroyID model:(CreateWealthModel *)model;

- (void)shouldRelease;

- (void)quitScreenAciton:(BOOL)fromHomeType;
@end
