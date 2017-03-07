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

- (void)show;

- (void)hidden;

- (void)scanQRCode;

- (void)callQRcodeFromPlatform;

// 重新呼出二维码
- (void)reCallCode;

@property (nonatomic, strong) UIImage *currentImage;

@end
