//
//  HelpViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/8/31.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()<UIScrollViewDelegate,UIWebViewDelegate>

@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, copy) NSString * url;

@end

@implementation HelpViewController

- (instancetype)initWithURL:(NSString *)url
{
    if (self = [super init]) {
        self.url = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customHelpView];
}

-(void)viewDidAppear:(BOOL)animated{
    [SAVORXAPI postUMHandleWithContentId:@"menu_help" key:nil value:nil];
}

- (void)customHelpView
{
    self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.opaque = NO;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self.webView loadRequest:request];
}

- (void)navBackButtonClicked:(UIButton *)sender {
    
    [SAVORXAPI postUMHandleWithContentId:@"menu_help_back" key:nil value:nil];
    if (self.webView.canGoBack) {
        [self.webView goBack];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *currentUrl = self.webView.request.URL.absoluteString;
    if (![currentUrl isEqualToString:@"http://h5.littlehotspot.com/Public/html/help/"]) {
       [SAVORXAPI postUMHandleWithContentId:@"menu_help_web" key:nil value:nil];
    }
}

@end
