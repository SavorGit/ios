//
//  voideoPlayFooterView.m
//  SavorX
//
//  Created by lijiawei on 17/2/8.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "voideoPlayFooterView.h"

@interface voideoPlayFooterView ()


@property (weak, nonatomic) IBOutlet UIImageView *yaokongBgImageView;
@property (weak, nonatomic) IBOutlet UIButton *volAddBtn;
@property (weak, nonatomic) IBOutlet UIButton *quitBtn;

@property (weak, nonatomic) IBOutlet UIButton *volSubBtn;
@end

@implementation voideoPlayFooterView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)voideoPlayFooterViewisEnable:(BOOL)isEnable{
    
    if(!isEnable){
        _muteBtn.enabled = YES;
        _volAddBtn.enabled = YES;
        _quitBtn.enabled = YES;
        _volSubBtn.enabled = YES;
        _videoPlayButton.enabled = YES;
    }else{
        _muteBtn.enabled = NO;
        _volAddBtn.enabled = NO;
        _quitBtn.enabled = NO;
        _volSubBtn.enabled = NO;
        _videoPlayButton.enabled = NO;
    }
}

- (IBAction)videoPlayAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    if(_delegate && [_delegate respondsToSelector:@selector(voideoPlayFooterView:didVideoPlayButton:)])
    {
        [_delegate voideoPlayFooterView:self didVideoPlayButton:button];
    }
}

- (IBAction)volAction:(id)sender {
    
    if(_delegate && [_delegate respondsToSelector:@selector(voidelPlayVolumeAction:)])
    {
        [_delegate voidelPlayVolumeAction:3];
    }
}


- (IBAction)volumeplusAction:(id)sender {
    
    if(_delegate && [_delegate respondsToSelector:@selector(voidelPlayVolumeAction:)])
    {
        [_delegate voidelPlayVolumeAction:4];
    }
}

- (IBAction)quitAction:(id)sender {
    
    if(_delegate && [_delegate respondsToSelector:@selector(stopVoideoPlay)]){
        [_delegate stopVoideoPlay];
        
    }
    
}


- (IBAction)muteAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if(button.selected){
        if(_delegate && [_delegate respondsToSelector:@selector(voidelPlayVolumeAction:)])
        {
            [_delegate voidelPlayVolumeAction:1];
        }
    }else{
        if(_delegate && [_delegate respondsToSelector:@selector(voidelPlayVolumeAction:)])
        {
            [_delegate voidelPlayVolumeAction:2];
        }
    }
}

@end
