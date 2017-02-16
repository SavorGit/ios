//
//  AddSliderCollectionViewCell.m
//  SavorX
//
//  Created by 郭春城 on 16/11/9.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "AddSliderCollectionViewCell.h"

@interface AddSliderCollectionViewCell ()

@property (nonatomic, strong) UIButton * rightImageview;

@end

@implementation AddSliderCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self customSelf];
    }
    return self;
}

- (void)customSelf
{
    self.rightImageview = [[UIButton alloc] init];
    [self.rightImageview setImage:[UIImage imageNamed:@"fullScreen"] forState:UIControlStateNormal];
    [self.rightImageview addTarget:self action:@selector(fullScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.rightImageview];
    
    [self.rightImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
}

- (void)fullScreen
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(SliderCollectionViewCellDidClicked:)]) {
        [self.delegate SliderCollectionViewCellDidClicked:self];
    }
}

@end
