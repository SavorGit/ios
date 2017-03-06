//
//  HomeAnimationView.m
//  SavorX
//
//  Created by lijiawei on 17/1/19.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HomeAnimationView.h"
#import "SXDlnaViewController.h"
#import "ScanQRCodeViewController.h"
#import "BaseNavigationController.h"
#import "LGSideMenuController.h"
#import "WMPageController.h"
#import "PhotoSliderViewController.h"
#import "SXVideoPlayViewController.h"
#import "PhotoManyViewController.h"
#import "DemandViewController.h"
#import "ScreenDocumentViewController.h"
#import "ScreenProjectionView.h"
#import "WMPageController.h"

#define HasAlertScreen @"HasAlertScreen"

@interface HomeAnimationView ()<QRCodeDidBindDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *devImageView;
@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) UIViewController * currentVC;

@end

@implementation HomeAnimationView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDQiutScreenNotification object:nil];
}

+ (instancetype)animationView
{
    static HomeAnimationView *view;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        view = [self loadFromXib];
        
//        LGSideMenuController * side = (LGSideMenuController *)[UIApplication sharedApplication].keyWindow.rootViewController;
//        
//        [side.rootViewController.view addSubview:view];
//        [view mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.size.mas_equalTo(CGSizeMake(130, 100));
//            make.bottom.mas_equalTo(-120);
//            make.right.mas_equalTo(-25);
//        }];
        
        view.textLabel = [[UILabel alloc] init];
        view.textLabel.text = @"投屏中...";
        view.textLabel.font = [UIFont systemFontOfSize:12];
        view.textLabel.textColor = [UIColor whiteColor];
        view.textLabel.backgroundColor = [UIColor blackColor];
        view.textLabel.textAlignment = NSTextAlignmentCenter;
        [view addSubview:view.textLabel];
        [view.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(130, 20));
            make.top.mas_equalTo(80);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
        
//        [view.devImageView setImage:[UIImage imageNamed:@"faxianshebei"]];
        view.currentImage = [[UIImage alloc] init];
        [view hidden];
        
        [[NSNotificationCenter defaultCenter] addObserver:view selector:@selector(quitScreenHidden) name:RDQiutScreenNotification object:nil];
    });
    
    return view;
}

-(void)awakeFromNib{
    [super awakeFromNib];
}

- (void)startScreenWithViewController:(UIViewController *)viewController
{
    if ([self.currentVC isKindOfClass:[PhotoSliderViewController class]]) {
        PhotoSliderViewController * vc = (PhotoSliderViewController *)self.currentVC;
        [vc shouldRelease];
//        [self.devImageView setImage:[UIImage imageNamed:@"tupian"]];
    }else if ([self.currentVC isKindOfClass:[SXVideoPlayViewController class]]) {
        SXVideoPlayViewController * vc = (SXVideoPlayViewController *)self.currentVC;
        [vc shouldRelease];
//        [self.devImageView setImage:[UIImage imageNamed:@"shipin"]];
    }else if ([self.currentVC isKindOfClass:[DemandViewController class]]) {
        DemandViewController * vc = (DemandViewController *)self.currentVC;
        [vc shouldRelease];
//        [self.devImageView setImage:[UIImage imageNamed:@"shipin"]];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    self.currentVC = nil;
    
    if ([viewController isKindOfClass:[PhotoSliderViewController class]] ||
        [viewController isKindOfClass:[SXVideoPlayViewController class]]) {
        // 设置屏幕常亮
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    
    self.currentVC = viewController;
    
//    if ([self.currentVC isKindOfClass:[PhotoSliderViewController class]]) {
//        [self.devImageView setImage:[UIImage imageNamed:@"tupian"]];
//    }else if ([self.currentVC isKindOfClass:[SXVideoPlayViewController class]]) {
//        [self.devImageView setImage:[UIImage imageNamed:@"shipin"]];
//    }else if ([self.currentVC isKindOfClass:[DemandViewController class]]) {
//        [self.devImageView setImage:[UIImage imageNamed:@"shipin"]];
//    }else if ([self.currentVC isKindOfClass:[PhotoManyViewController class]]){
//        [self.devImageView setImage:[UIImage imageNamed:@"tupian"]];
//    }else if([self.currentVC isKindOfClass:[ScreenDocumentViewController class]]){
//        [self.devImageView setImage:[UIImage imageNamed:@"wenjian"]];
//    }
    
    [self.devImageView setImage:self.currentImage];
}

- (void)stopScreen
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    self.currentVC = nil;
}

- (void)show
{
    if ([GlobalData shared].isWifiStatus) {
        self.hidden = NO;
    }
}

- (void)hidden
{
   self.hidden = YES;
}

// 收到退出投屏通知处理方法
- (void)quitScreenHidden{
    
    [self hidden];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    self.currentVC = nil;
}

#pragma mark -- 二维码扫描
- (void)scanQRCode
{
    if (([GlobalData shared].isBindRD || [GlobalData shared].isBindDLNA)) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"断开连接?" message:@"您确定与当前电视断开链接吗?\n断开后将无法进行投屏!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [SAVORXAPI ScreenDemandShouldBackToTV];
            [[GlobalData shared] disconnect];
        }];
        [alert addAction:action1];
        [alert addAction:action2];
        
//        UITabBarController * tab = (UITabBarController *)self.window.rootViewController;
        [[Helper getRootNavigationController].topViewController presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if (![GlobalData shared].isWifiStatus) {
        [self goToSetting];
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
            [MBProgressHUD showTextHUDwithTitle:@"当前网络环境暂未发现可投屏设备"];
        }
    }
}

- (void)callQRcodeFromPlatform
{
    
    if ([GlobalData shared].isWifiStatus) {
        //判断用户当前是否允许热点儿使用相机权限
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusNotDetermined){
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    //如果还没有进行选择
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self CameroIsReady];
                    });
                }else{
                    
                }
            }];
        }else if (authStatus == AVAuthorizationStatusAuthorized){
            //如果已经允许了权限
            [self CameroIsReady];
        }else{
            //没有使用相机的权限
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"前往开启相机权限" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
            [alert addAction:action1];
            [alert addAction:action2];
            [[Helper getRootNavigationController] presentViewController:alert animated:YES completion:nil];
        }
        
    }else{
        [self goToSetting];
    }
}

//相机权限准备好，即调用TCP连接检测与UDP广播发送进行二维码呼出
- (void)CameroIsReady
{
    MBProgressHUD * hud = [MBProgressHUD showCustomLoadingHUDInView:[UIApplication sharedApplication].keyWindow withTitle:@"准备扫描二维码"];
    
    __block BOOL hasPush = NO;
    __block NSInteger count = 0;
    
    NSDictionary * dict = @{@"function" : @"showQRCode"};
    [SAVORXAPI postWithURL:@"http://192.168.43.1:8080" parameters:dict success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        [hud hideAnimated:NO];
        if ([[result objectForKey:@"result"] integerValue] == 0) {
            ScanQRCodeViewController * scan = [[ScanQRCodeViewController alloc] init];
            scan.delegate = self;
            
            if (!hasPush) {
                hasPush = YES;
                [[Helper getRootNavigationController] pushViewController:scan animated:YES];
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        count++;
        if (count >= 2) {
            if (error.code == -1009 || error.code == -1001) {
                [hud hideAnimated:NO];
                [MBProgressHUD showTextHUDwithTitle:@"二维码呼出超时"];
            }else{
                [hud hideAnimated:NO];
                [MBProgressHUD showTextHUDwithTitle:@"二维码呼出失败"];
            }
        }
    }];
    
    NSString *hosturl = [NSString stringWithFormat:@"%@/command/execute/call-tdc", [GlobalData shared].callQRCodeURL];
    [SAVORXAPI getWithURL:hosturl parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        [hud hideAnimated:NO];
        NSInteger code = [result[@"code"] integerValue];
        if(code == 10000){
            ScanQRCodeViewController * scan = [[ScanQRCodeViewController alloc] init];
            scan.delegate = self;
            if (!hasPush) {
                hasPush = YES;
                [[Helper getRootNavigationController] pushViewController:scan animated:YES];
            }
        }
        //
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //
        count++;
        if (count >= 2) {
            if (error.code == -1009 || error.code == -1001) {
                [hud hideAnimated:NO];
                [MBProgressHUD showTextHUDwithTitle:@"二维码呼出超时"];
            }else{
                [hud hideAnimated:NO];
                [MBProgressHUD showTextHUDwithTitle:@"二维码呼出失败"];
            }
        }
    }];
}

#pragma mark -- QRCodeDidBindDelegate
- (void)QRCodeDidBindSuccessWithType:(QRResultType)type andWifiName:(NSString *)name
{
    if (type == QRResultTypeSuccess) {
        [MBProgressHUD showTextHUDwithTitle:BindSuccessStr];
        [self checkTopViewController];
    }else if (type == QRResultTypeQRError){
        [MBProgressHUD showTextHUDwithTitle:@"连接失败，请扫描电视中的二维码"];
    }else if(type == QRResultTypeWIFIError) {
        [self showAlertWithWifiName:name];
    }
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
        [SAVORXAPI showAlertWithString:@"请前往手机设置，打开无线局域网，连接至与电视同一wifi下" withController:[Helper getRootNavigationController]];
    }
}

- (void)checkTopViewController
{
    UINavigationController * na = [Helper getRootNavigationController];
    NSArray * VCArray = na.viewControllers;
    NSString * classStr = NSStringFromClass([[VCArray objectAtIndex:VCArray.count - 2] class]);
    if ([classStr isEqualToString:@"SliderShowViewController"] ||
        [classStr isEqualToString:@"PhotoSliderViewController"]) {
        [na popToViewController:[VCArray objectAtIndex:VCArray.count - 3] animated:YES];
    }else if([classStr isEqualToString:@"WMPageController"]){
        WMPageController * wm = (WMPageController *)[VCArray objectAtIndex:VCArray.count - 2];
        [na popViewControllerAnimated:YES];
        [wm rightAction];
    }else{
        [na popViewControllerAnimated:YES];
    }
}

//测试后期可以去掉
- (IBAction)animationStart:(id)sender {
    
    if (self.currentVC) {
        [[Helper getRootNavigationController] pushViewController:self.currentVC animated:YES];
    }else if ([GlobalData shared].isBindDLNA || [GlobalData shared].isBindRD) {
        UINavigationController * na = [Helper getRootNavigationController];
        if ([na.topViewController isKindOfClass:[WMPageController class]]) {
            WMPageController * wm = (WMPageController *)na.topViewController;
            [wm rightAction];
        }
    }else{
        [self scanQRCode];
    }
}

- (void)showAlertWithWifiName:(NSString *)name
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight)];
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7f];
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    UIView * showView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 238)];
    showView.backgroundColor = [UIColor whiteColor];
    showView.center = view.center;
    [view addSubview:showView];
    showView.layer.cornerRadius = 8.f;
    showView.layer.masksToBounds = YES;
    
    UILabel * label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 59)];
    label1.backgroundColor = UIColorFromRGB(0xeeeeee);
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text = @"连接失败";
    label1.font = [UIFont systemFontOfSize:18];
    [showView addSubview:label1];
    
    UILabel * label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, 300, 20)];
    label2.textColor = UIColorFromRGB(0x222222);
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"请将wifi连接至";
    label2.font = [UIFont systemFontOfSize:17];
    [showView addSubview:label2];
    
    UILabel * label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 112, 300, 20)];
    label3.textColor = UIColorFromRGB(0x222222);
    label3.textAlignment = NSTextAlignmentCenter;
    if (name.length > 0) {
        label3.text = name;
    }else{
        label3.text = @"电视所在Wi-Fi";
    }
    label3.font = [UIFont boldSystemFontOfSize:20];
    [showView addSubview:label3];
    
    UILabel * label4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, 300, 20)];
    label4.textColor = UIColorFromRGB(0x8888888);
    label4.textAlignment = NSTextAlignmentCenter;
    label4.text = @"手机与电视连接wifi不一致，请切换后重试";
    label4.font = [UIFont systemFontOfSize:14];
    [showView addSubview:label4];
    
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0, 189, 300, 49)];
    [button setTitleColor:UIColorFromRGB(0xc9b067) forState:UIControlStateNormal];
    [button setTitle:@"我知道了" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [button addTarget:view action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderWidth = .5f;
    button.layer.borderColor = UIColorFromRGB(0xe8e8e8).CGColor;
    [showView addSubview:button];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
