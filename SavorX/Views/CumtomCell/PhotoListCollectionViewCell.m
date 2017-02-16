//
//  PhotoListCollectionViewCell.m
//  SavorX
//
//  Created by 郭春城 on 16/10/20.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "PhotoListCollectionViewCell.h"

@interface PhotoListCollectionViewCell ()

@property (nonatomic, strong) UIView * blackView;

@end

@implementation PhotoListCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self customMyself];
    }
    return self;
}

- (void)customMyself
{
    self.bgImageView = [[UIImageView alloc] init];
    self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bgImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.bgImageView];
    
    self.blackView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.blackView];
    
    self.selectImageView = [[UIImageView alloc] init];
    [self.selectImageView setImage:[UIImage imageNamed:@"ImageSelectedSmallOff"]];
    [self.contentView addSubview:self.selectImageView];
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.blackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(31, 31));
        make.bottom.mas_equalTo(-2);
        make.right.mas_equalTo(-2);
    }];
    
    self.layer.cornerRadius = 3.f;
    self.layer.masksToBounds = YES;
}

- (void)setSelectedStatus:(BOOL)isSelected
{
    [self.selectImageView setHidden:!isSelected];
}

- (void)changeSelectedTo:(BOOL)selected
{
    if (selected) {
        [self.selectImageView setImage:[UIImage imageNamed:@"ImageSelectedSmallOn"]];
    }else{
        [self.selectImageView setImage:[UIImage imageNamed:@"ImageSelectedSmallOff"]];
    }
}

@end
