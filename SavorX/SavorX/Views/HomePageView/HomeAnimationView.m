//
//  HomeAnimationView.m
//  SavorX
//
//  Created by lijiawei on 17/1/19.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HomeAnimationView.h"
#import "SXDlnaViewController.h"
#import "HSConnectViewController.h"
#import "BaseNavigationController.h"
#import "WMPageController.h"
#import "PhotoSliderViewController.h"
#import "SXVideoPlayViewController.h"
#import "DemandViewController.h"
#import "PhotoManyViewController.h"
#import "ScreenDocumentViewController.h"
#import "UIImage+Additional.h"
#import "RDAlertView.h"
#import "RDCheackSence.h"
#import "GCCDLNA.h"
#import "SDWebImageManager.h"

#define HasAlertScreen @"HasAlertScreen"

@interface HomeAnimationView ()
@property (weak, nonatomic) IBOutlet UIImageView *devImageView;

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) UIViewController * currentVC;

@property (nonatomic, strong) RDCheackSence * checkSecen;

@property (nonatomic, assign) NSInteger isFirstCount;


@end

@implementation HomeAnimationView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDQiutScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidDisconnectDeviceNotification object:nil];
}

+ (instancetype)animationView
{
    static HomeAnimationView *view;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        view = [self loadFromXib];
        
        view.textLabel = [[UILabel alloc] init];
        view.textLabel.userInteractionEnabled = YES;
        view.textLabel.font = [UIFont systemFontOfSize:12];
        view.textLabel.textColor = UIColorFromRGB(0xf5f5f5);
        view.textLabel.backgroundColor = [UIColor clearColor];
        view.textLabel.textAlignment = NSTextAlignmentCenter;
        [view addSubview:view.textLabel];
        CGFloat textLabelWidth = [Helper autoWidthWith:147.f];
        CGFloat textLabelHeight = [Helper autoHeightWith:31.f];
        CGFloat textLabTopDistance = [Helper autoHeightWith:86.f];
        [view.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(textLabelWidth, textLabelHeight));
            make.top.mas_equalTo(textLabTopDistance);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
        
        view.quitScreenLabel = [[UILabel alloc] init];
        view.quitScreenLabel.text = @"退出投屏";
        view.quitScreenLabel.layer.cornerRadius = 3.0;
        view.quitScreenLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        view.quitScreenLabel.layer.borderWidth = 1;
        view.quitScreenLabel.userInteractionEnabled = YES;
        view.quitScreenLabel.font = [UIFont systemFontOfSize:13];
        view.quitScreenLabel.textColor = UIColorFromRGB(0xffffff);
        view.quitScreenLabel.backgroundColor = [UIColor clearColor];
        view.quitScreenLabel.textAlignment = NSTextAlignmentCenter;
        [view addSubview:view.quitScreenLabel];
        CGFloat quitScreenLabWidth = [Helper autoWidthWith:74.f];
        CGFloat quitScreenLabHeight = [Helper autoHeightWith:21.f];
        CGFloat quitScreenLabTopDistance = [Helper autoHeightWith:91.f];
        [view.quitScreenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(quitScreenLabWidth, quitScreenLabHeight));
            make.top.mas_equalTo(quitScreenLabTopDistance);
            make.centerX.equalTo(view);

        }];
 
        CGFloat devImageWidth = [Helper autoWidthWith:147.f];
        CGFloat devImageHeight = [Helper autoHeightWith:81.f];
        CGFloat devImageTopDistance = [Helper autoHeightWith:5.f];
        [view.devImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(devImageWidth, devImageHeight));
            make.top.mas_equalTo(devImageTopDistance);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
        
        view.devImageView.contentMode = UIViewContentModeScaleAspectFill;
        view.devImageView.clipsToBounds = YES;
        view.currentImage = [[UIImage alloc] init];
        [view hidden];
        
        [[NSNotificationCenter defaultCenter] addObserver:view selector:@selector(quitScreenHidden) name:RDQiutScreenNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:view selector:@selector(quitScreenHidden) name:RDDidDisconnectDeviceNotification object:nil];
    });
    
    return view;
}

-(void)awakeFromNib{
    [super awakeFromNib];
}

- (void)startScreenWithViewController:(UIViewController *)viewController
{
    [self show];
    
    [self stopScreen];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    self.currentVC = viewController;
    
    if (self.currentImage) {
        [self.devImageView setImage:self.currentImage];
    }else{
        [self.devImageView setImage:[UIImage imageNamed:@"ic_projecting_bg"]];
    }
    
    _isScreening = YES;
}

- (void)SDSetImage:(NSString *)path
{
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:path] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        self.currentImage = image;
        [self.devImageView setImage:self.currentImage];
    }];
}

// 退出投屏
- (void)quitScreen
{
   
    if ([self.currentVC isKindOfClass:[PhotoSliderViewController class]]) {
        PhotoSliderViewController * vc = (PhotoSliderViewController *)self.currentVC;
        [vc stopScreenImage:YES];
        
    }else if ([self.currentVC isKindOfClass:[PhotoManyViewController class]]) {
        PhotoManyViewController * vc = (PhotoManyViewController *)self.currentVC;
        [vc stopScreenImage:YES];
    }else if ([self.currentVC isKindOfClass:[SXVideoPlayViewController class]]) {
        SXVideoPlayViewController * vc = (SXVideoPlayViewController *)self.currentVC;
        [vc stopVoideoPlay:YES];

    }else if ([self.currentVC isKindOfClass:[DemandViewController class]]) {
        DemandViewController * vc = (DemandViewController *)self.currentVC;
        [vc quitScreenAciton:YES];
    }else if ([self.currentVC isKindOfClass:[ScreenDocumentViewController class]]) {
        ScreenDocumentViewController * vc = (ScreenDocumentViewController *)self.currentVC;
        [vc stopScreenDocment:YES];
    }
}

- (void)stopScreen
{
    if ([self.currentVC isKindOfClass:[PhotoSliderViewController class]]) {
        PhotoSliderViewController * vc = (PhotoSliderViewController *)self.currentVC;
        [vc shouldRelease];
    }else if ([self.currentVC isKindOfClass:[SXVideoPlayViewController class]]) {
        SXVideoPlayViewController * vc = (SXVideoPlayViewController *)self.currentVC;
        [vc shouldRelease];
    }else if ([self.currentVC isKindOfClass:[DemandViewController class]]) {
        DemandViewController * vc = (DemandViewController *)self.currentVC;
        [vc shouldRelease];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    self.currentVC = nil;
    _isScreening = NO;
}

- (void)stopScreenWithEggGame
{
    [self quitScreenHidden];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)show
{
    if ([GlobalData shared].networkStatus == RDNetworkStatusReachableViaWiFi) {
        self.hidden = NO;
    }
}

- (void)hidden
{
   self.hidden = YES;
}

// 收到退出投屏通知处理方法
- (void)quitScreenHidden{

    CGAffineTransform transform;
    transform = CGAffineTransformMakeTranslation(140.0,0.0);
    [UIView animateWithDuration:.5f animations:^{
        self.transform = transform;
    }completion:^(BOOL finished){
        [self hidden];
        self.transform = CGAffineTransformIdentity;
    }];
    [self stopScreen];
}

#pragma mark -- 二维码扫描
- (void)scanQRCode
{
    if (([GlobalData shared].isBindRD || [GlobalData shared].isBindDLNA)) {
        
        WMPageController * page = [[Helper getRootNavigationController].viewControllers firstObject];
//        [page disconnentClick];
        return;
    }
    
    if ([GlobalData shared].networkStatus != RDNetworkStatusReachableViaWiFi) {
        [self goToSetting];
        return;
    }
    
    
    if ([GCCDLNA defaultManager].isSearch) {
        self.checkSecen = [[RDCheackSence alloc] init];
        [self.checkSecen startCheckSence];
        
        return;
    }
    
    if ([GlobalData shared].scene == RDSceneHaveRDBox) {
        [self callQRcodeFromPlatform];
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

- (void)callQRcodeFromPlatform
{
    
    if ([GlobalData shared].networkStatus == RDNetworkStatusReachableViaWiFi) {
        //判断用户当前是否允许小热点使用相机权限
        [self CameroIsReady];
        
    }else{
        [self goToSetting];
    }
}

//相机权限准备好，即调用TCP连接检测与UDP广播发送进行二维码呼出
- (void)CameroIsReady
{
    
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
        [Helper interfaceOrientation:UIInterfaceOrientationPortrait];
    }
        __block BOOL hasSuccess = NO; //记录是否呼码成功过
        __block NSInteger hasFailure = 0; //记录失败次数
    
    MBProgressHUD * hud = [MBProgressHUD showCustomLoadingHUDInView:[UIApplication sharedApplication].keyWindow withTitle:@"正在呼出验证码"];
    NSString *platformUrl = [NSString stringWithFormat:@"%@/command/execute/call-tdc", [GlobalData shared].callQRCodeURL];
    [SAVORXAPI getWithURL:platformUrl parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        [hud hideAnimated:NO];
        NSInteger code = [result[@"code"] integerValue];
        if(code == 10000){
            if (hasSuccess) {
                return;
            }
            HSConnectViewController * view = [[HSConnectViewController alloc] init];
            if (![[Helper getRootNavigationController].topViewController isKindOfClass:[HSConnectViewController class]]) {
                [[Helper getRootNavigationController] pushViewController:view animated:YES];
            }
        }
        //
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //
        hasFailure += 1;
        
        if (hasFailure < 4) {
            return;
        }
        
        if (error.code == -1009 || error.code == -1001) {
            [hud hideAnimated:NO];
            [MBProgressHUD showTextHUDwithTitle:@"验证码呼出超时"];
        }else{
            [hud hideAnimated:NO];
            [MBProgressHUD showTextHUDwithTitle:@"验证码呼出失败"];
        }
    }];
    
    NSString *hosturl = [NSString stringWithFormat:@"%@/command/execute/call-tdc", [GlobalData shared].secondCallCodeURL];
    [SAVORXAPI getWithURL:hosturl parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        [hud hideAnimated:NO];
        NSInteger code = [result[@"code"] integerValue];
        if(code == 10000){
            if (hasSuccess) {
                return;
            }
            HSConnectViewController * view = [[HSConnectViewController alloc] init];
            if (![[Helper getRootNavigationController].topViewController isKindOfClass:[HSConnectViewController class]]) {
                [[Helper getRootNavigationController] pushViewController:view animated:YES];
                hasSuccess = YES;
            }
        }
        //
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //
        
        hasFailure += 1;
        
        if (hasFailure < 4) {
            return;
        }
        
        if (error.code == -1009 || error.code == -1001) {
            [hud hideAnimated:NO];
            [MBProgressHUD showTextHUDwithTitle:@"验证码呼出超时"];
        }else{
            [hud hideAnimated:NO];
            [MBProgressHUD showTextHUDwithTitle:@"验证码呼出失败"];
        }
    }];
    
    NSString *boxPlatformURL = [NSString stringWithFormat:@"%@/command/execute/call-tdc", [GlobalData shared].thirdCallCodeURL];
    [SAVORXAPI getWithURL:boxPlatformURL parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        [hud hideAnimated:NO];
        NSInteger code = [result[@"code"] integerValue];
        if(code == 10000){
            if (hasSuccess) {
                return;
            }
            HSConnectViewController * view = [[HSConnectViewController alloc] init];
            if (![[Helper getRootNavigationController].topViewController isKindOfClass:[HSConnectViewController class]]) {
                [[Helper getRootNavigationController] pushViewController:view animated:YES];
                hasSuccess = YES;
            }
        }
        //
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //
        
        hasFailure += 1;
        
        if (hasFailure < 4) {
            return;
        }
        
        if (error.code == -1009 || error.code == -1001) {
            [hud hideAnimated:NO];
            [MBProgressHUD showTextHUDwithTitle:@"验证码呼出超时"];
        }else{
            [hud hideAnimated:NO];
            [MBProgressHUD showTextHUDwithTitle:@"验证码呼出失败"];
        }
    }];
    
    NSString *boxURL = [NSString stringWithFormat:@"%@/showCode?deviceId=%@", [GlobalData shared].boxCodeURL, [GlobalData shared].deviceID];
    [SAVORXAPI getWithURL:boxURL parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        [hud hideAnimated:NO];
        NSInteger code = [result[@"code"] integerValue];
        if(code == 10000){
            if (hasSuccess) {
                return;
            }
            HSConnectViewController * view = [[HSConnectViewController alloc] init];
            if (![[Helper getRootNavigationController].topViewController isKindOfClass:[HSConnectViewController class]]) {
                [[Helper getRootNavigationController] pushViewController:view animated:YES];
                hasSuccess = YES;
            }
        }
        //
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //
        
        hasFailure += 1;
        
        if (hasFailure < 4) {
            return;
        }
        
        if (error.code == -1009 || error.code == -1001) {
            [hud hideAnimated:NO];
            [MBProgressHUD showTextHUDwithTitle:@"验证码呼出超时"];
        }else{
            [hud hideAnimated:NO];
            [MBProgressHUD showTextHUDwithTitle:@"验证码呼出失败"];
        }
    }];
}

//前往系统WIFI设置
- (void)goToSetting
{
    if (SYSTEM_VERSION_LESS_THAN(@"10")) {
        //iOS10之前可以直接跳转系统WIFI设置
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请将手机连接至电视所在WiFi" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
        }];
        [alert addAction:action1];
        [alert addAction:action2];
        [[Helper getRootNavigationController] presentViewController:alert animated:YES completion:nil];
    }else{
        //iOS10之后暂不支持直接跳转系统WIFI
        RDAlertView * alert = [[RDAlertView alloc] initWithTitle:@"提示" message:@"请前往手机设置，打开无线局域网，连接至与电视同一wifi下"];
        RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"我知道了" handler:^{
            
        } bold:YES];
        [alert addActions:@[action]];
        [alert show];
    }
}

// 点击投屏浮层，快捷进入
- (IBAction)animationStart:(id)sender {
    
    if (self.currentVC) {
        [[Helper getRootNavigationController] pushViewController:self.currentVC animated:YES];
        [SAVORXAPI postUMHandleWithContentId:@"home_quick_entry" key:nil value:nil];
    }else if ([GlobalData shared].isBindDLNA || [GlobalData shared].isBindRD) {
        UINavigationController * na = [Helper getRootNavigationController];
        if ([na.topViewController isKindOfClass:[WMPageController class]]) {
            WMPageController * wm = (WMPageController *)na.topViewController;
//            [wm rightAction];
        }
    }else{
        [self scanQRCode];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
