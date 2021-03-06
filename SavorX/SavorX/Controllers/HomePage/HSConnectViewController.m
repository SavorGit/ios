//
//  HSConnectViewController.m
//  SavorX
//
//  Created by 郭春城 on 17/3/21.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSConnectViewController.h"
#import "RDBoxModel.h"
#import "RDKeyBoard.h"
#import "HelpViewController.h"
#import "RDInteractionLoadingView.h"

@interface HSConnectViewController ()<RDKeyBoradDelegate>

@property (nonatomic, strong) NSMutableArray * labelSource;
@property (nonatomic, copy) NSString *numSring;
@property (nonatomic, strong) NSMutableString *keyMuSring;
@property (nonatomic, strong) UILabel * textLabel;
@property (nonatomic, strong) UILabel * failConectLabel;
@property (nonatomic, strong) UIButton *reConnectBtn;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UILabel * wifiLabel;
@property (nonatomic, strong) UIView * topAlert;

@property (nonatomic, strong) RDInteractionLoadingView *maskingView;
//@property (nonatomic, strong) UIImageView *animationImageView;

@end

@implementation HSConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGB(0x922c3e);
    self.labelSource = [NSMutableArray new];
    self.numSring = [[NSString alloc] init];
    self.keyMuSring = [[NSMutableString alloc] initWithCapacity:100];
   [self setupViews];
    
//    //监听程序进入活跃状态
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [SAVORXAPI postUMHandleWithContentId:@"link_tv_enter" key:nil value:nil];
    
}

- (void)setupViews
{
    self.title = RDLocalizedString(@"RDString_ConnetToTV");
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor clearColor];
    bgView.userInteractionEnabled = YES;
    [bgView setImage:[UIImage imageNamed:@"ljds_bg"]];
    bgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.equalTo(bgView.mas_width).multipliedBy(299.f/414.f);
    }];
    
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(navBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kStatusBarHeight);
        make.left.mas_equalTo(0);
        make.height.width.mas_equalTo(50);
    }];
    
    self.wifiLabel = [[UILabel alloc] init];
    self.wifiLabel.textColor = UIColorFromRGB(0xece6de);
    self.wifiLabel.font = kPingFangLight(16);
    self.wifiLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:self.wifiLabel];
    [self.wifiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo([Helper autoHeightWith:50]);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(20);
        make.width.mas_lessThanOrEqualTo([Helper autoWidthWith:210]);
    }];
    self.wifiLabel.text = [NSString stringWithFormat:@"%@wifi:%@", RDLocalizedString(@"RDString_ScreenContinuePre"), [Helper getWifiName]];
    
    UIView * bottomView = [[UIView alloc] initWithFrame:CGRectZero];
    bottomView.backgroundColor = UIColorFromRGB(0x922c3e);
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgView.mas_bottom);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
    }];
    
    for (NSInteger i = 0; i < 3; i++) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.masksToBounds = YES;
        label.backgroundColor = UIColorFromRGB(0xece6de);
        label.textColor = kThemeColor;
        label.font = [UIFont boldSystemFontOfSize:30];
        [bottomView addSubview:label];
        float distance = [Helper autoWidthWith:110];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo([Helper autoHeightWith:15]);
            make.size.mas_equalTo(CGSizeMake([Helper autoWidthWith:60],[Helper autoWidthWith:60]));
            if (i == 0) {
                make.centerX.mas_equalTo(-distance);
            }else if (i == 1) {
                make.centerX.mas_equalTo(0);
            }else{
                make.centerX.mas_equalTo(distance);
            }
        }];
        [self.labelSource addObject:label];
    }
    
    self.topAlert = [[UIView alloc] init];
    self.topAlert.layer.borderColor = UIColorFromRGB(0xca8c3b).CGColor;
    self.topAlert.layer.borderWidth = [Helper autoWidthWith:2.5];
    [bottomView addSubview:self.topAlert];
    [self.topAlert mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo([Helper autoHeightWith:15-2.5]);
        make.size.mas_equalTo(CGSizeMake([Helper autoWidthWith:65],[Helper autoWidthWith:65]));
        make.centerX.mas_equalTo(-[Helper autoWidthWith:110]);
    }];
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    if (kMainBoundsHeight == 568) {
        self.textLabel.font = kPingFangLight(15);
    }else{
        self.textLabel.font = kPingFangLight(16);
    }
    self.textLabel.text = RDLocalizedString(@"RDString_PleaseInputNum");
    self.textLabel.textColor = UIColorFromRGB(0xece6de);
    self.textLabel.backgroundColor = [UIColor clearColor];
    [bottomView addSubview:self.textLabel];
    self.textLabel.hidden = NO;
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake([Helper autoWidthWith:kMainBoundsWidth - 40] ,[Helper autoHeightWith:30] ));
        make.top.mas_equalTo([Helper autoHeightWith:95]);
        
        make.centerX.mas_equalTo(bgView);
    }];
    
    self.failConectLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.failConectLabel.textAlignment = NSTextAlignmentRight;
    if (kMainBoundsHeight == 568) {
        self.failConectLabel.font = kPingFangLight(15);
    }else{
        self.failConectLabel.font = kPingFangLight(16);
    }
    self.failConectLabel.backgroundColor = [UIColor clearColor];
    self.failConectLabel.text = [RDLocalizedString(@"RDString_FailedWithConnect") stringByAppendingString:@"，"];
    self.failConectLabel.textColor = UIColorFromRGB(0xece6de);
    [bottomView addSubview:self.failConectLabel];
    self.failConectLabel.hidden = YES;
    [self.failConectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (kMainBoundsHeight == 568) {
            make.centerX.mas_equalTo(-40);
            make.top.mas_equalTo([Helper autoHeightWith:100]);
            make.size.mas_equalTo(CGSizeMake([Helper autoWidthWith:90], [Helper autoHeightWith:20]));
        }else{
            make.centerX.mas_equalTo(-50);
            make.top.mas_equalTo([Helper autoHeightWith:100]);
            make.size.mas_equalTo(CGSizeMake([Helper autoWidthWith:100], [Helper autoHeightWith:20]));
        }
    }];
    
    self.reConnectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.reConnectBtn.backgroundColor = [UIColor clearColor];
    self.reConnectBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.reConnectBtn setTitleColor:UIColorFromRGB(0xece6de) forState:UIControlStateNormal];
    if (kMainBoundsHeight == 568) {
        self.reConnectBtn.titleLabel.font = kPingFangLight(15);
    }else{
        self.reConnectBtn.titleLabel.font = kPingFangLight(16);
    }
    [self.reConnectBtn setTitle:[RDLocalizedString(@"RDString_Reconnect") stringByAppendingString:@"？"] forState:UIControlStateNormal];;
    [self.reConnectBtn addTarget:self action:@selector(reClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:self.reConnectBtn];
    self.reConnectBtn.hidden = YES;
    [self.reConnectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (kMainBoundsHeight == 568) {
            make.centerX.mas_equalTo(40);
            make.top.mas_equalTo([Helper autoHeightWith:100]);
            make.size.mas_equalTo(CGSizeMake([Helper autoWidthWith:90], [Helper autoHeightWith:20]));
        }else{
            make.centerX.mas_equalTo(45);
            make.top.mas_equalTo([Helper autoHeightWith:100]);
            make.size.mas_equalTo(CGSizeMake(80, [Helper autoHeightWith:20]));
        }
    }];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = UIColorFromRGB(0xece6de);
    [bottomView addSubview:self.lineView];
    self.lineView.hidden = YES;
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (kMainBoundsHeight == 568) {
            make.centerX.mas_equalTo(37);
            make.top.mas_equalTo(self.reConnectBtn.mas_bottom).offset(0);
            make.size.mas_equalTo(CGSizeMake([Helper autoWidthWith:80], 1));
        }else{
            make.centerX.mas_equalTo(42);
            make.top.mas_equalTo(self.reConnectBtn.mas_bottom).offset(0);
            make.size.mas_equalTo(CGSizeMake(72, 1));
        }
    }];

    
    RDKeyBoard *keyBoard;
    keyBoard = [[RDKeyBoard alloc] initWithHeight:[Helper autoHeightWith:240] inView:self.view];
    if ([GlobalData shared].isIphoneX) {
        [keyBoard mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-34);
        }];
    }
    keyBoard.delegate = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_bangzhu"] style:UIBarButtonItemStyleDone target:self action:@selector(shouldPushHelp)];
    
}

- (void)shouldPushHelp
{
    HelpViewController * help = [[HelpViewController alloc] initWithURL:@"http://h5.littlehotspot.com/Public/html/help/helptwo.html"];
    help.title = RDLocalizedString(@"RDString_HelpForConnect");
    [self.navigationController  pushViewController:help  animated:YES];
    [SAVORXAPI postUMHandleWithContentId:@"link_tv_help" key:nil value:nil];
}

// 重新连接
- (void)reClick{
    [self getBoxInfo];
    [self creatMaskingLoadingView];
}

- (void)creatMaskingLoadingView{
    
    self.maskingView = [[RDInteractionLoadingView alloc] initWithView:[UIApplication sharedApplication].keyWindow title:[RDLocalizedString(@"RDString_Connecting") stringByAppendingString:@"..."]];
    
//    self.maskingView = [[UIView alloc] initWithFrame:CGRectZero];
//    self.maskingView.backgroundColor = [UIColor blackColor];
//    
//    UIWindow *keyWindow = [[[UIApplication sharedApplication] windows] lastObject];
//    self.maskingView.frame = keyWindow.bounds;
//    self.maskingView.bottom = keyWindow.top;
//    [keyWindow addSubview:self.maskingView];
//    [self showViewWithAnimationDuration:0.0];
//    
//    UIImageView *smallWindowView = [[UIImageView alloc] initWithFrame:CGRectZero];
//    [smallWindowView setImage:[UIImage imageNamed:@"lianjie_bg"]];
//    [self.maskingView addSubview:smallWindowView];
//    [smallWindowView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake([Helper autoWidthWith:190],[Helper autoHeightWith:160]));
//        make.centerX.mas_equalTo(self.maskingView);
//        make.centerY.mas_equalTo(self.maskingView);
//    }];
//    
//    self.  = [[UIImageView alloc] initWithFrame:CGRectZero];
//    self.animationImageView.backgroundColor = [UIColor clearColor];
//    [smallWindowView addSubview:self.animationImageView];
//    [self.animationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake([Helper autoWidthWith:80],[Helper autoHeightWith:20]));
//        make.bottom.mas_equalTo(smallWindowView.mas_bottom).offset(- 20);
//        make.centerX.mas_equalTo(self.maskingView);
//    }];
//    
//    // 播放一组图片，设置一共有多少张图片生成的动画
//    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:0];
//    for (int i = 1; i < 4; i++) {
//        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"connecting%d.png", i]];
//        [imageArray addObject:image];
//    }
//    self.animationImageView.animationImages = imageArray;
//    self.animationImageView.animationDuration = 0.5;
//    self.animationImageView.animationRepeatCount = 10000;
//    [self.animationImageView startAnimating];
//    

}

////程序进入活跃状态
//- (void)applicationWillActive
//{
//    if (self.animationImageView) {
//        [self.animationImageView startAnimating];
//    }
//}

- (void)hidenMaskingLoadingView{
    
    [self.maskingView hidden];
//    [self.animationImageView stopAnimating];
    
}
//#pragma mark - show view
//-(void)showViewWithAnimationDuration:(float)duration{
//    
//    [UIView animateWithDuration:duration animations:^{
//        self.maskingView.backgroundColor = RGBA(0, 0, 0, 0.7);
//        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
//        self.maskingView.bottom = keyWindow.bottom;
//    } completion:^(BOOL finished) {
//    }];
//}

- (void)RDKeyBoradViewDidClickedWith:(NSString *)str isDelete:(BOOL)isDelete{
    
    if (isDelete == YES ) {
        if (self.keyMuSring.length >= 1) {
            [self.keyMuSring deleteCharactersInRange:NSMakeRange(self.keyMuSring.length - 1,1)];
        }else{
            return;
        }
    }else{
        [self.keyMuSring appendString:str];
    }
    
    NSString * number = self.keyMuSring;
    
    if (number.length == self.labelSource.count) {
        self.numSring = number;
        [self getBoxInfo];
        [self creatMaskingLoadingView];
    }else if (number.length > self.labelSource.count) {
        [self.keyMuSring deleteCharactersInRange:NSMakeRange(3, number.length - 3)];
    }else{
        float distance = [Helper autoWidthWith:110];
        switch (number.length) {
            case 0:
            {
                [self.topAlert mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(-distance);
                }];
            }
                
                break;
                
            case 1:
            {
                [self.topAlert mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(0);
                }];
            }
                
                break;
                
            case 2:
            {
                [self.topAlert mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(distance);
                }];
            }
                
                break;
                
            default:
                break;
        }
        [UIView animateWithDuration:.1f animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    
    for (NSUInteger i = 0; i < self.labelSource.count; i++) {
        if (i < number.length) {
            UILabel * label = [self.labelSource objectAtIndex:i];
            label.text = [number substringWithRange:NSMakeRange(i, 1)];
        }else{
            UILabel * label = [self.labelSource objectAtIndex:i];
            label.text = @"";
        }
        if (self.numSring.length == 3 && number.length == 2) {
            self.failConectLabel.hidden = YES;
            self.reConnectBtn.hidden = YES;
            self.lineView.hidden = YES;
            self.textLabel.hidden = NO;
            self.numSring = @"";
            self.textLabel.text = RDLocalizedString(@"RDString_PleaseInputNum");
        }
    }
}

- (void)getBoxInfo
{
    __block NSInteger hasFailure = 0; //记录失败的次数
    
    __block BOOL ssidIsNull = NO;
    
    NSString *platformUrl = [NSString stringWithFormat:@"%@/command/box-info/%@", [GlobalData shared].callQRCodeURL, self.numSring];
    
    [SAVORXAPI getWithURL:platformUrl parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        
        NSInteger code = [[result objectForKey:@"code"] integerValue];
        if (code == 10000) {
            if ([GlobalData shared].isBindRD) {
                return;
            }
            
            NSDictionary * realResult = [result objectForKey:@"result"];
            if (isEmptyString([realResult objectForKey:@"ssid"])) {
                ssidIsNull = YES;
                hasFailure += 1;
                if (hasFailure < 4) {
                    
                }else{
                    [self showAlertWithWifiName:@""];
                    [self bindSuccessStatus];
                }
                return;
            }
            
            [self getBoxInfoWithResult:realResult];
        }else{
            
            hasFailure += 1;
            if (hasFailure < 4) {
                return;
            }else if (ssidIsNull) {
                [self showAlertWithWifiName:@""];
                [self bindSuccessStatus];
                return;
            }
            
            [MBProgressHUD showTextHUDwithTitle:[result objectForKey:@"msg"] delay:1.5f];
            self.textLabel.text = [result objectForKey:@"msg"];
        }
        [self bindSuccessStatus];
        [SAVORXAPI postUMHandleWithContentId:@"link_tv_input_num" key:@"link_tv_input_num" value:@"success"];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        hasFailure += 1;
        if (hasFailure < 4) {
            return;
        }else if (ssidIsNull) {
            [self showAlertWithWifiName:@""];
        }else{
            [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FailedWithConnect") delay:1.5f];
        }
        
        [self bindFaildStatus];
        [SAVORXAPI postUMHandleWithContentId:@"link_tv_input_num" key:@"link_tv_input_num" value:@"fail"];
        
    }];
    
    NSString *hosturl = [NSString stringWithFormat:@"%@/command/box-info/%@", [GlobalData shared].secondCallCodeURL, self.numSring];
    
    [SAVORXAPI getWithURL:hosturl parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        
        NSInteger code = [[result objectForKey:@"code"] integerValue];
        if (code == 10000) {
            
            if ([GlobalData shared].isBindRD) {
                return;
            }
            
            NSDictionary * realResult = [result objectForKey:@"result"];
            if (isEmptyString([realResult objectForKey:@"ssid"])) {
                ssidIsNull = YES;
                hasFailure += 1;
                if (hasFailure < 4) {
                    
                }else{
                    [self showAlertWithWifiName:@""];
                    [self bindSuccessStatus];
                }
                return;
            }
            
            [self getBoxInfoWithResult:realResult];
        }else{
            
            hasFailure += 1;
            if (hasFailure < 4) {
                return;
            }else if (ssidIsNull) {
                [self showAlertWithWifiName:@""];
                [self bindSuccessStatus];
                return;
            }
            
            [MBProgressHUD showTextHUDwithTitle:[result objectForKey:@"msg"] delay:1.5f];
            self.textLabel.text = [result objectForKey:@"msg"];
        }
        
        [self bindSuccessStatus];
        [SAVORXAPI postUMHandleWithContentId:@"link_tv_input_num" key:@"link_tv_input_num" value:@"success"];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        hasFailure += 1;
        if (hasFailure < 4) {
            return;
        }else if (ssidIsNull) {
            [self showAlertWithWifiName:@""];
        }else{
            [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FailedWithConnect") delay:1.5f];
        }
        
        [self bindFaildStatus];
        [SAVORXAPI postUMHandleWithContentId:@"link_tv_input_num" key:@"link_tv_input_num" value:@"fail"];
        
    }];
    
    NSString *boxPlatformURL = [NSString stringWithFormat:@"%@/command/box-info/%@", [GlobalData shared].thirdCallCodeURL, self.numSring];
    
    [SAVORXAPI getWithURL:boxPlatformURL parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        
        NSInteger code = [[result objectForKey:@"code"] integerValue];
        if (code == 10000) {
            
            if ([GlobalData shared].isBindRD) {
                return;
            }
            
            NSDictionary * realResult = [result objectForKey:@"result"];
            if (isEmptyString([realResult objectForKey:@"ssid"])) {
                ssidIsNull = YES;
                hasFailure += 1;
                if (hasFailure < 4) {
                    
                }else{
                    [self showAlertWithWifiName:@""];
                    [self bindSuccessStatus];
                }
                return;
            }
            
            [self getBoxInfoWithResult:realResult];
        }else{
            
            hasFailure += 1;
            if (hasFailure < 4) {
                return;
            }else if (ssidIsNull) {
                [self showAlertWithWifiName:@""];
                [self bindSuccessStatus];
                return;
            }
            
            [MBProgressHUD showTextHUDwithTitle:[result objectForKey:@"msg"] delay:1.5f];
            self.textLabel.text = [result objectForKey:@"msg"];
        }
        
        [self bindSuccessStatus];
        [SAVORXAPI postUMHandleWithContentId:@"link_tv_input_num" key:@"link_tv_input_num" value:@"success"];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        hasFailure += 1;
        if (hasFailure < 4) {
            return;
        }else if (ssidIsNull) {
            [self showAlertWithWifiName:@""];
        }else{
            [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FailedWithConnect") delay:1.5f];
        }
        
        [self bindFaildStatus];
        [SAVORXAPI postUMHandleWithContentId:@"link_tv_input_num" key:@"link_tv_input_num" value:@"fail"];
        
    }];
    
    NSString *boxURL = [NSString stringWithFormat:@"%@/verify?code=%@&deviceId=%@", [GlobalData shared].boxCodeURL, self.numSring, [GlobalData shared].deviceID];
    
    [SAVORXAPI getWithURL:boxURL parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        
        NSInteger code = [[result objectForKey:@"code"] integerValue];
        if (code == 10000) {
            
            if ([GlobalData shared].isBindRD) {
                return;
            }
            
            NSDictionary * realResult = [result objectForKey:@"result"];
            
            [self getBoxInfoWithResult:realResult];
        }else{
            
            hasFailure += 1;
            if (hasFailure < 4) {
                return;
            }
            
            [MBProgressHUD showTextHUDwithTitle:[result objectForKey:@"msg"] delay:1.5f];
            self.textLabel.text = [result objectForKey:@"msg"];
        }
        
        [self bindSuccessStatus];
        [SAVORXAPI postUMHandleWithContentId:@"link_tv_input_num" key:@"link_tv_input_num" value:@"success"];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        hasFailure += 1;
        if (hasFailure < 4) {
            return;
        }
        
        [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FailedWithConnect") delay:1.5f];
        [self bindFaildStatus];
        [SAVORXAPI postUMHandleWithContentId:@"link_tv_input_num" key:@"link_tv_input_num" value:@"fail"];
        
    }];
}

- (void)bindSuccessStatus
{
    [self hidenMaskingLoadingView];
    self.failConectLabel.hidden = YES;
    self.reConnectBtn.hidden = YES;
    self.lineView.hidden = YES;
    self.textLabel.hidden = NO;
}

- (void)bindFaildStatus
{
    [self hidenMaskingLoadingView];
    self.failConectLabel.hidden = NO;
    self.reConnectBtn.hidden = NO;
    self.lineView.hidden = NO;
    self.textLabel.hidden = YES;
}

- (void)navBackButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [SAVORXAPI postUMHandleWithContentId:@"link_tv_back" key:nil value:nil];
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
    label1.text = RDLocalizedString(@"RDString_FailedWithConnect");
    label1.font = [UIFont systemFontOfSize:18];
    [showView addSubview:label1];
    
    UILabel * label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, 300, 20)];
    label2.textColor = UIColorFromRGB(0x222222);
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = RDLocalizedString(@"RDSting_AlertWithTVWifiPre");
    label2.font = [UIFont systemFontOfSize:17];
    [showView addSubview:label2];
    
    UILabel * label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 112, 300, 22)];
    label3.textColor = UIColorFromRGB(0x222222);
    label3.textAlignment = NSTextAlignmentCenter;
    if (name.length > 0) {
        label3.text = name;
    }else{
        label3.text = RDLocalizedString(@"RDSting_AlertWithTVWifiSuf");
    }
    label3.font = [UIFont boldSystemFontOfSize:20];
    [showView addSubview:label3];
    
    UILabel * label4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, 300, 20)];
    label4.textColor = UIColorFromRGB(0x8888888);
    label4.textAlignment = NSTextAlignmentCenter;
    label4.text = RDLocalizedString(@"RDString_PleaseChangeWifi");
    label4.font = [UIFont systemFontOfSize:14];
    [showView addSubview:label4];
    
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0, 189, 300, 49)];
    [button setTitleColor:UIColorFromRGB(0xc9b067) forState:UIControlStateNormal];
    [button setTitle:RDLocalizedString(@"RDString_IKnewIt") forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [button addTarget:view action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderWidth = .5f;
    button.layer.borderColor = UIColorFromRGB(0xe8e8e8).CGColor;
    [showView addSubview:button];
}

- (void)getBoxInfoWithResult:(NSDictionary *)result
{
    RDBoxModel * model = [[RDBoxModel alloc] init];
    
    if ([HTTPServerManager checkHttpServerWithBoxIP:[result objectForKey:@"box_ip"]]) {
        model.BoxIP = [[result objectForKey:@"box_ip"] stringByAppendingString:@":8080"];
        model.BoxID = [result objectForKey:@"box_mac"];
        model.hotelID = [[result objectForKey:@"hotel_id"] integerValue];
        model.roomID = [[result objectForKey:@"room_id"] integerValue];
        model.sid = [result objectForKey:@"ssid"];
        if (![[result objectForKey:@"ssid"] isEqualToString:[Helper getWifiName]]){
            [GlobalData shared].cacheModel = model;
            [self showAlertWithWifiName:[result objectForKey:@"ssid"]];
            [SAVORXAPI postUMHandleWithContentId:@"link_tv_wifi_prompt" key:@"link_tv_wifi_prompt" value:@"ensure"];
        }else{
            [[GlobalData shared] bindToRDBoxDevice:model];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if (![[result objectForKey:@"ssid"] isEqualToString:[Helper getWifiName]]) {
        model.BoxIP = [[result objectForKey:@"box_ip"] stringByAppendingString:@":8080"];
        model.BoxID = [result objectForKey:@"box_mac"];
        model.hotelID = [[result objectForKey:@"hotel_id"] integerValue];
        model.roomID = [[result objectForKey:@"room_id"] integerValue];
        model.sid = [result objectForKey:@"ssid"];
        [GlobalData shared].cacheModel = model;
        [self showAlertWithWifiName:[result objectForKey:@"ssid"]];
    }else{
        [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FailedWithConnect") delay:1.5f];
        [self bindFaildStatus];
        [SAVORXAPI postUMHandleWithContentId:@"link_tv_input_num" key:@"link_tv_input_num" value:@"fail"];
    }
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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
