//
//  HomeAnimationView.h
//  SavorX
//
//  Created by lijiawei on 17/1/19.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseView.h"

@interface HomeAnimationView : BaseView

+ (instancetype)animationView;

- (void)startScreenWithViewController:(UIViewController *)viewController;

- (void)stopScreen;

- (void)quitScreen;

- (void)show;

- (void)hidden;

- (void)scanQRCode;

- (void)callQRcodeFromPlatform;

- (void)SDSetImage:(NSString *)path;

@property (nonatomic, strong) UIImage *currentImage;

@property (nonatomic, strong) UILabel *quitScreenLabel;

@property (nonatomic, strong) UITapGestureRecognizer* singleRecognizer;

@property (nonatomic, assign) BOOL isScreening; //是否正在投屏

@end
