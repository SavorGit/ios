//
//  VideoGuidedTwoDimensionalCode.m
//  SavorX
//
//  Created by 王海朋 on 17/3/2.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "VideoGuidedTwoDimensionalCode.h"
#import "HomeAnimationView.h"

@interface VideoGuidedTwoDimensionalCode ()

@property (nonatomic, strong) UIView *videoBgView;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayerItemVideoOutput * playerItemVideoOutput;
@property (nonatomic, copy) NSString *guidType;
@property (nonatomic, copy) NSString *videoName;

/**
 *  选择的block
 */
@property (nonatomic, copy) ScreenProjectionSelectViewSelectBlock selectBlock;

@end

@implementation VideoGuidedTwoDimensionalCode

-(id)init
{
    if (self = [super init]) {
        //注册通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(runLoopTheMovie:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orieChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

    }
    return self;
}

- (instancetype)showScreenProjectionTitle:(NSString *)guidType block:(ScreenProjectionSelectViewSelectBlock)selectBlock{
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.frame = keyWindow.bounds;
    self.bottom = keyWindow.top;
    [keyWindow addSubview:self];
    
    self.videoName = [[NSString alloc] init];
    self.guidType = [[NSString alloc] init];
    self.guidType = guidType;
    self.selectBlock = selectBlock;

    if ([self.guidType isEqualToString:@"scanGuide"]) {
        
        self.videoName = @"scanVideoGuided";
        [self creatScanGuidUI];
        
    }else if ([self.guidType isEqualToString:@"documentGuide"]){
        
        self.videoName = @"documentVideoGuided";
        [self creatDocumentGuidUI];
    }
    
    [self showViewWithAnimationDuration:.3f];
    
    return self;
}

// 创建扫码引导页面
- (void)creatScanGuidUI{
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"教您如何连接电视";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(150, 44));
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(70);
    }];
    
    UIButton *reScanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [reScanBtn setTitle:@"开始扫码" forState:UIControlStateNormal];
    reScanBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [reScanBtn setBackgroundColor:[UIColor colorWithRed:215.0/255.0 green:190.0/255.0 blue:126.0/255.0 alpha:1.0]];
    [reScanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [reScanBtn addTarget:self action:@selector(startScanAction:) forControlEvents:UIControlEventTouchUpInside];
    reScanBtn.layer.masksToBounds = YES;
    reScanBtn.layer.cornerRadius = 5.0;
    reScanBtn.layer.borderWidth = 1.0;
    reScanBtn.layer.borderColor = [[UIColor clearColor] CGColor];
    [self addSubview:reScanBtn];
    
    [reScanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 32));
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(265);
    }];
    
    [self creatPlayer];
    [self.player play];
}

// 创建文档引导页面
- (void)creatDocumentGuidUI{
    
    [self creatPlayer];
    [self.videoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, kMainBoundsHeight));
        make.top.equalTo(self).offset(0);
    }];
    self.playerLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight);
    
    [self.player play];
    
}

// 创建视频页面
- (void)creatPlayer{
    
    self.videoBgView = [[UIView alloc] initWithFrame:CGRectZero];
    self.videoBgView.backgroundColor = [UIColor clearColor ];
    [self addSubview:self.videoBgView];
    [self.videoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 425));
        make.top.equalTo(self).offset(125);
    }];
    
   NSURL*playURL=  [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",self.videoName] ofType:@"mp4"]];
    AVPlayerItem * playerItem = [AVPlayerItem playerItemWithURL:playURL];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, 425);
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.videoBgView.layer addSublayer:self.playerLayer];
    
}

// 退出本页面，结束播放视频
- (void)startScanAction:(id)sender {

    NSInteger index = 1;
    if(_selectBlock){
        _selectBlock(index);
        _selectBlock = nil;
    }
    
    [self dismissViewWithAnimationDuration:0.4f];
    
    // 释放视频相关
    [self.player pause];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
}

#pragma  mark - player
// 收到通知，重播
- (void)runLoopTheMovie:(NSNotification *)noti{
    
    if ([self.guidType isEqualToString:@"scanGuide"]) {
        
        AVPlayerItem * playerItem = [noti object];
        [playerItem seekToTime:kCMTimeZero];
        
        [self.player play];
        NSLog(@"重播");
        
    }else if ([self.guidType isEqualToString:@"documentGuide"]){
        
        [self startScanAction:nil];
        
    }

}

#pragma mark - show view
-(void)showViewWithAnimationDuration:(float)duration{
    
    [UIView animateWithDuration:duration animations:^{
        self.backgroundColor = RGBA(0, 0, 0, 0.88);
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        self.bottom = keyWindow.bottom;
    } completion:^(BOOL finished) {
    }];
}

-(void)dismissViewWithAnimationDuration:(float)duration{
    
    [UIView animateWithDuration:duration animations:^{
        
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        self.bottom = keyWindow.top;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];

    }];
}

// 旋转屏幕通知处理
- (void)orieChanged
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait) {
        
        self.videoBgView.frame = CGRectMake(0, 125, kMainBoundsWidth, 425);
        self.playerLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, 425);
        
    }else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        
        self.videoBgView.frame = CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight);
        self.playerLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight);
        
    }
}

@end
