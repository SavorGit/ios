//
//  SmashEggsGameViewController.m
//  SavorX
//
//  Created by 王海朋 on 2017/5/8.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "SmashEggsGameViewController.h"
#import "HSEggsResultModel.h"
#import "RDGoldenEggs.h"
#import "RDPrizeView.h"
#import "RDAlertView.h"
#import "RDAlertAction.h"
#import "RDAwardTool.h"
#import "Helper.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "HomeAnimationView.h"
#import "RDHammer.h"
#import "ShareRDViewController.h"

@interface SmashEggsGameViewController ()<UITextViewDelegate,RDGoldenEggsDelegate,AVAudioPlayerDelegate,RDPrizeViewDelegate>

@property (nonatomic ,strong) UILabel *titleLabel;
@property (nonatomic ,strong) UITextView *ruleTextView;
@property (nonatomic ,strong) RDGoldenEggs * eggsView;
@property (nonatomic ,strong) UILabel *timeLabel;
@property (nonatomic ,assign) int timeCount;
@property (nonatomic ,strong) NSTimer *timer;
@property (nonatomic ,strong) UIView *maskingView;
@property (nonatomic ,strong) UIImageView *textBgView;
@property (nonatomic ,assign) BOOL isShake;
@property (nonatomic ,strong) UILabel *prizeLevelLab;
@property (nonatomic, strong) NSMutableDictionary *shouldDemandDict;
@property (nonatomic, strong) UIImageView *upBgView;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, weak) RDHammer * hammer;

@end

@implementation SmashEggsGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initOtherParmars];
    [self creatSubViews];
    [self creatBgVoice];
    [_player play];
 
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"恢复机会" style:UIBarButtonItemStyleDone target:self action:@selector(addMoreChance)];
}

- (void)addMoreChance
{
    [RDAwardTool awardAddMoreChance];
    _titleLabel.text = [NSString stringWithFormat:@"您当前有%ld次机会", [RDAwardTool awardGetLottery_num]];
}

// 初始化基本参数
- (void)initOtherParmars{
    _videoUrl = [[NSBundle mainBundle] URLForResource:@"selectEggs" withExtension:@"mp3"];
    self.title = @"砸蛋游戏";
    _isShake = NO;
    self.shouldDemandDict = [[NSMutableDictionary alloc] init];
    [self.shouldDemandDict setObject:@(NO) forKey:@"should"];
}

- (void)creatBgVoice{

    NSError *err;
    //初始化播放器
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:_videoUrl error:&err];
    _player.volume = 0.3;
    _player.delegate = self;
    _player.numberOfLoops = -1;
    //设置播放速率
    _player.rate = 1.0;
    //准备播放
    [_player prepareToPlay];
    
}

- (void)play {
    //开始播放
    [_player play];
}

- (void)stop{
    //暂停播放
    [_player stop];
}

- (void)creatSubViews{
    
    UIScrollView *bgScrollView = [[UIScrollView alloc] init];
    bgScrollView.contentSize = CGSizeMake(kMainBoundsWidth, 412 + 476);
    bgScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:bgScrollView];
    [bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, kMainBoundsHeight));
        make.top.mas_equalTo(0);
    }];
    
    _upBgView = [[UIImageView alloc] init];
    _upBgView.backgroundColor = [UIColor clearColor];
    [_upBgView setImage:[UIImage imageNamed:@"zajindanup_bg"]];
    _upBgView.userInteractionEnabled = YES;
    [bgScrollView addSubview:_upBgView];
    [_upBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 412));
        make.top.mas_equalTo(self.view.top);
        make.centerX.equalTo(self.view);
    }];
    
    UIImageView *downBgView = [[UIImageView alloc] init];
    downBgView.backgroundColor = [UIColor clearColor];
    downBgView.image = [UIImage imageNamed:@"zajindandown_bg"];
    downBgView.userInteractionEnabled = YES;
    [bgScrollView addSubview:downBgView];
    [downBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 476));
        make.top.mas_equalTo(_upBgView.mas_bottom);
    }];
    
    UIImageView *lucyLgImgView = [[UIImageView alloc] init];
    lucyLgImgView.backgroundColor = [UIColor clearColor];
    lucyLgImgView.image = [UIImage imageNamed:@"zdwenan"];
    lucyLgImgView.userInteractionEnabled = YES;
    [bgScrollView addSubview:lucyLgImgView];
    [lucyLgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(256, 176));
        make.top.mas_equalTo(40);
        make.centerX.equalTo(self.view);
    }];
    
    //创建金蛋视图对象
    [self creatEggMiddleView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.textColor = UIColorFromRGB(0xfbeed9);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = [NSString stringWithFormat:@"您当前有%ld次机会", [RDAwardTool awardGetLottery_num]];
    [bgScrollView addSubview:_titleLabel];
    CGFloat textLabelWidth = [Helper autoWidthWith:150.f];
    CGFloat textLabelHeight = [Helper autoHeightWith:20.f];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(textLabelWidth, textLabelHeight));
        make.top.mas_equalTo(_eggsView.mas_bottom).offset(37);
        make.centerX.equalTo(self.view);
    }];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setImage:[UIImage imageNamed:@"yaoqing_anniu"] forState:UIControlStateNormal];
    [shareBtn setBackgroundColor:[UIColor clearColor]];
    [shareBtn addTarget:self action:@selector(sharePress:) forControlEvents:UIControlEventTouchUpInside];
    [bgScrollView addSubview:shareBtn];
    [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(167, 48));
        make.top.mas_equalTo(_titleLabel.mas_bottom).offset(15);
        make.centerX.equalTo(self.view);
    }];
    
    _textBgView = [[UIImageView alloc] init];
    _textBgView.backgroundColor = [UIColor clearColor];
    _textBgView.userInteractionEnabled = YES;
    _textBgView.layer.masksToBounds = YES;
    _textBgView.layer.borderWidth = 1.0;
    _textBgView.layer.borderColor = UIColorFromRGB(0xf3ebdb).CGColor;
    [bgScrollView addSubview:_textBgView];
    [_textBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 40, 200));
        make.top.mas_equalTo(shareBtn.mas_bottom).offset(38);
        make.left.mas_equalTo(20);
    }];
    
    UIImageView *gameRuleimgView = [[UIImageView alloc] init];
    gameRuleimgView.backgroundColor = [UIColor clearColor];
    gameRuleimgView.image = [UIImage imageNamed:@"youxigz_bg"];
    gameRuleimgView.userInteractionEnabled = YES;
    [_textBgView addSubview:gameRuleimgView];
    [gameRuleimgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(115, 35));
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];

    
    UILabel *gameRuleLab = [[UILabel alloc] init];
    gameRuleLab.font = [UIFont systemFontOfSize:17];
    gameRuleLab.textColor = UIColorFromRGB(0x222222);
    gameRuleLab.textAlignment = NSTextAlignmentLeft;
    gameRuleLab.text = @"游戏规则";
    [gameRuleimgView addSubview:gameRuleLab];
    [gameRuleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 30));
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(10);
    }];
    
    _ruleTextView = [[UITextView alloc] init];
    _ruleTextView.textColor = UIColorFromRGB(0xf3ebdb);
    _ruleTextView.backgroundColor = [UIColor clearColor];
    _ruleTextView.font = [UIFont systemFontOfSize:12];
    _ruleTextView.editable = NO;
    _ruleTextView.delegate = self;
    _ruleTextView.text = @"1.此游戏为手机与电视同步互动游戏，参与此活动者需先连接电视；\n\n2.每个用户连接电视后，可选择上面任意一个蛋砸开；\n\n3.游戏时间：每天11:00-14:00/17:00-21:00";
    _ruleTextView.scrollEnabled = NO;
    [_textBgView addSubview:_ruleTextView];
    [_ruleTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(301, 150));
        make.top.mas_equalTo(gameRuleimgView.mas_bottom).offset(10);
        make.left.mas_equalTo(15);
    }];
    
}

- (void)creatEggMiddleView{
    
    _eggsView = [[RDGoldenEggs alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 123) andEggImage:[UIImage imageNamed:@"jindan"]];
    _eggsView.delegate = self;
    [_eggsView startShakeAnimation];
    [self.view addSubview:_eggsView];
    [_eggsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 123));
        make.bottom.mas_equalTo(_upBgView.mas_bottom).offset(-25);
        make.left.mas_equalTo(0);
    }];

}

//点击金蛋的代理回调
- (void)RDGoldenEggs:(RDGoldenEggs *)eggsView didSelectEggWithIndex:(NSInteger)index
{
    if ([RDAwardTool awardCanAwardWithAPILottery_num:self.adModel.lottery_num] == NO) {
        RDAlertView *alertView = [[RDAlertView alloc] initWithTitle:@"" message:@"今天的抽奖机会用完了\n明天再来吧~"];
        RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"我知道了" handler:^{
            
        } bold:NO];
        [alertView addActions:@[action]];
        [alertView show];
        return;
    }

    
    if (([GlobalData shared].isBindRD)) {
        [self requestForEggsNetWork];
        [self stop];
        [self.eggsView stopShakeAnimation];
    }else{
        [self.shouldDemandDict setObject:@(YES) forKey:@"should"];
        [[HomeAnimationView animationView] scanQRCode];
    }
    
}

// 创建中奖结果页面
- (void)creatPrizeMiddleView:(HSEggsResultModel *)model{
    
    RDPrizeView *prizeView = [[RDPrizeView alloc] initWithFrame:CGRectMake(0, 0, 294, 244) withModel:model];
    prizeView.delegate = self;
    [_maskingView addSubview:prizeView];
    [prizeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(294, 244));
        make.center.equalTo(self.view);
    }];
    
    UIButton *prCloseimgBtn = [[UIButton alloc] init];
    [prCloseimgBtn setImage:[UIImage imageNamed:@"zjjg_guanbi"] forState:UIControlStateNormal];
    [prCloseimgBtn addTarget:self action:@selector(prizeClosed) forControlEvents:UIControlEventTouchUpInside];
    [_maskingView addSubview:prCloseimgBtn];
    [prCloseimgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(32, 61));
        make.left.mas_equalTo(kMainBoundsWidth - 90);
        make.bottom.mas_equalTo(prizeView.mas_top);
    }];
}

- (void)prizeClosed{
    [_maskingView removeFromSuperview];
    [self eggsViewStartAnimation];
    [SAVORXAPI screenEggsStopGame];
}

- (void)sharePress:(UIButton *)button{
    ShareRDViewController * share = [[ShareRDViewController alloc] init];
    share.title = @"推荐";
    [self.navigationController pushViewController:share animated:YES];
}

// 创建蒙层倒计时
- (void)creatMaskingView{
    
    _maskingView = [[UIView alloc] init];
    _maskingView.frame = CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight);
    _maskingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.9f];
    [self.view addSubview:_maskingView];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont boldSystemFontOfSize:80];
    _timeLabel.textColor = [UIColor orangeColor];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.text = @"3";
    [_maskingView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 80));
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
    }];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeHandel) userInfo:nil repeats:YES];
    _timeCount = 3;

}

// 创建锤子砸蛋中页面
- (void)creatPlayHammerViews{
    
    UIImageView *haTitleImgView = [[UIImageView alloc] init];
    haTitleImgView.image = [UIImage imageNamed:@"yaoyiyao"];
    haTitleImgView.userInteractionEnabled = YES;
    [_maskingView addSubview:haTitleImgView];
    [haTitleImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(215, 73));
        make.centerX.equalTo(_maskingView);
        make.top.mas_equalTo(_maskingView.top).offset(100);
        
    }];
    
    RDHammer *hammer = [[RDHammer alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth - 20, 250)];
    [_maskingView addSubview:hammer];
    [hammer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 20, 250));
        make.top.mas_equalTo(haTitleImgView.mas_bottom).offset(10);
        make.left.mas_equalTo(10);
        
    }];
    self.hammer = hammer;
    
    UIButton *haCloseImgBtn = [[UIButton alloc] init];
    [haCloseImgBtn setImage:[UIImage imageNamed:@"yao_guanbi"] forState:UIControlStateNormal];
    [haCloseImgBtn addTarget:self action:@selector(haClosed) forControlEvents:UIControlEventTouchUpInside];
    [_maskingView addSubview:haCloseImgBtn];
    [haCloseImgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(32, 32));
        make.centerX.equalTo(self.view);
        make.top.mas_equalTo(hammer.mas_bottom).offset(70);
    }];
    
}
- (void)haClosed{
    
    [_maskingView removeFromSuperview];
    [self eggsViewStartAnimation];
    _isShake = NO;
    [SAVORXAPI screenEggsStopGame];
}

// 倒计时控制器
- (void)timeHandel{
     _timeCount--;
    _timeLabel.text = [NSString stringWithFormat:@"%i",_timeCount];
    if (_timeCount <= 0) {
        [_timer invalidate];
        _timer = nil;
        [_maskingView removeAllSubviews];
        [self creatPlayHammerViews];
        _isShake = YES;
    }
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (_isShake == YES) {
        NSLog(@"开始摇一摇");
        [self.hammer startShakeAnimation];
        [self requestHitEggNetWork];
        _videoUrl = [[NSBundle mainBundle] URLForResource:@"glass" withExtension:@"mp3"];
        [self creatBgVoice];
        _player.numberOfLoops = 0;
        [self play];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }

}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (_isShake == YES) {
        [self.hammer stopShakeAnimation];
        NSLog(@"取消摇一摇");
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (_isShake == YES) {
        [self.hammer stopShakeAnimation];
        NSLog(@"结束摇一摇");
    }
}

// 请求砸蛋连接
- (void)requestForEggsNetWork{
    
    NSInteger isGetPrize;
    if ( [RDAwardTool awardShouldWin] == YES) {
        isGetPrize = 1;
    }else{
        isGetPrize = 0;
    }
    
    NSString *currentDate = [Helper getCurrentTimeWithFormat:@"yyyyMMdd"];
    //如果是绑定状态
    if ([GlobalData shared].isBindRD) {
        
        MBProgressHUD * hud = [MBProgressHUD showCustomLoadingHUDInView:self.view];
        
        [SAVORXAPI  gameForEggsWithURL:STBURL hunger:(NSInteger)isGetPrize date:(NSString *)currentDate success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            if ([[result objectForKey:@"result"] integerValue] == 0) {
                [self creatMaskingView];
                
            }else{
                [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
                [self eggsViewStartAnimation];
            }
            [hud hideAnimated:NO];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [hud hideAnimated:NO];
            [MBProgressHUD showTextHUDwithTitle:@"请求失败，请重试"];
            [self eggsViewStartAnimation];
        }];
        
    }else{
        [[HomeAnimationView animationView] scanQRCode];
    }
}

// 请求砸蛋结果
- (void)requestHitEggNetWork{
    
    //如果是绑定状态
    if ([GlobalData shared].isBindRD) {
        
        [SAVORXAPI  gameSmashedEggWithURL:STBURL success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            if ([[result objectForKey:@"result"] integerValue] == 0) {
                HSEggsResultModel *erModel = [[HSEggsResultModel alloc] initWithDictionary:result];
                
                if (erModel.done == 1) {
                    
                    if (_isShake == NO) {
                        return;
                    }
                    
                    _isShake = NO;
                    [self.hammer stopShakeAnimation];
                    
                    //进行了一次抽奖
                    [RDAwardTool awardHasAwardWithResultModel:erModel];
                    _titleLabel.text = [NSString stringWithFormat:@"您当前有%ld次机会", [RDAwardTool awardGetLottery_num]];
                    if (erModel.win == 1) {
                        NSLog(@"获得奖品了");
                    }else{
                        NSLog(@"没有获得奖品");
                    }
                    [_maskingView removeAllSubviews];
                    [self creatPrizeMiddleView:erModel];
                }
                
            }else{
                [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
        
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[self.shouldDemandDict objectForKey:@"should"] boolValue]) {
        [self requestForEggsNetWork];
        [self.shouldDemandDict setObject:@(NO) forKey:@"should"];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [self stop];
    if (_timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [SAVORXAPI screenEggsStopGame];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)eggsViewStartAnimation
{
    _videoUrl = [[NSBundle mainBundle] URLForResource:@"selectEggs" withExtension:@"mp3"];
    [self creatBgVoice];
    [self play];
    [self.eggsView startShakeAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
