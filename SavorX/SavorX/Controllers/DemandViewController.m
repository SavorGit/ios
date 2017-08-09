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

#import "WebViewController.h"
#import "WMPageController.h"
#import "RDLogStatisticsAPI.h"

#import "RDHomeStatusView.h"
#import "HSIsOrCollectionRequest.h"
#import "RDInteractionLoadingView.h"
#import "HotPopShareView.h"
#import "RDVideoHeaderView.h"

#import "HSImTeRecommendRequest.h"
#import "HotTopicShareView.h"
#import "RDFavoriteTableViewCell.h"
#import "RDAlertView.h"

#define BOTTOMHEIGHT 50.f

@interface DemandViewController ()<UIWebViewDelegate, UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

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
@property (nonatomic, strong) UIButton * collectButton;
@property (nonatomic, strong) UIView *maskingView;
@property (nonatomic, assign) BOOL isComplete; //内容是否阅读完整

@property (nonatomic, assign) BOOL isOnlyVideo; //是否是纯视频
@property (nonatomic, strong) UITableView * baseTableView; //纯视频展示视图
@property (nonatomic, strong) UIView * testView;   //底部视图
@property (nonatomic, strong) UITableView * tableView; //表格展示视图
@property (nonatomic, strong) NSMutableArray * dataSource; //数据源
@property (nonatomic, assign) BOOL hasWebObserver;

@end

@implementation DemandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [NSMutableArray new];
    
    _isComplete = NO;
    [self createUI];
    [self setupDatas];
}

- (void)setupDatas
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidPlayEnd) name:RDBoxQuitScreenNotification object:nil];
}

//初始化界面
- (void)createUI
{
    self.title = self.model.title;
    
    self.backImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.backImageView sd_setImageWithURL:[NSURL URLWithString:self.model.imageURL] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    [self.view addSubview:self.backImageView];
    self.backImageView.userInteractionEnabled = YES;
    [self.backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
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
    [self.playSilder setMinimumTrackTintColor:kThemeColor];
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
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    self.collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.collectButton setImage:[UIImage imageNamed:@"icon_collect"] forState:UIControlStateNormal];
    [self.collectButton setImage:[UIImage imageNamed:@"icon_collect_yes"] forState:UIControlStateSelected];
    [self.collectButton setAdjustsImageWhenHighlighted:NO];
    [self.collectButton addTarget:self action:@selector(collectAciton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.collectButton];
    
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    [shareButton setAdjustsImageWhenHighlighted:NO];
    [shareButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
    
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.right.mas_equalTo(-10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [self.collectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
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
    self.quitScreenButton.backgroundColor = kThemeColor;
    [self.quitScreenButton setTitle:RDLocalizedString(@"RDString_BackDemand") forState:UIControlStateNormal];
    [self.quitScreenButton.titleLabel setFont:kPingFangRegular(16)];
    [self.quitScreenButton setTitleColor:UIColorFromRGB(0xede6de) forState:UIControlStateNormal];
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
    
    [self refreshPage];
//    [self createWebView];
    [self createBottomView];
    [self addBottomEvent];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self createTimer];
    });
}

// 退出投屏
- (void)quitScreenAciton:(BOOL)fromHomeType{

    [SAVORXAPI ScreenDemandShouldBackToTVWithSuccess:^{
          
        [self videoDidPlayEnd];
        
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
     [self.navigationController popViewControllerAnimated:YES];
    
}

//tv按钮被点击，即重新点播该视频
- (void)tvAciton
{
    [self restartVod];
}

#pragma mark ---收藏按钮点击
- (void)collectAciton:(UIButton *)button
{
    NSInteger isCollect;
    if (button.selected == YES) {
        isCollect = 0;
    }else{
        isCollect = 1;
    }
    HSIsOrCollectionRequest * request = [[HSIsOrCollectionRequest alloc] initWithArticleId:self.model.artid withState:isCollect];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSDictionary *dic = (NSDictionary *)response;
        if ([[dic objectForKey:@"code"] integerValue] == 10000) {
            if (self.model.collected == 1) {
                self.model.collected = 0;
                [MBProgressHUD showSuccessHUDInView:self.view title:RDLocalizedString(@"RDString_SuccessWithCancle")];
                [SAVORXAPI postUMHandleWithContentId:@"details_page_cancel_collection" key:@"details_page_cancel_collection" value:@"success"];
            }else{
                self.model.collected = 1;
                [MBProgressHUD showSuccessHUDInView:self.view title:RDLocalizedString(@"RDString_SuccessWithCollect")];
                [SAVORXAPI postUMHandleWithContentId:@"details_page_collection" key:@"details_page_collection" value:@"success"];
            }
            button.selected = !button.selected;
        }
        
        [GlobalData shared].isCollectAction = YES;
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        if (isCollect == 0) {
            [SAVORXAPI postUMHandleWithContentId:@"details_page_cancel_collection" key:@"details_page_cancel_collection" value:@"fail"];
        }else{
            [SAVORXAPI postUMHandleWithContentId:@"details_page_collection" key:@"details_page_collection" value:@"fail"];
        }
        [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FailedWithCollect") delay:1.f];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        if (isCollect == 0) {
            [SAVORXAPI postUMHandleWithContentId:@"details_page_cancel_collection" key:@"details_page_cancel_collection" value:@"fail"];
        }else{
            [SAVORXAPI postUMHandleWithContentId:@"details_page_collection" key:@"details_page_collection" value:@"fail"];
        }
        [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FailedWithCollect") delay:1.f];
    }];
}

#pragma mark ---分享按钮点击
- (void)shareAction:(UIButton *)button
{
    if (!self.model.contentURL || !(self.model.contentURL.length > 0)) {
        [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDSting_NotSurpport") delay:1.5f];
        return;
    }
    
    HotPopShareView *shareView = [[HotPopShareView alloc] initWithModel:self.model andVC:self  andCategoryID:self.categroyID andSourceId:1];
    [[UIApplication sharedApplication].keyWindow addSubview:shareView];
}

//创建浏览的webView
- (void)createWebView
{
    
    self.webView = [[UIWebView alloc] init];
    self.webView.backgroundColor = UIColorFromRGB(0xf6f2ed);
    self.webView.opaque = NO;
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backImageView.mas_bottom);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-BOTTOMHEIGHT);
    }];
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    
    if (!self.model.contentURL || !(self.model.contentURL.length > 0)) {
        return;
    }
    
    if (self.model.type != 4) {
        if (!isEmptyString(self.model.contentURL)) {
            [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[[self.model.contentURL stringByAppendingString:@"?location=newRead&app=inner"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
            [MBProgressHUD showWebLoadingHUDInView:self.webView];
        }
    }else{
        self.webView.scrollView.userInteractionEnabled = NO;
        
        RDVideoHeaderView * view = [[RDVideoHeaderView alloc] init];
        [view reloadWithModel:self.model];
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backImageView.mas_bottom);
            make.left.mas_equalTo(0);
            make.size.mas_equalTo(view.frame.size);
        }];
    }
}

//创建底部播放控制栏
- (void)createBottomView
{
    self.playBackView = [[UIView alloc] initWithFrame:CGRectMake(0, kMainBoundsHeight - BOTTOMHEIGHT, kMainBoundsWidth, BOTTOMHEIGHT)];
    self.playBackView.backgroundColor = UIColorFromRGB(0x922c3e);
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
                [self videoDidPlayEnd];
                [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
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
        [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_IsHandeling")];
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
                [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FailedWithHandel")];
                self.playBtn.selected = !self.playBtn.selected;
                [self changeTimerWithPlayStatus];
                self.isHandle = NO;
                [self updatePlayStatus];
            }];
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
                [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FailedWithHandel")];
                self.playBtn.selected = !self.playBtn.selected;
                [self changeTimerWithPlayStatus];
                self.isHandle = NO;
            }];
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
                [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FailedWithHandel")];
            }];
        }
    }
}

//重置当前播放条目
- (void)restartVod
{
    RDInteractionLoadingView * hud = [[RDInteractionLoadingView alloc] initWithView:self.view title:RDLocalizedString(@"RDString_Demanding")];
    self.screenButton.enabled = NO;
    if ([GlobalData shared].isBindRD) {
        
        [SAVORXAPI demandWithURL:STBURL name:self.model.name type:1 position:0 force:0  success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            if ([[result objectForKey:@"result"] integerValue] == 0) {
                [[RDHomeStatusView defaultView] startScreenWithViewController:self withStatus:RDHomeStatus_Demand];
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
            [hud hidden];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            self.screenButton.enabled = YES;
            [hud hidden];
            [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FailedWithPlay")];
            self.isHandle = NO;
        }];
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SAVORXAPI postUMHandleWithContentId:self.model.artid withType:demandHandle];
    [self cheakIsFavorite];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    if (self.model.type != -100) {
        //如果是非酒楼宣传片，则进行统计
        [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_START type:RDLOGTYPE_CONTENT model:self.model categoryID:[NSString stringWithFormat:@"%ld", self.categroyID]];
        if (self.model.type == 4) {
            //如果是纯视频，则直接complete
            [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_COMPELETE type:RDLOGTYPE_CONTENT model:self.model categoryID:[NSString stringWithFormat:@"%ld", self.categroyID]];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.model.type != -100) {
        //如果是非酒楼宣传片，则进行统计
        [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_END type:RDLOGTYPE_CONTENT model:self.model categoryID:[NSString stringWithFormat:@"%ld", self.categroyID]];
    }
}

- (void)cheakIsFavorite
{
    // 设置收藏按钮状态
    if (self.model.collected == 1) {
        self.collectButton.selected = YES;
    }else{
        self.collectButton.selected = NO;
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
            [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FailedWithPlay")];
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString hasSuffix:@"mp4"]) {
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [MBProgressHUD hiddenWebLoadingInView:self.webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hiddenWebLoadingInView:self.webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self showNoNetWorkViewInView:self.webView];
}

- (void)retryToGetData
{
    [self hideNoNetWorkView];
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[[self.model.contentURL stringByAppendingString:@"?location=newRead&app=inner"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    [MBProgressHUD showWebLoadingHUDInView:self.webView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    if (self.model.type != -100) {
        if (self.webView.scrollView.contentSize.height - self.webView.scrollView.contentOffset.y - self.webView.frame.size.height <= 100) {
            if (_isComplete == NO) {
                [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_COMPELETE type:RDLOGTYPE_CONTENT model:self.model categoryID:[NSString stringWithFormat:@"%ld", self.categroyID]];
                _isComplete = YES;
            }
            
        }
    }
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
        }
        
        [self.navigationController popToViewController:vc animated:YES];
    }
     [SAVORXAPI postUMHandleWithContentId:@"bunch planting_page_back" key:nil value:nil];
}

- (void)shouldRelease
{
    self.webView.delegate = nil;
    self.webView.scrollView.delegate = nil;
    if (self.timer) {
        [self.timer setFireDate:[NSDate distantFuture]];
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)videoDidPlayEnd
{
    self.minimumLabel.text = @"00:00";
    self.playSilder.value = 0;
    self.isPlayEnd = YES;
    self.playBtn.selected = NO;
    [self updatePlayStatus];
    self.quitScreenButton.hidden = YES;
    self.maskingView.hidden = YES;
    self.screenButton.hidden = NO;
    self.screenButton.enabled = YES;
    [self shouldRelease];
    [self quitBack];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)refreshPage
{
    if (self.model.type == 4) {
        
        self.isOnlyVideo = YES;
        [self refreshWithOnlyVideo];
        
    }else{
        
        self.isOnlyVideo = NO;
        [self refreshWithVideo];
    }
    [self setUpDatas];
}

#pragma mark - 非纯视频的页面布局
- (void)refreshWithVideo
{
    if (self.baseTableView.superview) {
        self.baseTableView.delegate = nil;
        self.baseTableView.dataSource = nil;
        [self.baseTableView removeFromSuperview];
    }
    
    if (!self.webView) {
        [self createWebViewWithVideo];
    }
    if (!self.webView.superview) {
        [self.view addSubview:self.webView];
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backImageView.mas_bottom);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(kMainBoundsWidth);
            make.bottom.mas_equalTo(0);
        }];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.webView.scrollView.delegate = self;
        self.webView.delegate = self;
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)self.webView;
    }
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    if (!isEmptyString(self.model.contentURL)) {
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[self.model.contentURL stringByAppendingString:@"?location=newRead&app=inner"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [self.webView loadRequest:request];
        [MBProgressHUD showWebLoadingHUDInView:self.webView];
        if (!self.webView.superview) {
            [self addObserver];
        }
    }
}

- (void)createWebViewWithVideo
{
    //初始化webView
    self.webView = [[UIWebView alloc] init];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    
    [self.webView.scrollView addSubview:self.testView];
}

#pragma mark - 纯视频的页面布局
//刷新当前的纯视频视图
- (void)refreshWithOnlyVideo
{
    if (self.webView.superview) {
        //移除非纯视频播放展示的webView
        [self.webView removeFromSuperview];
        [self.testView removeFromSuperview];
        self.webView.delegate = nil;
        self.webView.scrollView.delegate = nil;
        self.tableView.delegate = nil;
        self.tableView.dataSource = nil;
        [self removeObserver];
    }
    
    //添加纯视频播放页面的推荐列表
    if (!self.baseTableView) {
        [self createTableViewWithOnlyVideo];
    }
    if (!self.baseTableView.superview) {
        [self.view addSubview:self.baseTableView];
        [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backImageView.mas_bottom).offset(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
        self.baseTableView.dataSource = self;
        self.baseTableView.delegate = self;
    }
    
    //添加用户右滑退出该页面的手势操作
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self.baseTableView;
    RDVideoHeaderView * headerView = (RDVideoHeaderView *)self.baseTableView.tableHeaderView;
    [headerView reloadWithModel:self.model];
    
    [self.dataSource removeAllObjects];
    [self.baseTableView reloadData];
}

- (void)createTableViewWithOnlyVideo
{
    self.baseTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight) style:UITableViewStyleGrouped];
    self.baseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.baseTableView.clipsToBounds = YES;
    self.baseTableView.backgroundColor = UIColorFromRGB(0xf6f2ed);
    
    RDVideoHeaderView * headerView = [[RDVideoHeaderView alloc] init];
    self.baseTableView.tableHeaderView = headerView;
}

#pragma mark - 初始化下方推荐数据
- (void)setUpDatas{
    
    [HSImTeRecommendRequest cancelRequest];
    HSImTeRecommendRequest * request = [[HSImTeRecommendRequest alloc] initWithArticleId:self.model.artid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.dataSource removeAllObjects];
        
        NSDictionary *dic = (NSDictionary *)response;
        NSArray *resultArr = [dic objectForKey:@"result"];
        
        for (int i = 0; i < resultArr.count; i ++) {
            CreateWealthModel *welthModel = [[CreateWealthModel alloc] initWithDictionary:resultArr[i]];
            welthModel.acreateTime = welthModel.updateTime;
            [self.dataSource addObject:welthModel];
        }
        // 当返回有推荐数据时调用
        if (self.dataSource.count > 0) {
            if (self.isOnlyVideo) {
                [self.baseTableView reloadData];
            }else{
                [self footViewShouldBeReset];
                [self.tableView reloadData];
            }
        }
        
        if (self.isOnlyVideo) {
            RDVideoHeaderView * headerView = (RDVideoHeaderView *)self.baseTableView.tableHeaderView;
            [headerView needRecommand:self.dataSource.count != 0];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (self.isOnlyVideo) {
            RDVideoHeaderView * headerView = (RDVideoHeaderView *)self.baseTableView.tableHeaderView;
            [headerView needRecommand:self.dataSource.count != 0];
        }
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        if (self.isOnlyVideo) {
            RDVideoHeaderView * headerView = (RDVideoHeaderView *)self.baseTableView.tableHeaderView;
            [headerView needRecommand:self.dataSource.count != 0];
        }
        
    }];
}

- (void)addObserver
{
    if (!self.hasWebObserver) {
        self.hasWebObserver = YES;
        [self.webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeObserver
{
    if (self.hasWebObserver) {
        self.hasWebObserver = NO;
        [self.webView.scrollView removeObserver:self forKeyPath:@"contentSize" context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [MBProgressHUD hiddenWebLoadingInView:self.webView];
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self footViewShouldBeReset];
    }
}

- (void)footViewShouldBeReset
{
    [self removeObserver];
    
    if (self.testView.superview) {
        [self.testView removeFromSuperview];
    }
    //TableView的高度
    CGFloat tabHeight = 0;
    if (self.dataSource.count != 0) {
        tabHeight = self.dataSource.count *96 + 48;
    }
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(tabHeight);
    }];
    
    //底部View总高度
    CGFloat theight = tabHeight + 115 + 30;
    if (self.dataSource.count != 0) {
        theight += 8;
    }
    
    CGFloat cSizeheight = self.webView.scrollView.contentSize.height;
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, theight);
    CGSize contentSize = self.webView.scrollView.contentSize;
    //底部View与顶部网页的间隔为0
    frame.origin.y = cSizeheight;
    self.testView.frame = frame;
    [self.webView.scrollView addSubview:self.testView];
    [self.webView.scrollView setContentSize:CGSizeMake(contentSize.width, contentSize.height + theight + 50)];
    
    [self addObserver];
    
    //不是纯视频类型添加分享部分
    if (self.model.type != 4) {
        [self shareBoardByDefined];
    }
}

- (void)shareBoardByDefined {
    
    if ([self.testView viewWithTag:1000]) {
        [[self.testView viewWithTag:1000] removeFromSuperview];
    }
    HotTopicShareView *shareView = [[HotTopicShareView alloc] initWithModel:self.model andVC:self andCategoryID:self.categroyID andY:30];
    shareView.tag = 1000;
    [self.testView addSubview:shareView];
    
}

#pragma mark -- 懒加载
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = UIColorFromRGB(0xf6f2ed);
        _tableView.backgroundView = nil;
        _tableView.scrollEnabled = NO;
        [self.testView addSubview:_tableView];
        
        CGFloat diatanceToTop = 115+30+8;
        // 纯视频类型去除上边分享部分
        if (self.model.type == 4) {
            diatanceToTop = 8;
        }
        CGFloat tabHeiht;
        if (self.dataSource.count == 0) {
            tabHeiht = 0;
        }else{
            tabHeiht = self.dataSource.count *96 +48;
        }
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(kMainBoundsWidth);
            make.height.mas_equalTo(tabHeiht);
            make.top.mas_equalTo(diatanceToTop);
            make.left.mas_equalTo(0);
        }];
        
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 48)];
        headView.backgroundColor = UIColorFromRGB(0xf6f2ed);
        UILabel *recommendLabel = [[UILabel alloc] init];
        recommendLabel.frame = CGRectMake(15, 10, 100, 30);
        recommendLabel.textColor = UIColorFromRGB(0x922c3e);
        recommendLabel.font = kPingFangRegular(15);
        recommendLabel.text = RDLocalizedString(@"RDString_RecommendForYou");
        recommendLabel.textAlignment = NSTextAlignmentLeft;
        [headView addSubview:recommendLabel];
        _tableView.tableHeaderView = headView;
    }
    
    return _tableView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"videoTableCell";
    RDFavoriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[RDFavoriteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    //最后一条分割线隐藏
    if (indexPath.row == self.dataSource.count - 1) {
        [cell setLineViewHidden:YES];
    }else{
        [cell setLineViewHidden:NO];
    }
    
    CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configWithModel:model];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 96.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
    
    if ([GlobalData shared].isBindRD) {
        
        [self demandVideoWithModel:model force:0];
        
    }else{
        
        [[RDHomeStatusView defaultView] scanQRCode];
    }
    
}

- (UIView *)testView
{
    if (!_testView) {
        _testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,kMainBoundsWidth, 100)];
        _testView.backgroundColor = UIColorFromRGB(0xf6f2ed);
        _testView.clipsToBounds = YES;
    }
    return _testView;
}

- (void)demandVideoWithModel:(CreateWealthModel *)model force:(NSInteger)force{
    
    RDInteractionLoadingView * hud = [[RDInteractionLoadingView alloc] initWithView:self.view title:RDLocalizedString(@"RDString_Demanding")];
    [SAVORXAPI demandWithURL:STBURL name:model.name type:1 position:0  force:force success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        if ([[result objectForKey:@"result"] integerValue] == 0) {
            
            self.model = model;
            [SAVORXAPI successRing];
            [self recommendToScreenSuccess];
            
        }else if ([[result objectForKey:@"result"] integerValue] == 4) {
            
            NSString *infoStr = [result objectForKey:@"info"];
            RDAlertView *alertView = [[RDAlertView alloc] initWithTitle:RDLocalizedString(@"RDString_AlertWithScreen") message:[NSString stringWithFormat:@"%@%@%@", RDLocalizedString(@"RDString_ScreenContinuePre"), infoStr, RDLocalizedString(@"RDString_ScreenContinueSuf")]];
            RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:RDLocalizedString(@"RDString_Cancle") handler:^{
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" withParmDic:@{@"to_screen_competition_hint" : @"cancel",@"type" : @"vod"} ];
            } bold:NO];
            RDAlertAction * actionOne = [[RDAlertAction alloc] initWithTitle:RDLocalizedString(@"RDString_ContinueScreen") handler:^{
                [self demandVideoWithModel:model force:1];
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" withParmDic:@{@"to_screen_competition_hint" : @"ensure",@"type" : @"vod"} ];
            } bold:YES];
            [alertView addActions:@[action,actionOne]];
            [alertView show];
            
        }else{
            [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
        }
        [hud hidden];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [hud hidden];
        [MBProgressHUD showTextHUDwithTitle:DemandFailure];
    }];
}

// 点击推荐投屏成功
- (void)recommendToScreenSuccess{
    
    self.title = self.model.title;
    self.playSilder.maximumValue = self.model.duration;
    NSInteger pLayDurationInt = self.model.duration; // some duration from the JSON
    NSInteger playMinutesInt = pLayDurationInt / 60;
    NSInteger playSecondsInt = pLayDurationInt % 60;
    NSString *playTimeStr = [NSString stringWithFormat:@"%02ld:%02ld", (long)playMinutesInt, (long)playSecondsInt];
    self.maximumLabel.text = playTimeStr;
    
    [[RDHomeStatusView defaultView] startScreenWithViewController:self withStatus:RDHomeStatus_Demand];
    [SAVORXAPI postUMHandleWithContentId:@"home_click_bunch_video" key:nil value:nil];
    
    [self.backImageView sd_setImageWithURL:[NSURL URLWithString:self.model.imageURL] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    [self refreshPage];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self createTimer];
    });
}

- (void)dealloc
{
    NSLog(@"点播页面释放了");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDBoxQuitScreenNotification object:nil];
    
    [self removeObserver];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
