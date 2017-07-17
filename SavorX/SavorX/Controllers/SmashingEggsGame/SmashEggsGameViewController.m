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
#import "RDHammer.h"
#import "ShareRDViewController.h"
#import "WinResultViewController.h"
#import "HSSmashEggsRequest.h"
#import "HSSmashEggsModel.h"
#import "GlobalData.h"
#import "RDHomeStatusView.h"
#import "RDInteractionLoadingView.h"

@interface SmashEggsGameViewController ()<UITextViewDelegate,RDGoldenEggsDelegate,AVAudioPlayerDelegate>

@property (nonatomic ,strong) UILabel *titleLabel;
@property (nonatomic ,strong) UITextView *ruleTextView;
@property (nonatomic ,strong) RDGoldenEggs * eggsView;
@property (nonatomic ,strong) UILabel *timeLabel;
@property (nonatomic ,assign) int timeCount;
@property (nonatomic ,strong) NSTimer *timer;
@property (nonatomic ,strong) UIView *maskingView;
@property (nonatomic ,strong) UIImageView *textBgView;
@property (nonatomic ,assign) BOOL isShake;
@property (nonatomic, assign) BOOL isMotionning; //记录当前是否正在摇动
@property (nonatomic ,strong) UILabel *prizeLevelLab;
@property (nonatomic, strong) NSMutableDictionary *shouldDemandDict;
@property (nonatomic, strong) UIImageView *upBgView;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, weak) RDHammer * hammer;
@property (nonatomic, strong) HSSmashEggsModel *smashEggsModel;

@end

@implementation SmashEggsGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initOtherParmars];
    [self creatSubViews];
    [self creatBgVoiceWithLoops:-1];
    [_player play];
    
//    [self requestEggsInfor];
 
}

// 初始化基本参数
- (void)initOtherParmars{
    _videoUrl = [[NSBundle mainBundle] URLForResource:@"selectEggs" withExtension:@"mp3"];
    self.title = @"砸蛋游戏";
    _isShake = NO;
    self.shouldDemandDict = [[NSMutableDictionary alloc] init];
    [self.shouldDemandDict setObject:@(NO) forKey:@"should"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haClosed) name:RDBoxQuitScreenNotification object:nil];
}

// 请求砸蛋次数
- (void)requestEggsInfor{
    
    HSSmashEggsRequest * request = [[HSSmashEggsRequest alloc] initWithHotelId:[GlobalData shared].hotelId];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSDictionary *resultDic = [response objectForKey:@"result"];
        
        if ([[resultDic objectForKey:@"lottery_num"] count] != 0) {
            
            _smashEggsModel = [[HSSmashEggsModel alloc] initWithDictionary:[resultDic objectForKey:@"award"]];
            [RDAwardTool awardSaveAwardNumber:_smashEggsModel.lottery_num];
            _titleLabel.text = [NSString stringWithFormat:@"您当前有%ld次机会", [RDAwardTool awardGetLottery_num]];
        }

        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)creatBgVoiceWithLoops:(NSInteger)loop{

    NSError *err;
    
    if (_player) {
        if (_player.isPlaying) {
            [_player stop];
        }
    }
    
    //初始化播放器
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:_videoUrl error:&err];
    _player.volume = 0.3;
    _player.delegate = self;
    _player.numberOfLoops = loop;
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
        make.top.mas_equalTo(_eggsView.mas_bottom).offset(62);
        make.centerX.equalTo(self.view);
    }];
    
    UIButton *winResultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [winResultBtn setImage:[UIImage imageNamed:@"yaoqing_anniu"] forState:UIControlStateNormal];
    [winResultBtn setBackgroundColor:[UIColor clearColor]];
    [winResultBtn addTarget:self action:@selector(winResultPress) forControlEvents:UIControlEventTouchUpInside];
    [bgScrollView addSubview:winResultBtn];
    CGFloat distance = (kMainBoundsWidth - 167 *2)/3;
    [winResultBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(167, 48));
        make.top.mas_equalTo(_titleLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(distance);
    }];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setImage:[UIImage imageNamed:@"yaoqing_anniu"] forState:UIControlStateNormal];
    [shareBtn setBackgroundColor:[UIColor clearColor]];
    [shareBtn addTarget:self action:@selector(sharePress:) forControlEvents:UIControlEventTouchUpInside];
    [bgScrollView addSubview:shareBtn];
    [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(167, 48));
        make.top.mas_equalTo(_titleLabel.mas_bottom).offset(10);
        make.right.mas_equalTo(self.view).offset(-distance);
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
        make.top.mas_equalTo(shareBtn.mas_bottom).offset(35);
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
    _ruleTextView.font = [UIFont systemFontOfSize:15];
    _ruleTextView.editable = NO;
    _ruleTextView.delegate = self;
    _ruleTextView.text = @"1.此游戏为手机与电视同步互动游戏，参与此活动者须先连接电视；\n\n2.每个用户连接电视后，可选择上面任意一个蛋砸开；\n\n3.每个手机每天可以参与五次砸蛋";
    if (kMainBoundsWidth == 320) {
        _ruleTextView.font = [UIFont systemFontOfSize:13];
    }
    _ruleTextView.scrollEnabled = NO;
    [_textBgView addSubview:_ruleTextView];
    CGFloat ruleTextWidth = [Helper autoWidthWith:301.f];
    CGFloat ruleTextHeight = [Helper autoHeightWith:150.f];
    CGFloat ruleTextToLeft = [Helper autoWidthWith:15];
    [_ruleTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ruleTextWidth, ruleTextHeight));
        make.top.mas_equalTo(gameRuleimgView.mas_bottom).offset(10);
        make.left.mas_equalTo(_textBgView.mas_left).offset(ruleTextToLeft);
    }];
    
    UILabel * bottomLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    bottomLabel.textColor = UIColorFromRGB(0xf3ebdb);
    bottomLabel.backgroundColor = [UIColor clearColor];
    bottomLabel.font = [UIFont systemFontOfSize:15];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.text = @"本活动最终解释权归\"小热点\"所有";
    bottomLabel.userInteractionEnabled = YES;
    [downBgView addSubview:bottomLabel];
    [bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-80);
        make.height.mas_equalTo(20);
    }];
}

- (void)winResultPress{
    
    [self stop];
    [self.eggsView stopShakeAnimation];
    
    WinResultViewController *wrVC = [[WinResultViewController alloc] init];
    [self.navigationController pushViewController:wrVC animated:YES];
    
}

- (void)creatEggMiddleView{
    
    _eggsView = [[RDGoldenEggs alloc] initWithFrame:CGRectMake(0, 100, kMainBoundsWidth - 20, 123) andEggImage:[UIImage imageNamed:@"jindan"]];
    _eggsView.delegate = self;
    [_eggsView startShakeAnimation];
    [self.view addSubview:_eggsView];
    [_eggsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 20, 123));
        make.bottom.mas_equalTo(_upBgView.mas_bottom).offset(-25);
        make.left.mas_equalTo(10);
    }];

}

//点击金蛋的代理回调
- (void)RDGoldenEggs:(RDGoldenEggs *)eggsView didSelectEggWithIndex:(NSInteger)index
{
    [SAVORXAPI postUMHandleWithContentId:@"game_page_choose" key:nil value:nil];
    
    if ([RDAwardTool awardCanAwardWithAPILottery_num:_smashEggsModel.lottery_num] == NO) {
        RDAlertView *alertView = [[RDAlertView alloc] initWithTitle:@"" message:@"今天的抽奖机会用完了\n明天再来吧~"];
        RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"我知道了" handler:^{
            
        } bold:NO];
        [alertView addActions:@[action]];
        [alertView show];
        return;
    }

    
    if (([GlobalData shared].isBindRD)) {
        [self requestForEggsNetWork];
    }else{
        [self.shouldDemandDict setObject:@(YES) forKey:@"should"];
        [[RDHomeStatusView defaultView] scanQRCode];
    }
    
}

// 创建中奖结果页面
- (void)creatPrizeMiddleView:(HSEggsResultModel *)model{
    
    CGFloat prizeViewWidth  = [Helper autoWidthWith:294];
    CGFloat prizeViewHeight  = [Helper autoHeightWith:244];
    RDPrizeView *prizeView = [[RDPrizeView alloc] initWithFrame:CGRectMake(0, 0, prizeViewWidth, prizeViewHeight) withModel:model];
    [_maskingView addSubview:prizeView];
    [prizeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(prizeViewWidth, prizeViewHeight));
        make.center.equalTo(_maskingView);
    }];
    
    UIButton *prCloseimgBtn = [[UIButton alloc] init];
    [prCloseimgBtn setImage:[UIImage imageNamed:@"zjjg_guanbi"] forState:UIControlStateNormal];
    [prCloseimgBtn addTarget:self action:@selector(prizeClosed) forControlEvents:UIControlEventTouchUpInside];
    [_maskingView addSubview:prCloseimgBtn];
    CGFloat prCloseWidth = [Helper autoWidthWith:32.f];
    CGFloat prCloseHeight = [Helper autoHeightWith:61.f];
    [prCloseimgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(prCloseWidth, prCloseHeight));
        make.right.mas_equalTo(prizeView.mas_right).offset(- 15);
        make.bottom.mas_equalTo(prizeView.mas_top).offset(1);
    }];
}

- (void)prizeClosed{
    
    [SAVORXAPI postUMHandleWithContentId:@"game_page_result_finish" key:nil value:nil];
    
    [self dismissViewWithAnimationDuration:0.3f];
    [self eggsViewStartAnimation];
    [SAVORXAPI screenEggsStopGame];
}

- (void)sharePress:(UIButton *)button{
    
    [SAVORXAPI postUMHandleWithContentId:@"game_page_recommend" key:nil value:nil];
    
    ShareRDViewController * share = [[ShareRDViewController alloc] initWithType:SHARERDTYPE_GAME];
    share.title = @"推荐";
    [self.navigationController pushViewController:share animated:YES];
}

// 创建蒙层倒计时
- (void)creatMaskingView{
    
    UIView * view = [[UIApplication sharedApplication].keyWindow viewWithTag:10000];
    if (view) {
        [view removeFromSuperview];
    }
    
    _maskingView = [[UIView alloc] init];
    _maskingView.tag = 10000;
    _maskingView.frame = CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight);
    _maskingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.92f];

    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    _maskingView.bottom = keyWindow.top;
    [keyWindow addSubview:_maskingView];
    [self showViewWithAnimationDuration:.3f];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont boldSystemFontOfSize:80];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.text = @"3";
    [_maskingView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 80));
        make.center.equalTo([UIApplication sharedApplication].keyWindow);
    }];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeHandel) userInfo:nil repeats:YES];
    _timeCount = 3;

}

#pragma mark - show view
-(void)showViewWithAnimationDuration:(float)duration{
    self.eggsView.userInteractionEnabled = NO;
    [UIView animateWithDuration:duration animations:^{
        
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        _maskingView.bottom = keyWindow.bottom;
        
    } completion:^(BOOL finished) {
        
        self.eggsView.userInteractionEnabled = YES;
        
    }];
}

-(void)dismissViewWithAnimationDuration:(float)duration{
    
    [UIView animateWithDuration:duration animations:^{
        
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        
        _maskingView.bottom = keyWindow.top;
        
    } completion:^(BOOL finished) {
        
        [_maskingView removeFromSuperview];
        
    }];
}

// 创建锤子砸蛋中页面
- (void)creatPlayHammerViews{
    
    [SAVORXAPI postUMHandleWithContentId:@"game_page_hit" key:nil value:nil];
    
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
        make.top.mas_equalTo(haTitleImgView.mas_bottom).offset(30);
        make.left.mas_equalTo(10);
        
    }];
    self.hammer = hammer;
    
    UIButton *haCloseImgBtn = [[UIButton alloc] init];
    [haCloseImgBtn setImage:[UIImage imageNamed:@"yao_guanbi"] forState:UIControlStateNormal];
    [haCloseImgBtn addTarget:self action:@selector(haClosed) forControlEvents:UIControlEventTouchUpInside];
    [_maskingView addSubview:haCloseImgBtn];
    [haCloseImgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(32, 32));
        make.centerX.equalTo(_maskingView);
        make.top.mas_equalTo(kMainBoundsHeight - 15 - 64);
    }];
    
}
- (void)haClosed{
    
    [SAVORXAPI postUMHandleWithContentId:@"game_page_hammer_back" key:nil value:nil];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(eggGameStopWithTimeOut) object:nil];
    
     [self dismissViewWithAnimationDuration:0.3f];
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
        [self.hammer startShakeAnimation];
        [self requestHitEggNetWork];
        self.isMotionning = YES;
        _videoUrl = [[NSBundle mainBundle] URLForResource:@"glass" withExtension:@"mp3"];
        [self creatBgVoiceWithLoops:0];
        [self play];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (_isShake == YES) {
        self.isMotionning = NO;
        [self.hammer stopShakeAnimation];
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (_isShake == YES) {
        self.isMotionning = NO;
        [self.hammer stopShakeAnimation];
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
        
        RDInteractionLoadingView * hud = [[RDInteractionLoadingView alloc] initWithView:self.view title:@"正在加载"];
        
        [SAVORXAPI  gameForEggsWithURL:STBURL hunger:(NSInteger)isGetPrize date:(NSString *)currentDate force:0 success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            if ([[result objectForKey:@"result"] integerValue] == 0) {
                [self stop];
                [self.eggsView stopShakeAnimation];
                [[RDHomeStatusView defaultView] stopScreenWithEggGame];
                [self creatMaskingView];
                [self performSelector:@selector(eggGameStopWithTimeOut) withObject:nil afterDelay:120];
            }else{
                [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
            }
            [hud hidden];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [hud hidden];
            if (error.code != 677) {
                [MBProgressHUD showTextHUDwithTitle:@"请求失败，请重试"];
            }
        }];
        
    }else{
        [[RDHomeStatusView defaultView] scanQRCode];
    }
}

// 请求砸蛋结果
- (void)requestHitEggNetWork{
    //如果是绑定状态
    if ([GlobalData shared].isBindRD) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(eggGameStopWithTimeOut) object:nil];
        [self performSelector:@selector(eggGameStopWithTimeOut) withObject:nil afterDelay:120];
        
        [SAVORXAPI  gameSmashedEggWithURL:STBURL success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            
            if ([[result objectForKey:@"result"] integerValue] == 0) {
                
                HSEggsResultModel *erModel = [[HSEggsResultModel alloc] initWithDictionary:result];
                
                if (erModel.done == 1) {
                    
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(eggGameStopWithTimeOut) object:nil];
                    
                    if (_isShake == NO) {
                        return;
                    }
                    
                    _isShake = NO;
                    self.isMotionning = NO;
                    [self.hammer stopShakeAnimation];
                    
                    //进行了一次抽奖
                    [RDAwardTool awardHasAwardWithResultModel:erModel];
                    if (_smashEggsModel.lottery_num > 0) {
                        _smashEggsModel.lottery_num = _smashEggsModel.lottery_num - 1;
                    }
                    _titleLabel.text = [NSString stringWithFormat:@"您当前有%ld次机会", [RDAwardTool awardGetLottery_num]];
                    [_maskingView removeAllSubviews];
                    [self creatPrizeMiddleView:erModel];
                }
                
            }else{
                [SAVORXAPI postUMHandleWithContentId:@"game_page_result" key:@"game_page_result" value:@"prize_failure"];
                [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [SAVORXAPI postUMHandleWithContentId:@"game_page_result" key:@"game_page_result" value:@"prize_failure"];
            if (![GlobalData shared].isBindRD || [GlobalData shared].networkStatus != RDNetworkStatusReachableViaWiFi) {
                [SAVORXAPI showAlertWithMessage:@"游戏超时啦, 请重新启动"];
            }
            
        }];
        
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    
    if (self.isMotionning) {
        [self.player play];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[self.shouldDemandDict objectForKey:@"should"] boolValue]) {
        [self requestForEggsNetWork];
        [self.shouldDemandDict setObject:@(NO) forKey:@"should"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_player.isPlaying) {
        [self play];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [SAVORXAPI postUMHandleWithContentId:@"game_page_back" key:nil value:nil];
    
    [self stop];
    if (_timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
    
    [SAVORXAPI screenEggsStopGame];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [super viewDidDisappear:animated];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)eggsViewStartAnimation
{
    _videoUrl = [[NSBundle mainBundle] URLForResource:@"selectEggs" withExtension:@"mp3"];
    [self creatBgVoiceWithLoops:-1];
    [self play];
    [self.eggsView startShakeAnimation];
}

- (void)eggGameStopWithTimeOut
{
    [SAVORXAPI postUMHandleWithContentId:@"game_page_hammer_back" key:nil value:nil];

    [self dismissViewWithAnimationDuration:0.3f];
    [self eggsViewStartAnimation];
    _isShake = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDBoxQuitScreenNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
