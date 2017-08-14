//
//  ImageAtlasCollectViewCell.m
//  SavorX
//
//  Created by 王海朋 on 2017/8/7.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "ImageAtlasCollectViewCell.h"
#import "UIImageView+WebCache.h"

@interface ImageAtlasCollectViewCell()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *countLabel;

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
    _bgImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_bgImageView];
    [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kMainBoundsWidth/2 - 5);
        make.height.mas_equalTo(120);
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];
    
    _countLabel = [[UILabel alloc]init];
    _countLabel.font = kPingFangLight(11);
    _countLabel.textColor = UIColorFromRGB(0xf6f2ed);
    _countLabel.backgroundColor = UIColorFromRGB(0x000000);
    _countLabel.alpha = 0.5;
    _countLabel.layer.cornerRadius = 2;
    _countLabel.layer.masksToBounds = YES;
    _countLabel.textAlignment = NSTextAlignmentCenter;
    [_bgImageView addSubview:_countLabel];
    [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(25, 14));
        make.bottom.mas_equalTo(_bgImageView.mas_bottom).offset(-10);
        make.right.mas_equalTo(_bgImageView.mas_right).offset(-10);
    }];
    
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.font = kPingFangRegular(15);
    _titleLabel.textColor = UIColorFromRGB(0x434343);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = @"这是标题";
    _titleLabel.numberOfLines = 2;
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kMainBoundsWidth/2 - 2.5 - 20);
        make.height.mas_equalTo(21);
        make.top.mas_equalTo(_bgImageView.mas_bottom).offset(10);
        make.left.mas_equalTo(10);
    }];
}

- (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title font:(UIFont *)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = title;
    label.font = font;
    label.numberOfLines = 0;
    [label sizeToFit];
    CGFloat height = label.frame.size.height;
    return height;
}

- (void)configModelData:(CreateWealthModel *)model andIsPortrait:(BOOL)isPortrait{

    if (isPortrait == NO) {
        
        [_bgImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(kMainBoundsWidth/3 - 7.5);
            make.height.mas_equalTo(90);
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }];
        
        [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(kMainBoundsWidth/3 - 2.5 - 20);
            make.height.mas_equalTo(21);
            make.top.mas_equalTo(_bgImageView.mas_bottom).offset(10);
            make.left.mas_equalTo(10);
        }];
    }
    
    CGFloat titleHeight = [self getHeightByWidth:kMainBoundsWidth/2 - 2.5 - 20 title:model.title font:kPingFangRegular(15)];
    if (titleHeight > 20) {
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(42);
        }];
    }
    self.titleLabel.text = model.title;
    
    self.countLabel.text = [NSString stringWithFormat:@"%@%@",model.colTuJi, RDLocalizedString(@"RDString_Image")];
    [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:model.imageURL] placeholderImage:[UIImage imageNamed:@"zanwu"]];
    
}

@end
