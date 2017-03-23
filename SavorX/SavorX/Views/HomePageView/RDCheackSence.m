
//
//  RDCheackSence.m
//  SavorX
//
//  Created by 郭春城 on 17/3/7.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDCheackSence.h"
#import "RDAlertView.h"
#import "GCCDLNA.h"
#import "BaseNavigationController.h"
#import "SXDlnaViewController.h"
#import "HomeAnimationView.h"
#import "LGSideMenuController.h"
#import "WMPageController.h"
#import "HSConnectViewController.h"

@interface RDCheackSence ()

@property (nonatomic, strong) RDAlertView * alertView;

@end

@implementation RDCheackSence

- (void)dealloc
{
    [[GCCDLNA defaultManager] removeObserver:self forKeyPath:@"isSearch" context:nil];
}

- (void)startCheckSence
{
    if ([GCCDLNA defaultManager].isSearch) {
        [self applicationIsSearchSence];
    }
    
    [[GCCDLNA defaultManager] addObserver:self forKeyPath:@"isSearch" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)applicationIsSearchSence
{
    
    if ([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[LGSideMenuController class]]) {
        LGSideMenuController * side = (LGSideMenuController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        BaseNavigationController * baseNa = (BaseNavigationController *)side.rootViewController;
        if ([baseNa.topViewController isKindOfClass:[WMPageController class]]) {
            
            WMPageController * page = (WMPageController *)baseNa.topViewController;
            [page.homeButton closeWithMust];
        }else if ([baseNa.topViewController isKindOfClass:[HSConnectViewController class]]){
            [baseNa popViewControllerAnimated:NO];
        }
    }
    
    self.alertView = [[RDAlertView alloc] initWithTitle:@"提示" message:@"正在扫描可连接的电视...."];
    RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"我知道了" handler:^{
        
    } bold:NO];
    [self.alertView addActions:@[action]];
    [self.alertView show];
}

- (void)applicationEndSearchSence
{
    if (self.alertView.superview) {
        [self.alertView removeFromSuperview];
        if ([GlobalData shared].scene == RDSceneHaveRDBox) {
            [[HomeAnimationView animationView] callQRcodeFromPlatform];
        }else{
            if ([GlobalData shared].scene == RDSceneHaveDLNA) {
                SXDlnaViewController * SX = [[SXDlnaViewController alloc] init];
                BaseNavigationController * na = [[BaseNavigationController alloc] initWithRootViewController:SX];
                [[Helper getRootNavigationController] presentViewController:na animated:YES completion:nil];
            }else{
                RDAlertView * alert = [[RDAlertView alloc] initWithTitle:@"提示" message:@"未发现可连接的电视\n请连接与电视相同的wifi"];
                RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"我知道了" handler:^{
                    
                } bold:YES];
                [alert addActions:@[action]];
                [alert show];
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isSearch"]) {
        
        if (![GCCDLNA defaultManager].isSearch) {
            [self applicationEndSearchSence];
        }
        
    }
}

@end
