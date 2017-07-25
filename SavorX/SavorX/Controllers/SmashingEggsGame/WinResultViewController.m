//
//  WinResultViewController.m
//  SavorX
//
//  Created by 王海朋 on 2017/7/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "WinResultViewController.h"
#import "HSRecordSmashEggsRequest.h"

@interface WinResultViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView * webView;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) NSString *winResultStr;

@end

@implementation WinResultViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = VCBackgroundColor;
    self.winResultStr = [[NSString alloc] init];
//    [self createWebView];
//    [self.view addSubview:self.topView];
    [self requestEggsResult];

}

// 请求砸蛋次数
- (void)requestEggsResult{
    
    [self showLoadingView];
    HSRecordSmashEggsRequest * request = [[HSRecordSmashEggsRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self hiddenLoadingView];
        
        NSDictionary *dic = (NSDictionary *)response;
        NSDictionary *resultDic = [dic objectForKey:@"result"];
        self.winResultStr = [NSString stringWithFormat:@"%@?deviceid=%@",resultDic[@"url"],[GlobalData shared].deviceID];
        [self createWebView];
        [self.view addSubview:self.topView];

    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self hiddenLoadingView];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self hiddenLoadingView];
    }];
}

- (void)createWebView
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    self.webView = [[UIWebView alloc] init];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.delegate = self;
    self.webView.frame = CGRectMake(0, 0, width, kMainBoundsHeight);
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.winResultStr]];
    [self.webView loadRequest:request];
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    
    [MBProgressHUD showWebLoadingHUDInView:self.webView];
    
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

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hiddenWebLoadingInView:self.webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hiddenWebLoadingInView:self.webView];
    NSLog(@"error%@",error);
    if ([error code] == NSURLErrorCancelled) {
        return;
    }
    [self showNoNetWorkViewInView:self.webView];
}

- (void)retryToGetData
{
    [self hideNoNetWorkView];
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.winResultStr]]];
    [MBProgressHUD showWebLoadingHUDInView:self.webView];
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
