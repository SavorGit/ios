//
//  SXVideoPlayViewController.h
//  SavorX
//
//  Created by lijiawei on 17/2/8.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseViewController.h"
#import "HSVodModel.h"

@interface SXVideoPlayViewController : BaseViewController

@property (nonatomic, assign) NSInteger totalTime; //视频总时长
@property (nonatomic, copy) NSString * videoUrl; //视频对应地址
@property (nonatomic, strong) HSVodModel * model;
@property (nonatomic, assign) int type;

- (void)shouldRelease;
-(void)stopVoideoPlay:(BOOL)fromHomeType;

@end
