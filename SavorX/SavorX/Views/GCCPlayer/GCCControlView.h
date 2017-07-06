//
//  GCCControlView.h
//  RDPlayer
//
//  Created by 郭春城 on 16/10/20.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GCCControlViewDelegate <NSObject>

@optional
- (void)playButtonDidClickedToPlay:(UIButton *)button;
- (void)playButtonDidClickedToPause:(UIButton *)button;
- (void)screenButtonDidClicked:(UIButton *)button;
- (void)sliderDidSlideToTime:(NSInteger)time;
- (void)backButtonDidClicked;
- (void)replayButtonDidClicked;
- (void)shotButtonDidClicked;
- (void)shareButtonDidClicked;
- (void)collectButtonDidClicked:(UIButton *)button;
- (void)TVButtonDidClicked;
- (void)playItemShouldChangeDefinitionTo:(NSInteger)tag;
- (void)toolViewStatusHidden:(BOOL)isHidden;

@end

@interface GCCControlView : UIView

@property (nonatomic, assign) id<GCCControlViewDelegate> delegate;
@property (nonatomic, assign) BOOL isSlider; //进度条在被拖动
@property (nonatomic, strong) UIButton * TVButton; //投屏按钮

- (void)play; //播放
- (void)pause; //暂停
- (void)stop; //停止
- (void)loading; //缓冲
- (void)stopLoading; //停止缓冲
- (void)seekTimeWithPause; //暂停状态拖动到某一时间

- (void)videoDidInit;

- (void)playOrientationLandscape; //切换横屏
- (void)playOrientationLandscapeWithOnlyVideo;
- (void)playOrientationPortrait; //切换竖屏
- (void)playOrientationPortraitWithOnlyVideo;

- (void)setVideoTotalTime:(NSInteger)time; //设置视频总时长
- (void)setVideoTitle:(NSString *)title; //设置视频标题
- (void)setBufferValue:(CGFloat)value; //设置缓冲进度
- (void)setSliderValue:(CGFloat)value currentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime; //设置当前播放进度
- (void)setVideoIsCollect:(BOOL)isCollect; //设置是否收藏状态

- (void)backgroundImage:(NSString *)url;

- (void)changeControlViewShowStatus; //改变控制栏显示状态

@end
