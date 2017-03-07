//
//  RDAlertAction.m
//  Test - 2.1
//
//  Created by 郭春城 on 17/3/7.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDAlertAction.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation RDAlertAction

- (instancetype)initWithTitle:(NSString *)title handler:(void (^)())handler bold:(BOOL)bold
{
    if (self = [super init]) {
        
        [self setTitle:title forState:UIControlStateNormal];
        self.block = handler;
        [self setTitleColor:UIColorFromRGB(0xc9b067) forState:UIControlStateNormal];
        if (bold) {
            self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        }else{
            self.titleLabel.font = [UIFont systemFontOfSize:16];
        }
        
    }
    return self;
}

@end
