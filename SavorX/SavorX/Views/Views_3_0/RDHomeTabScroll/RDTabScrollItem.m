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
@property (nonatomic, strong) UILabel * timeLabel;

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
    self.backgroundColor = UIColorFromRGB(0xf6f2ed);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = .3f;
    self.layer.shadowRadius = 6.f;
    self.layer.shadowOffset = CGSizeMake(2.f, 2.f);
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    CGSize imageViewSize = self.imageView.frame.size;
    
    UIView * leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 50)];
    leftView.center = CGPointMake(imageViewSize.width / 2 - 60, imageViewSize.height / 2);
    leftView.tag = 101;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonDidBeClicked:)];
    tap.numberOfTapsRequired = YES;
    [leftView addGestureRecognizer:tap];
    [self addSubview:leftView];
    UIButton * leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 80, 24);
    [leftButton setBackgroundImage:[UIImage imageNamed:@"sjbf"] forState:UIControlStateNormal];
    leftButton.center = CGPointMake(leftView.frame.size.width / 2, leftView.frame.size.height / 2);
    leftButton.userInteractionEnabled = NO;
    [leftView addSubview:leftButton];
    
    UIView * rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 50)];
    rightView.center = CGPointMake(imageViewSize.width / 2 + 60, imageViewSize.height / 2);
    rightView.tag = 102;
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonDidBeClicked:)];
    tap2.numberOfTapsRequired = YES;
    [rightView addGestureRecognizer:tap2];
    [self addSubview:rightView];
    UIButton * rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 80, 24);
    [rightButton setBackgroundImage:[UIImage imageNamed:@"dsbf"] forState:UIControlStateNormal];
    rightButton.center = CGPointMake(rightView.frame.size.width / 2, rightView.frame.size.height / 2);
    rightButton.userInteractionEnabled = NO;
    [rightView addSubview:rightButton];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageViewSize.width - 55, imageViewSize.height - 5 - 18, 50, 18)];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = [UIFont systemFontOfSize:11];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.55f];
    self.timeLabel.text = @" 0\'00\"";
    [self addSubview:self.timeLabel];
    self.timeLabel.layer.cornerRadius = 9;
    self.timeLabel.layer.masksToBounds = YES;
    self.timeLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.timeLabel.layer.borderWidth = .5f;
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, imageViewSize.height, self.frame.size.width, self.frame.size.height - imageViewSize.height)];
    [self addSubview:self.bottomView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, self.frame.size.width - 30, 16)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.textColor = UIColorFromRGB(0x434343);
    self.titleLabel.text = @"浙数文化与创新工场签署战略合作框架协议";
    [self.bottomView addSubview:self.titleLabel];
    
//    self.detailLogo = [[UIImageView alloc] initWithFrame:CGRectMake(20, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 10, 25, 25)];
//    self.detailLogo.backgroundColor = [UIColor redColor];
//    [self.bottomView addSubview:self.detailLogo];
    
    self.detailFrom = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 25)];
    self.detailFrom.font = [UIFont systemFontOfSize:12];
    self.detailFrom.textColor = UIColorFromRGB(0x898886);
    self.detailFrom.text = @"来自网易新闻";
    [self.bottomView addSubview:self.detailFrom];
    [self.detailFrom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.bottom.mas_equalTo(-15);
        make.height.mas_equalTo(12);
        make.width.lessThanOrEqualTo(@(100));
    }];
    
    self.detailDate = [[UILabel alloc] initWithFrame:CGRectMake(self.detailFrom.frame.origin.x + self.detailFrom.frame.size.width + 20, self.detailFrom.frame.origin.y, 60, 25)];
    self.detailDate.font = [UIFont systemFontOfSize:10];
    self.detailDate.textColor = UIColorFromRGB(0xb2afab);
    self.detailDate.text = @"2017.07.03";
    [self.bottomView addSubview:self.detailDate];
    [self.detailDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.detailFrom.mas_right).offset(10);
        make.bottom.mas_equalTo(-15);
        make.height.mas_equalTo(12);
        make.width.lessThanOrEqualTo(@(100));
    }];
    
    [self.page resetIndex:self.index];
}

- (void)buttonDidBeClicked:(UITapGestureRecognizer *)tap
{
    if (tap.view.tag == 101) {
        
    }else{
        
    }
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
        CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width * .646);
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        _imageView.backgroundColor = [UIColor blackColor];
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
