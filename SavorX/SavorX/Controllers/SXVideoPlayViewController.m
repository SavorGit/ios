//
//  SXVideoPlayViewController.m
//  SavorX
//
//  Created by lijiawei on 17/2/8.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "SXVideoPlayViewController.h"
#import "UINavigationBar+PS.h"
#import "VoideoPlayHeaderView.h"
#import "voideoPlayFooterView.h"
#import "VoideoPlayStatusCell.h"
#import "GCCUPnPManager.h"
#import "HomeAnimationView.h"
#import "UINavigationBar+PS.h"
#import "RDAlertView.h"
#import "RDAlertAction.h"


#define Max_OffsetY  50
#define WeakSelf(x)      __weak typeof (self) x = self
#define  Statur_HEIGHT   [[UIApplication sharedApplication] statusBarFrame].size.height
#define  NAVIBAR_HEIGHT  (self.navigationController.navigationBar.frame.size.height)

#define  INVALID_VIEW_HEIGHT (Statur_HEIGHT + NAVIBAR_HEIGHT)


@interface SXVideoPlayViewController ()<VoideoPlayHeaderViewDelegate,voideoPlayFooterViewDelegate,VoideoPlayStatusCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) VoideoPlayHeaderView * headBackView;
@property (nonatomic,strong) voideoPlayFooterView *footerView;
@property (nonatomic, strong) NSTimer * timer; //更新播放时间定时器
@property (nonatomic, strong) NSURLSessionDataTask * task; //记录最后一次请求
@property (nonatomic, assign) BOOL isPlayEnd; //是否处于播放结束状态
@property (nonatomic, assign) BOOL isHandle; //记录当前是否在进行操作
@property (nonatomic, assign) NSInteger DLNAVolume;

@end

@implementation SXVideoPlayViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.type = 1;
    }
    return self;
}

- (void)dealloc
{
    _headBackView = nil;
    _footerView = nil;
    [UIApplication sharedApplication].statusBarStyle = UISearchBarStyleDefault;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidBindDeviceNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDBoxQuitScreenNotification object:nil];
    NSLog(@"视频播放释放了");
}

- (void)shouldRelease
{
    if (self.timer) {
        [self.timer setFireDate:[NSDate distantFuture]];
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark -懒加载-

- (UIView*)headBackView
{
    if (!_headBackView) {
        _headBackView = [VoideoPlayHeaderView loadFromXib];
        _headBackView.userInteractionEnabled = YES;
        _headBackView.delegate = self;
        _headBackView.frame = CGRectMake(0, 0, kMainBoundsWidth,230);
    }
    return _headBackView;
}

-(UIView *)footerView{
    if(!_footerView){
        _footerView = [voideoPlayFooterView loadFromXib];
        _footerView.userInteractionEnabled = YES;
        _footerView.delegate = self;
        _footerView.frame = CGRectMake(0, 0, kMainBoundsWidth,275);
    }
    return _footerView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = VCBackgroundColor;
    
    if (self.model) {
        self.totalTime = self.model.duration;
    }
    
    if (self.totalTime == 0) {
        AVURLAsset * asset;
        if (self.model) {
            asset = [AVURLAsset assetWithURL:[NSURL URLWithString:self.model.videoURL]];
        }else{
            asset = [AVURLAsset assetWithURL:[NSURL URLWithString:self.videoUrl]];
        }
        if (asset) {
            self.totalTime = (NSInteger)asset.duration.value / asset.duration.timescale;
        }
    }
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [self setupDatas];
    [self setupViews];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [SAVORXAPI postUMHandleWithContentId:@"home_video" key:nil value:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
}

-(void)setupDatas{
    if ([GlobalData shared].isBindDLNA) {
        self.DLNAVolume = 50;
        [[GCCUPnPManager defaultManager] getVolumeSuccess:^(NSInteger volume) {
            self.DLNAVolume = volume;
        } failure:^{
            
        }];
    }
}

-(void)setupViews{
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    //导航

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voideoPlayStatusCellConnectAction) name:RDDidBindDeviceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidPlayEnd) name:RDBoxQuitScreenNotification object:nil];
    
    self.tableView.tableHeaderView = self.headBackView;
    if (kMainBoundsWidth < 375) {
        UIView * view = self.footerView;
        view.frame = CGRectMake(0, 0, kMainBoundsWidth, 400);
        self.tableView.tableFooterView = view;
    }else{
        self.tableView.tableFooterView =  self.footerView;
    }
    [self.headBackView.palySlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
    self.headBackView.palySlider.minimumValue = 1;
    self.headBackView.palySlider.maximumValue = (NSInteger)self.totalTime;
    [self.headBackView.palySlider setMinimumTrackTintColor:[UIColor colorWithHexString:@"#fb573c"]];
    [self.headBackView.palySlider setMaximumTrackTintColor:[UIColor colorWithHexString:@"#a2a7aa"]];
    
    NSInteger pLayDurationInt = self.totalTime; // some duration from the JSON
    NSInteger playMinutesInt = pLayDurationInt / 60;
    NSInteger playSecondsInt = pLayDurationInt % 60;
    NSString *playTimeStr = [NSString stringWithFormat:@"%02ld:%02ld", (long)playMinutesInt, (long)playSecondsInt];
    self.headBackView.maxinumLabel.text = playTimeStr;
    
    [self isEnableFooter];
    
    if ([GlobalData shared].isBindRD || [GlobalData shared].isBindDLNA) {
        [self createTimer];
    }else{
        [SAVORXAPI showConnetToTVAlert:@"video"];
    }
}

//创建更新播放进度定时器
- (void)createTimer
{
    if (self.timer) {
        [self.timer setFireDate:[NSDate distantFuture]];
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateSiderValue) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}


#pragma mark -- UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VoideoPlayStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:[VoideoPlayStatusCell cellIdentifier]];
    if(cell == nil){
        cell = [VoideoPlayStatusCell loadFromXib];
        cell.delegate = self;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![GlobalData shared].isBindRD && ![GlobalData shared].isBindDLNA) {
        return 1;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

//更新进度条关键函数
- (void)updateSiderValue
{
    if (self.task) {
        [self.task cancel];
    }
    
    if ([GlobalData shared].isBindRD) {
        [SAVORXAPI queryVideoWithURL:STBURL success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            NSInteger code = [[result objectForKey:@"result"] integerValue];
            if (code == 0) {
                CGFloat posFloat = [[result objectForKey:@"pos"] floatValue]/1000;
                NSLog(@"%lf", posFloat);
                [self.headBackView.palySlider setValue:posFloat];
                [self updateTimeLabel:posFloat];
            }else if (code == -1 || code == 1){
                [self videoDidPlayEnd];
                [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
        
    }else if ([GlobalData shared].isBindDLNA){
        [[GCCUPnPManager defaultManager] getPlayProgressSuccess:^(NSString *totalDuration, NSString *currentDuration, float progress) {
            if (progress >= 1 - 1 / self.headBackView.palySlider.maximumValue) {
                [self videoDidPlayEnd];
                [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
            }else{
                CGFloat posFloat = [[GCCUPnPManager defaultManager] timeIntegerFromString:totalDuration] * progress;
                [self.headBackView.palySlider setValue:posFloat];
                [self updateTimeLabel:posFloat];
            }
            
        } failure:^{
            
        }];
    }
}

//更新播放时间
- (void)updateTimeLabel:(CGFloat)posFloat
{
    if (posFloat > self.headBackView.palySlider.value) {
        return;
    }
    
    NSInteger pLayDurationInt = (NSInteger)posFloat; // some duration from the JSON
    NSInteger playMinutesInt = pLayDurationInt / 60;
    NSInteger playSecondsInt = pLayDurationInt % 60;
    
    NSString *playTimeStr = [NSString stringWithFormat:@"%02ld:%02ld", (long)playMinutesInt, (long)playSecondsInt];
    [self.headBackView.mininumLabel setText:playTimeStr];
}

#pragma mark delegate
-(void)VoideoPlaysliderValueChange{
    
    [self updateTimeLabel:self.headBackView.palySlider.value];
}

-(void)VoideoPlaysliderStartTouch{
    if (self.task) {
        [self.task cancel];
    }
    [self.timer setFireDate:[NSDate distantFuture]];
}

// 拖动进度
-(void)VoideoPlaysliderEndTouch{
    
    [SAVORXAPI postUMHandleWithContentId:@"video_to_screen_drag_progress" key:nil value:nil];
    if (self.isPlayEnd) {
        [self restartVod];
    }else{
        
        if ([GlobalData shared].isBindRD) {
            NSString * value;
            if (self.headBackView.palySlider.value < 1) {
                value = [NSString stringWithFormat:@"%0.0f",self.headBackView.palySlider.value + 1.f];
            }else{
                value = [NSString stringWithFormat:@"%0.0f",self.headBackView.palySlider.value];
            }
            
            [SAVORXAPI seekVideoWithURL:STBURL position:value success:^(NSURLSessionDataTask *task, NSDictionary *result) {
                if ([[result objectForKey:@"result"] integerValue] == 0) {
                    
                    [self.timer setFireDate:[NSDate distantPast]];
                }else{
                    [MBProgressHUD showTextHUDwithTitle:[result objectForKey:@"info"]];
                    [self videoDidPlayEnd];
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [MBProgressHUD showTextHUDwithTitle:@"操作失败"];
            }];
            
        }else if([GlobalData shared].isBindDLNA){
            [[GCCUPnPManager defaultManager] seekProgressTo:(NSInteger)self.headBackView.palySlider.value success:^{
                [self.timer setFireDate:[NSDate distantPast]];
            } failure:^{
                [MBProgressHUD showTextHUDwithTitle:@"操作失败"];
            }];
        }
    }
}


-(void)voideoPlayFooterView:(voideoPlayFooterView *)vView didVideoPlayButton:(UIButton *)button{
    
    [SAVORXAPI postUMHandleWithContentId:@"video_to_screen_pause" key:nil value:nil];
    
    button.enabled = NO;
    if (self.isHandle) {
        [MBProgressHUD showTextHUDwithTitle:@"正在进行操作"];
        return;
    }
    self.isHandle = YES;
    if (button.isSelected) {
        [self.timer setFireDate:[NSDate distantPast]];
        if (self.isPlayEnd) {
            [self restartVod];
            return;
        }
        
        if ([GlobalData shared].isBindRD) {
            [SAVORXAPI resumeVideoWithURL:STBURL success:^(NSURLSessionDataTask *task, NSDictionary *result) {
                if ([[result objectForKey:@"result"] integerValue] != 0) {
                    [MBProgressHUD showTextHUDwithTitle:[result objectForKey:@"info"]];
                    [self changeTimerWithPlayStatus];
                }else{
                    button.selected = !button.selected;
                }
                self.isHandle = NO;
                button.enabled = YES;
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [MBProgressHUD showTextHUDwithTitle:@"操作失败"];
                [self changeTimerWithPlayStatus];
                self.isHandle = NO;
                button.enabled = YES;
            }];
        }else if ([GlobalData shared].isBindDLNA) {
            [[GCCUPnPManager defaultManager] playSuccess:^{
                button.selected = !button.selected;
                self.isHandle = NO;
                button.enabled = YES;
            } failure:^{
                [MBProgressHUD showTextHUDwithTitle:@"操作失败"];
                self.footerView.videoPlayButton.selected = !self.footerView.videoPlayButton;
                [self changeTimerWithPlayStatus];
                self.isHandle = NO;
                button.enabled = YES;
            }];
            return;
        }
    }else{
        [self.timer setFireDate:[NSDate distantFuture]];
        
        if ([GlobalData shared].isBindRD) {
            [SAVORXAPI pauseVideoWithURL:STBURL success:^(NSURLSessionDataTask *task, NSDictionary *result) {
                if ([[result objectForKey:@"result"] integerValue] != 0) {
                    [MBProgressHUD showTextHUDwithTitle:[result objectForKey:@"info"]];
                    self.footerView.videoPlayButton.selected = !self.footerView.videoPlayButton;
                    [self changeTimerWithPlayStatus];
                }else{
                    button.selected = !button.selected;
                }
                self.isHandle = NO;
                button.enabled = YES;
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [MBProgressHUD showTextHUDwithTitle:@"操作失败"];
                self.footerView.videoPlayButton.selected = !self.footerView.videoPlayButton;
                [self changeTimerWithPlayStatus];
                self.isHandle = NO;
                button.enabled = YES;
            }];
        }else if ([GlobalData shared].isBindDLNA) {
            [[GCCUPnPManager defaultManager] pauseSuccess:^{
                button.selected = !button.selected;
                
                self.isHandle = NO;
                button.enabled = YES;
            } failure:^{
                [MBProgressHUD showTextHUDwithTitle:@"操作失败"];
                self.footerView.videoPlayButton.selected = !self.footerView.videoPlayButton;
                [self changeTimerWithPlayStatus];
                self.isHandle = NO;
                button.enabled = YES;
            }];
            return;
        }
    }
}

//重置当前播放条目
- (void)restartVod
{
    [MBProgressHUD showCustomLoadingHUDInView:self.view];
    
    NSString * asseturlStr;
    
    if ([GlobalData shared].isBindRD) {
        if (self.model) {
            
            [self demandVideoWithforce:0];
        }else{
            asseturlStr = [NSString stringWithFormat:@"%@%@", [HTTPServerManager getCurrentHTTPServerIP], self.videoUrl];
            [self demandVideoWithPostMedPath:[asseturlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] force:0];
        }
    }else if ([GlobalData shared].isBindDLNA) {
        if (self.model) {
            asseturlStr = [self.model.videoURL stringByAppendingString:@".f20.mp4"];
        }else{
            asseturlStr = [NSString stringWithFormat:@"%@%@", [HTTPServerManager getCurrentHTTPServerIP], self.videoUrl];
        }
        
        [[GCCUPnPManager defaultManager] setAVTransportURL:asseturlStr Success:^{
            [[HomeAnimationView animationView] startScreenWithViewController:self];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.isPlayEnd = NO;
            [self createTimer];
            self.isHandle = NO;
            [self.tableView reloadData];
            self.footerView.videoPlayButton.enabled = YES;
            self.footerView.videoPlayButton.selected = NO;
            
        } failure:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showTextHUDwithTitle:@"播放失败"];
            self.isHandle = NO;
            self.footerView.videoPlayButton.selected = YES;
            self.footerView.videoPlayButton.enabled = YES;
        }];
    }
}

- (void)demandVideoWithPostMedPath:(NSString *)mediaPath force:(NSInteger)force{
    
    [SAVORXAPI postVideoWithURL:STBURL mediaPath:mediaPath position:@"0" force:force success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([[result objectForKey:@"result"] integerValue] == 0) {
            [[HomeAnimationView animationView] startScreenWithViewController:self];
            self.isPlayEnd = NO;
            self.footerView.videoPlayButton.selected = NO;
            [self createTimer];
            [self.tableView reloadData];
        }else if ([[result objectForKey:@"result"] integerValue] == 4) {
            
            NSString *infoStr = [result objectForKey:@"info"];
            RDAlertView *alertView = [[RDAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"当前%@正在投屏，是否继续投",infoStr]];
            RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"取消" handler:^{
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" withParmDic:@{@"to_screen_competition_hint" : @"cancel",@"type" : @"vod"}];
            } bold:NO];
            RDAlertAction * actionOne = [[RDAlertAction alloc] initWithTitle:@"继续投屏" handler:^{
                [self demandVideoWithPostMedPath:mediaPath force:1];
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" withParmDic:@{@"to_screen_competition_hint" : @"ensure",@"type" : @"vod"}];
            } bold:NO];
            [alertView addActions:@[action,actionOne]];
            [alertView show];
            
        }else{
            self.footerView.videoPlayButton.selected = YES;
            [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
        }
        self.isHandle = NO;
        self.footerView.videoPlayButton.enabled = YES;
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showTextHUDwithTitle:@"播放失败"];
        self.isHandle = NO;
        self.footerView.videoPlayButton.selected = YES;
        self.footerView.videoPlayButton.enabled = YES;
    }];
}

- (void)demandVideoWithforce:(NSInteger)force{
    
    [SAVORXAPI demandWithURL:STBURL name:self.model.name type:self.type position:0 force:force success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([[result objectForKey:@"result"] integerValue] == 0) {
            [[HomeAnimationView animationView] startScreenWithViewController:self];
            self.isPlayEnd = NO;
            self.footerView.videoPlayButton.selected = NO;
            [self createTimer];
            [self.tableView reloadData];
        }else if ([[result objectForKey:@"result"] integerValue] == 4) {
            
            NSString *infoStr = [result objectForKey:@"info"];
            RDAlertView *alertView = [[RDAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"当前%@正在投屏，是否继续投",infoStr]];
            RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"取消" handler:^{
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" withParmDic:@{@"to_screen_competition_hint" : @"cancel",@"type" : @"vod"}];
            } bold:NO];
            RDAlertAction * actionOne = [[RDAlertAction alloc] initWithTitle:@"继续投屏" handler:^{
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" withParmDic:@{@"to_screen_competition_hint" : @"ensure",@"type" : @"vod"}];
                [self demandVideoWithforce:1];
            } bold:NO];
            [alertView addActions:@[action,actionOne]];
            [alertView show];
            
        }
        else{
            self.footerView.videoPlayButton.selected = YES;
            [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
        }
        self.isHandle = NO;
        self.footerView.videoPlayButton.enabled = YES;
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showTextHUDwithTitle:@"播放失败"];
        self.isHandle = NO;
        self.footerView.videoPlayButton.selected = YES;
        self.footerView.videoPlayButton.enabled = YES;
    }];
    
}

-(void)changeTimerWithPlayStatus
{
    if (self.footerView.videoPlayButton.selected) {
        [self.timer setFireDate:[NSDate distantPast]];
    }else{
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

-(void)navBackArrow{
    
    [self.navigationController popViewControllerAnimated:YES];
}

// 退出投屏
-(void)stopVoideoPlay:(BOOL)fromHomeType{
    
    if (self.isPlayEnd) {
        [self restartVod];
    }else{
        [SAVORXAPI ScreenDemandShouldBackToTVWithSuccess:^{
            [self videoDidPlayEnd];
            [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
        } failure:^{
            
        }];
    }
}

-(void)voidelPlayVolumeAction:(NSInteger)action{
    
    if (action == 1 || action == 2) {
        self.footerView.muteBtn.enabled = NO;
    }
    if ([GlobalData shared].isBindRD) {
        [SAVORXAPI volumeWithURL:STBURL action:action success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([[result objectForKey:@"result"] integerValue] == 0) {
                if (action == 1 || action == 2) {
                    self.footerView.muteBtn.enabled = YES;
                }else{
                    self.footerView.muteBtn.selected = NO;
                }
                if (action == 3) {
                    [SAVORXAPI postUMHandleWithContentId:@"video_to_screen_vol_down" key:nil value:nil];
                }else if (action == 4){
                    [SAVORXAPI postUMHandleWithContentId:@"video_to_screen_vol_up" key:nil value:nil];
                }
            }else{
                [MBProgressHUD showTextHUDwithTitle:[result objectForKey:@"info"]];
                if (action == 1 || action == 2) {
                    self.footerView.muteBtn.enabled = YES;
                    self.footerView.muteBtn.selected = !self.footerView.muteBtn.isSelected;
                }
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (action == 1 || action == 2) {
                self.footerView.muteBtn.enabled = YES;
                self.footerView.muteBtn.selected = !self.footerView.muteBtn.isSelected;
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showTextHUDwithTitle:@"播放失败"];
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
                [SAVORXAPI postUMHandleWithContentId:@"video_to_screen_vol_down" key:nil value:nil];
                if (self.DLNAVolume > 0) {
                    self.DLNAVolume--;
                }
                volume = self.DLNAVolume;
            }
                break;
                
            case 4:
            {
                [SAVORXAPI postUMHandleWithContentId:@"video_to_screen_vol_up" key:nil value:nil];
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
            if (action == 1 || action == 2) {
                self.footerView.muteBtn.enabled = YES;
            }else{
                self.footerView.muteBtn.selected = NO;
            }
        } failure:^{
            if (action == 1 || action == 2) {
                self.footerView.muteBtn.enabled = YES;
                self.footerView.muteBtn.selected = !self.footerView.muteBtn.isSelected;
            }
        }];
    }
}

-(void)voideoPlayStatusCellConnectAction{
    
    if (![GlobalData shared].isBindRD && ![GlobalData shared].isBindDLNA) {
        [[HomeAnimationView animationView] scanQRCode];
        return;
    }
    [self isEnableFooter];
    [self restartVod];
    [self.tableView reloadData];
}

- (void)setIsPlayEnd:(BOOL)isPlayEnd
{
    _isPlayEnd = isPlayEnd;
    [self.footerView setQuitButtonStates:isPlayEnd];
}

- (void)navBackButtonClicked:(UIButton *)sender
{
    [self shouldRelease];
    UINavigationController * na = [Helper getRootNavigationController];
    if ([NSStringFromClass([na class]) isEqualToString:@"BaseNavigationController"] && self.model) {
        UIViewController * vc = [na.viewControllers firstObject];
        [self.navigationController popToViewController:vc animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    [SAVORXAPI postUMHandleWithContentId:@"video_to_screen_back_list" key:nil value:nil];
}

-(void)isEnableFooter{
    
    if (![GlobalData shared].isBindRD && ![GlobalData shared].isBindDLNA){
        
        [self.footerView voideoPlayFooterViewisEnable:YES];
    }else{
        [self.footerView voideoPlayFooterViewisEnable:NO];
    }
}

- (void)videoDidPlayEnd
{
    self.headBackView.mininumLabel.text = @"00:00";
    self.headBackView.palySlider.value = 0;
    self.footerView.videoPlayButton.selected = YES;
    self.isPlayEnd = YES;
    [self.timer invalidate];
    self.timer = nil;
    if (self.task) {
        [self.task cancel];
    }
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
