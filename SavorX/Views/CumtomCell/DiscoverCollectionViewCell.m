//
//  DiscoverCollectionViewCell.m
//  SavorX
//
//  Created by 郭春城 on 16/8/14.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "DiscoverCollectionViewCell.h"

@implementation DiscoverCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self creteDiscoverCell];
    }
    return self;
}

- (void)creteDiscoverCell
{
    self.bgImageView = [[UIImageView alloc] init];
    self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bgImageView.clipsToBounds = YES;
    self.bgImageView.backgroundColor = VCBackgroundColor;

    [self.contentView addSubview:self.bgImageView];

    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.45f];
    self.titleLabel.shadowOffset = CGSizeMake(.5f, 1);
    [self.contentView addSubview:self.titleLabel];
    
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.font = [UIFont systemFontOfSize:18];
    self.detailLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    self.detailLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.detailLabel];
    
    UIView * blackView = [[UIView alloc] init];
    blackView.backgroundColor = [UIColor blackColor];
    blackView.alpha = 0.3f;
    [self.bgImageView addSubview:blackView];
    
    [blackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(self.contentView.frame.size.width , self.contentView.frame.size.height));
        make.center.mas_equalTo(0);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-10);
        make.left.equalTo(self.contentView).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
        make.height.mas_equalTo(18);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(23);
        make.left.equalTo(self.contentView).offset(5);
        make.right.equalTo(self.contentView).offset(-5);
        make.height.mas_equalTo(15);
    }];
    
//    [grayBGView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(0.f);
//    }];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
}

@end
