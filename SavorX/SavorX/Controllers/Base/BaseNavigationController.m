//
//  BaseNavigationController.m
//  SavorX
//
//  Created by lijiawei on 17/1/17.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseNavigationController.h"
#import "ScreenDocumentViewController.h"
#import "WebViewController.h"
#import "UIViewController+LGSideMenuController.h"
#import "WMPageController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [UIImage imageWithColor:kNavBackGround size:CGSizeMake(kMainBoundsWidth, kNaviBarHeight + kStatusBarHeight)];
    [[UINavigationBar appearanceWhenContainedIn:[BaseNavigationController class], nil] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    // Do any additional setup after loading the view.
}

- (BOOL)prefersStatusBarHidden {
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight) {
        return YES;
    }
    
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    if ([self.topViewController isKindOfClass:[WMPageController class]]) {
        WMPageController * vc = (WMPageController *)self.topViewController;
        if (vc.isShowScreenView) {
            return UIStatusBarStyleDefault;
        }
    }
    
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

//允许屏幕旋转
- (BOOL)shouldAutorotate
{
    return YES;
}

//返回当前屏幕旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
