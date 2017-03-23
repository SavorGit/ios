//
//  RDHomeScreenButton.m
//  Test - 2.1
//
//  Created by 郭春城 on 17/3/2.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDHomeScreenButton.h"
#import "SDImageCache.h"
#import "WMPageController.h"
#import "LGSideMenuController.h"

static CGFloat RDHomeScreenPopAnimationTime = .5f;
static CGFloat RDHomeScreenCloseAnimationTime = .3f;

@interface RDHomeScreenButton ()<LGSideMenuControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIView * backgroundView;

@property (nonatomic, strong) UIButton * repeatButton;
@property (nonatomic, strong) UIButton * photoButton;
@property (nonatomic, strong) UIButton * videoButton;
@property (nonatomic, strong) UIButton * sliderButton;
@property (nonatomic, strong) UIButton * niceVideoButton;
@property (nonatomic, strong) UIButton * documentButton;

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
        
        [self createDelegate];
    }
    return self;
}

- (void)createDelegate
{
    LGSideMenuController * side = (LGSideMenuController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    side.delegate = self;
    
    UINavigationController * na = (UINavigationController *)side.rootViewController;
    na.delegate = self;
}

- (void)createViews
{
    self.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height - self.frame.size.height / 2 - 30 - kStatusBarHeight - kNaviBarHeight);
    
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.masksToBounds = YES;
    
    self.backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    
    self.photoButton = [self createButtonWithTag:100 image:[UIImage imageNamed:@"tupian"]];
    self.videoButton = [self createButtonWithTag:101 image:[UIImage imageNamed:@"shipin"]];
    self.sliderButton = [self createButtonWithTag:102 image:[UIImage imageNamed:@"huandengpian"]];
    self.documentButton = [self createButtonWithTag:103 image:[UIImage imageNamed:@"wenjian"]];
    self.niceVideoButton = [self createButtonWithTag:104 image:[UIImage imageNamed:@"dianbo"]];
    
    [self createRepeatButton];
    
    [self.backgroundView addSubview:self.photoButton];
    [self.backgroundView addSubview:self.videoButton];
    [self.backgroundView addSubview:self.sliderButton];
    [self.backgroundView addSubview:self.documentButton];
    [self.backgroundView addSubview:self.niceVideoButton];
    [self.backgroundView addSubview:self.repeatButton];
    
    [self setBackgroundImage:[UIImage imageNamed:@"toupin"] forState:UIControlStateNormal];
    
    [self showWithNoBox];
    
    [self addTarget:self action:@selector(popOptionsWithAnimation) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeOptionsWithAnimation)];
    tap.numberOfTapsRequired = 1;
    [self.backgroundView addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFoundBoxSence) name:RDDidFoundBoxSenceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoseBoxSence) name:RDDidNotFoundSenceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoseBoxSence) name:RDDidFoundDLNASenceNotification object:nil];
}

//发现了盒子环境
- (void)didFoundBoxSence
{
    if (!self.isBoxSence) {
        [self showWithBox];
        if (self.isShowOptions) {
            [self animationAddNiceVideoButton];
        }else{
            [self popWithNoAnimation];
        }
    }
}

//失去了盒子环境
- (void)didLoseBoxSence
{
    if (self.isBoxSence) {
        [self showWithNoBox];
        if (self.isShowOptions) {
            [self animationRemoveNiceVideoButton];
        }
    }
}

//动画添加精彩视频按钮
- (void)animationAddNiceVideoButton
{
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
        
    }];
}

//动态移除精彩视频按钮
- (void)animationRemoveNiceVideoButton
{
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
        
    }];
}

- (void)popWithNoAnimation
{
    if (![self checkIsCanShowInWindow]) {
        return;
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.backgroundView];
    [MBProgressHUD showTextHUDwithTitle:@"发现电视, 可以投屏"];
    self.repeatButton.center = [self viewCenter];
    CGPoint point = self.repeatButton.center;
    self.photoButton.center = point;
    self.videoButton.center = point;
    self.sliderButton.center = point;
    self.documentButton.center = point;
    self.niceVideoButton.center = point;
}

//弹出菜单
- (void)popOptionsWithAnimation
{
    [SAVORXAPI postUMHandleWithContentId:@"home_toscreen_list_expand" key:nil value:nil];
    
    if (![self checkIsCanShowInWindow]) {
        [self closeOptionsWithAnimation];
        return;
    }
    
    if (!self.isBoxSence) {
        self.alpha = 1.f;
    }
    self.isShowOptions = YES;
    [[SDImageCache sharedImageCache] clearMemory];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.backgroundView];
    
    UIView * tempView = [[UIApplication sharedApplication].keyWindow viewWithTag:888];
    if (tempView) {
        [tempView removeFromSuperview];
    }
    
    self.repeatButton.center = [self viewCenter];
    CGPoint point = self.repeatButton.center;
    self.photoButton.center = point;
    self.videoButton.center = point;
    self.sliderButton.center = point;
    self.documentButton.center = point;
    self.niceVideoButton.center = point;
    
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
    
    self.isShowOptions = NO;
    
    [self animationCloseButton:self.photoButton completion:nil];
    [self animationCloseButton:self.videoButton completion:nil];
    [self animationCloseButton:self.sliderButton completion:nil];
    [self animationCloseButton:self.documentButton completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
    }];
    [self animationCloseButton:self.niceVideoButton completion:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayReset4GAlpha) object:nil];
    if (!self.isBoxSence) {
        [self performSelector:@selector(delayReset4GAlpha) withObject:nil afterDelay:3.f];
    }
}

- (void)closeWithMust{
    
    self.isShowOptions = NO;
    
    [self animationCloseButton:self.photoButton completion:nil];
    [self animationCloseButton:self.videoButton completion:nil];
    [self animationCloseButton:self.sliderButton completion:nil];
    [self animationCloseButton:self.documentButton completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
    }];
    [self animationCloseButton:self.niceVideoButton completion:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayReset4GAlpha) object:nil];
    if (!self.isBoxSence) {
        self.alpha = 1.f;
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

- (void)animationCloseButton:(UIButton *)button completion:(void (^)(BOOL finished))completion
{
    CGPoint center = self.repeatButton.center;
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
    self.repeatButton.center = [self viewCenter];
    self.repeatButton.layer.cornerRadius = self.layer.cornerRadius;
    self.layer.masksToBounds = YES;
    [self.repeatButton setBackgroundImage:[UIImage imageNamed:@"toupin"] forState:UIControlStateNormal];
    [self.repeatButton addTarget:self action:@selector(checkIsShowOptions) forControlEvents:UIControlEventTouchUpInside];
}

- (void)checkIsShowOptions
{
    if (self.isShowOptions) {
        self.isShowOptions = NO;
        
        [self animationCloseButton:self.photoButton completion:nil];
        [self animationCloseButton:self.videoButton completion:nil];
        [self animationCloseButton:self.sliderButton completion:nil];
        [self animationCloseButton:self.documentButton completion:^(BOOL finished) {
            [self.backgroundView removeFromSuperview];
        }];
        [self animationCloseButton:self.niceVideoButton completion:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayReset4GAlpha) object:nil];
        if (!self.isBoxSence) {
            [self performSelector:@selector(delayReset4GAlpha) withObject:nil afterDelay:3.f];
        }
        [SAVORXAPI postUMHandleWithContentId:@"home_toscreen_list_collapse" key:nil value:nil];
    }else{
        [self popOptionsWithAnimation];
    }
}

- (UIButton *)createButtonWithTag:(NSInteger)tag image:(UIImage *)image
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGFloat diameter = 72.f / 375 * [UIScreen mainScreen].bounds.size.width;
    button.frame = CGRectMake(0, 0, diameter, diameter);;
    button.center = [self viewCenter];
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
    self.alpha = 1.f;
}

- (void)showWithNoBox
{
    self.isBoxSence = NO;
    self.alpha = .6f;
}

//检测是否可以在window上添加投屏菜单蒙层
- (BOOL)checkIsCanShowInWindow
{
    BOOL result = YES;
    
    LGSideMenuController * side = (LGSideMenuController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)side.rootViewController;
    if ([na.topViewController isKindOfClass:[WMPageController class]]) {
        if (side.isLeftViewShowing) {
            result = NO;
        }
        if (na.interactivePopGestureRecognizer.state != UIGestureRecognizerStatePossible) {
            result = NO;
        }
        if ([[UIApplication sharedApplication].keyWindow viewWithTag:4444]) {
            return NO;
        }
    }else{
        result = NO;
    }
    
    return result;
}

- (void)didShowLeftView:(UIView *)leftView sideMenuController:(LGSideMenuController *)sideMenuController
{
    if (self.backgroundView.superview) {
        [self closeOptionsWithAnimation];
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (![viewController isKindOfClass:[WMPageController class]]) {
        if (self.backgroundView.superview) {
            [self closeOptionsWithAnimation];
        }
    }
}

- (CGPoint)viewCenter
{
    CGPoint center = self.center;
    
    if (self.superview) {
        CGRect rect = [self convertRect:self.bounds toView:[UIApplication sharedApplication].keyWindow];
        center.y = rect.origin.y + rect.size.height / 2;
    }else{
        center.y += kStatusBarHeight + kNaviBarHeight;
    }
    
    return center;
}

@end
