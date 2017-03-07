//
//  ScanQRCodeViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/8/4.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "ScanQRCodeViewController.h"
#import "GCCCodeScanning.h"
#import "VideoGuidedTwoDimensionalCode.h"

@interface ScanQRCodeViewController ()<GCCCodeScanningDelegate>

@property (nonatomic, strong) GCCCodeScanning * scan; //扫描二维码控件

@end

@implementation ScanQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"扫一扫";
    
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.hidden = NO;
    [MBProgressHUD showLoadingHUDInView:self.view];
    [self createUI];
    
//    [self.scan stop];
//    VideoGuidedTwoDimensionalCode *vgVC = [[VideoGuidedTwoDimensionalCode alloc] init];
//    [vgVC showScreenProjectionTitle:@"扫码引导" block:^(NSInteger selectIndex) {
//        [self.scan start];
//    }];
}

- (void)createUI
{
    self.scan = [[GCCCodeScanning alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - NavHeight) andScanViewFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 2 / 3, [UIScreen mainScreen].bounds.size.width * 2 / 3)];
    self.scan.delegate = self;
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [self.view addSubview:self.scan];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationRestart) name:UIApplicationDidBecomeActiveNotification object:nil];
}

/**
 *  扫描到二维码之后的代理回调
 *
 *  @param value 扫描到的结果信息
 */
- (void)GCCCodeScanningSuccessGetSomeInfo:(NSString *)value
{
    MBProgressHUD * HUD = [MBProgressHUD showCustomLoadingHUDInView:self.view];
    
    //停止扫描
    [self.scan stop];
    
    if (![HTTPServerManager checkHttpServerIsWifi]) {
        //如果不是wifi环境
        [HUD hideAnimated:YES];
        [MBProgressHUD showTextHUDwithTitle:@"请先连接wifi再进行操作"];
        [HUD hideAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    value = [value componentsSeparatedByString:@"?"].lastObject;
    NSArray * array = [value componentsSeparatedByString:@"="];
    
    if (array.count == 1) {
        if (_delegate && [_delegate respondsToSelector:@selector(QRCodeDidBindSuccessWithType:andWifiName:)]) {
            [_delegate QRCodeDidBindSuccessWithType:QRResultTypeQRError andWifiName:nil];
        }
        [HUD hideAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if ([HTTPServerManager checkHttpServerWithBoxIP:[[value componentsSeparatedByString:@"="] objectAtIndex:1]]) {
        //如果和对应二维码设备处于同一网段
        NSArray * array = [value componentsSeparatedByString:@"&"];
        RDBoxModel * model = [[RDBoxModel alloc] init];
        for (NSInteger i = 0; i < array.count; i++) {
            NSArray * paramArray = [[array objectAtIndex:i] componentsSeparatedByString:@"="];
            if ([paramArray.firstObject isEqualToString:@"ip"]) {
                model.BoxIP = [paramArray.lastObject stringByAppendingString:@":8080"];
            }else if ([paramArray.firstObject isEqualToString:@"bid"]) {
                model.hotelID = [paramArray.lastObject integerValue];
            }else if ([paramArray.firstObject isEqualToString:@"rid"]) {
                model.roomID = [paramArray.lastObject integerValue];
            }else if ([paramArray.firstObject isEqualToString:@"sid"]) {
                model.sid = paramArray.lastObject;
                if (![model.sid isEqualToString:[Helper getWifiName]]) {
                    if (_delegate && [_delegate respondsToSelector:@selector(QRCodeDidBindSuccessWithType:andWifiName:)]) {
                        [_delegate QRCodeDidBindSuccessWithType:QRResultTypeWIFIError andWifiName:model.sid];
                    }
                    [HUD hideAnimated:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                    return;
                }
            }
        }
        
        [[GlobalData shared] bindToRDBoxDevice:model];
        if (self.playView) {
            [self.playView shouldRelease];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(QRCodeDidBindSuccessWithType:andWifiName:)]) {
            [_delegate QRCodeDidBindSuccessWithType:QRResultTypeSuccess andWifiName:nil];
        }
        
        [HUD hideAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }else {
        
        //如果和对应二维码设备不处于同一网段
        NSArray * array = [value componentsSeparatedByString:@"&"];
        RDBoxModel * model = [[RDBoxModel alloc] init];
        for (NSInteger i = 0; i < array.count; i++) {
            NSArray * paramArray = [[array objectAtIndex:i] componentsSeparatedByString:@"="];
            if ([paramArray.firstObject isEqualToString:@"ip"]) {
                model.BoxIP = [paramArray.lastObject stringByAppendingString:@":8080"];
            }else if ([paramArray.firstObject isEqualToString:@"bId"]) {
                model.hotelID = [paramArray.lastObject integerValue];
            }else if ([paramArray.firstObject isEqualToString:@"rId"]) {
                model.roomID = [paramArray.lastObject integerValue];
            }else if ([paramArray.firstObject isEqualToString:@"sid"]) {
                model.sid = paramArray.lastObject;
                if (![model.sid isEqualToString:[Helper getWifiName]]) {
                    if (_delegate && [_delegate respondsToSelector:@selector(QRCodeDidBindSuccessWithType:andWifiName:)]) {
                        [_delegate QRCodeDidBindSuccessWithType:QRResultTypeWIFIError andWifiName:model.sid];
                    }
                    [HUD hideAnimated:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                    return;
                }
            }
        }
        if (_delegate && [_delegate respondsToSelector:@selector(QRCodeDidBindSuccessWithType:andWifiName:)]) {
            [_delegate QRCodeDidBindSuccessWithType:QRResultTypeQRError andWifiName:nil];
        }
        [HUD hideAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//开始动画效果
- (void)animationRestart
{
    [self.scan start];
}

//释放时移除监听
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
