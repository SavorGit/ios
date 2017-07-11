//
//  RDHomeStatusView.m
//  SavorX
//
//  Created by 郭春城 on 2017/7/11.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDHomeStatusView.h"
#import "RDCheackSence.h"
#import "PhotoSliderViewController.h"
#import "PhotoManyViewController.h"
#import "GCCDLNA.h"
#import "RDAlertView.h"
#import "HSConnectViewController.h"

#import "SXVideoPlayViewController.h"
#import "DemandViewController.h"
#import "ScreenDocumentViewController.h"

@interface RDHomeStatusView ()

@property (nonatomic, strong) UILabel * statusLabel;
@property (nonatomic, strong) UIButton * statusButton;
@property (nonatomic, assign) RDHomeStatusType status;

@property (nonatomic, strong) UIViewController * currentVC;

@property (nonatomic, strong) RDCheackSence * checkSecen;

@end

@implementation RDHomeStatusView

+ (instancetype)defaultView
{
    static RDHomeStatusView *view;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        view = [[RDHomeStatusView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 38) status:RDHomeStatus_Normal];
        
    });
    
    return view;
}

- (void)dealloc
{
    [self removeNotification];
}

- (instancetype)initWithFrame:(CGRect)frame status:(RDHomeStatusType)status
{
    if (self = [super initWithFrame:frame]) {
        self.status = status;
        [self createSelf];
    }
    return self;
}

- (void)createSelf
{
    UIView * topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, .5)];
    topLine.backgroundColor = UIColorFromRGB(0xdddbd8);
    [self addSubview:topLine];
    
    UIView * bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - .5, self.frame.size.width, .5)];
    bottomLine.backgroundColor = UIColorFromRGB(0xece6de);
    [self addSubview:bottomLine];
    
    self.statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.statusButton setTitleColor:UIColorFromRGB(0x54453e) forState:UIControlStateNormal];
    self.statusButton.layer.borderColor = UIColorFromRGB(0xc4cdb9).CGColor;
    self.statusButton.layer.borderWidth = .5f;
    self.statusButton.layer.cornerRadius = 3;
    self.statusButton.layer.masksToBounds = YES;
    self.statusButton.titleLabel.font = kPingFangLight(14);
    [self.statusButton addTarget:self action:@selector(statusButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.statusButton];
    
    [self.statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(7);
        make.bottom.mas_equalTo(-7);
        make.right.mas_equalTo(-20);
        make.width.mas_equalTo(70);
    }];
    
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.textColor = UIColorFromRGB(0x922c3e);
    self.statusLabel.font = kPingFangLight(14);
    self.statusLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.statusLabel];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(9);
        make.left.mas_equalTo(10);
        make.bottom.mas_equalTo(-9);
        make.right.equalTo(self.statusButton.mas_right).offset(-10);
    }];
    
    [self reloadStatus];
    
    [self addNotification];
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopScreen) name:RDQiutScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopScreen) name:RDDidDisconnectDeviceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindBox) name:RDDidBindDeviceNotification object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDQiutScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidDisconnectDeviceNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidBindDeviceNotification object:nil];
}

- (void)bindBox
{
    self.status = RDHomeStatus_Bind;
    [self reloadStatus];
}

- (void)statusButtonDidClicked
{
    if (self.status == RDHomeStatus_Normal) {
        [self scanQRCode];
    }else if (self.status == RDHomeStatus_Bind) {
        [self disconnentClick];
    }else{
        if (self.currentVC) {
            [[Helper getRootNavigationController] pushViewController:self.currentVC animated:YES];
        }
    }
}

// 断开连接
- (void)disconnentClick{
    
    RDAlertView *rdAlert = [[RDAlertView alloc] initWithTitle:@"提示" message:@"是否与电视断开，\n断开后将无法投屏？"];
    RDAlertAction *actionOne = [[RDAlertAction alloc] initWithTitle:@"取消" handler:^{
        [SAVORXAPI postUMHandleWithContentId:@"home_break_connect" key:@"home_break_connect" value:@"cancel"];
    } bold:NO];
    RDAlertAction *actionTwo = [[RDAlertAction alloc] initWithTitle:@"断开连接" handler:^{
        [SAVORXAPI postUMHandleWithContentId:@"home_break_connect" key:@"home_break_connect" value:@"break"];
        [SAVORXAPI ScreenDemandShouldBackToTVWithSuccess:^{
            [[GlobalData shared] disconnect];
        } failure:^{
            
        }];
    } bold:YES];
    NSArray *actionArr = [NSArray arrayWithObjects:actionOne,actionTwo, nil];
    [rdAlert addActions:actionArr];
    [rdAlert show];
}

- (void)reloadStatus
{
    switch (self.status) {
        case RDHomeStatus_Normal:
        {
            self.statusLabel.text = @"您已进入酒楼,快来体验用电视看手机";
            [self.statusButton setTitle:@"连接电视" forState:UIControlStateNormal];
        }
            
            break;
            
        case RDHomeStatus_Bind:
        {
            self.statusLabel.text = [NSString stringWithFormat:@"已连接--%@的电视", [Helper getWifiName]];
            [self.statusButton setTitle:@"断开连接" forState:UIControlStateNormal];
        }
            
            break;
            
        case RDHomeStatus_Photo:
        {
            self.statusLabel.text = @"正在投屏图片,点击进入>>";
            [self.statusButton setTitle:@"退出投屏" forState:UIControlStateNormal];
        }
            
            break;
            
        case RDHomeStatus_Video:
        {
            self.statusLabel.text = @"正在投屏视频,点击进入>>";
            [self.statusButton setTitle:@"退出投屏" forState:UIControlStateNormal];
        }
            
            break;
            
        case RDHomeStatus_File:
        {
            self.statusLabel.text = @"正在投屏文件,点击进入>>";
            [self.statusButton setTitle:@"退出投屏" forState:UIControlStateNormal];
        }
            
            break;
            
        case RDHomeStatus_Demand:
        {
            self.statusLabel.text = @"正在点播视频,点击进入>>";
            [self.statusButton setTitle:@"退出点播" forState:UIControlStateNormal];
        }
            
            break;
            
        default:
            break;
    }
}

-(void)awakeFromNib{
    [super awakeFromNib];
}

- (void)startScreenWithViewController:(UIViewController *)viewController withStatus:(RDHomeStatusType)status
{
    [self show];
    
//    [self stopScreen];
    
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
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    self.currentVC = viewController;
    self.status = status;
    [self reloadStatus];
    
    _isScreening = YES;
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
    self.status = RDHomeStatus_Normal;
    [self reloadStatus];
}

- (void)stopScreenWithEggGame
{
    [self stopScreen];
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

#pragma mark -- 二维码扫描
- (void)scanQRCode
{
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
        RDAlertView * alert = [[RDAlertView alloc] initWithTitle:@"提示" message:@"未发现可连接的电视\n请连接与电视相同的wifi"];
        RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"我知道了" handler:^{
            
        } bold:YES];
        [alert addActions:@[action]];
        [alert show];
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

@end
