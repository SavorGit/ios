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
    NSInteger width = [Helper autoWidthWith:180];
    
    if (kMainBoundsWidth >= 410) {
        width = [Helper autoWidthWith:210];
    }
    
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
