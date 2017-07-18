//
//  LeftTableHeaderView.m
//  SavorX
//
//  Created by 郭春城 on 17/1/20.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "LeftTableHeaderView.h"

@interface LeftTableHeaderView ()

@end

@implementation LeftTableHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self customSelf];
    }
    return self;
}

- (void)customSelf
{
    UIView * BGView = [[UIView alloc] initWithFrame:CGRectZero];
    BGView.backgroundColor = [UIColor clearColor];
    [self addSubview:BGView];
    [BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(55, 80));
    }];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [imageView setImage:[UIImage imageNamed:@"cdh_logo"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.cornerRadius = 10;
    imageView.layer.masksToBounds = YES;
    [BGView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.height.mas_equalTo(55);
        make.right.mas_equalTo(0);
    }];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = kPingFangLight(14);
    label.textColor = UIColorFromRGB(0xece6de);
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"小热点";
    label.backgroundColor = [UIColor clearColor];
    [BGView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(10);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
}

@end
