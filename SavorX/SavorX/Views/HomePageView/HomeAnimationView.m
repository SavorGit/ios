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
#import "WMPageController.h"
#import "PhotoSliderViewController.h"
#import "SXVideoPlayViewController.h"
#import "DemandViewController.h"
#import "UIImage+Additional.h"
#import "RDAlertView.h"
#import "RDCheackSence.h"
#import "GCCDLNA.h"

#define HasAlertScreen @"HasAlertScreen"

@interface HomeAnimationView ()<QRCodeDidBindDelegate>
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
        view.textLabel.text = @"投屏中...";
        view.textLabel.font = [UIFont systemFontOfSize:12];
        view.textLabel.textColor = UIColorFromRGB(0xf5f5f5);
        view.textLabel.backgroundColor = [UIColor clearColor];
        view.textLabel.textAlignment = NSTextAlignmentCenter;
        [view addSubview:view.textLabel];
        CGFloat textLabelWidth = [Helper autoWidthWith:145.f];
        CGFloat textLabelHeight = [Helper autoHeightWith:23.f];
        CGFloat textLabTopDistance = [Helper autoHeightWith:84.f];
        [view.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(textLabelWidth, textLabelHeight));
            make.top.mas_equalTo(textLabTopDistance);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
        
        CGFloat devImageWidth = [Helper autoWidthWith:145.f];
        CGFloat devImageHeight = [Helper autoHeightWith:79.f];
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
    
    [self.devImageView setImage:self.currentImage];
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

    CGAffineTransform transform;
    transform = CGAffineTransformMakeTranslation(140.0,0.0);
    [UIView animateWithDuration:.5f animations:^{
        self.transform = transform;
        NSLog(@"---我要退出投屏了---。。。");
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
        [page disconnentClick];
        return;
    }
    
    if (![GlobalData shared].isWifiStatus) {
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
    
    if ([GlobalData shared].isWifiStatus) {
        //判断用户当前是否允许小热点使用相机权限
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
    
    NSString *hosturl = [NSString stringWithFormat:@"%@/command/execute/call-tdc", [GlobalData shared].callQRCodeURL];
    [SAVORXAPI getWithURL:hosturl parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        [hud hideAnimated:NO];
        NSInteger code = [result[@"code"] integerValue];
        if(code == 10000){
            ScanQRCodeViewController * scan = [[ScanQRCodeViewController alloc] init];
            scan.delegate = self;
            self.isFirstCount++;
            if (self.isFirstCount == 1) {
                scan.isHelp = YES;
            }else{
                scan.isHelp = NO;
            }
            [[Helper getRootNavigationController] pushViewController:scan animated:YES];
        }
        //
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //
        if (error.code == -1009 || error.code == -1001) {
            [hud hideAnimated:NO];
            [MBProgressHUD showTextHUDwithTitle:@"二维码呼出超时"];
        }else{
            [hud hideAnimated:NO];
            [MBProgressHUD showTextHUDwithTitle:@"二维码呼出失败"];
        }
    }];
}

// 重新呼出二维码
- (void)reCallCode{
    
    MBProgressHUD * hud = [MBProgressHUD showCustomLoadingHUDInView:[UIApplication sharedApplication].keyWindow withTitle:@"准备扫描二维码"];
    
    NSString *hosturl = [NSString stringWithFormat:@"%@/command/execute/call-tdc", [GlobalData shared].callQRCodeURL];
    [SAVORXAPI getWithURL:hosturl parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        [hud hideAnimated:NO];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //
        if (error.code == -1009 || error.code == -1001) {
            [hud hideAnimated:NO];
            [MBProgressHUD showTextHUDwithTitle:@"二维码呼出超时"];
        }else{
            [hud hideAnimated:NO];
            [MBProgressHUD showTextHUDwithTitle:@"二维码呼出失败"];
        }
    }];
    
}

#pragma mark -- QRCodeDidBindDelegate
- (void)QRCodeDidBindSuccessWithType:(QRResultType)type andWifiName:(NSString *)name
{
    if (type == QRResultTypeSuccess) {
        
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
        RDAlertView * alert = [[RDAlertView alloc] initWithTitle:@"提示" message:@"请前往手机设置，打开无线局域网，连接至与电视同一wifi下"];
        RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"我知道了" handler:^{
            
        } bold:YES];
        [alert addActions:@[action]];
        [alert show];
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
    view.tag = 422;
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
