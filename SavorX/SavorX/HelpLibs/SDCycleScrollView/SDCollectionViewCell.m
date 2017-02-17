//
//  SDCollectionViewCell.m
//  SDCycleScrollView
//
//  Created by aier on 15-3-22.
//  Copyright (c) 2015年 GSD. All rights reserved.
//


/*
 
 *********************************************************************************
 *
 * 🌟🌟🌟 新建SDCycleScrollView交流QQ群：185534916 🌟🌟🌟
 *
 * 在您使用此自动轮播库的过程中如果出现bug请及时以以下任意一种方式联系我们，我们会及时修复bug并
 * 帮您解决问题。
 * 新浪微博:GSD_iOS
 * Email : gsdios@126.com
 * GitHub: https://github.com/gsdios
 *
 * 另（我的自动布局库SDAutoLayout）：
 *  一行代码搞定自动布局！支持Cell和Tableview高度自适应，Label和ScrollView内容自适应，致力于
 *  做最简单易用的AutoLayout库。
 * 视频教程：http://www.letv.com/ptv/vplay/24038772.html
 * 用法示例：https://github.com/gsdios/SDAutoLayout/blob/master/README.md
 * GitHub：https://github.com/gsdios/SDAutoLayout
 *********************************************************************************
 
 */


#import "SDCollectionViewCell.h"
#import "UIView+SDExtension.h"

@interface SDCollectionViewCell ()

@property (nonatomic, strong) UIView * hotelView;
@property (nonatomic, strong) UILabel * hotelNameLabel;

@end

@implementation SDCollectionViewCell
{
    __weak UILabel *_titleLabel;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupImageView];
        [self setupTitleLabel];
        
        [self setCustomView];
    }
    
    return self;
}

- (void)setCustomView
{
    self.hotelView = [[UIView alloc] initWithFrame:CGRectZero];
    self.hotelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6f];
    self.hotelView.layer.cornerRadius = 15;
    self.hotelView.layer.masksToBounds = YES;
    [self.imageView addSubview:self.hotelView];
    [self.hotelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.imageView);
        make.bottom.mas_equalTo(-30);
        make.size.mas_equalTo(CGSizeMake(180, 30));
    }];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [imageView setImage:[UIImage imageNamed:@"hotel_icon"]];
    [self.hotelView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.centerY.equalTo(self.hotelView);
        make.size.mas_equalTo(CGSizeMake(13, 13));
    }];
    
    self.hotelNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.hotelNameLabel.textColor = [UIColor whiteColor];
    self.hotelNameLabel.font = [UIFont systemFontOfSize:15];
    self.hotelNameLabel.textAlignment = NSTextAlignmentCenter;
    self.hotelNameLabel.text = @"酒楼名称";
    [self.hotelView addSubview:self.hotelNameLabel];
    [self.hotelNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.hotelView);
        make.left.mas_equalTo(12+13+8);
        make.right.mas_equalTo(-12);
    }];
    
    self.hotelView.hidden = YES;
}

- (void)showHotelName:(NSString *)name
{
    self.hotelNameLabel.text = name;
    self.hotelView.hidden = NO;
}

- (void)hiddenHotelName
{
    self.hotelView.hidden = YES;
}

- (void)setTitleLabelBackgroundColor:(UIColor *)titleLabelBackgroundColor
{
    _titleLabelBackgroundColor = titleLabelBackgroundColor;
    _titleLabel.backgroundColor = titleLabelBackgroundColor;
}

- (void)setTitleLabelTextColor:(UIColor *)titleLabelTextColor
{
    _titleLabelTextColor = titleLabelTextColor;
    _titleLabel.textColor = titleLabelTextColor;
}

- (void)setTitleLabelTextFont:(UIFont *)titleLabelTextFont
{
    _titleLabelTextFont = titleLabelTextFont;
    _titleLabel.font = titleLabelTextFont;
}

- (void)setupImageView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    [self.contentView addSubview:imageView];
}

- (void)setupTitleLabel
{
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    _titleLabel.hidden = YES;
    [self.contentView addSubview:titleLabel];
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    _titleLabel.text = [NSString stringWithFormat:@"   %@", title];
    if (_titleLabel.hidden) {
        _titleLabel.hidden = NO;
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.onlyDisplayText) {
        _titleLabel.frame = self.bounds;
    } else {
        _imageView.frame = self.bounds;
        CGFloat titleLabelW = self.sd_width;
        CGFloat titleLabelH = _titleLabelHeight;
        CGFloat titleLabelX = 0;
        CGFloat titleLabelY = self.sd_height - titleLabelH;
        _titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    }
}

@end
