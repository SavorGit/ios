//
//  VoideoPlayStatusCell.m
//  SavorX
//
//  Created by lijiawei on 17/2/8.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "VoideoPlayStatusCell.h"

@implementation VoideoPlayStatusCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)connectAction:(id)sender {
    
    if(_delegate && [_delegate respondsToSelector:@selector(voideoPlayStatusCellConnectAction)])
    {
        [_delegate voideoPlayStatusCellConnectAction];
    }
}

@end
