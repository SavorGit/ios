//
//  ScreenCollectionViewCell.m
//  SavorX
//
//  Created by 郭春城 on 16/10/27.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "ScreenCollectionViewCell.h"

@interface ScreenCollectionViewCell ()

@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel *  contentLabel;

@end

@implementation ScreenCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self customScreenCell];
    }
    return self;
}

- (void)customScreenCell
{
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.imageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.imageView];
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:19];
    self.titleLabel.textColor = UIColorFromRGB(0x495664);
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.titleLabel];

    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.font = [UIFont systemFontOfSize:14];
    self.contentLabel.textColor = UIColorFromRGB(0x7a828b);
    self.contentLabel.numberOfLines = 2;
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.contentLabel];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(kMainBoundsWidth - 56);
        make.height.mas_equalTo(90);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
//        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
//        make.left.mas_equalTo(110);
//        make.width.mas_equalTo(self.contentView.width -138);
    //        make.height.equalTo(self.imageView.mas_width).multipliedBy(10);
        make.left.equalTo(self.contentView.mas_left).offset(110);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(self.contentView.mas_centerY).offset(-5);
        
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(17);
//        make.bottom.mas_equalTo(self.titleLabel.mas_bottom).offset(10);
//        make.left.mas_equalTo(110);
//        make.width.mas_equalTo(self.contentView.width - 148);
        make.left.equalTo(self.titleLabel.mas_left);
        make.right.equalTo(self.titleLabel.mas_right);
        make.height.mas_equalTo(40);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(2);

        
        }];
}

- (void)setImageNamed:(NSString *)imageName andTitle:(NSString *)title andContent:(NSString *)content
{
    [self.imageView setImage:[UIImage imageNamed:imageName]];
    self.titleLabel.text = title;
    self.contentLabel.text= content;
}

@end
