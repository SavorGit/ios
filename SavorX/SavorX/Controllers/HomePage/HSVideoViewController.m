//
//  HSVideoViewController.m
//  SavorX
//
//  Created by 郭春城 on 17/3/22.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSVideoViewController.h"
#import "HSConnectViewController.h"
#import "DemandViewController.h"
#import "SXVideoPlayViewController.h"
#import "HomeAnimationView.h"
#import "GCCUPnPManager.h"
#import "UMCustomSocialManager.h"

@interface HSVideoViewController ()<GCCPlayerViewDelegate>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UIButton * collectButton; //收藏按钮
@property (nonatomic, strong) UIButton * shareButton; //分享按钮
@property (nonatomic, strong) UIButton * TVButton; //投屏按钮
@property (nonatomic, strong) UIButton * backButton; //返回按钮

@property (nonatomic, strong) UIView * videoView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) HSVodModel * model;
@property (nonatomic, strong) UIImage * image;

@end

@implementation HSVideoViewController

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidBindDeviceNotification object:nil];
}

- (instancetype)initWithModel:(HSVodModel *)model image:(UIImage *)image
{
    if (self = [super init]) {
        self.model = model;
        self.image = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor blackColor];
    
    self.videoView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.videoView];
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.center.mas_equalTo(0);
        make.height.equalTo(self.view.mas_width).multipliedBy([UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height).mas_offset(30);
    }];
    
    self.playView = [[GCCPlayerView alloc] initWithURL:self.model.videoURL];
    self.playView.backgroundColor = [UIColor blackColor];
    [self.playView setVideoTitle:self.model.title];
    [self.playView backgroundImage:self.image];
    [self.videoView addSubview:self.playView];
    self.playView.delegate = self;
    [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.equalTo(self.view.mas_width).multipliedBy([UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height);
    }];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = self.model.title;
    [self.videoView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(20);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(30);
    }];
    
    
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
        [self setIsCollect:iscollect];
    }
    
    self.topView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.topView];
    self.topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(70);
    }];
    
    self.TVButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.TVButton setImage:[UIImage imageNamed:@"tv"] forState:UIControlStateNormal];
    [self.TVButton addTarget:self action:@selector(videoShouldBeDemand) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.TVButton];
    
    self.collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.collectButton setImage:[UIImage imageNamed:@"icon_collect"] forState:UIControlStateNormal];
    [self.collectButton setImage:[UIImage imageNamed:@"icon_collect_yes"] forState:UIControlStateSelected];
    [self.collectButton addTarget:self action:@selector(videoShouldBeCollect:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.collectButton];
    
    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareButton setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(videoShouldBeShare) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.shareButton];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setImage:[UIImage imageNamed:@"RDBack"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonDidBeClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.backButton];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.right.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [self.collectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.right.mas_equalTo(-50);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [self.TVButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.right.mas_equalTo(-100);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self playOrientationPortrait];
    if (!self.model.canPlay) {
        [self hiddenTVButton];
    }
    
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
    if (_isFormDemand == YES) {
        UINavigationController * na = [Helper getRootNavigationController];
        if ([NSStringFromClass([na class]) isEqualToString:@"BaseNavigationController"]) {
            UIViewController * vc = [na.viewControllers firstObject];
            [self.navigationController popToViewController:vc animated:YES];
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
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
        [self setIsCollect:NO];
    }else{
        [SAVORXAPI postUMHandleWithContentId:self.model.cid withType:collectHandle];
        [favoritesArray addObject:[self.model toDictionary]];
        [MBProgressHUD showSuccessHUDInView:self.view title:@"收藏成功"];
        [[NSUserDefaults standardUserDefaults] setObject:favoritesArray forKey:@"MyFavorites"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self setIsCollect:YES];
    }
}

- (void)videoShouldBeShare
{
    [UMCustomSocialManager defaultManager].image = self.image;
    [[UMCustomSocialManager defaultManager] showUMSocialSharedWithModel:self.model andController:self];
}

- (void)hiddenTVButton
{
    [self.playView hiddenTVButton];
    self.TVButton.hidden = YES;
}

- (void)setIsCollect:(BOOL)isCollect
{
    [self.playView setIsCollect:isCollect];
    if (isCollect) {
        [self.collectButton setSelected:YES];
        [self.collectButton setImage:[UIImage imageNamed:@"icon_collect_yes"] forState:UIControlStateNormal];
    }else{
        [self.collectButton setSelected:NO];
        [self.collectButton setImage:[UIImage imageNamed:@"icon_collect"] forState:UIControlStateNormal];
    }
}

- (void)orientationChanged
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait) {
        [self playOrientationPortrait];
    }else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        [self playOrientationLandscape];
    }
}

- (void)playOrientationPortrait
{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.center.mas_equalTo(0);
        make.height.equalTo(self.view.mas_width).multipliedBy([UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height).mas_offset(30);
    }];
    self.topView.hidden = NO;
    [self.playView playOrientationPortraitWithOnlyVideo];
    [self.navigationController setNeedsStatusBarAppearanceUpdate];
}

- (void)playOrientationLandscape
{
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.equalTo(self.view.mas_width).multipliedBy([UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height).mas_offset(30);
    }];
    self.topView.hidden = YES;
    [self.playView playOrientationLandscapeWithOnlyVideo];
    [self.navigationController setNeedsStatusBarAppearanceUpdate];
}

- (void)shareAction:(UIButton *)button
{
    [UMCustomSocialManager defaultManager].image = self.image;
    [[UMCustomSocialManager defaultManager] showUMSocialSharedWithModel:self.model andController:self];
}

- (void)videoShouldBeDemand
{
    if (self.model.canPlay && !_isFormDemand ) {
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            [self interfaceOrientation:UIInterfaceOrientationPortrait];
        }
        
        [[HomeAnimationView animationView] scanQRCode];
    }else if (self.model.canPlay && _isFormDemand == YES ){
        
        [self.navigationController popViewControllerAnimated:YES];
        if (_coFromWebView) {
            _coFromWebView(nil);
        }
    }
    else{
        [MBProgressHUD showTextHUDwithTitle:@"当前视频不支持该操作"];
    }
}

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    
    [self.playView pause];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if ([[Helper getRootNavigationController].topViewController isKindOfClass:[HSConnectViewController class]] || [[Helper getRootNavigationController].topViewController isKindOfClass:[HSVideoViewController class]]) {
        
    }else{
        [self.playView shouldRelease];
    }
    [super viewDidDisappear:animated];
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