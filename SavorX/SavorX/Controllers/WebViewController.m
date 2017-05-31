//
//  WebViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/8/8.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "WebViewController.h"
#import "UMCustomSocialManager.h"
#import "HSConnectViewController.h"
#import "HomeAnimationView.h"
#import "SXVideoPlayViewController.h"
#import "DemandViewController.h"
#import "GCCUPnPManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "RDLogStatisticsAPI.h"
#import "RDAlertView.h"
#import "RDAlertAction.h"

@interface WebViewController ()<UIWebViewDelegate, UIGestureRecognizerDelegate, GCCPlayerViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIWebView * webView; //加载Html网页视图
@property (nonatomic, strong) MPVolumeView * volumeView;
@property (nonatomic, assign) BOOL isComplete; //内容是否阅读完整
@end

@implementation WebViewController

-(void)dealloc{
    
    //移除页面相关通知监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidBindDeviceNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isComplete = NO;
    [self createUI];
}

//初始化界面
- (void)createUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    self.title = self.model.title;
    
    //初始化播放器
    self.playView = [[GCCPlayerView alloc] initWithURL:self.model.videoURL];
    self.playView.backgroundColor = [UIColor blackColor];
    self.playView.delegate = self;
    [self.playView backgroundImage:self.model.imageURL];
    [self.playView setVideoTitle:self.model.title];
    [self.view addSubview:self.playView];
    self.playView.model = self.model;
    self.playView.categoryID = self.categoryID;
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
    
    //初始化webView
    self.webView = [[UIWebView alloc] init];
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.playView.mas_bottom);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(kMainBoundsWidth);
        make.bottom.mas_equalTo(0);
    }];
    self.webView.scrollView.delegate = self;
    self.webView.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self.webView;
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[self.model.contentURL stringByAppendingString:@"?location=newRead"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    self.webView.opaque = NO;
    [self.webView loadRequest:request];
    
    [MBProgressHUD showWebLoadingHUDInView:self.webView];
    
    //添加页面相关的通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phoneBindDevice) name:RDDidBindDeviceNotification object:nil];
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillDidBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActivePlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
}

//当手机连接到机顶盒
- (void)phoneBindDevice
{
    if ([GlobalData shared].isBindRD && self.model.canPlay == 1) {

        [self demandVideoWithforce:0];
        
    }else if ([GlobalData shared].isBindDLNA){
        //如果是绑定状态
        MBProgressHUD * hud = [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在点播"];
        [[GCCUPnPManager defaultManager] setAVTransportURL:[self.model.videoURL stringByAppendingString:@".f20.mp4"] Success:^{
            
            DemandViewController *view = [[DemandViewController alloc] init];
            view.categroyID = self.categoryID;
            view.model = self.model;
            [SAVORXAPI successRing];
            [[HomeAnimationView animationView] startScreenWithViewController:view];
            [self.navigationController pushViewController:view animated:YES];
            
            [hud hideAnimated:NO];
        } failure:^{
            [hud hideAnimated:NO];
            [MBProgressHUD showTextHUDwithTitle:DemandFailure];
        }];
    }
}

//返回按钮被点击
- (void)backButtonDidBeClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

//手机的方向发生了变化
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
        [self.navigationController setNeedsStatusBarAppearanceUpdate];
    }else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [self.playView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
        }];
        [self.playView playOrientationLandscape];
        [MBProgressHUD hideHUDForView:self.webView animated:NO];
        [self.navigationController setNeedsStatusBarAppearanceUpdate];
    }
}

//收藏按钮被点击
- (void)videoShouldBeCollect:(UIButton *)button
{
    if (!self.model.contentURL || !(self.model.contentURL.length > 0)) {
        [MBProgressHUD showTextHUDwithTitle:@"该内容暂不支持收藏" delay:1.5f];
    }
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
        [SAVORXAPI postUMHandleWithContentId:@"details_page_cancel_collection" key:@"details_page_cancel_collection" value:@"success"];
        [[NSUserDefaults standardUserDefaults] setObject:favoritesArray forKey:@"MyFavorites"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.playView setIsCollect:NO];
    }else{
        [SAVORXAPI postUMHandleWithContentId:self.model.cid withType:collectHandle];
        [favoritesArray addObject:[self.model toDictionary]];
        [MBProgressHUD showSuccessHUDInView:self.view title:@"收藏成功"];
        [SAVORXAPI postUMHandleWithContentId:@"details_page_collection" key:@"details_page_collection" value:@"success"];
        [[NSUserDefaults standardUserDefaults] setObject:favoritesArray forKey:@"MyFavorites"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.playView setIsCollect:YES];
    }
}

//视频分享按钮被点击
- (void)videoShouldBeShare
{
    [[UMCustomSocialManager defaultManager] showUMSocialSharedWithModel:self.model andController:self andType:0 categroyID:self.categoryID];
    [SAVORXAPI postUMHandleWithContentId:@"details_page_share" key:nil value:nil];
}

//分享按钮被点击
- (void)shareAction:(UIButton *)button
{
    [[UMCustomSocialManager defaultManager] showUMSocialSharedWithModel:self.model andController:self andType:0 categroyID:self.categoryID];
    [SAVORXAPI postUMHandleWithContentId:@"details_page_share" key:nil value:nil];
}

//视频的点播按钮被点击
- (void)videoShouldBeDemand
{
    if (self.model.canPlay) {
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            [self interfaceOrientation:UIInterfaceOrientationPortrait];
        }
        
        if (([GlobalData shared].isBindRD)){
            
            [SAVORXAPI postUMHandleWithContentId:self.model.cid withType:demandHandle];
            
            [self demandVideoWithforce:0];
            
        }else{
            [[HomeAnimationView animationView] scanQRCode];
        }

    }else{
        [MBProgressHUD showTextHUDwithTitle:@"当前视频不支持该操作"];
    }
}

- (void)demandVideoWithforce:(NSInteger)force{
    
    //如果是绑定状态
    MBProgressHUD * hud = [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在点播"];
    [SAVORXAPI demandWithURL:STBURL name:self.model.name type:1 position:0 force:force success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        if ([[result objectForKey:@"result"] integerValue] == 0) {
            
            DemandViewController *view = [[DemandViewController alloc] init];
            view.categroyID = self.categoryID;
            view.model = self.model;
            [SAVORXAPI successRing];
            [[HomeAnimationView animationView] SDSetImage:self.model.imageURL];
            [[HomeAnimationView animationView] startScreenWithViewController:view];
            [self.navigationController pushViewController:view animated:YES];
            [SAVORXAPI postUMHandleWithContentId:@"home_click_bunch_video" key:nil value:nil];
        }else if ([[result objectForKey:@"result"] integerValue] == 4) {
            
            NSString *infoStr = [result objectForKey:@"info"];
            RDAlertView *alertView = [[RDAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"当前%@正在投屏，是否继续投",infoStr]];
            RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"取消" handler:^{
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" key:@"to_screen_competition_hint" value:@"cancel"];
            } bold:NO];
            RDAlertAction * actionOne = [[RDAlertAction alloc] initWithTitle:@"继续投屏" handler:^{
                [self demandVideoWithforce:1];
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" key:@"to_screen_competition_hint" value:@"ensure"];
            } bold:NO];
            [alertView addActions:@[action,actionOne]];
            [alertView show];
            
        }else{
            [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
        }
        [hud hideAnimated:NO];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [hud hideAnimated:NO];
        [MBProgressHUD showTextHUDwithTitle:DemandFailure];
    }];

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
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_START type:RDLOGTYPE_CONTENT model:self.model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.playView pause];
    if ([UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if ([[Helper getRootNavigationController].topViewController isKindOfClass:[HSConnectViewController class]] || [[Helper getRootNavigationController].topViewController isKindOfClass:[WebViewController class]] || [[Helper getRootNavigationController].topViewController isKindOfClass:[DemandViewController class]]) {
        
    }else{
        [self.playView shouldRelease];
    }
    
    [super viewDidDisappear:animated];
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_END type:RDLOGTYPE_CONTENT model:self.model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
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
}

- (void)navBackButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [SAVORXAPI postUMHandleWithContentId:@"details_page_back" key:nil value:nil];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    if (self.webView.scrollView.contentSize.height - self.webView.scrollView.contentOffset.y - self.webView.frame.size.height <= 100) {
        if (_isComplete == NO) {
            [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_COMPELETE type:RDLOGTYPE_CONTENT model:self.model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
            _isComplete = YES;
        }

    }
}

//app进入后台运行
- (void)appWillDidBackground{
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_END type:RDLOGTYPE_CONTENT model:self.model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
}

//app进入前台运行
- (void)appBecomeActivePlayground{
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_START type:RDLOGTYPE_CONTENT model:self.model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
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
