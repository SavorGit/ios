//
//  PhotoVideoScreenViewController.m
//  SavorX
//
//  Created by 郭春城 on 2017/7/6.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "PhotoVideoScreenViewController.h"

@interface PhotoVideoScreenViewController ()

@property (nonatomic, strong) UIImageView * backImageView;
@property (nonatomic, strong) UILabel *minimumLabel; //最小时间显示
@property (nonatomic, strong) UISlider *playSilder; //进度条控制
@property (nonatomic, strong) UILabel *maximumLabel; //最大时间显示
@property (nonatomic, strong) UIButton * collectButton;
@property (nonatomic, strong) NSURL * url;

@property (nonatomic, strong) UIView * toolView;
@property (nonatomic, strong) UIButton * playButton;
@property (nonatomic, strong) UIButton * scrennButton;
@property (nonatomic, strong) UIButton * volumeButton;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isPlayEnd;
@property (nonatomic, assign) BOOL isNoVolume;

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
    
    [self createUI];
}

- (void)createUI
{
    AVAsset * asset = [AVAsset assetWithURL:self.url];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.backImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.backImageView setImage:[UIImage imageNamed:@"videoheaderBg"]];
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
    self.playSilder.maximumValue = (NSInteger)asset.duration.value / asset.duration.timescale;;
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
    [self.playButton setBackgroundColor:kThemeColor];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.size.mas_equalTo(self.playButton.frame.size);
    }];
    [self autoPlayButtonStatus];
    self.playButton.layer.cornerRadius = self.playButton.frame.size.width / 2;
    self.playButton.layer.masksToBounds = YES;
    [self.playButton addTarget:self action:@selector(playButtonDidBeClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.scrennButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.scrennButton.frame = CGRectMake(0, 0, self.playButton.frame.size.width - 10, self.playButton.frame.size.width - 10);
    [self.scrennButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    //    [self.playButton setAdjustsImageWhenHighlighted:NO];
    [self.toolView addSubview:self.scrennButton];
    [self.scrennButton setBackgroundColor:kThemeColor];
    [self.scrennButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(playView.mas_centerY).offset(5);
        make.right.equalTo(playView.mas_left).offset(-10);
        make.size.mas_equalTo(self.scrennButton.frame.size);
    }];
    [self autoScrennButtonStatus];
    self.scrennButton.layer.cornerRadius = self.scrennButton.frame.size.width / 2;
    self.scrennButton.layer.masksToBounds = YES;
    [self.scrennButton addTarget:self action:@selector(scrennButtonDidBeClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.volumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.volumeButton.frame = CGRectMake(0, 0, self.playButton.frame.size.width - 10, self.playButton.frame.size.width - 10);
    [self.volumeButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    //    [self.playButton setAdjustsImageWhenHighlighted:NO];
    [self.toolView addSubview:self.volumeButton];
    [self.volumeButton setBackgroundColor:kThemeColor];
    [self.volumeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(playView.mas_centerY).offset(5);
        make.left.equalTo(playView.mas_right).offset(10);
        make.size.mas_equalTo(self.volumeButton.frame.size);
    }];
    [self autoVolumeButtonStatus];
    self.volumeButton.layer.cornerRadius = self.volumeButton.frame.size.width / 2;
    self.volumeButton.layer.masksToBounds = YES;
    [self.volumeButton addTarget:self action:@selector(volumeButtonDidBeClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * volumeTool = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.toolView.frame.size.width - 60, self.playButton.frame.size.height)];
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
    [addButton setTitle:@"音量+" forState:UIControlStateNormal];
    [volumeTool addSubview:addButton];
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(2);
        make.left.mas_equalTo(2);
        make.bottom.mas_equalTo(-2);
        make.right.equalTo(volumeTool.mas_centerX).offset(-2);
    }];
    addButton.tag = 101;
    [addButton addTarget:self action:@selector(volumeDidHandleWith:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * minusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [minusButton setTitle:@"音量-" forState:UIControlStateNormal];
    [volumeTool addSubview:minusButton];
    [minusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(2);
        make.left.equalTo(volumeTool.mas_centerX).offset(2);
        make.bottom.mas_equalTo(-2);
        make.right.mas_equalTo(-2);
    }];
    minusButton.tag = 102;
    [minusButton addTarget:self action:@selector(volumeDidHandleWith:) forControlEvents:UIControlEventTouchUpInside];
}

//对音量的加减进行操作
- (void)volumeDidHandleWith:(UIButton *)button
{
    if (button.tag == 101) {
        //加声音
        
    }else{
        //减声音
        
    }
}

//静音按钮被点击了
- (void)volumeButtonDidBeClicked
{
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
        [self.volumeButton setImage:[UIImage imageNamed:@"De_labajingyin"] forState:UIControlStateNormal];
    }else{
        [self.volumeButton setImage:[UIImage imageNamed:@"De_laba"] forState:UIControlStateNormal];
    }
}

//投屏按钮被点击了
- (void)scrennButtonDidBeClicked
{
    self.isPlayEnd = !self.isPlayEnd;
    [self autoScrennButtonStatus];
}

//根据投屏状态改变投屏按钮
- (void)autoScrennButtonStatus
{
    if (self.isPlayEnd) {
        [self.scrennButton setTitle:@"投屏" forState:UIControlStateNormal];
    }else{
        [self.scrennButton setTitle:@"退出" forState:UIControlStateNormal];
    }
}

//播放按钮被点击了
- (void)playButtonDidBeClicked
{
    self.isPlaying = !self.isPlaying;
    [self autoPlayButtonStatus];
}

//根据播放状态改变播放按钮
- (void)autoPlayButtonStatus
{
    if (self.isPlaying) {
        [self.playButton setImage:[UIImage imageNamed:@"De_zanting"] forState:UIControlStateNormal];
    }else{
        [self.playButton setImage:[UIImage imageNamed:@"De_bofang"] forState:UIControlStateNormal];
    }
}

- (void)collectAciton:(UIButton *)action
{
    
}

- (void)shareAction:(UIButton *)action
{
    
}

- (void)navBackButtonClicked:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [SAVORXAPI postUMHandleWithContentId:@"bunch planting_page_back" key:nil value:nil];
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
