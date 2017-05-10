//
//  SmashEggsGameViewController.m
//  SavorX
//
//  Created by 王海朋 on 2017/5/8.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "SmashEggsGameViewController.h"
#import "HSEggsResultModel.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "HomeAnimationView.h"

@interface SmashEggsGameViewController ()<UITextViewDelegate>

@property(nonatomic ,strong) UILabel *titleLabel;
@property(nonatomic ,strong) UITextView *ruleTextView;
@property(nonatomic ,strong) UIImageView *imgBgView;
@property(nonatomic ,strong) UILabel *timeLabel;
@property(nonatomic ,assign) int timeCount;
@property(nonatomic ,strong) NSTimer *timer;
@property(nonatomic ,strong) UIView *maskingView;
@property(nonatomic ,strong) UIImageView *textBgView;
@property(nonatomic ,assign) BOOL isShake;
@property(nonatomic ,strong) UILabel *prizeLevelLab;
@property (nonatomic, strong) NSMutableDictionary * shouldDemandDict;
@end

@implementation SmashEggsGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatSubViews];
    
    self.title = @"砸蛋游戏";
    _isShake = NO;
    self.shouldDemandDict = [[NSMutableDictionary alloc] init];
    [self.shouldDemandDict setObject:@(NO) forKey:@"should"];
    
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
    
    UIImageView *upBgView = [[UIImageView alloc] init];
    upBgView.backgroundColor = [UIColor clearColor];
    [upBgView setImage:[UIImage imageNamed:@"zajindanup_bg"]];
    upBgView.userInteractionEnabled = YES;
    [bgScrollView addSubview:upBgView];
    [upBgView mas_makeConstraints:^(MASConstraintMaker *make) {
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
        make.top.mas_equalTo(upBgView.mas_bottom);
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
    
    _imgBgView = [[UIImageView alloc] init];
    _imgBgView.backgroundColor = [UIColor clearColor];
    _imgBgView.userInteractionEnabled = YES;
    [bgScrollView addSubview:_imgBgView];
    [_imgBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 123));
        make.bottom.mas_equalTo(upBgView.mas_bottom).offset(-25);
        make.left.mas_equalTo(0);
    }];
    [self creatEggMiddleView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:12];
    _titleLabel.textColor = UIColorFromRGB(0xf5f5f5);
    _titleLabel.backgroundColor = [UIColor lightGrayColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"您当前有1次机会";
    [bgScrollView addSubview:_titleLabel];
    CGFloat textLabelWidth = [Helper autoWidthWith:150.f];
    CGFloat textLabelHeight = [Helper autoHeightWith:30.f];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(textLabelWidth, textLabelHeight));
        make.top.mas_equalTo(_imgBgView.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
    }];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setImage:[UIImage imageNamed:@"yaoqing_anniu"] forState:UIControlStateNormal];
    [shareBtn setBackgroundColor:[UIColor clearColor]];
    [shareBtn addTarget:self action:@selector(sharePress:) forControlEvents:UIControlEventTouchUpInside];
    [bgScrollView addSubview:shareBtn];
    [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(167, 48));
        make.top.mas_equalTo(_titleLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
    }];
    
    _textBgView = [[UIImageView alloc] init];
    _textBgView.backgroundColor = [UIColor lightGrayColor];
    _textBgView.userInteractionEnabled = YES;
    [bgScrollView addSubview:_textBgView];
    [_textBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 40, 200));
        make.top.mas_equalTo(shareBtn.mas_bottom).offset(10);
        make.left.mas_equalTo(20);
    }];
    
    UILabel *gameRuleLab = [[UILabel alloc] init];
    gameRuleLab.font = [UIFont systemFontOfSize:12];
    gameRuleLab.textColor = UIColorFromRGB(0xf5f5f5);
    gameRuleLab.backgroundColor = [UIColor lightGrayColor];
    gameRuleLab.textAlignment = NSTextAlignmentLeft;
    gameRuleLab.text = @"游戏规则:";
    [_textBgView addSubview:gameRuleLab];
    [gameRuleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 20));
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(5);
    }];
    
    _ruleTextView = [[UITextView alloc] init];
    _ruleTextView.textColor = [UIColor blackColor];
    _ruleTextView.font = [UIFont systemFontOfSize:16];
    _ruleTextView.editable = NO;
    _ruleTextView.userInteractionEnabled = NO;
    _ruleTextView.delegate = self;
    _ruleTextView.backgroundColor = [UIColor whiteColor];
    _ruleTextView.text = @"1.中阿斯顿哈佛阿萨德佛萨佛所诉公司规定暗红色的佛哦啊水电费；\n2.阿什顿佛啊搜到个红色的公司大国萨谷搜矮冬瓜撒打工啊搜到过建瓯市打工撒殴打过大过撒的嘎嘎十多个后撒点过后十多个；\n3.阿萨德红告诉低功耗哦啊是公婆阿萨德国际化破挥洒的公平三大后方和萨拉低功耗拉黑属地管理和萨拉电光火石拉活过来按时阿萨德骨灰盒撒旦改好啦属地管理撒旦个\n4.啊胡搜的分红阿萨德烘干房会受到个红色打火锅搜啊和郭鹏三大个航拍啊收到刚回来的撒谎过来撒东华理工合适的拉回公司打工回拉萨电话费拉萨的活雷锋";
    _ruleTextView.scrollEnabled = NO;
    [_textBgView addSubview:_ruleTextView];
    [_ruleTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 40 - 20, 170));
        make.top.mas_equalTo(gameRuleLab.mas_bottom);
        make.left.mas_equalTo(10);
    }];
    
}

- (void)creatEggMiddleView{
    
    UIImageView *eggOneImgView = [[UIImageView alloc] init];
    eggOneImgView.backgroundColor = [UIColor clearColor];
    eggOneImgView.image = [UIImage imageNamed:@"jindan"];
    eggOneImgView.userInteractionEnabled = YES;
    eggOneImgView.tag = 10010;
    [_imgBgView addSubview:eggOneImgView];
    [eggOneImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(96,123));
        make.left.mas_equalTo(((kMainBoundsWidth - 96*3)/4));
        make.top.mas_equalTo(_imgBgView.mas_top).offset(0);
        
    }];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTap.numberOfTouchesRequired = 1;
    [eggOneImgView addGestureRecognizer:singleTap];
    
    UIImageView *eggTwoImgView = [[UIImageView alloc] init];
    eggTwoImgView.backgroundColor = [UIColor clearColor];
    eggTwoImgView.image = [UIImage imageNamed:@"jindan"];
    eggTwoImgView.userInteractionEnabled = YES;
    eggTwoImgView.tag = 10011;
    [_imgBgView addSubview:eggTwoImgView];
    [eggTwoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(96,123));
        make.left.mas_equalTo(eggOneImgView.mas_right).offset(((kMainBoundsWidth - 96*3)/4));
        make.top.mas_equalTo(_imgBgView.mas_top).offset(0);
        
    }];
    
    UITapGestureRecognizer *singleTTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTTap.numberOfTouchesRequired = 1;
    [eggTwoImgView addGestureRecognizer:singleTTap];
    
    UIImageView *eggThreeImgView = [[UIImageView alloc] init];
    eggThreeImgView.backgroundColor = [UIColor clearColor];
    eggThreeImgView.image = [UIImage imageNamed:@"jindan"];
    eggThreeImgView.userInteractionEnabled = YES;
    eggThreeImgView.tag = 10012;
    [_imgBgView addSubview:eggThreeImgView];
    [eggThreeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(96,123));
        make.left.mas_equalTo(eggTwoImgView.mas_right).offset(((kMainBoundsWidth - 96*3)/4));
        make.top.mas_equalTo(_imgBgView.mas_top).offset(0);
        
    }];
    
    UITapGestureRecognizer *singleThTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleThTap.numberOfTouchesRequired = 1;
    [eggThreeImgView addGestureRecognizer:singleThTap];

}

- (void)creatPrizeMiddleView{
    
    UIImageView *prizeBgImgView = [[UIImageView alloc] init];
    prizeBgImgView.backgroundColor = [UIColor blueColor];
    prizeBgImgView.layer.cornerRadius = 6.0;
    [_maskingView addSubview:prizeBgImgView];
    [prizeBgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 80, 230));
        make.left.mas_equalTo(40);
        make.center.equalTo(self.view);
        make.centerY.equalTo(self.view);
        
    }];
    
    UILabel *congratueLab = [[UILabel alloc] init];
    congratueLab.font = [UIFont systemFontOfSize:16];
    congratueLab.textColor = UIColorFromRGB(0xf5f5f5);
    congratueLab.backgroundColor = [UIColor clearColor];
    congratueLab.textAlignment = NSTextAlignmentCenter;
    congratueLab.text = @"恭喜您，中奖了~~~";
    [prizeBgImgView addSubview:congratueLab];
    [congratueLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 50));
        make.top.mas_equalTo(prizeBgImgView.top).offset(5);
        make.centerX.equalTo(self.view);
    }];
    
    UILabel *phoneNameLab = [[UILabel alloc] init];
    phoneNameLab.font = [UIFont systemFontOfSize:12];
    phoneNameLab.textColor = UIColorFromRGB(0xf5f5f5);
    phoneNameLab.backgroundColor = [UIColor clearColor];
    phoneNameLab.textAlignment = NSTextAlignmentLeft;
    phoneNameLab.text = @"游戏者的手机";
    [prizeBgImgView addSubview:phoneNameLab];
    [phoneNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 30));
        make.top.mas_equalTo(congratueLab.mas_bottom);
        make.left.mas_equalTo(5);
    }];

    _prizeLevelLab = [[UILabel alloc] init];
    _prizeLevelLab.font = [UIFont systemFontOfSize:30];
    _prizeLevelLab.textColor = UIColorFromRGB(0xf5f5f5);
    _prizeLevelLab.backgroundColor = [UIColor clearColor];
    _prizeLevelLab.textAlignment = NSTextAlignmentCenter;
    _prizeLevelLab.text = @"特等奖";
    [prizeBgImgView addSubview:_prizeLevelLab];
    [_prizeLevelLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(150, 60));
        make.top.mas_equalTo(phoneNameLab.mas_bottom);
        make.centerX.equalTo(self.view);
    }];
    
    UILabel *prizeFormLab = [[UILabel alloc] init];
    prizeFormLab.font = [UIFont systemFontOfSize:14];
    prizeFormLab.textColor = [UIColor blackColor];
    prizeFormLab.backgroundColor = [UIColor clearColor];
    prizeFormLab.textAlignment = NSTextAlignmentCenter;
    prizeFormLab.text = @"快去找服务员领取奖品吧";
    [prizeBgImgView addSubview:prizeFormLab];
    [prizeFormLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(160, 30));
        make.top.mas_equalTo(prizeBgImgView.mas_bottom).offset(- 80);
        make.centerX.equalTo(prizeBgImgView);
    }];
    
    UILabel *prizeTimeLab = [[UILabel alloc] init];
    prizeTimeLab.font = [UIFont systemFontOfSize:14];
    prizeTimeLab.textColor = [UIColor blackColor];
    prizeTimeLab.backgroundColor = [UIColor clearColor];
    prizeTimeLab.textAlignment = NSTextAlignmentCenter;
    prizeTimeLab.text = @"有效领奖时间:60分钟,";
    [prizeBgImgView addSubview:prizeTimeLab];
    [prizeTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(140, 30));
        make.top.mas_equalTo(prizeBgImgView.mas_bottom).offset(-40);
        make.left.mas_equalTo(20);
    }];
    
    UILabel *alertLab = [[UILabel alloc] init];
    alertLab.font = [UIFont systemFontOfSize:14];
    alertLab.textColor = [UIColor redColor];
    alertLab.backgroundColor = [UIColor clearColor];
    alertLab.textAlignment = NSTextAlignmentCenter;
    alertLab.text = @"关闭后将无法领取";
    [prizeBgImgView addSubview:alertLab];
    [alertLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(140, 30));
        make.top.mas_equalTo(prizeBgImgView.mas_bottom).offset(-40);
        make.left.mas_equalTo(prizeTimeLab.mas_right);
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
    _timeCount = 5;

}

// 创建锤子砸蛋中页面
- (void)creatPlayHammerViews{
    
    [self creatPrizeMiddleView];
    
//    UILabel *hammerTitleLab = [[UILabel alloc] init];
//    hammerTitleLab.font = [UIFont boldSystemFontOfSize:16];
//    hammerTitleLab.textColor = [UIColor orangeColor];
//    hammerTitleLab.backgroundColor = [UIColor clearColor];
//    hammerTitleLab.textAlignment = NSTextAlignmentCenter;
//    hammerTitleLab.text = @"用力摇动手机即可砸蛋";
//    [_maskingView addSubview:hammerTitleLab];
//    [hammerTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 30));
//        make.centerX.equalTo(_maskingView);
//        make.top.mas_equalTo(_maskingView.top).offset(100);
//    }];
//    
//    UIImageView *hammerImgView = [[UIImageView alloc] init];
//    hammerImgView.backgroundColor = [UIColor blueColor];
//    hammerImgView.userInteractionEnabled = YES;
//    [_maskingView addSubview:hammerImgView];
//    [hammerImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 20, 300));
//        make.top.mas_equalTo(hammerTitleLab.mas_bottom).offset(20);
//        make.left.mas_equalTo(10);
//        
//    }];

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
    }

}
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
//    NSLog(@"摇一摇被取消");
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (_isShake == YES) {
        
        if (motion ==UIEventSubtypeMotionShake )
        {
            //播放音效
            SystemSoundID   soundID;  // shake_sound_male.wav
            NSString *path = [[NSBundle mainBundle ] pathForResource:@"glass" ofType:@"wav"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
            AudioServicesPlaySystemSound (soundID);
            //设置震动
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
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
                _prizeLevelLab.text = erModel.info;
                
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
