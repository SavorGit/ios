 //
//  DemandViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/8/10.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "DemandViewController.h"
#import "UMCustomSocialManager.h"
#import "GCCUPnPManager.h"
#import "UIImageView+WebCache.h"
#import "HomeAnimationView.h"

#import "WebViewController.h"
#import "WMPageController.h"
#import "HSVideoViewController.h"

#define BOTTOMHEIGHT 50.f

@interface DemandViewController ()<UIWebViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIWebView * webView; //加载Html网页视图
@property (nonatomic, strong) UIView *playBackView; //播放空间的背景View
@property (nonatomic, strong) UIButton *playBtn; //播放按钮
@property (nonatomic, strong) UILabel *minimumLabel; //最小时间显示
@property (nonatomic, strong) UISlider *playSilder; //进度条控制
@property (nonatomic, strong) UILabel *maximumLabel; //最大时间显示
@property (nonatomic, strong) NSTimer * timer; //轮询播放进度定时器
@property (nonatomic, assign) BOOL isPlayEnd; //当前是否处于播放结束状态
@property (nonatomic, strong) NSURLSessionDataTask * task; //记录当前请求任务
@property (nonatomic, assign) BOOL isHandle; //记录当前是否在进行操作
@property (nonatomic, strong) UIButton * volumeButton; //静音按钮
@property (nonatomic, strong) UIButton * screenButton;
@property (nonatomic, strong) UIButton * quitScreenButton;
@property (nonatomic, strong) UIImageView * backImageView;
@property (nonatomic, assign) NSInteger DLNAVolume;
@property (nonatomic, strong) UIButton * collectButton;
@property (nonatomic, strong) UIView *maskingView;

@end

@implementation DemandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
    [self setupDatas];
}

- (void)setupDatas
{
    if ([GlobalData shared].isBindDLNA) {
        self.DLNAVolume = 50;
        [[GCCUPnPManager defaultManager] getVolumeSuccess:^(NSInteger volume) {
            self.DLNAVolume = volume;
        } failure:^{
            
        }];
    }
}

//初始化界面
- (void)createUI
{
    self.view.backgroundColor = [UIColor blackColor];
    self.title = self.model.title;
    
    self.backImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.backImageView sd_setImageWithURL:[NSURL URLWithString:self.model.imageURL]];
    [self.view addSubview:self.backImageView];
    self.backImageView.userInteractionEnabled = YES;
    [self.backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.equalTo(self.view.mas_width).multipliedBy([UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height);
    }];
    
    UIView * playSliderView = [[UIView alloc] initWithFrame:CGRectZero];
    playSliderView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7f];
    [self.backImageView addSubview:playSliderView];
    [playSliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(35);
    }];
    
    self.playSilder = [[UISlider alloc] initWithFrame:CGRectZero];
    [self.playSilder setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
    self.playSilder.minimumValue = 0;
    self.playSilder.maximumValue = self.model.duration;
    [self.playSilder setMinimumTrackTintColor:FontColor];
    [self.playSilder setMaximumTrackTintColor:[UIColor colorWithHexString:@"#a2a7aa"]];
    [playSliderView addSubview:self.playSilder];
    [self.playSilder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(playSliderView);
        make.left.mas_equalTo(50);
        make.right.mas_equalTo(-50);
        make.height.mas_equalTo(20);
    }];
    
    self.minimumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.minimumLabel.font = [UIFont systemFontOfSize:12.f];
    self.minimumLabel.text = @"00:00";
    self.minimumLabel.textAlignment = NSTextAlignmentRight;
    self.minimumLabel.textColor = [UIColor whiteColor];
    [playSliderView addSubview:self.minimumLabel];
    [self.minimumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(40);
    }];
    
    self.maximumLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 45, 75, 45, 20)];
    self.maximumLabel.font = [UIFont systemFontOfSize:12.f];
    self.maximumLabel.textColor = [UIColor whiteColor];
    NSInteger pLayDurationInt = self.model.duration; // some duration from the JSON
    NSInteger playMinutesInt = pLayDurationInt / 60;
    NSInteger playSecondsInt = pLayDurationInt % 60;
    NSString *playTimeStr = [NSString stringWithFormat:@"%02ld:%02ld", (long)playMinutesInt, (long)playSecondsInt];
    self.maximumLabel.text = playTimeStr;
    self.maximumLabel.textAlignment = NSTextAlignmentLeft;
    [playSliderView addSubview:self.maximumLabel];
    [self.maximumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(-5);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(40);
    }];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton setAdjustsImageWhenHighlighted:NO];
    [backButton addTarget:self action:@selector(navBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    self.collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.collectButton setImage:[UIImage imageNamed:@"icon_collect"] forState:UIControlStateNormal];
    [self.collectButton setAdjustsImageWhenHighlighted:NO];
    [self.collectButton addTarget:self action:@selector(collectAciton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.collectButton];
    
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    [shareButton setAdjustsImageWhenHighlighted:NO];
    [shareButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
    
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.right.mas_equalTo(-10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [self.collectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.right.mas_equalTo(-60);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    self.screenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.screenButton setImage:[UIImage imageNamed:@"tv"] forState:UIControlStateNormal];
    [self.screenButton addTarget:self action:@selector(tvAciton) forControlEvents:UIControlEventTouchUpInside];
    self.screenButton.selected = YES;
    self.screenButton.hidden = YES;
    [self.view addSubview:self.screenButton];
    
    [self.screenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.right.mas_equalTo(-110);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    self.maskingView = [[UIView alloc] init];
    self.maskingView.backgroundColor = [UIColor blackColor];
    self.maskingView.alpha = 0.6;
    [self.backImageView addSubview:self.maskingView];
    [self.maskingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(-15);;
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.equalTo(self.view.mas_width).offset(- 20).multipliedBy([UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height) ;

    }];
    
    
    self.quitScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.quitScreenButton.backgroundColor = UIColorFromRGB(0xf1d897);
    self.quitScreenButton.alpha = 0.8;
    [self.quitScreenButton setTitle:@"退出投屏" forState:UIControlStateNormal];
    [self.quitScreenButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [self.quitScreenButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.quitScreenButton.layer.masksToBounds = YES;
    self.quitScreenButton.layer.cornerRadius = 5.0;
    self.quitScreenButton.layer.borderWidth = 1.0;
    self.quitScreenButton.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.quitScreenButton addTarget:self action:@selector(quitScreenAciton:) forControlEvents:UIControlEventTouchUpInside];
    self.quitScreenButton.selected = YES;
    [self.view addSubview:self.quitScreenButton];
    
    [self.quitScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(90, 32));
        make.centerX.equalTo(self.backImageView);
        make.centerY.equalTo(self.backImageView);
    }];
    
    [self createWebView];
    [self createBottomView];
    [self addBottomEvent];
    [self createTimer];
}

// 退出投屏
- (void)quitScreenAciton:(BOOL)fromHomeType{

    [SAVORXAPI ScreenDemandShouldBackToTVWithSuccess:^{
          
        self.isPlayEnd = YES;
        self.playBtn.selected = NO;
        [self updatePlayStatus];
        self.screenButton.enabled = YES;
        self.screenButton.hidden = NO;
        
        self.quitScreenButton.hidden = YES;
        self.maskingView.hidden = YES;
        
        [self.timer setFireDate:[NSDate distantFuture]];
        [self.timer invalidate];
        self.timer = nil;
        
        self.minimumLabel.text = @"00:00";
        self.playSilder.value = 0;
        
        [self quitBack];
        [SAVORXAPI postUMHandleWithContentId:@"bunch planting_page_exit_screen" key:nil value:nil];
        if (fromHomeType == YES) {
            [SAVORXAPI postUMHandleWithContentId:@"home_quick_back" key:@"home_quick_back" value:@"success"];
        }
        
    } failure:^{
        self.screenButton.enabled = YES;
        if (fromHomeType == YES) {
            [SAVORXAPI postUMHandleWithContentId:@"home_quick_back" key:@"home_quick_back" value:@"fail"];
        }
    }];

}

- (void)quitBack{
    
    if (!self.model.videoURL || !(self.model.videoURL.length > 0)) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
//    UINavigationController * na = [Helper getRootNavigationController];
//    int j = (int)na.viewControllers.count - 2;
//    if (j < 0) {
//        j = 0;
//    }
    
//    UIViewController * vc = na.viewControllers[j];
//    if ([vc  isKindOfClass:[WebViewController class]] ) {
////        [self.navigationController popToViewController:vc animated:YES];
//    }else if ([vc  isKindOfClass:[WMPageController class]]){
//        [self.navigationController popViewControllerAnimated:YES];
//    }
    
//    UIViewController * vc = na.viewControllers;
//    if ([vc  isKindOfClass:[WebViewController class]] ) {
//        [self.navigationController popToViewController:vc animated:YES];
//    }else if ([vc  isKindOfClass:[WMPageController class]]){
//        WebViewController *weVc = [[WebViewController alloc] init];
//        weVc.image = self.backImageView.image;
//        weVc.model = self.model;
//        weVc.isFormDemand = YES;
//        [self.navigationController pushViewController:weVc animated:YES];
//        weVc.coFromWebView = ^(NSDictionary *parmDic){
//            [self restartVod];
//        };
//    }
    
     [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)tvAciton
{
    [self restartVod];
}

//收藏按钮被点击触发
- (void)collectAciton:(UIButton *)button
{
    if (!self.model.contentURL || !(self.model.contentURL.length > 0)) {
        [MBProgressHUD showTextHUDwithTitle:@"该内容暂不支持收藏" delay:1.5f];
        return;
    }
    
    NSMutableArray *favoritesArray = [NSMutableArray array];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"MyFavorites"] isKindOfClass:[NSArray class]]) {
        favoritesArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyFavorites"]];
    }
    NSInteger contenId = self.model.cid;
    if (button.selected) {
        [favoritesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj objectForKey:@"contentURL"] isEqualToString:self.model.contentURL]) {
                [favoritesArray removeObject:obj];
                *stop = YES;
            }
        }];
        [SAVORXAPI postUMHandleWithContentId:self.model.cid withType:cancleCollectHandle];
        [MBProgressHUD showSuccessHUDInView:self.view title:@"取消成功"];
        [SAVORXAPI postUMHandleWithContentId:@"bunch planting_page_share_cancel_collection" key:@"bunch planting_page_share_cancel_collection" value:@"success"];
        [[NSUserDefaults standardUserDefaults] setObject:favoritesArray forKey:@"MyFavorites"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [button setSelected:NO];
        [button setImage:[UIImage imageNamed:@"icon_collect"] forState:UIControlStateNormal];
        [SAVORXAPI postUMHandleWithContentId:contenId withType:cancleCollectHandle];
    }else{
        [SAVORXAPI postUMHandleWithContentId:self.model.cid withType:collectHandle];
        [favoritesArray addObject:[self.model toDictionary]];
        [MBProgressHUD showSuccessHUDInView:self.view title:@"收藏成功"];
        [SAVORXAPI postUMHandleWithContentId:@"bunch planting_page_share_collection" key:@"bunch planting_page_share_collection" value:@"success"];
        [[NSUserDefaults standardUserDefaults] setObject:favoritesArray forKey:@"MyFavorites"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [button setSelected:YES];
        [button setImage:[UIImage imageNamed:@"icon_collect_yes"] forState:UIControlStateNormal];
        [SAVORXAPI postUMHandleWithContentId:contenId withType:collectHandle];
    }
}

//分享按钮被点击触发
- (void)shareAction:(UIButton *)button
{
    if (!self.model.contentURL || !(self.model.contentURL.length > 0)) {
        [MBProgressHUD showTextHUDwithTitle:@"该内容暂不支持分享" delay:1.5f];
        return;
    }
    
    [UMCustomSocialManager defaultManager].image = self.backImageView.image;
    [[UMCustomSocialManager defaultManager] showUMSocialSharedWithModel:self.model andController:self andType:1];
    [SAVORXAPI postUMHandleWithContentId:@"bunch planting_page_share" key:nil value:nil];
}

//创建浏览的webView
- (void)createWebView
{
    
    self.webView = [[UIWebView alloc] init];
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backImageView.mas_bottom);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-BOTTOMHEIGHT);
    }];
    self.webView.delegate = self;
    
    if (!self.model.contentURL || !(self.model.contentURL.length > 0)) {
        return;
    }
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[[self.model.contentURL stringByAppendingString:@"?location=newRead"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    [MBProgressHUD showWebLoadingHUDInView:self.webView];
}

//创建底部播放控制栏
- (void)createBottomView
{
    self.playBackView = [[UIView alloc] initWithFrame:CGRectMake(0, kMainBoundsHeight - BOTTOMHEIGHT, kMainBoundsWidth, BOTTOMHEIGHT)];
    self.playBackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7f];
    [self.view addSubview:self.playBackView];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setFrame:CGRectMake(0, 0, 40, 40)];
    self.playBtn.center = CGPointMake(kMainBoundsWidth / 8 * 7, 25);
    [self.playBtn setImage:[UIImage imageNamed:@"De_bofang"] forState:UIControlStateSelected];
    [self.playBtn setImage:[UIImage imageNamed:@"De_zanting"] forState:UIControlStateNormal];
    self.playBtn.selected = YES;
    [self.playBtn setImage:[UIImage imageNamed:@"De_bofang_g"] forState:UIControlStateHighlighted];
    [self updatePlayStatus];
    [self.playBtn setAdjustsImageWhenHighlighted:NO];
    [self.playBackView addSubview:self.playBtn];
    
    self.volumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.volumeButton setFrame:CGRectMake(0, 0, 40, 40)];
    self.volumeButton.center = CGPointMake(kMainBoundsWidth / 8 * 5, 25);
    [self.volumeButton setImage:[UIImage imageNamed:@"De_laba"] forState:UIControlStateSelected];
    [self.volumeButton setImage:[UIImage imageNamed:@"De_laba_g"] forState:UIControlStateNormal];
    [self.volumeButton setSelected:YES];
    [self.volumeButton setImage:[UIImage imageNamed:@"De_laba_g"] forState:UIControlStateHighlighted];
    self.volumeButton.tag = 101;
    [self.volumeButton addTarget:self action:@selector(voidelPlayVolumeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.volumeButton setAdjustsImageWhenHighlighted:NO];
    [self.playBackView addSubview:self.volumeButton];
    
    UIButton * volumeAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    [volumeAdd setFrame:CGRectMake(0, 0, 40, 40)];
    volumeAdd.center = CGPointMake(kMainBoundsWidth / 8 * 3, 25);
    [volumeAdd setImage:[UIImage imageNamed:@"De_voljia"] forState:UIControlStateNormal];
    [volumeAdd setImage:[UIImage imageNamed:@"De_voljia_g"] forState:UIControlStateHighlighted];
    volumeAdd.tag = 102;
    [volumeAdd addTarget:self action:@selector(voidelPlayVolumeAction:) forControlEvents:UIControlEventTouchUpInside];
    [volumeAdd setAdjustsImageWhenHighlighted:NO];
    [self.playBackView addSubview:volumeAdd];
    
    UIButton * volumeSmall = [UIButton buttonWithType:UIButtonTypeCustom];
    [volumeSmall setFrame:CGRectMake(0, 0, 40, 40)];
    volumeSmall.center = CGPointMake(kMainBoundsWidth / 8, 25);
    [volumeSmall setImage:[UIImage imageNamed:@"De_voljian"] forState:UIControlStateNormal];
    [volumeSmall setImage:[UIImage imageNamed:@"De_voljian_g"] forState:UIControlStateHighlighted];
    volumeSmall.tag = 103;
    [volumeSmall addTarget:self action:@selector(voidelPlayVolumeAction:) forControlEvents:UIControlEventTouchUpInside];
    [volumeSmall setAdjustsImageWhenHighlighted:NO];
    [self.playBackView addSubview:volumeSmall];
}

//添加底部控件相关用户交互动作响应
- (void)addBottomEvent
{
    [self.playBtn addTarget:self action:@selector(playBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.playSilder addTarget:self action:@selector(sliderValueChange) forControlEvents:UIControlEventValueChanged];
    [self.playSilder addTarget:self action:@selector(sliderStartTouch) forControlEvents:UIControlEventTouchDown];
    [self.playSilder addTarget:self action:@selector(sliderEndTouch) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
}

//创建定时器
- (void)createTimer
{
    self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateSiderValue) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

//更新当前播放进度
- (void)updateSiderValue
{
    if ([GlobalData shared].isBindRD) {
        if (self.task) {
            [self.task cancel];
        }
        
        [SAVORXAPI queryVideoWithURL:STBURL success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            NSInteger code = [[result objectForKey:@"result"] integerValue];
            if (code == 0) {
                CGFloat posFloat = [[result objectForKey:@"pos"] floatValue]/1000;
                [self.playSilder setValue:posFloat];
                [self updateTimeLabel:posFloat];
            }else if (code == -1 || code == 1){
                self.minimumLabel.text = @"00:00";
                self.playSilder.value = 0;
                self.isPlayEnd = YES;
                self.playBtn.selected = NO;
                [self updatePlayStatus];
                self.quitScreenButton.hidden = YES;
                self.maskingView.hidden = YES;
                self.screenButton.hidden = NO;
                self.screenButton.enabled = YES;
                [self.timer invalidate];
                self.timer = nil;
                [self quitBack];
                [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }else if ([GlobalData shared].isBindDLNA){
        [[GCCUPnPManager defaultManager] getPlayProgressSuccess:^(NSString *totalDuration, NSString *currentDuration, float progress) {
            if (progress >= 1 - 1 / self.playSilder.maximumValue) {
                self.minimumLabel.text = @"00:00";
                self.playSilder.value = 0;
                self.isPlayEnd = YES;
                self.playBtn.selected = NO;
                [self updatePlayStatus];
                self.quitScreenButton.hidden = YES;
                self.maskingView.hidden = YES;
                self.screenButton.hidden = NO;
                self.screenButton.enabled = YES;
                [self.timer invalidate];
                self.timer = nil;
                [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
            }else{
                CGFloat posFloat = [[GCCUPnPManager defaultManager] timeIntegerFromString:totalDuration] * progress;
                [self.playSilder setValue:posFloat];
                [self updateTimeLabel:posFloat];
                self.playBtn.selected = YES;
                [self updatePlayStatus];
            }
            
        } failure:^{
            
        }];
    }
}

- (void)updatePlayStatus
{
    if (self.playBtn.isSelected == YES) {
        [self.playBtn setImage:[UIImage imageNamed:@"De_bofang_g"] forState:UIControlStateNormal];
    }else if (self.playBtn.isSelected == NO){
        [self.playBtn setImage:[UIImage imageNamed:@"De_zanting_g"] forState:UIControlStateHighlighted];
        [self.playBtn setImage:[UIImage imageNamed:@"De_zanting"] forState:UIControlStateNormal];
        
    }
}

//根据进度条更新播放时间显示
- (void)updateTimeLabel:(CGFloat)posFloat
{
    if (posFloat > self.playSilder.maximumValue) {
        return;
    }
    
    NSInteger pLayDurationInt = (NSInteger)posFloat; // some duration from the JSON
    NSInteger playMinutesInt = pLayDurationInt / 60;
    NSInteger playSecondsInt = pLayDurationInt % 60;
    
    NSString *playTimeStr = [NSString stringWithFormat:@"%02ld:%02ld", (long)playMinutesInt, (long)playSecondsInt];
    [self.minimumLabel setText:playTimeStr];
}

//播放按钮被点击
- (void)playBtnClicked
{
    if (self.isHandle) {
        [MBProgressHUD showTextHUDwithTitle:@"正在进行操作"];
        return;
    }
    self.isHandle = YES;
    self.playBtn.selected = !self.playBtn.selected;
    [self updatePlayStatus];
    if (self.playBtn.selected) {
        [SAVORXAPI postUMHandleWithContentId:@"bunch planting_page_play_video" key:nil value:nil];
        [self.timer setFireDate:[NSDate distantPast]];
        if (self.isPlayEnd) {
            [self restartVod];
            return;
        }
        if ([GlobalData shared].isBindRD) {
            [SAVORXAPI resumeVideoWithURL:STBURL success:^(NSURLSessionDataTask *task, NSDictionary *result) {
                if ([[result objectForKey:@"result"] integerValue] != 0) {
                    [MBProgressHUD showTextHUDwithTitle:[result objectForKey:@"info"]];
                    self.playBtn.selected = !self.playBtn.selected;
                    [self updatePlayStatus];
                    [self changeTimerWithPlayStatus];
                }
                self.isHandle = NO;
                [self updatePlayStatus];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [MBProgressHUD showTextHUDwithTitle:@"操作失败"];
                self.playBtn.selected = !self.playBtn.selected;
                [self changeTimerWithPlayStatus];
                self.isHandle = NO;
                [self updatePlayStatus];
            }];
        }else if ([GlobalData shared].isBindDLNA) {
            [[GCCUPnPManager defaultManager] playSuccess:^{
                self.isHandle = NO;
            } failure:^{
                [MBProgressHUD showTextHUDwithTitle:@"操作失败"];
                self.playBtn.selected = !self.playBtn.selected;
                [self changeTimerWithPlayStatus];
                self.isHandle = NO;
                [self updatePlayStatus];
            }];
            return;
        }
    }else{
        
        [SAVORXAPI postUMHandleWithContentId:@"bunch planting_page_pause_button" key:nil value:nil];
        
        [self.timer setFireDate:[NSDate distantFuture]];
        
        if ([GlobalData shared].isBindRD) {
            [SAVORXAPI pauseVideoWithURL:STBURL success:^(NSURLSessionDataTask *task, NSDictionary *result) {
                if ([[result objectForKey:@"result"] integerValue] != 0) {
                    [MBProgressHUD showTextHUDwithTitle:[result objectForKey:@"info"]];
                    self.playBtn.selected = !self.playBtn.selected;
                    [self updatePlayStatus];
                    [self changeTimerWithPlayStatus];
                }
                self.isHandle = NO;
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [MBProgressHUD showTextHUDwithTitle:@"操作失败"];
                self.playBtn.selected = !self.playBtn.selected;
                [self changeTimerWithPlayStatus];
                self.isHandle = NO;
            }];
        }else if ([GlobalData shared].isBindDLNA) {
            [[GCCUPnPManager defaultManager] pauseSuccess:^{
                self.isHandle = NO;
            } failure:^{
                [MBProgressHUD showTextHUDwithTitle:@"操作失败"];
                self.playBtn.selected = !self.playBtn.selected;
                [self updatePlayStatus];
                [self changeTimerWithPlayStatus];
                self.isHandle = NO;
            }];
            return;
        }
    }
}

- (void)changeTimerWithPlayStatus
{
    if (self.playBtn.selected) {
        [self.timer setFireDate:[NSDate distantPast]];
    }else{
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

//进度条改变
- (void)sliderValueChange
{
    [self updateTimeLabel:self.playSilder.value];
}

//进度条开始进行用户交互
- (void)sliderStartTouch
{
    [self.timer setFireDate:[NSDate distantFuture]];
}

//进度条用户交互结束
- (void)sliderEndTouch
{
    [SAVORXAPI postUMHandleWithContentId:@"bunch planting_page_drag_progress" key:nil value:nil];
    if (self.isPlayEnd) {
        [self restartVod];
    }else{
        if ([GlobalData shared].isBindRD) {
            NSString * value;
            if (self.playSilder.value < 1) {
                value = [NSString stringWithFormat:@"%0.0f",self.playSilder.value + 1.f];
            }else{
                value = [NSString stringWithFormat:@"%0.0f",self.playSilder.value];
            }
            
            [SAVORXAPI seekVideoWithURL:STBURL position:value success:^(NSURLSessionDataTask *task, NSDictionary *result) {
                if ([[result objectForKey:@"result"] integerValue] == 0) {
                    [self.timer setFireDate:[NSDate distantPast]];
                }else{
                    [MBProgressHUD showTextHUDwithTitle:[result objectForKey:@"info"]];
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [MBProgressHUD showTextHUDwithTitle:@"操作失败"];
            }];
        }else if([GlobalData shared].isBindDLNA){
            [[GCCUPnPManager defaultManager] seekProgressTo:(NSInteger)self.playSilder.value success:^{
                [self.timer setFireDate:[NSDate distantPast]];
            } failure:^{
                [MBProgressHUD showTextHUDwithTitle:@"操作失败"];
            }];
        }
    }
}

//重置当前播放条目
- (void)restartVod
{
    MBProgressHUD * hud = [MBProgressHUD showCustomLoadingHUDInView:self.view];
    self.screenButton.enabled = NO;
    if ([GlobalData shared].isBindRD) {
        
        [SAVORXAPI demandWithURL:STBURL name:self.model.name type:1 position:0 success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            if ([[result objectForKey:@"result"] integerValue] == 0) {
                [[HomeAnimationView animationView] startScreenWithViewController:self];
                self.isPlayEnd = NO;
                self.playBtn.selected = YES;
                [self updatePlayStatus];
                self.quitScreenButton.hidden = NO;
                self.maskingView.hidden = NO;
                self.screenButton.hidden = YES;
                [self createTimer];
            }else{
                [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
            }
            self.screenButton.enabled = YES;
            self.isHandle = NO;
            [hud hideAnimated:NO];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            self.screenButton.enabled = YES;
            [hud hideAnimated:NO];
            [MBProgressHUD showTextHUDwithTitle:@"播放失败"];
            self.isHandle = NO;
        }];
        
    }else if ([GlobalData shared].isBindDLNA) {
        [[GCCUPnPManager defaultManager] setAVTransportURL:[self.model.videoURL stringByAppendingString:@".f20.mp4"] Success:^{
            [[HomeAnimationView animationView] startScreenWithViewController:self];
            self.quitScreenButton.hidden = NO;
            self.maskingView.hidden = NO;
            self.screenButton.hidden = YES;
            [hud hideAnimated:NO];
            self.isPlayEnd = NO;
            self.playBtn.selected = YES;
            [self updatePlayStatus];
            [self createTimer];
            self.isHandle = NO;
            self.screenButton.enabled = YES;
        } failure:^{
            self.screenButton.enabled = YES;
            [hud hideAnimated:NO];
            [MBProgressHUD showTextHUDwithTitle:@"播放失败"];
            self.isHandle = NO;

        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SAVORXAPI postUMHandleWithContentId:self.model.cid withType:demandHandle];
    [self cheakIsFavorite];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
}

- (void)cheakIsFavorite
{
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
        [self.collectButton setSelected:iscollect];
        if (iscollect) {
            [self.collectButton setImage:[UIImage imageNamed:@"icon_collect_yes"] forState:UIControlStateNormal];
        }else{
            [self.collectButton setImage:[UIImage imageNamed:@"icon_collect"] forState:UIControlStateNormal];
        }
    }
}

-(void)voidelPlayVolumeAction:(UIButton *)button{
    NSInteger action;
    if (button.tag == 101) {
        [SAVORXAPI postUMHandleWithContentId:@"bunch planting_page_vol_mute" key:nil value:nil];
        button.enabled = NO;
        if (button.isSelected) {
            action = 1;
        }else{
            action = 2;
        }
    }else if (button.tag == 102) {
        [SAVORXAPI postUMHandleWithContentId:@"bunch planting_page_vol_up" key:nil value:nil];
        action = 4;
    }else{
        [SAVORXAPI postUMHandleWithContentId:@"bunch planting_page_vol_down" key:nil value:nil];
        action = 3;
    }
    if ([GlobalData shared].isBindRD) {
        
        [SAVORXAPI volumeWithURL:STBURL action:action success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            if ([[result objectForKey:@"result"] integerValue] == 0) {
                if (action == 3 || action == 4) {
                    self.volumeButton.selected = YES;
                }else{
                    button.selected = !button.isSelected;
                }
            }else{
                [MBProgressHUD showTextHUDwithTitle:[result objectForKey:@"info"]];
            }
            if (button.tag == 101) {
                button.enabled = YES;
            }
            if (button.tag == 101 && self.volumeButton.selected == YES) {
                [self.volumeButton setImage:[UIImage imageNamed:@"De_laba_g"] forState:UIControlStateNormal];
            }else if (button.tag == 101 && self.volumeButton.selected == NO){
                [self.volumeButton setImage:[UIImage imageNamed:@"De_labajingyin"] forState:UIControlStateNormal];
                [self.volumeButton setImage:[UIImage imageNamed:@"De_labajingyin_g"] forState:UIControlStateHighlighted];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showTextHUDwithTitle:@"播放失败"];
            if (button.tag == 101) {
                button.enabled = YES;
            }
        }];
        
    }else if ([GlobalData shared].isBindDLNA) {
        NSInteger volume;
        switch (action) {
            case 1:
                volume = 0;
                break;
                
            case 2:
                volume = self.DLNAVolume;
                break;
                
            case 3:
            {
                if (self.DLNAVolume > 0) {
                    self.DLNAVolume--;
                }
                volume = self.DLNAVolume;
            }
                break;
                
            case 4:
            {
                if (self.DLNAVolume < 100) {
                    self.DLNAVolume++;
                }
                volume = self.DLNAVolume;
            }
                break;
                
            default:
                
                volume = 0;
                
                break;
        }
        [[GCCUPnPManager defaultManager] setVolume:volume Success:^{
            button.selected = !button.isSelected;
            if (button.tag == 101) {
                button.enabled = YES;
            }
        } failure:^{
            if (button.tag == 101) {
                button.enabled = YES;
            }
        }];
    }else{
        if (button.tag == 101) {
            button.enabled = YES;
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
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

- (void)navBackButtonClicked:(UIButton *)sender
{
    UINavigationController * na = [Helper getRootNavigationController];
    if ([NSStringFromClass([na class]) isEqualToString:@"BaseNavigationController"]) {
        UIViewController * vc = [na.viewControllers firstObject];
        
        UIViewController * secondVC = [na.viewControllers objectAtIndex:na.viewControllers.count - 2];
        if ([secondVC isKindOfClass:[WebViewController class]]) {
            WebViewController * web = (WebViewController *)secondVC;
            [web.playView shouldRelease];
        }else if([secondVC isKindOfClass:[HSVideoViewController class]]){
            HSVideoViewController * hsVideo = (HSVideoViewController *)secondVC;
            [hsVideo.playView shouldRelease];
        }
        
        [self.navigationController popToViewController:vc animated:YES];
    }
     [SAVORXAPI postUMHandleWithContentId:@"bunch planting_page_back" key:nil value:nil];
}

- (void)shouldRelease
{
    if (self.timer) {
        [self.timer setFireDate:[NSDate distantFuture]];
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)dealloc
{
    NSLog(@"点播页面释放了");
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
