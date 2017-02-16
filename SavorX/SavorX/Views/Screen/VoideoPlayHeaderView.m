//
//  VoideoPlayHeaderView.m
//  SavorX
//
//  Created by lijiawei on 17/2/8.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "VoideoPlayHeaderView.h"

@interface VoideoPlayHeaderView ()




@end

@implementation VoideoPlayHeaderView



- (IBAction)backAction:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(navBackArrow)]){
        
        [_delegate navBackArrow];
    }
    
}

- (IBAction)sliderValueChange:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(VoideoPlaysliderValueChange)])
    {
        [_delegate VoideoPlaysliderValueChange];
    }

    
}
- (IBAction)sliderStartTouch:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(VoideoPlaysliderStartTouch)])
    {
        [_delegate VoideoPlaysliderStartTouch];
    }
}
- (IBAction)sliderEndTouch:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(VoideoPlaysliderEndTouch)])
    {
        [_delegate VoideoPlaysliderEndTouch];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
