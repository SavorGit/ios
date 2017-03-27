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
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self.webView loadRequest:request];
}

- (void)navBackButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [SAVORXAPI postUMHandleWithContentId:@"menu_help_back" key:nil value:nil];
}

@end
