//
//  ImageAtlasCollectViewCell.m
//  SavorX
//
//  Created by 王海朋 on 2017/8/7.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "ImageAtlasCollectViewCell.h"

@interface ImageAtlasCollectViewCell()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ImageAtlasCollectViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self creatSubViews];
    }
    return self;
}

- (void)creatSubViews{
    
    _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    _bgImageView.layer.masksToBounds = YES;
    _bgImageView.backgroundColor = [UIColor cyanColor];
    [self addSubview:_bgImageView];
    [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kMainBoundsWidth/2 - 10);
        make.height.mas_equalTo(70);
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];
    
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.font = kPingFangMedium(16);
    _titleLabel.textColor = UIColorFromRGB(0x434343);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"这是标题";
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth/2 - 10, 20));
        make.top.mas_equalTo(_bgImageView.mas_bottom).offset(8);
        make.left.mas_equalTo(0);
    }];
}

@end
