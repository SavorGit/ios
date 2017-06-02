//
//  RDHomeScreenButton.m
//  Test - 2.1
//
//  Created by 郭春城 on 17/3/2.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDHomeScreenButton.h"

#define RDHomeScreenButtonCenterInHotel CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height - self.frame.size.height / 2 - kStatusBarHeight - kNaviBarHeight);
#define RDHomeScreenButtonCenterOutHotel CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height - kStatusBarHeight - kNaviBarHeight - 2);

@interface RDHomeScreenButton ()

@property (nonatomic, assign) BOOL isBoxSence; //记录当前时候是在酒店环境
@property (nonatomic, assign) BOOL isShowOptions; //记录当前是否在展示选项

@end

@implementation RDHomeScreenButton

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidFoundBoxSenceNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidNotFoundSenceNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidFoundDLNASenceNotification object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createViews];
        [self setExclusiveTouch:YES];
    }
    return self;
}

- (void)createViews
{
    if ([GlobalData shared].scene == RDSceneHaveRDBox) {
        self.center = RDHomeScreenButtonCenterInHotel;
    }else{
        self.center = RDHomeScreenButtonCenterOutHotel;
    }
    
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.masksToBounds = YES;

    [self setBackgroundImage:[UIImage imageNamed:@"toupin"] forState:UIControlStateNormal];
    
    [self showWithNoBox];
    
    [self addTarget:self action:@selector(screenButtonDidBeClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFoundBoxSence) name:RDDidFoundBoxSenceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoseBoxSence) name:RDDidNotFoundSenceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoseBoxSence) name:RDDidFoundDLNASenceNotification object:nil];
}

- (void)screenButtonDidBeClicked
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(RDHomeScreenButtonDidBeClicked)]) {
        [self.delegate RDHomeScreenButtonDidBeClicked];
    }
}

//发现了盒子环境
- (void)didFoundBoxSence
{
    [self showWithBox];
    [self animationFoundBoxSence];
}

//动画切换至盒子环境
- (void)animationFoundBoxSence
{
    [UIView animateWithDuration:.1f animations:^{
        self.center = RDHomeScreenButtonCenterInHotel;
    } completion:^(BOOL finished) {
        
    }];
}

//失去了盒子环境
- (void)didLoseBoxSence
{
    [self showWithNoBox];
    [self animationLoseBoxSence];
}

//动画切换至运营商环境
- (void)animationLoseBoxSence
{
    [UIView animateWithDuration:.1f animations:^{
        self.center = RDHomeScreenButtonCenterOutHotel;
    } completion:^(BOOL finished) {
        
    }];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayReset4GAlpha) object:nil];
    if (!self.isBoxSence) {
        [self performSelector:@selector(delayReset4GAlpha) withObject:nil afterDelay:3.f];
    }
}

//延时重置4G透明度
- (void)delayReset4GAlpha
{
    if (!self.isBoxSence) {
        [UIView animateWithDuration:.4f animations:^{
            self.alpha = .6f;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)showWithBox
{
    self.isBoxSence = YES;
    self.alpha = 1.f;
    [self setBackgroundImage:[UIImage imageNamed:@"toupin"] forState:UIControlStateNormal];
}

- (void)showWithNoBox
{
    self.isBoxSence = NO;
    self.alpha = .6f;
    [self setBackgroundImage:[UIImage imageNamed:@"toupin4G"] forState:UIControlStateNormal];
}

@end
