//
//  WinResultViewController.m
//  SavorX
//
//  Created by 王海朋 on 2017/7/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "WinResultViewController.h"

@interface WinResultViewController ()

@property (nonatomic, strong) UIWebView * webView;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation WinResultViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createWebView];
    [self.view addSubview:self.topView];
    
    // Do any additional setup after loading the view.
}

- (void)createWebView
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    self.webView = [[UIWebView alloc] init];
    self.webView.frame = CGRectMake(0, 0, width, kMainBoundsHeight);
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://admin.littlehotspot.com/content/3505.html"]];
    [self.webView loadRequest:request];
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    
}

- (BOOL)prefersStatusBarHidden {
    //隐藏为YES，显示为NO
    return YES;
}

#pragma mark - getter
- (UIView *)topView
{
    if (_topView == nil) {
        
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
        _topView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_topView];
        [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 44));
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }];
        
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(5,0, 40, 44)];
        [_backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [_backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateSelected];
        [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_backButton];
    }
    return _topView;
}

#pragma mark -backButtonClick
- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
