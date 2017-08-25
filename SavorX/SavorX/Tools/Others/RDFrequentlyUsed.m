//
//  RDFrequentlyUsed.m
//  SavorX
//
//  Created by 王海朋 on 2017/7/22.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDFrequentlyUsed.h"

@implementation RDFrequentlyUsed

+ (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title font:(UIFont *)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = title;
    label.font = font;
    label.numberOfLines = 0;
    [label sizeToFit];
    CGFloat height = label.frame.size.height;
    return height;
}

@end
