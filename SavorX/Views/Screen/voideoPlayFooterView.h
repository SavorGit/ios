//
//  voideoPlayFooterView.h
//  SavorX
//
//  Created by lijiawei on 17/2/8.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseView.h"


@protocol voideoPlayFooterViewDelegate;

@interface voideoPlayFooterView : BaseView

@property (weak, nonatomic) IBOutlet UIButton *videoPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;

@property(nonatomic,weak)id<voideoPlayFooterViewDelegate>delegate;

-(void)voideoPlayFooterViewisEnable:(BOOL)isEnable;

@end


@protocol voideoPlayFooterViewDelegate <NSObject>

-(void)voideoPlayFooterView:(voideoPlayFooterView *)vView didVideoPlayButton:(UIButton *)button;

-(void)stopVoideoPlay;

-(void)voidelPlayVolumeAction:(NSInteger)action;

@end
