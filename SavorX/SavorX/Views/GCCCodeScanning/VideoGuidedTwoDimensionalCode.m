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

/**
 *  选择的block
 */
@property (nonatomic, copy) ScreenProjectionSelectViewSelectBlock selectBlock;

@end

@implementation VideoGuidedTwoDimensionalCode

//+ (instancetype)shareStance{
//    
//    static VideoGuidedTwoDimensionalCode * screenObject = nil;
//    static dispatch_once_t predicate;
//    dispatch_once(&predicate, ^{
//        screenObject=[[VideoGuidedTwoDimensionalCode alloc] init];
//    });
//    return screenObject;
//}

-(id)init
{
    if (self = [super init]) {
    }
    return self;
}
- (instancetype)showScreenProjectionTitle:(NSString *)title block:(ScreenProjectionSelectViewSelectBlock)selectBlock{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.frame = keyWindow.bounds;
    self.bottom = keyWindow.top;
    [self creadUI];
    self.selectBlock = selectBlock;
    
    [keyWindow addSubview:self];
    [self showViewWithAnimationDuration:.3f];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orieChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    return self;
}

- (void)creadUI{
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"教您如何连接电视";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(150, 20));
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(-170);
    }];
    
    
    self.videoBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, kMainBoundsWidth, 200)];
    self.videoBgView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:self.videoBgView];
    
    NSURL * playURL = [NSURL URLWithString:@"http://200048203.vod.myqcloud.com/200048203_bfa6ad56e1f811e6a93519af8e641b73.f30.mp4"];
    AVPlayerItem * playerItem = [AVPlayerItem playerItemWithURL:playURL];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, 200);
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.videoBgView.layer addSublayer:self.playerLayer];
    
    [self.player play];
    
    UIButton *reScanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [reScanBtn setTitle:@"开始扫码" forState:UIControlStateNormal];
    reScanBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [reScanBtn setBackgroundColor:[UIColor colorWithRed:215.0/255.0 green:190.0/255.0 blue:126.0/255.0 alpha:1.0]];
    [reScanBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [reScanBtn addTarget:self action:@selector(startScanAction:) forControlEvents:UIControlEventTouchUpInside];
    reScanBtn.layer.masksToBounds = YES;
    reScanBtn.layer.cornerRadius = 5.0;
    reScanBtn.layer.borderWidth = 1.0;
    reScanBtn.layer.borderColor = [[UIColor clearColor] CGColor];
    
    [self addSubview:reScanBtn];
    
    [reScanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 32));
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(150);
    }];
}

#pragma mark - show view
-(void)showViewWithAnimationDuration:(float)duration{
    if ([GlobalData shared].isScreenProjectionView) {
        return;
    }
    [GlobalData shared].isScreenProjectionView = YES;
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
        [GlobalData shared].isScreenProjectionView = NO;
    }];
}

- (void)startScanAction:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    [self selectBtnindex:btn.tag];
    
    [self.player pause];
    [self.player replaceCurrentItemWithPlayerItem:nil];
//    [[HomeAnimationView animationView] scanQRCode];
}

-(void)selectBtnindex:(NSInteger)index{
    
    if(_selectBlock){
        _selectBlock(index);
        _selectBlock = nil;
    }
   [self dismissViewWithAnimationDuration:0.4f];
    
   [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)orieChanged
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait) {
        
        self.videoBgView.frame = CGRectMake(0, 200, kMainBoundsWidth, 200);
        self.playerLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, 200);
        
    }else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        
        self.videoBgView.frame = CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight);
        self.playerLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight);
        
    }
}

@end
