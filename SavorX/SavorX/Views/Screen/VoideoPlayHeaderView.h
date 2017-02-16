//
//  VoideoPlayHeaderView.h
//  SavorX
//
//  Created by lijiawei on 17/2/8.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseView.h"

@protocol VoideoPlayHeaderViewDelegate;


@interface VoideoPlayHeaderView : BaseView

@property (weak, nonatomic) IBOutlet UILabel *mininumLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxinumLabel;
@property (weak, nonatomic) IBOutlet UISlider *palySlider;

@property(nonatomic,weak) id<VoideoPlayHeaderViewDelegate>delegate;


@end

@protocol VoideoPlayHeaderViewDelegate <NSObject>

//进度条值改变
-(void)VoideoPlaysliderValueChange;
//进度条开始交互
-(void)VoideoPlaysliderStartTouch;
//进度条交互结束
-(void)VoideoPlaysliderEndTouch;

-(void)navBackArrow;

@end
