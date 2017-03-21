//
//  WebViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/8/8.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "WebViewController.h"
#import "UMCustomSocialManager.h"
#import "ScanQRCodeViewController.h"
#import "HomeAnimationView.h"
#import "SXVideoPlayViewController.h"
#import "DemandViewController.h"
#import "GCCUPnPManager.h"
#import <MediaPlayer/MediaPlayer.h>

@interface WebViewController ()<UIWebViewDelegate, UIGestureRecognizerDelegate, GCCPlayerViewDelegate>

@property (nonatomic, strong) UIWebView * webView; //加载Html网页视图
@property (nonatomic, strong) MPVolumeView * volumeView;

@end

@implementation WebViewController

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidBindDeviceNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-100, -100, 40, 40)];
//    [self.volumeView setHidden:NO];
//    [self.view addSubview:self.volumeView];
    
    [self createUI];
}

//初始化界面
- (void)createUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    self.title = self.model.title;
    
    self.playView = [[GCCPlayerView alloc] initWithURL:self.model.videoURL];
    self.playView.backgroundColor = [UIColor blackColor];
    self.playView.delegate = self;
    [self.playView setVideoTitle:self.model.title];
    [self.view addSubview:self.playView];
    [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.equalTo(self.view.mas_width).multipliedBy([UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height);
    }];
    if (!self.model.canPlay) {
        [self.playView hiddenTVButton];
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"MyFavorites"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *theArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyFavorites"]];
        __block BOOL iscollect = NO;
        [theArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj objectForKey:@"contentURL"] isEqualToString:self.model.contentURL]) {
                iscollect = YES;
                *stop = YES;
                return;
            }
        }];
        [self.playView setIsCollect:iscollect];
    }
    
    self.webView = [[UIWebView alloc] init];
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.playView.mas_bottom);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(kMainBoundsWidth);
        make.bottom.mas_equalTo(0);
    }];
    self.webView.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self.webView;
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[self.model.contentURL stringByAppendingString:@"?location=newRead"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    self.webView.opaque = NO;
    [self.webView loadRequest:request];
    
    [MBProgressHUD showWebLoadingHUDInView:self.webView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phoneBindDevice) name:RDDidBindDeviceNotification object:nil];
}

- (void)phoneBindDevice
{
    if ([GlobalData shared].isBindRD && self.model.canPlay == 1) {
        //如果是绑定状态
        MBProgressHUD * hud = [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在点播"];
        [SAVORXAPI demandWithURL:STBURL name:self.model.name type:1 position:0 success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            if ([[result objectForKey:@"result"] integerValue] == 0) {
                if (self.model.type == 3) {
                    DemandViewController *view = [[DemandViewController alloc] init];
                    view.model = self.model;
                    [SAVORXAPI successRing];
                    [[HomeAnimationView animationView] startScreenWithViewController:view];
                    [self.navigationController pushViewController:view animated:YES];
                }else{
                    SXVideoPlayViewController * play = [[SXVideoPlayViewController alloc] init];
                    play.model = self.model;
                    [[HomeAnimationView animationView] startScreenWithViewController:play];
                    [self.navigationController pushViewController:play animated:YES];
                }
                [self.playView shouldRelease];
            }else{
                [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
            }
            [hud hideAnimated:NO];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [hud hideAnimated:NO];
            [MBProgressHUD showTextHUDwithTitle:DemandFailure];
        }];
    }else if ([GlobalData shared].isBindDLNA){
        //如果是绑定状态
        MBProgressHUD * hud = [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在点播"];
        [[GCCUPnPManager defaultManager] setAVTransportURL:[self.model.videoURL stringByAppendingString:@".f20.mp4"] Success:^{
            if (self.model.type == 3) {
                DemandViewController *view = [[DemandViewController alloc] init];
                view.model = self.model;
                [SAVORXAPI successRing];
                [[HomeAnimationView animationView] startScreenWithViewController:view];
                [self.navigationController pushViewController:view animated:YES];
            }else{
                SXVideoPlayViewController * play = [[SXVideoPlayViewController alloc] init];
                play.model = self.model;
                [[HomeAnimationView animationView] startScreenWithViewController:play];
                [self.navigationController pushViewController:play animated:YES];
            }
            [hud hideAnimated:NO];
            [self.playView shouldRelease];
        } failure:^{
            [hud hideAnimated:NO];
            [MBProgressHUD showTextHUDwithTitle:DemandFailure];
        }];
    }
}

- (void)backButtonDidBeClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)orientationChanged
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        [self.playView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(20);
        }];
        [self.playView playOrientationPortrait];
        
        if (self.webView.isLoading) {
            [MBProgressHUD showWebLoadingHUDInView:self.webView];
        }
        
        if ([GlobalData shared].scene == RDSceneHaveRDBox ||
            [GlobalData shared].scene == RDSceneHaveDLNA) {
            
        }
        
    }else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [self.playView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
        }];
        [self.playView playOrientationLandscape];
        [MBProgressHUD hideHUDForView:self.webView animated:NO];
    }
}

//收藏按钮被点击
- (void)videoShouldBeCollect:(UIButton *)button
{
    NSMutableArray *favoritesArray = [NSMutableArray array];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"MyFavorites"] isKindOfClass:[NSArray class]]) {
        favoritesArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyFavorites"]];
    }
    if (button.selected) {
        [favoritesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj objectForKey:@"contentURL"] isEqualToString:self.model.contentURL]) {
                [favoritesArray removeObject:obj];
                *stop = YES;
            }
        }];
        [SAVORXAPI postUMHandleWithContentId:self.model.cid withType:cancleCollectHandle];
        [MBProgressHUD showSuccessHUDInView:self.view title:@"取消成功"];
        [[NSUserDefaults standardUserDefaults] setObject:favoritesArray forKey:@"MyFavorites"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.playView setIsCollect:NO];
    }else{
        [SAVORXAPI postUMHandleWithContentId:self.model.cid withType:collectHandle];
        [favoritesArray addObject:[self.model toDictionary]];
        [MBProgressHUD showSuccessHUDInView:self.view title:@"收藏成功"];
        [[NSUserDefaults standardUserDefaults] setObject:favoritesArray forKey:@"MyFavorites"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.playView setIsCollect:YES];
    }
}

- (void)videoShouldBeShare
{
    [UMCustomSocialManager defaultManager].image = self.image;
    [[UMCustomSocialManager defaultManager] showUMSocialSharedWithModel:self.model andController:self];
}

//分享按钮被点击
- (void)shareAction:(UIButton *)button
{
    [UMCustomSocialManager defaultManager].image = self.image;
    [[UMCustomSocialManager defaultManager] showUMSocialSharedWithModel:self.model andController:self];
}

- (void)videoShouldBeDemand
{
    if (self.model.canPlay) {
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            [self interfaceOrientation:UIInterfaceOrientationPortrait];
        }
        
        [[HomeAnimationView animationView] scanQRCode];
    }else{
        [MBProgressHUD showTextHUDwithTitle:@"当前视频不支持该操作"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.volumeView setHidden:NO];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [SAVORXAPI postUMHandleWithContentId:self.model.cid withType:readHandle];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [self.volumeView setHidden:YES];
    [self.playView pause];
    if ([UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if ([[Helper getRootNavigationController].topViewController isKindOfClass:[ScanQRCodeViewController class]] || [[Helper getRootNavigationController].topViewController isKindOfClass:[WebViewController class]]) {
        
    }else{
        [self.playView shouldRelease];
    }
    
    [super viewDidDisappear:animated];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString hasSuffix:@"mp4"]) {
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideHUDForView:self.webView animated:NO];
}

#pragma mark 屏幕转屏相关

/**
 *  强制屏幕转屏
 *
 *  @param orientation 屏幕方向
 */
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    // arc下
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        // 设置横屏
        
    } else if (orientation == UIInterfaceOrientationPortrait) {
        // 设置竖屏
        
    }
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
