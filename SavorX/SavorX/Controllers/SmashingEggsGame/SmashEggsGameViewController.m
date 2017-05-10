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
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "HomeAnimationView.h"

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

@end

@implementation SmashEggsGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initOtherParmars];
    [self creatSubViews];
    [self creatBgVoice];
    [_player play];

}

// 初始化基本参数
- (void)initOtherParmars{
    _videoUrl = [[NSBundle mainBundle] URLForResource:@"glass" withExtension:@"wav"];
    self.title = @"砸蛋游戏";
    _isShake = NO;
    self.shouldDemandDict = [[NSMutableDictionary alloc] init];
    [self.shouldDemandDict setObject:@(NO) forKey:@"should"];
}

- (void)creatBgVoice{

    NSError *err;
    //初始化播放器
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:_videoUrl error:&err];
    _player.volume = 0.5;
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
    _titleLabel.text = @"您当前有1次机会";
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
    gameRuleLab.font = [UIFont systemFontOfSize:15];
    gameRuleLab.textColor = [UIColor blackColor];
    gameRuleLab.textAlignment = NSTextAlignmentLeft;
    gameRuleLab.text = @"游戏规则";
    [gameRuleimgView addSubview:gameRuleLab];
    [gameRuleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 30));
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(10);
    }];
    
    _ruleTextView = [[UITextView alloc] init];
    _ruleTextView.textColor = [UIColor whiteColor];
    _ruleTextView.backgroundColor = [UIColor clearColor];
    _ruleTextView.font = [UIFont systemFontOfSize:12];
    _ruleTextView.editable = NO;
    _ruleTextView.delegate = self;
    _ruleTextView.text = @"1.中阿斯顿哈佛阿萨德佛萨佛所诉公司规定暗红色的佛哦啊水电费；\n\n2.阿什顿佛啊搜到个红色的公司大国萨谷搜矮冬瓜撒打工啊搜到过建瓯市打工撒殴打过大过撒的嘎嘎十多个后撒点过后十多个；\n\n3.阿萨德红告诉低功耗哦啊是公婆阿萨德国际化破挥洒的公平三大后方和萨拉低功耗拉黑属地管理和萨拉电光火石拉活过来按时阿萨德骨灰盒撒旦改好啦属地管理撒旦个\n4.啊胡搜的分红阿萨德烘干房会受到个红色打火锅搜啊和郭鹏三大个航拍啊收到刚回来的撒谎过来撒东华理工合适的拉回公司打工回拉萨电话费拉萨的活雷锋";
    _ruleTextView.scrollEnabled = NO;
    [_textBgView addSubview:_ruleTextView];
    [_ruleTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(301, 150));
        make.top.mas_equalTo(gameRuleimgView.mas_bottom);
        make.left.mas_equalTo(10);
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
    NSLog(@"点击了第%ld个金蛋", index + 1);
    
    if (([GlobalData shared].isBindRD)) {
        [self creatMaskingView];
        [self stop];
    }else{
        [self.shouldDemandDict setObject:@(YES) forKey:@"should"];
        [[HomeAnimationView animationView] scanQRCode];
    }
}

// 创建中奖结果页面
- (void)creatPrizeMiddleView{
    
    HSEggsResultModel *model = [[HSEggsResultModel alloc] init];;
    RDPrizeView *prizeView = [[RDPrizeView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth - 80, 230) withModel:model];
    prizeView.delegate = self;
    prizeView.layer.cornerRadius = 6.0;
    prizeView.backgroundColor = [UIColor blueColor];
    [_maskingView addSubview:prizeView];
    [prizeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 80, 230));
        make.left.mas_equalTo(40);
        make.center.equalTo(self.view);
        make.centerY.equalTo(self.view);
    }];
}

- (void)sharePress:(UIButton *)button{
    
}

// 点击选择金蛋
- (void)handleTap:(UIGestureRecognizer *)recognizer{
    
    if (([GlobalData shared].isBindRD)) {
        [self creatMaskingView];
    }else{
        [self.shouldDemandDict setObject:@(YES) forKey:@"should"];
        [[HomeAnimationView animationView] scanQRCode];
    }
}

// 创建蒙层倒计时
- (void)creatMaskingView{
    _maskingView = [[UIView alloc] init];
    _maskingView.frame = CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight);
    _maskingView.backgroundColor = [UIColor blackColor];
    _maskingView.alpha = 0.85;
    [self.view addSubview:_maskingView];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont boldSystemFontOfSize:80];
    _timeLabel.textColor = [UIColor orangeColor];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.text = @"5";
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
    
//    [self creatPrizeMiddleView];
    
    UILabel *hammerTitleLab = [[UILabel alloc] init];
    hammerTitleLab.font = [UIFont boldSystemFontOfSize:16];
    hammerTitleLab.textColor = [UIColor orangeColor];
    hammerTitleLab.backgroundColor = [UIColor clearColor];
    hammerTitleLab.textAlignment = NSTextAlignmentCenter;
    hammerTitleLab.text = @"用力摇动手机即可砸蛋";
    [_maskingView addSubview:hammerTitleLab];
    [hammerTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 30));
        make.centerX.equalTo(_maskingView);
        make.top.mas_equalTo(_maskingView.top).offset(100);
    }];
    
    UIImageView *hammerImgView = [[UIImageView alloc] init];
    hammerImgView.backgroundColor = [UIColor blueColor];
    hammerImgView.userInteractionEnabled = YES;
    [_maskingView addSubview:hammerImgView];
    [hammerImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 20, 300));
        make.top.mas_equalTo(hammerTitleLab.mas_bottom).offset(20);
        make.left.mas_equalTo(10);
        
    }];
}

// 倒计时控制器
- (void)timeHandel{
     _timeCount--;
    _timeLabel.text = [NSString stringWithFormat:@"%i",_timeCount];
    if (_timeCount <= 0) {
        if (_timer.isValid) {
            [_timer invalidate];
            _timer = nil;
            
            [_maskingView removeAllSubviews];
            [self creatPlayHammerViews];
            
            _isShake = YES;
        }
    }
    NSLog(@"zheshiceshi");
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (_isShake == YES) {
        NSLog(@"开始摇一摇");
        [self requestHitEggNetWork];
        _videoUrl = [[NSBundle mainBundle] URLForResource:@"glass" withExtension:@"wav"];
        [self creatBgVoice];
        [self play];
    }

}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (_isShake == YES) {
        
        if (motion ==UIEventSubtypeMotionShake )
        {
            [self stop];
            //设置震动
//            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        NSLog(@"摇一摇停止");
    }
}

// 请求砸蛋连接
- (void)requestForEggsNetWork{
    
    //如果是绑定状态
    if ([GlobalData shared].isBindRD) {
        [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在连接"];
        
        [SAVORXAPI  gameForEggsWithURL:STBURL success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            if ([[result objectForKey:@"result"] integerValue] == 0) {
                [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
            }else{
                [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showTextHUDwithTitle:DemandFailure];
        }];
        
    }else{
        [[HomeAnimationView animationView] scanQRCode];
    }
}

// 请求砸蛋结果
- (void)requestHitEggNetWork{
    
    //如果是绑定状态
    if ([GlobalData shared].isBindRD) {
        [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在连接"];
        
        [SAVORXAPI  gameSmashedEggWithURL:STBURL success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            if ([[result objectForKey:@"result"] integerValue] == 0) {
                HSEggsResultModel *erModel = [[HSEggsResultModel alloc] initWithDictionary:result];
                _prizeLevelLab.text = erModel.prize_name;
                
                [_maskingView removeAllSubviews];
                [self creatPrizeMiddleView];
                
            }else{
                [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showTextHUDwithTitle:DemandFailure];
        }];
        
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[self.shouldDemandDict objectForKey:@"should"] boolValue]) {
        [self creatMaskingView];
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

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
