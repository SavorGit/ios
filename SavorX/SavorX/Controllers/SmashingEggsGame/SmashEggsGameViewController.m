//
//  SmashEggsGameViewController.m
//  SavorX
//
//  Created by 王海朋 on 2017/5/8.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "SmashEggsGameViewController.h"
//#import "GameResultViewController.h"

@interface SmashEggsGameViewController ()

@property(nonatomic ,strong) UILabel *titleLabel;
@property(nonatomic ,strong) UITextView *ruleTextView;
@property(nonatomic ,strong) UIImageView *imgBgView;
@end

@implementation SmashEggsGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatSubViews];
    
    // Do any additional setup after loading the view.
}

- (void)creatSubViews{
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:12];
    _titleLabel.textColor = UIColorFromRGB(0xf5f5f5);
    _titleLabel.backgroundColor = [UIColor lightGrayColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"您当前有1次机会";
    [self.view addSubview:_titleLabel];
    CGFloat textLabelWidth = [Helper autoWidthWith:150.f];
    CGFloat textLabelHeight = [Helper autoHeightWith:30.f];
    CGFloat textLabTopDistance = [Helper autoHeightWith:20.f];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(textLabelWidth, textLabelHeight));
        make.top.mas_equalTo(textLabTopDistance);
        make.centerX.equalTo(self.view);
    }];
    
    _imgBgView = [[UIImageView alloc] init];
    _imgBgView.backgroundColor = [UIColor lightGrayColor];
    _imgBgView.userInteractionEnabled = YES;
    [self.view addSubview:_imgBgView];
    [_imgBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 40, 260));
        make.top.mas_equalTo(_titleLabel.mas_bottom).offset(20);
        make.left.mas_equalTo(20);
    }];
    [self creatEggMiddleView];
    
    UIView *textBgView = [[UIView alloc] init];
    textBgView.backgroundColor = [UIColor lightGrayColor];
    textBgView.userInteractionEnabled = YES;
    [self.view addSubview:textBgView];
    [textBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 40, 230));
        make.top.mas_equalTo(_imgBgView.mas_bottom).offset(20);
        make.left.mas_equalTo(20);
    }];
    
    UILabel *gameRuleLab = [[UILabel alloc] init];
    gameRuleLab.font = [UIFont systemFontOfSize:12];
    gameRuleLab.textColor = UIColorFromRGB(0xf5f5f5);
    gameRuleLab.backgroundColor = [UIColor lightGrayColor];
    gameRuleLab.textAlignment = NSTextAlignmentLeft;
    gameRuleLab.text = @"游戏规则:";
    [textBgView addSubview:gameRuleLab];
    [gameRuleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 30));
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(5);
    }];
    
    _ruleTextView = [[UITextView alloc] init];
    _ruleTextView.textColor = [UIColor blackColor];
    _ruleTextView.font = [UIFont systemFontOfSize:16];
    _ruleTextView.delegate = self;
    _ruleTextView.backgroundColor = [UIColor whiteColor];
    _ruleTextView.text = @"1.中阿斯顿哈佛阿萨德佛萨佛所诉公司规定暗红色的佛哦啊水电费；\n2.阿什顿佛啊搜到个红色的公司大国萨谷搜矮冬瓜撒打工啊搜到过建瓯市打工撒殴打过大过撒的嘎嘎十多个后撒点过后十多个；\n3.阿萨德红告诉低功耗哦啊是公婆阿萨德国际化破挥洒的公平三大后方和萨拉低功耗拉黑属地管理和萨拉电光火石拉活过来按时阿萨德骨灰盒撒旦改好啦属地管理撒旦个\n4.啊胡搜的分红阿萨德烘干房会受到个红色打火锅搜啊和郭鹏三大个航拍啊收到刚回来的撒谎过来撒东华理工合适的拉回公司打工回拉萨电话费拉萨的活雷锋";
    _ruleTextView.scrollEnabled = YES;
    [textBgView addSubview:_ruleTextView];
    [_ruleTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 40 - 20, 190));
        make.top.mas_equalTo(gameRuleLab.mas_bottom);
        make.left.mas_equalTo(10);
    }];
    
    
}

- (void)creatEggMiddleView{
    
//    _imgBgView = [[UIImageView alloc] init];
//    _imgBgView.backgroundColor = [UIColor lightGrayColor];
//    _imgBgView.userInteractionEnabled = YES;
//    [self.view addSubview:_imgBgView];
//    [_imgBgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 40, 260));
//        make.top.mas_equalTo(_titleLabel.mas_bottom).offset(20);
//        make.left.mas_equalTo(20);
//    }];
    
    UIImageView *eggOneImgView = [[UIImageView alloc] init];
    eggOneImgView.backgroundColor = [UIColor redColor];
    eggOneImgView.userInteractionEnabled = YES;
    eggOneImgView.tag = 10010;
    [_imgBgView addSubview:eggOneImgView];
    [eggOneImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake((kMainBoundsWidth - 40 - 40)/3, 220));
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(_imgBgView.mas_top).offset(20);
        
    }];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTap.numberOfTouchesRequired = 1;
    [eggOneImgView addGestureRecognizer:singleTap];
    
    UIImageView *eggTwoImgView = [[UIImageView alloc] init];
    eggTwoImgView.backgroundColor = [UIColor blueColor];
    eggTwoImgView.userInteractionEnabled = YES;
    eggTwoImgView.tag = 10011;
    [_imgBgView addSubview:eggTwoImgView];
    [eggTwoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake((kMainBoundsWidth - 40 - 40)/3, 220));
        make.left.mas_equalTo(eggOneImgView.mas_right).offset(10);
        make.top.mas_equalTo(_imgBgView.mas_top).offset(20);
        
    }];
    
    UIImageView *eggThreeImgView = [[UIImageView alloc] init];
    eggThreeImgView.backgroundColor = [UIColor cyanColor];
    eggThreeImgView.userInteractionEnabled = YES;
    eggThreeImgView.tag = 10012;
    [_imgBgView addSubview:eggThreeImgView];
    [eggThreeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake((kMainBoundsWidth - 40 - 40)/3, 220));
        make.left.mas_equalTo(eggTwoImgView.mas_right).offset(10);
        make.top.mas_equalTo(_imgBgView.mas_top).offset(20);
        
    }];

}

- (void)creatPrizeMiddleView{
    
//    _imgBgView = [[UIImageView alloc] init];
//    _imgBgView.backgroundColor = [UIColor lightGrayColor];
//    _imgBgView.userInteractionEnabled = YES;
//    [self.view addSubview:_imgBgView];
//    [_imgBgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 40, 260));
//        make.top.mas_equalTo(_titleLabel.mas_bottom).offset(20);
//        make.left.mas_equalTo(20);
//    }];
    
    UILabel *phoneNameLab = [[UILabel alloc] init];
    phoneNameLab.font = [UIFont systemFontOfSize:12];
    phoneNameLab.textColor = UIColorFromRGB(0xf5f5f5);
    phoneNameLab.backgroundColor = [UIColor lightGrayColor];
    phoneNameLab.textAlignment = NSTextAlignmentLeft;
    phoneNameLab.text = @"游戏者的手机";
    [_imgBgView addSubview:phoneNameLab];
    [phoneNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 30));
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(5);
    }];
    
    UILabel *congratueLab = [[UILabel alloc] init];
    congratueLab.font = [UIFont systemFontOfSize:16];
    congratueLab.textColor = UIColorFromRGB(0xf5f5f5);
    congratueLab.backgroundColor = [UIColor lightGrayColor];
    congratueLab.textAlignment = NSTextAlignmentCenter;
    congratueLab.text = @"恭喜您，中奖了~~~";
    [_imgBgView addSubview:congratueLab];
    [congratueLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 50));
        make.top.mas_equalTo(phoneNameLab.mas_bottom);
        make.centerX.equalTo(self.view);
    }];
    
    UILabel *prizeLevelLab = [[UILabel alloc] init];
    prizeLevelLab.font = [UIFont systemFontOfSize:30];
    prizeLevelLab.textColor = UIColorFromRGB(0xf5f5f5);
    prizeLevelLab.backgroundColor = [UIColor lightGrayColor];
    prizeLevelLab.textAlignment = NSTextAlignmentCenter;
    prizeLevelLab.text = @"特等奖";
    [_imgBgView addSubview:prizeLevelLab];
    [prizeLevelLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(150, 60));
        make.top.mas_equalTo(congratueLab.mas_bottom).offset(15);
        make.centerX.equalTo(self.view);
    }];
    
    UIImageView *bottomBgView = [[UIImageView alloc] init];
    bottomBgView.backgroundColor = [UIColor whiteColor];
    bottomBgView.userInteractionEnabled = YES;
    [_imgBgView addSubview:bottomBgView];
    [bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 40 - 10, 80));
        make.bottom.mas_equalTo(_imgBgView.mas_bottom).offset(-10);
        make.left.mas_equalTo(5);
    }];
    
    UILabel *prizeFormLab = [[UILabel alloc] init];
    prizeFormLab.font = [UIFont systemFontOfSize:14];
    prizeFormLab.textColor = [UIColor blackColor];
    prizeFormLab.backgroundColor = [UIColor clearColor];
    prizeFormLab.textAlignment = NSTextAlignmentCenter;
    prizeFormLab.text = @"快去找服务员领取奖品吧";
    [bottomBgView addSubview:prizeFormLab];
    [prizeFormLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(160, 30));
        make.top.mas_equalTo(bottomBgView.mas_top).offset(10);
        make.left.mas_equalTo(5);
    }];
    
    UILabel *prizeTimeLab = [[UILabel alloc] init];
    prizeTimeLab.font = [UIFont systemFontOfSize:14];
    prizeTimeLab.textColor = [UIColor blackColor];
    prizeTimeLab.backgroundColor = [UIColor clearColor];
    prizeTimeLab.textAlignment = NSTextAlignmentCenter;
    prizeTimeLab.text = @"有效领奖时间:60分钟";
    [bottomBgView addSubview:prizeTimeLab];
    [prizeTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(140, 30));
        make.top.mas_equalTo(bottomBgView.mas_top).offset(10);
        make.left.mas_equalTo(prizeFormLab.mas_right).offset(10);
    }];
    
    UILabel *alertLab = [[UILabel alloc] init];
    alertLab.font = [UIFont systemFontOfSize:15];
    alertLab.textColor = [UIColor blackColor];
    alertLab.backgroundColor = [UIColor whiteColor];
    alertLab.textAlignment = NSTextAlignmentCenter;
    alertLab.text = @"请勿关闭此页面，关闭后，您将失去兑奖资格";
    [bottomBgView addSubview:alertLab];
    [alertLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 40 - 10, 30));
        make.top.mas_equalTo(prizeTimeLab.mas_bottom).offset(5);
        make.left.mas_equalTo(0);
    }];

}

- (void)handleTap:(UIGestureRecognizer *)recognizer{
    UIImageView *view = (UIImageView *)recognizer.view;
    NSInteger index = view.tag;
    if (index == 10010) {
        
        [_imgBgView removeAllSubviews];
        
        [self creatPrizeMiddleView];
        
//        GameResultViewController *GRVC = [[GameResultViewController alloc] init];
//        [self.navigationController pushViewController:GRVC animated:YES];
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
