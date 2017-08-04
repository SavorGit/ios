//
//  PhotoVideoScreenViewController.m
//  SavorX
//
//  Created by 郭春城 on 2017/7/6.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "PhotoVideoScreenViewController.h"
#import "RDAlertView.h"
#import "HSConnectViewController.h"
#import "RDHomeStatusView.h"
#import "RDInteractionLoadingView.h"

@interface PhotoVideoScreenViewController ()

@property (nonatomic, strong) UIImageView * backImageView;
@property (nonatomic, strong) UILabel *minimumLabel; //最小时间显示
@property (nonatomic, strong) UISlider *playSilder; //进度条控制
@property (nonatomic, strong) UILabel *maximumLabel; //最大时间显示
@property (nonatomic, strong) NSURL * url;

@property (nonatomic, strong) UIView * toolView;
@property (nonatomic, strong) UIButton * playButton;
@property (nonatomic, strong) UIButton * scrennButton;
@property (nonatomic, strong) UIButton * volumeButton;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isPlayEnd;
@property (nonatomic, assign) BOOL isNoVolume;

@property (nonatomic, strong) NSURLSessionDataTask * lastTask;
@property (nonatomic, assign) CGFloat lastValue;
@property (nonatomic, strong) UIView * alertView;

@property (nonatomic, strong) UIView * progressView;
@property (nonatomic, strong) UILabel * percentageLab;

@end

@implementation PhotoVideoScreenViewController

- (instancetype)initWithVideoFileURL:(NSString *)url
{
    if (self = [super init]) {
        self.url = [NSURL fileURLWithPath:url];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGB(0xf6f2ed);
    [self createUI];
}

- (void)createUI
{
    AVAsset * asset = [AVAsset assetWithURL:self.url];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.backImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.backImageView setImage:[UIImage imageNamed:@"sptpdb_bg"]];
    [self.view addSubview:self.backImageView];
    self.backImageView.userInteractionEnabled = YES;
    [self.backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.equalTo(self.view.mas_width).multipliedBy(254.f/414.f);
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
    self.playSilder.maximumValue = (NSInteger)asset.duration.value / asset.duration.timescale;;
    [self.playSilder setMinimumTrackTintColor:UIColorFromRGB(0xcf3850)];
    [self.playSilder setMaximumTrackTintColor:[UIColorFromRGB(0xffffff) colorWithAlphaComponent:.5f]];
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
    NSInteger pLayDurationInt = (NSInteger)asset.duration.value / asset.duration.timescale;
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
    
    [self createToolView];
}

- (void)createToolView
{
    UIView * bottomView = [[UIView alloc] init];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backImageView.mas_bottom);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    self.toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth - 80, kMainBoundsWidth - 80)];
//    self.toolView.backgroundColor = [UIColor blueColor];
    [bottomView addSubview:self.toolView];
    [self.toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.size.mas_equalTo(self.toolView.frame.size);
    }];
    self.toolView.layer.cornerRadius = 15;
    self.toolView.layer.masksToBounds = YES;
    self.toolView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.2f].CGColor;
    self.toolView.layer.borderWidth = 5;
    
    UIView * playView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.toolView.frame.size.width / 2 - 30, self.toolView.frame.size.height / 2 - 30)];
    [self.toolView addSubview:playView];
    [playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.toolView.frame.size.width / 2 - 30);
        make.top.mas_equalTo(30);
        make.centerX.mas_equalTo(0);
    }];
    playView.layer.cornerRadius = playView.frame.size.width / 2;
    playView.layer.masksToBounds = YES;
    playView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.2f].CGColor;
    playView.layer.borderWidth = 5;
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.frame = CGRectMake(0, 0, playView.frame.size.width - 50, playView.frame.size.width - 50);
//    [self.playButton setAdjustsImageWhenHighlighted:NO];
    [playView addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.size.mas_equalTo(self.playButton.frame.size);
    }];
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"control_bg"] forState:UIControlStateNormal];
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"controlanxia_bg"] forState:UIControlStateHighlighted];
    [self.playButton addTarget:self action:@selector(playButtonDidBeClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.scrennButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.scrennButton.frame = CGRectMake(0, 0, self.playButton.frame.size.width - 10, self.playButton.frame.size.width - 10);
    [self.scrennButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    //    [self.playButton setAdjustsImageWhenHighlighted:NO];
    [self.toolView addSubview:self.scrennButton];
    [self.scrennButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(playView.mas_centerY).offset(5);
        make.right.equalTo(playView.mas_left).offset(-10);
        make.size.mas_equalTo(self.scrennButton.frame.size);
    }];
    [self.scrennButton setBackgroundImage:[UIImage imageNamed:@"control_bg"] forState:UIControlStateNormal];
    [self.scrennButton setBackgroundImage:[UIImage imageNamed:@"controlanxia_bg"] forState:UIControlStateHighlighted];
    [self.scrennButton addTarget:self action:@selector(scrennButtonDidBeClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.volumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.volumeButton.frame = CGRectMake(0, 0, self.playButton.frame.size.width - 10, self.playButton.frame.size.width - 10);
    [self.volumeButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    //    [self.playButton setAdjustsImageWhenHighlighted:NO];
    [self.toolView addSubview:self.volumeButton];
    [self.volumeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(playView.mas_centerY).offset(5);
        make.left.equalTo(playView.mas_right).offset(10);
        make.size.mas_equalTo(self.volumeButton.frame.size);
    }];
    [self autoVolumeButtonStatus];
    [self.volumeButton setBackgroundImage:[UIImage imageNamed:@"control_bg"] forState:UIControlStateNormal];
    [self.volumeButton setBackgroundImage:[UIImage imageNamed:@"controlanxia_bg"] forState:UIControlStateHighlighted];
    [self.volumeButton addTarget:self action:@selector(volumeButtonDidBeClicked) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat toolWidth = self.toolView.frame.size.width - 60;
    UIView * volumeTool = [[UIView alloc] initWithFrame:CGRectMake(0, 0, toolWidth, toolWidth / 204 * 55)];
    volumeTool.backgroundColor = kThemeColor;
    [self.toolView addSubview:volumeTool];
    [volumeTool mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(playView.mas_bottom).offset(30);
        make.size.mas_equalTo(volumeTool.frame.size);
    }];
    volumeTool.layer.cornerRadius = volumeTool.frame.size.height / 2;
    volumeTool.layer.masksToBounds = YES;
    
    UIView * lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor whiteColor];
    [volumeTool addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(-10);
        make.width.mas_equalTo(.5f);
        make.centerX.mas_equalTo(0);
    }];
    
    UIButton * addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setBackgroundImage:[UIImage imageNamed:@"yljian"] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageNamed:@"yljiananxia"] forState:UIControlStateHighlighted];
    [volumeTool addSubview:addButton];
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.equalTo(volumeTool.mas_centerX).offset(0);
    }];
    addButton.tag = 101;
    [addButton addTarget:self action:@selector(volumeDidHandleWith:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * minusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [minusButton setBackgroundImage:[UIImage imageNamed:@"yljia"] forState:UIControlStateNormal];
    [minusButton setBackgroundImage:[UIImage imageNamed:@"yljiaanxia"] forState:UIControlStateHighlighted];
    [volumeTool addSubview:minusButton];
    [minusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.equalTo(volumeTool.mas_centerX).offset(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    minusButton.tag = 102;
    [minusButton addTarget:self action:@selector(volumeDidHandleWith:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([GlobalData shared].isBindRD) {
        self.isPlaying = YES;
        self.isPlayEnd = NO;
    }else{
        self.isPlaying = NO;
        self.isPlayEnd = YES;
        [self alertView];
    }
    [self autoScrennButtonStatus];
    [self autoPlayButtonStatus];
    
    [self.playSilder addTarget:self action:@selector(sliderValueChange) forControlEvents:UIControlEventValueChanged];
    [self.playSilder addTarget:self action:@selector(sliderStartTouch) forControlEvents:UIControlEventTouchDown];
    [self.playSilder addTarget:self action:@selector(sliderEndTouch) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    [self addNotification];
}

- (void)sliderStartTouch
{
    if (self.lastTask) {
        [self.lastTask cancel];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateQuery) object:nil];
    self.lastValue = self.playSilder.value;
}

- (void)sliderValueChange
{
    [self updateTimeLabel:self.playSilder.value];
}

- (void)sliderEndTouch
{
    if ([GlobalData shared].isBindRD) {
        
        if (self.isPlayEnd) {
            [self resetVod];
        }else{
            NSString * value;
            if (self.playSilder.value < 1) {
                value = [NSString stringWithFormat:@"%0.0f",self.playSilder.value + 1.f];
            }else{
                value = [NSString stringWithFormat:@"%0.0f",self.playSilder.value];
            }
            [SAVORXAPI seekVideoWithURL:STBURL position:value success:^(NSURLSessionDataTask *task, NSDictionary *result) {
                
                if ([[result objectForKey:@"result"] integerValue] == 0) {
                    [self autoPlayButtonStatus];
                }else{
                    [MBProgressHUD showTextHUDwithTitle:[result objectForKey:@"info"]];
                    [self.playSilder setValue:self.lastValue animated:YES];
                }
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
                [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FailedWithHandel")];
                [self.playSilder setValue:self.lastValue animated:YES];
                
            }];
        }
        
    }else{
        [self.playSilder setValue:0 animated:YES];
    }
    
}

//对音量的加减进行操作
- (void)volumeDidHandleWith:(UIButton *)button
{
    if (![GlobalData shared].isBindRD) {
        [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_PleaseConnetToTV") delay:1.f];
        return;
    }
    
    button.userInteractionEnabled = NO;
    NSInteger action;
    if (button.tag == 101) {
        [SAVORXAPI postUMHandleWithContentId:@"video_to_screen_vol_down" key:nil value:nil];
        //减声音
        action = 3;
    }else{
        [SAVORXAPI postUMHandleWithContentId:@"video_to_screen_vol_up" key:nil value:nil];
        //加声音
        action = 4;
    }
    [SAVORXAPI volumeWithURL:STBURL action:action success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        button.userInteractionEnabled = YES;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        button.userInteractionEnabled = YES;
    }];
}

//静音按钮被点击了
- (void)volumeButtonDidBeClicked
{
    if (![GlobalData shared].isBindRD) {
        [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_PleaseConnetToTV") delay:1.f];
    }
    self.volumeButton.userInteractionEnabled = NO;
    NSInteger action = 1;
    if (self.isNoVolume) {
        action = 2;
    }
    [SAVORXAPI volumeWithURL:STBURL action:action success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        
        if ([[result objectForKey:@"result"] integerValue] == 0) {
            self.isNoVolume = !self.isNoVolume;
            [self autoVolumeButtonStatus];
        }
        self.volumeButton.userInteractionEnabled = YES;
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        self.volumeButton.userInteractionEnabled = YES;
    }];
}

//根据当前静音状态改变静音按钮
- (void)autoVolumeButtonStatus
{
    if (self.isNoVolume) {
        [self.volumeButton setImage:[UIImage imageNamed:@"sptplaba_jingyin"] forState:UIControlStateNormal];
    }else{
        [self.volumeButton setImage:[UIImage imageNamed:@"sptplaba_dianbo"] forState:UIControlStateNormal];
    }
}

//投屏按钮被点击了
- (void)scrennButtonDidBeClicked
{
    if (![GlobalData shared].isBindRD) {
        [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_PleaseConnetToTV") delay:1.f];
        return;
    }
    if (self.isPlayEnd) {
        [self resetVod];
    }else{
        [SAVORXAPI postUMHandleWithContentId:@"video_to_screen_exit_screen" key:nil value:nil];
        [SAVORXAPI ScreenDemandShouldBackToTVWithSuccess:^{
            self.isPlayEnd = YES;
            self.isPlaying = NO;
            [self autoPlayButtonStatus];
            [self autoScrennButtonStatus];
        } failure:^{
            [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FailedWithHandel")];
        }];
    }
}

- (void)resetVod
{
    NSString *asseturlStr = [NSString stringWithFormat:@"%@video?%@", [HTTPServerManager getCurrentHTTPServerIP], RDScreenVideoName];
    [self demandVideoWithMediaPath:asseturlStr force:0];
}

- (void)demandVideoWithMediaPath:(NSString *)mediaPath force:(NSInteger)force{
    RDInteractionLoadingView * hud = [[RDInteractionLoadingView alloc] initWithView:self.view title:RDLocalizedString(@"RDString_Screening")];
    
    [SAVORXAPI postVideoWithURL:STBURL mediaPath:mediaPath position:@"0" force:force success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        if ([[result objectForKey:@"result"] integerValue] == 0) {
            
            [[RDHomeStatusView defaultView] startScreenWithViewController:self withStatus:RDHomeStatus_Video];
            self.isPlaying = YES;
            self.isPlayEnd = NO;
            [self autoPlayButtonStatus];
            [self autoScrennButtonStatus];
            
            [SAVORXAPI postUMHandleWithContentId:@"video_to_screen_play" key:nil value:nil];
            
        }else if ([[result objectForKey:@"result"] integerValue] == 4) {
            
            NSString *infoStr = [result objectForKey:@"info"];
            RDAlertView *alertView = [[RDAlertView alloc] initWithTitle:RDLocalizedString(@"RDString_AlertWithScreen") message:[NSString stringWithFormat:@"%@%@%@", RDLocalizedString(@"RDString_ScreenContinuePre"), infoStr, RDLocalizedString(@"RDString_ScreenContinueSuf")]];
            RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:RDLocalizedString(@"RDString_Cancle") handler:^{
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" withParmDic:@{@"to_screen_competition_hint" : @"cancel",@"type" : @"video"}];
            } bold:NO];
            RDAlertAction * actionOne = [[RDAlertAction alloc] initWithTitle:RDLocalizedString(@"RDString_ContinueScreen") handler:^{
                [self demandVideoWithMediaPath:mediaPath force:1];
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" withParmDic:@{@"to_screen_competition_hint" : @"ensure",@"type" : @"video"}];
            } bold:YES];
            [alertView addActions:@[action,actionOne]];
            [alertView show];
            
        }
        else{
            [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
        }
        [hud hidden];
        self.playButton.userInteractionEnabled = YES;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [hud hidden];
        [MBProgressHUD showTextHUDwithTitle:ScreenFailure];
        self.playButton.userInteractionEnabled = YES;
    }];
}

//根据投屏状态改变投屏按钮
- (void)autoScrennButtonStatus
{
    if (self.isPlayEnd) {
        [self.scrennButton setTitle:RDLocalizedString(@"RDString_Screen") forState:UIControlStateNormal];
        
        self.minimumLabel.text = @"00:00";
        self.playSilder.value = 0;
        
    }else{
        [self.scrennButton setTitle:RDLocalizedString(@"RDString_Back") forState:UIControlStateNormal];
    }
}

//播放按钮被点击了
- (void)playButtonDidBeClicked
{
    if (![GlobalData shared].isBindRD) {
        [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_PleaseConnetToTV") delay:1.f];
        return;
    }
    
    self.playButton.userInteractionEnabled = NO;
    
    if (self.isPlayEnd) {
        [self resetVod];
    }else if (self.isPlaying) {
        [SAVORXAPI pauseVideoWithURL:STBURL success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            
            if ([[result objectForKey:@"result"] integerValue] == 0) {
                self.isPlaying = !self.isPlaying;
                [self autoPlayButtonStatus];
            }
            self.playButton.userInteractionEnabled = YES;
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            self.playButton.userInteractionEnabled = YES;
        }];
    }else{
        [SAVORXAPI resumeVideoWithURL:STBURL success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            
            if ([[result objectForKey:@"result"] integerValue] == 0) {
                self.isPlaying = !self.isPlaying;
                [self autoPlayButtonStatus];
            }
            self.playButton.userInteractionEnabled = YES;
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            self.playButton.userInteractionEnabled = YES;
        }];
    }
}

//根据播放状态改变播放按钮
- (void)autoPlayButtonStatus
{
    if (self.isPlaying) {
        [self.playButton setImage:[UIImage imageNamed:@"sptpbofang"] forState:UIControlStateNormal];
        
        [self performSelector:@selector(updateQuery) withObject:nil afterDelay:1.0];
        
    }else{
        [SAVORXAPI postUMHandleWithContentId:@"video_to_screen_pause" key:nil value:nil];
        [self.playButton setImage:[UIImage imageNamed:@"sptpzanting"] forState:UIControlStateNormal];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateQuery) object:nil];
    }
}

//更新进度
- (void)updateQuery
{
    if (self.lastTask) {
        [self.lastTask cancel];
    }
    
    self.lastTask = [SAVORXAPI queryVideoWithURL:STBURL success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        
        NSInteger code = [[result objectForKey:@"result"] integerValue];
        if (code == 0) {
            CGFloat posFloat = [[result objectForKey:@"pos"] floatValue]/1000;
            [self.playSilder setValue:posFloat];
            [self updateTimeLabel:posFloat];
        }else if (code == -1 || code == 1){
            [self videoDidPlayEnd];
            if ([RDHomeStatusView defaultView].status == RDHomeStatus_Video) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    [self performSelector:@selector(updateQuery) withObject:nil afterDelay:1.0];
}

//视频播放结束
- (void)videoDidPlayEnd;
{
    self.isPlayEnd = YES;
    self.isPlaying = NO;
    
    [self autoPlayButtonStatus];
    [self autoScrennButtonStatus];
}

//根据进度条更新播放时间显示
- (void)updateTimeLabel:(CGFloat)posFloat
{
    [SAVORXAPI postUMHandleWithContentId:@"video_to_screen_drag_progress" key:nil value:nil];
    if (posFloat > self.playSilder.maximumValue) {
        return;
    }
    
    NSInteger pLayDurationInt = (NSInteger)posFloat; // some duration from the JSON
    NSInteger playMinutesInt = pLayDurationInt / 60;
    NSInteger playSecondsInt = pLayDurationInt % 60;
    
    NSString *playTimeStr = [NSString stringWithFormat:@"%02ld:%02ld", (long)playMinutesInt, (long)playSecondsInt];
    [self.minimumLabel setText:playTimeStr];
}

- (void)navBackButtonClicked:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [SAVORXAPI postUMHandleWithContentId:@"album_toscreen_video_back" key:nil value:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (UIView *)alertView
{
    if (!_alertView) {
        _alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 40)];
        _alertView.backgroundColor = UIColorFromRGB(0xf6f2ed);
        [self.view addSubview:_alertView];
        [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.backImageView.mas_bottom);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(40);
        }];
        
        UIImageView * imageView = [[UIImageView alloc] init];
        [imageView setImage:[UIImage imageNamed:@"sptpwlj"]];
        [_alertView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.size.mas_equalTo(CGSizeMake(32, 22));
            make.centerY.mas_equalTo(0);
        }];
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:RDLocalizedString(@"RDString_ConnetToTV") forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0x54453e) forState:UIControlStateNormal];
        button.layer.borderColor = UIColorFromRGB(0xcdc4b9).CGColor;
        button.layer.borderWidth = .5f;
        button.layer.cornerRadius = 3;
        button.layer.masksToBounds = YES;
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [_alertView addSubview:button];
        [button addTarget:self action:@selector(connectToBox) forControlEvents:UIControlEventTouchUpInside];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.bottom.mas_equalTo(-10);
            make.right.mas_equalTo(-10);
            make.width.mas_equalTo(60);
        }];
        
        UILabel * label = [[UILabel alloc] init];
        label.text = RDLocalizedString(@"RDString_ClickToConnetToTV");
        label.textColor = UIColorFromRGB(0x922c3e);
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentLeft;
        [_alertView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView.mas_right).offset(10);
            make.right.mas_equalTo(button.mas_left).offset(-10);
            make.centerY.mas_equalTo(0);
            make.height.mas_equalTo(16);
        }];
    }
    return _alertView;
}

- (void)connectToBox
{
    [[RDHomeStatusView defaultView] scanQRCode];
}

- (void)voideoPlayDidConnect
{
    [self.alertView removeFromSuperview];
    [self resetVod];
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voideoPlayDidConnect) name:RDDidBindDeviceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidPlayEnd) name:RDBoxQuitScreenNotification object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidBindDeviceNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDBoxQuitScreenNotification object:nil];
}

- (void)dealloc
{
    [self removeNotification];
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
