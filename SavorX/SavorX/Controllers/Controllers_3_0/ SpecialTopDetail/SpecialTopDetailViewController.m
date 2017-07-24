//
//  SpecialTopDetailViewController.m
//  SavorX
//
//  Created by 王海朋 on 2017/7/7.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "SpecialTopDetailViewController.h"
#import "Masonry.h"
#import "HotTopicShareView.h"
#import "HSIsOrCollectionRequest.h"
#import "HotPopShareView.h"

@interface SpecialTopDetailViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIView *testView;
@property (nonatomic, strong) UIButton *collectButton;

@end

@implementation SpecialTopDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createWebView];
}

- (void)createWebView
{
    UIBarButtonItem * shareItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_share"] style:UIBarButtonItemStyleDone target:self action:@selector(shareAction)];
    self.collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.collectButton setImage:[UIImage imageNamed:@"icon_collect"] forState:UIControlStateNormal];
    [self.collectButton setImage:[UIImage imageNamed:@"icon_collect_yes"] forState:UIControlStateSelected];
    self.collectButton.frame = CGRectMake(0, 0, 40, 35);
    [self.collectButton addTarget:self action:@selector(collectAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * collectItem = [[UIBarButtonItem alloc] initWithCustomView:self.collectButton];
    self.navigationItem.rightBarButtonItems = @[shareItem, collectItem];
    if (self.specilDetailModel.collected == 1) {
        self.collectButton.selected = YES;
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = self.view.bounds.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
    self.webView = [[UIWebView alloc] init];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.delegate = self;
    self.webView.frame = CGRectMake(0, 0, width, height);
    
    if (!isEmptyString(self.specilDetailModel.contentURL)) {
        NSString *urlStr =  [NSString stringWithFormat:@"%@?location=newRead",self.specilDetailModel.contentURL];
        NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
        [self.webView loadRequest:request];
        [MBProgressHUD showWebLoadingHUDInView:self.webView];
    } 
    [self.view addSubview:self.webView];
    
    self.testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 140)];
    self.testView.backgroundColor = [UIColor clearColor];
    [self.webView.scrollView addSubview:self.testView];
    [self addObserver];
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
    NSString *urlStr =  [NSString stringWithFormat:@"%@?location=newRead",self.specilDetailModel.contentURL];
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
    [self.webView loadRequest:request];
    [MBProgressHUD showWebLoadingHUDInView:self.webView];
}

#pragma mark ---分享按钮点击
- (void)shareAction{
    [SAVORXAPI postUMHandleWithContentId:@"details_page_share" key:nil value:nil];
    HotPopShareView *shareView = [[HotPopShareView alloc] initWithModel:self.specilDetailModel andVC:self andCategoryID:self.categoryID];
    [[UIApplication sharedApplication].keyWindow addSubview:shareView];
}

#pragma mark ---收藏按钮点击
- (void)collectAction{
    
    NSInteger isCollect;
    if (self.collectButton.selected == YES) {
        isCollect = 0;
    }else{
        isCollect = 1;
    }
    HSIsOrCollectionRequest * request = [[HSIsOrCollectionRequest alloc] initWithArticleId:self.specilDetailModel.artid withState:isCollect];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSDictionary *dic = (NSDictionary *)response;
        if ([[dic objectForKey:@"code"] integerValue] == 10000) {
            if (self.specilDetailModel.collected == 1) {
                self.specilDetailModel.collected = 0;
                [MBProgressHUD showSuccessHUDInView:self.view title:@"取消成功"];
            }else{
                self.specilDetailModel.collected = 1;
                [MBProgressHUD showSuccessHUDInView:self.view title:@"收藏成功"];
            }
            self.collectButton.selected = !self.collectButton.selected;
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self footViewShouldBeReset];
    }
}

- (void)footViewShouldBeReset
{
    [self removeObserver];
    
    if (self.testView.superview) {
        [self.testView removeFromSuperview];
    }
    CGFloat theight =100;
    CGFloat height = self.webView.scrollView.contentSize.height;
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, theight);
    CGSize contentSize = self.webView.scrollView.contentSize;
    frame.origin.y = height;
    
    self.testView.frame = frame;
    [self.webView.scrollView addSubview:self.testView];
    [self.webView.scrollView setContentSize:CGSizeMake(contentSize.width, contentSize.height + theight )];
    
    [self addObserver];
    
    [self shareBoardByDefined];
}

- (void)shareBoardByDefined {
    HotTopicShareView *shareView = [[HotTopicShareView alloc] initWithModel:self.specilDetailModel andVC:self andCategoryID:self.categoryID andY:0];
    [self.testView addSubview:shareView];
}

- (void)addObserver
{
    [self.webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserver
{
    [self.webView.scrollView removeObserver:self forKeyPath:@"contentSize" context:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [SAVORXAPI postUMHandleWithContentId:@"details_page" key:nil value:nil];
}
- (void)viewDidDisappear:(BOOL)animated{
    [SAVORXAPI postUMHandleWithContentId:@"details_page_back" key:nil value:nil];
}
- (void)dealloc{
    
    [self removeObserver];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
