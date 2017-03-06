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

//重置状态
- (void)resetStatus;

//找到了可连接的机顶盒
- (void)foundRDBox;

//绑定了机顶盒
- (void)bindRDBox;

- (void)scanQRCode;

//相机权限准备好，即调用TCP连接检测与UDP广播发送进行二维码呼出
- (void)CameroIsReady;

//发现设备提示动画
-(void)startDevDetectedAnimation;

@property (nonatomic, strong) UIImage *currentImage;

@end
