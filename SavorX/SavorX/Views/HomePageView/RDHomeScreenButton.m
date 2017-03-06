//
//  RDHomeScreenButton.m
//  Test - 2.1
//
//  Created by 郭春城 on 17/3/2.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDHomeScreenButton.h"

static CGFloat RDHomeScreenPopAnimationTime = .5f;
static CGFloat RDHomeScreenCloseAnimationTime = .3f;

@interface RDHomeScreenButton ()

@property (nonatomic, strong) UIView * backgroundView;

@property (nonatomic, strong) UIButton * repeatButton;
@property (nonatomic, strong) UIButton * photoButton;
@property (nonatomic, strong) UIButton * videoButton;
@property (nonatomic, strong) UIButton * sliderButton;
@property (nonatomic, strong) UIButton * niceVideoButton;
@property (nonatomic, strong) UIButton * documentButton;

@property (nonatomic, assign) BOOL isBoxSence; //记录当前时候是在酒店环境
@property (nonatomic, assign) BOOL isShowOptions; //记录当前是否在展示选项
@property (nonatomic, assign) BOOL isAnimation; //记录当前动画状态

@end

@implementation RDHomeScreenButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createViews];
    }
    return self;
}

- (void)createViews
{
    self.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height - self.frame.size.height / 2 - 30);
    
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.masksToBounds = YES;
    
    self.backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    
    self.photoButton = [self createButtonWithTag:100 image:[UIImage imageNamed:@"tupian"]];
    self.videoButton = [self createButtonWithTag:101 image:[UIImage imageNamed:@"shipin"]];
    self.sliderButton = [self createButtonWithTag:102 image:[UIImage imageNamed:@"huandengpian"]];
    self.documentButton = [self createButtonWithTag:103 image:[UIImage imageNamed:@"wenjian"]];
    self.niceVideoButton = [self createButtonWithTag:104 image:[UIImage imageNamed:@"dainbo"]];
    
    [self createRepeatButton];
    
    [self.backgroundView addSubview:self.photoButton];
    [self.backgroundView addSubview:self.videoButton];
    [self.backgroundView addSubview:self.sliderButton];
    [self.backgroundView addSubview:self.documentButton];
    [self.backgroundView addSubview:self.niceVideoButton];
    [self.backgroundView addSubview:self.repeatButton];
    
    [self showWithBox];
    
    [self addTarget:self action:@selector(popOptionsWithAnimation) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeOptionsWithAnimation)];
    tap.numberOfTapsRequired = 1;
    [self.backgroundView addGestureRecognizer:tap];
}

//发现了盒子环境
- (void)didFoundBoxSence
{
    if (!self.isBoxSence) {
        [self showWithBox];
        if (self.isAnimation) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(RDHomeScreenPopAnimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self animationAddNiceVideoButton];
            });
        }else{
            if (self.isShowOptions) {
                [self animationAddNiceVideoButton];
            }
        }
    }
}

//失去了盒子环境
- (void)didLoseBoxSence
{
    if (self.isBoxSence) {
        [self showWithNoBox];
        if (self.isAnimation) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(RDHomeScreenCloseAnimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self animationRemoveNiceVideoButton];
            });
        }else{
            if (self.isShowOptions) {
                [self animationRemoveNiceVideoButton];
            }
        }
    }
}

//动画添加精彩视频按钮
- (void)animationAddNiceVideoButton
{
    if (self.isAnimation) {
        return;
    }
    
    self.isAnimation = YES;
    CGPoint point = self.repeatButton.center;
    
    double tempSin = sin(M_PI / 4);
    double tempCos = cos(M_PI / 4);
    CGFloat distance = self.frame.size.width / 2 + self.photoButton.frame.size.width / 2 + (20.f / 375 * [UIScreen mainScreen].bounds.size.width);
    CGPoint point1 = CGPointMake(point.x - distance, point.y);
    CGPoint point2 = CGPointMake(point.x - distance * tempCos, point.y - distance * tempSin);
    CGPoint point3 = CGPointMake(point.x, point.y - distance);
    CGPoint point4 = CGPointMake(point.x + distance * tempSin, point.y - distance * tempCos);
    CGPoint point5 = CGPointMake(point.x + distance, point.y);
    [self animationView:self.photoButton moveToPoint:point1 completion:nil];
    [self animationView:self.videoButton moveToPoint:point2 completion:nil];
    [self animationView:self.sliderButton moveToPoint:point3 completion:nil];
    [self animationView:self.documentButton moveToPoint:point4 completion:nil];
    [self animationView:self.niceVideoButton moveToPoint:point5 completion:^(BOOL finished) {
        self.isAnimation = NO;
    }];
}

//动态移除精彩视频按钮
- (void)animationRemoveNiceVideoButton
{
    if (self.isAnimation) {
        return;
    }
    
    self.isAnimation = YES;
    CGPoint point = self.repeatButton.center;
    
    double tempSin1 = sin(M_PI / (180 / 22.5));
    double tempSin2 = sin(M_PI / (180 / 67.5));
    CGFloat distance = self.frame.size.width / 2 + self.photoButton.frame.size.width / 2 + (20.f / 375 * [UIScreen mainScreen].bounds.size.width);
    CGPoint point1 = CGPointMake(point.x - distance * tempSin2, point.y - distance * tempSin1);
    CGPoint point2 = CGPointMake(point.x - distance * tempSin1, point.y - distance * tempSin2);
    CGPoint point3 = CGPointMake(point.x + distance * tempSin1, point.y - distance * tempSin2);
    CGPoint point4 = CGPointMake(point.x + distance * tempSin2, point.y - distance * tempSin1);
    [self animationView:self.photoButton moveToPoint:point1 completion:nil];
    [self animationView:self.videoButton moveToPoint:point2 completion:nil];
    [self animationView:self.sliderButton moveToPoint:point3 completion:nil];
    [self animationView:self.documentButton moveToPoint:point4 completion:nil];
    [self animationCloseButton:self.niceVideoButton completion:^(BOOL finished) {
        self.isAnimation = NO;
    }];
}

//弹出菜单
- (void)popOptionsWithAnimation
{
    if (self.isAnimation) {
        return;
    }
    self.isAnimation = YES;
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.backgroundView];
    CGPoint point = self.repeatButton.center;
    
    if (self.isBoxSence) {
        
        double tempSin = sin(M_PI / 4);
        double tempCos = cos(M_PI / 4);
        CGFloat distance = self.frame.size.width / 2 + self.photoButton.frame.size.width / 2 + (20.f / 375 * [UIScreen mainScreen].bounds.size.width);
        CGPoint point1 = CGPointMake(point.x - distance, point.y);
        CGPoint point2 = CGPointMake(point.x - distance * tempCos, point.y - distance * tempSin);
        CGPoint point3 = CGPointMake(point.x, point.y - distance);
        CGPoint point4 = CGPointMake(point.x + distance * tempSin, point.y - distance * tempCos);
        CGPoint point5 = CGPointMake(point.x + distance, point.y);
        [self animationView:self.photoButton moveToPoint:point1 completion:nil];
        [self animationView:self.videoButton moveToPoint:point2 completion:nil];
        [self animationView:self.sliderButton moveToPoint:point3 completion:nil];
        [self animationView:self.documentButton moveToPoint:point4 completion:nil];
        [self animationView:self.niceVideoButton moveToPoint:point5 completion:^(BOOL finished) {
            self.isAnimation = NO;
            self.isShowOptions = YES;
        }];
        
    }else{
        double tempSin1 = sin(M_PI / (180 / 22.5));
        double tempSin2 = sin(M_PI / (180 / 67.5));
        CGFloat distance = self.frame.size.width / 2 + self.photoButton.frame.size.width / 2 + (20.f / 375 * [UIScreen mainScreen].bounds.size.width);
        CGPoint point1 = CGPointMake(point.x - distance * tempSin2, point.y - distance * tempSin1);
        CGPoint point2 = CGPointMake(point.x - distance * tempSin1, point.y - distance * tempSin2);
        CGPoint point3 = CGPointMake(point.x + distance * tempSin1, point.y - distance * tempSin2);
        CGPoint point4 = CGPointMake(point.x + distance * tempSin2, point.y - distance * tempSin1);
        [self animationView:self.photoButton moveToPoint:point1 completion:nil];
        [self animationView:self.videoButton moveToPoint:point2 completion:nil];
        [self animationView:self.sliderButton moveToPoint:point3 completion:nil];
        [self animationView:self.documentButton moveToPoint:point4 completion:^(BOOL finished) {
            self.isAnimation = NO;
        }];
    }
}

- (void)animationView:(UIButton *)button moveToPoint:(CGPoint)point completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:RDHomeScreenPopAnimationTime delay:0 usingSpringWithDamping:.34f initialSpringVelocity:15 options:UIViewAnimationOptionCurveEaseIn animations:^{
        button.center = point;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

//关闭菜单
- (void)closeOptionsWithAnimation{
    if (self.isAnimation) {
        return;
    }
    
    self.isAnimation= YES;
    
    [self animationCloseButton:self.photoButton completion:nil];
    [self animationCloseButton:self.videoButton completion:nil];
    [self animationCloseButton:self.sliderButton completion:nil];
    [self animationCloseButton:self.documentButton completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
        self.isAnimation = NO;
        self.isShowOptions = NO;
    }];
    [self animationCloseButton:self.niceVideoButton completion:nil];
}

- (void)animationCloseButton:(UIButton *)button completion:(void (^)(BOOL finished))completion
{
    CGPoint center = self.center;
    [UIView animateWithDuration:RDHomeScreenCloseAnimationTime animations:^{
        button.center = center;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)createRepeatButton
{
    self.repeatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.repeatButton.frame = self.frame;
    self.repeatButton.center = self.center;
    self.repeatButton.layer.cornerRadius = self.layer.cornerRadius;
    self.layer.masksToBounds = YES;
    [self.repeatButton setBackgroundImage:[UIImage imageNamed:@"toupin"] forState:UIControlStateNormal];
    [self.repeatButton addTarget:self action:@selector(closeOptionsWithAnimation) forControlEvents:UIControlEventTouchUpInside];
}

- (UIButton *)createButtonWithTag:(NSInteger)tag image:(UIImage *)image
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGFloat diameter = 72.f / 375 * [UIScreen mainScreen].bounds.size.width;
    button.frame = CGRectMake(0, 0, diameter, diameter);
    button.center = self.center;
    button.layer.cornerRadius = button.frame.size.width / 2;
    button.layer.masksToBounds = YES;
    button.tag = tag;
    [button addTarget:self action:@selector(categoryDidBeChoose:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    return button;
}

- (void)categoryDidBeChoose:(UIButton *)button
{
    RDScreenType type;
    switch (button.tag) {
        case 100:
            type = RDScreenTypePhoto;
            break;
            
        case 101:
            type = RDScreenTypeVideo;
            break;
            
        case 102:
            type = RDScreenTypeSlider;
            break;
            
        case 103:
            type = RDScreenTypeDocument;
            break;
            
        case 104:
            type = RDScreenTypeNiceVideo;
            break;
            
        default:
            type = RDScreenTypeNiceVideo;
            break;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(RDHomeScreenButtonDidChooseType:)]) {
        [_delegate RDHomeScreenButtonDidChooseType:type];
    }
    [self closeOptionsWithAnimation];
}

- (void)showWithBox
{
    self.isBoxSence = YES;
    [self setBackgroundImage:[UIImage imageNamed:@"toupin"] forState:UIControlStateNormal];
}

- (void)showWithNoBox
{
    self.isBoxSence = NO;
    [self setBackgroundImage:[UIImage imageNamed:@"touping_4g"] forState:UIControlStateNormal];
}

@end
