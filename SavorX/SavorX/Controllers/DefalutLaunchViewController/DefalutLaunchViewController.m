//
//  DefalutLaunchViewController.m
//  RDLaunchTest
//
//  Created by 郭春城 on 2017/3/28.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "DefalutLaunchViewController.h"
#import "DefalutLaunchPlayView.h"
#import "Masonry.h"
#import "GCCGetInfo.h"

@interface DefalutLaunchViewController ()

@property (nonatomic, strong) DefalutLaunchPlayView * playView;

@end

@implementation DefalutLaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createViews];
    [self createPlayer];
}

- (void)createViews
{
    
}

- (void)createPlayer
{
    CGFloat widthF = [Helper autoWidthWith:180] / 10;
    NSInteger width = (NSInteger)roundf(widthF) * 10;
    
    self.playView = [[DefalutLaunchPlayView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    NSString * path = [[NSBundle mainBundle] pathForResource:@"DefaultLaunch" ofType:@"mp4"];
    [self.playView setVideoURL:path];
    [self.view addSubview:self.playView];
    [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(width);
        make.centerX.mas_equalTo(0);
        make.centerY.equalTo(self.view).offset(-(kMainBoundsHeight / 8));
    }];
    
//    UIView * upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 2)];
//    upView.backgroundColor = [UIColor whiteColor];
//    [self.playView addSubview:upView];
//    
//    UIView * leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, width)];
//    leftView.backgroundColor = [UIColor whiteColor];
//    [self.playView addSubview:leftView];
//    
//    UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, width - 2, width, 2)];
//    bottomView.backgroundColor = [UIColor whiteColor];
//    [self.playView addSubview:bottomView];
//    
//    UIView * rightView = [[UIView alloc] initWithFrame:CGRectMake(width - 2, 0, 2, width)];
//    rightView.backgroundColor = [UIColor whiteColor];
//    [self.playView addSubview:rightView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)playDidEnd
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    self.playEnd();
}

//允许屏幕旋转
- (BOOL)shouldAutorotate
{
    return YES;
}

//返回当前屏幕旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
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
