//
//  HelpViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/8/31.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIWebView * webView;

@end

@implementation HelpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customHelpView];
}

- (void)customHelpView
{
    self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.opaque = NO;
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://h5.rerdian.com/Public/html/help"]];
    [self.webView loadRequest:request];
}

@end
