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
    self.playView = [[DefalutLaunchPlayView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    NSString * path = [[NSBundle mainBundle] pathForResource:@"DefaultLaunch" ofType:@"mp4"];
    [self.playView setVideoURL:path];
    [self.view addSubview:self.playView];
    
    [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([Helper autoWidthWith:200]);
        make.height.mas_equalTo([Helper autoWidthWith:200]);
        make.centerX.mas_equalTo(0);
        make.centerY.equalTo(self.view).offset(-(kMainBoundsHeight / 6));
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)playDidEnd
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    self.playEnd();
}

- (void)dealloc
{
    NSLog(@"释放了");
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
