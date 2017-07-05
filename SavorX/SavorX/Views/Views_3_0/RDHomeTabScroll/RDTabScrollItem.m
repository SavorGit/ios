//
//  RDTabScrollItem.m
//  小热点切换
//
//  Created by 郭春城 on 2017/6/29.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDTabScrollItem.h"
#import "RDTabScrollViewPage.h"

@interface RDTabScrollItem ()

@property (nonatomic, copy) NSString * name;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UIView * bottomView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIImageView * detailLogo;
@property (nonatomic, strong) UILabel * detailFrom;
@property (nonatomic, strong) UILabel * detailDate;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) RDTabScrollViewPage * page;

@end

@implementation RDTabScrollItem

- (instancetype)initWithFrame:(CGRect)frame info:(NSString *)name index:(NSInteger)index
{
    if (self = [super initWithFrame:frame]) {
        
        self.index = index;
        [self.imageView setImage:[UIImage imageNamed:name]];
        [self createSubViews];
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self.imageView setImage:[UIImage new]];
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = .3f;
    self.layer.shadowRadius = 6.f;
    self.layer.shadowOffset = CGSizeMake(2.f, 2.f);
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.imageView.frame.origin.y + self.imageView.frame.size.height, self.frame.size.width, self.frame.size.height - self.imageView.frame.origin.y - self.imageView.frame.size.height)];
    [self addSubview:self.bottomView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width - 30, 16)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.text = @"浙数文化与创新工场签署战略合作框架协议";
    [self.bottomView addSubview:self.titleLabel];
    
//    self.detailLogo = [[UIImageView alloc] initWithFrame:CGRectMake(20, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 10, 25, 25)];
//    self.detailLogo.backgroundColor = [UIColor redColor];
//    [self.bottomView addSubview:self.detailLogo];
    
    self.detailFrom = [[UILabel alloc] initWithFrame:CGRectMake(self.detailLogo.frame.origin.x + self.detailLogo.frame.size.width + 10, self.detailLogo.frame.origin.y, 80, 25)];
    self.detailFrom.font = [UIFont systemFontOfSize:12];
    self.detailFrom.textColor = [UIColor grayColor];
    self.detailFrom.text = @"来自网易新闻";
    [self.bottomView addSubview:self.detailFrom];
    [self.detailFrom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.bottom.mas_equalTo(-10);
        make.height.mas_equalTo(25);
        make.width.lessThanOrEqualTo(@(100));
    }];
    
    self.detailDate = [[UILabel alloc] initWithFrame:CGRectMake(self.detailFrom.frame.origin.x + self.detailFrom.frame.size.width + 20, self.detailFrom.frame.origin.y, 60, 25)];
    self.detailDate.font = [UIFont systemFontOfSize:10];
    self.detailDate.textColor = [UIColor grayColor];
    self.detailDate.text = @"2017.07.03";
    [self.bottomView addSubview:self.detailDate];
    [self.detailDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.detailFrom.mas_right).offset(10);
        make.bottom.mas_equalTo(-10);
        make.height.mas_equalTo(25);
        make.width.lessThanOrEqualTo(@(100));
    }];
    
    [self.page resetIndex:self.index];
}

- (void)configWithInfo:(NSString *)name index:(NSInteger)index
{
    self.index = index;
    [self.page resetIndex:self.index];
    if (![self.name isEqualToString:name]) {
        [self.imageView setImage:[UIImage imageNamed:name]];
    }
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width * .587);
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (RDTabScrollViewPage *)page
{
    if (!_page) {
        _page = [[RDTabScrollViewPage alloc] initWithFrame:CGRectMake(0, 0, 60, 23) totalNumber:10 type:RDTabScrollViewPageType_UPBIG index:1];
        [self.bottomView addSubview:_page];
        [_page mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-5);
            make.right.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(50, 23));
        }];
    }
    return _page;
}

@end