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
#import "RDIsOnline.h"
#import "RDLogStatisticsAPI.h"

@interface SpecialTopDetailViewController () <UIWebViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIView *testView;
@property (nonatomic, strong) UIButton *collectButton;

@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, assign) BOOL isComplete; //内容是否阅读完整

@end

@implementation SpecialTopDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.categoryID = 103;
    [self checkIsOnLine];
}

- (void)checkIsOnLine
{
    self.isReady = NO;
    [self showLoadingView];
    RDIsOnline * request = [[RDIsOnline alloc] initWithArtID:self.specilDetailModel.artid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        self.isReady = YES;
        [self hiddenLoadingView];
        [self createWebView];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self hiddenLoadingView];
        [self showNoDataViewInView:self.view noDataType:kNoDataType_NotFound];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self hiddenLoadingView];
        [self showNoNetWorkViewInView:self.view];
    }];
}

- (void)createWebView
{
    _isComplete = NO;
    
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillDidBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActivePlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
    
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
    CGFloat height = self.view.bounds.size.height;
    self.webView = [[UIWebView alloc] init];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    self.webView.opaque = NO;
    self.webView.frame = CGRectMake(0, 0, width, height);
    
    if (!isEmptyString(self.specilDetailModel.contentURL)) {
        NSString *urlStr =  [NSString stringWithFormat:@"%@?location=newRead&app=inner",self.specilDetailModel.contentURL];
        NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
        [self.webView loadRequest:request];
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [MBProgressHUD showWebLoadingHUDInView:self.webView];
    return YES;
}

- (void)retryToGetData
{
    [self hideNoNetWorkView];
    if (self.isReady) {
        NSString *urlStr =  [NSString stringWithFormat:@"%@?location=newRead&app=inner",self.specilDetailModel.contentURL];
        NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
        [self.webView loadRequest:request];
        [MBProgressHUD showWebLoadingHUDInView:self.webView];
    }else{
        [self checkIsOnLine];
    }
}

#pragma mark ---分享按钮点击
- (void)shareAction{
    [SAVORXAPI postUMHandleWithContentId:@"details_page_share" key:nil value:nil];
    HotPopShareView *shareView = [[HotPopShareView alloc] initWithModel:self.specilDetailModel andVC:self andCategoryID:self.categoryID andSourceId:0];
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
                [MBProgressHUD showSuccessHUDInView:self.view title:RDLocalizedString(@"RDString_SuccessWithCancle")];
                [SAVORXAPI postUMHandleWithContentId:@"details_page_cancel_collection" key:@"details_page_cancel_collection" value:@"success"];
            }else{
                self.specilDetailModel.collected = 1;
                [MBProgressHUD showSuccessHUDInView:self.view title:RDLocalizedString(@"RDString_SuccessWithCollect")];
                [SAVORXAPI postUMHandleWithContentId:@"details_page_collection" key:@"details_page_collection" value:@"success"];
            }
            self.collectButton.selected = !self.collectButton.selected;
        }
        
        [GlobalData shared].isCollectAction = YES;
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        if (isCollect == 0) {
            [SAVORXAPI postUMHandleWithContentId:@"details_page_cancel_collection" key:@"details_page_cancel_collection" value:@"fail"];
        }else{
            [SAVORXAPI postUMHandleWithContentId:@"details_page_collection" key:@"details_page_collection" value:@"fail"];
        }
        [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FailedWithCollect") delay:1.f];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        if (isCollect == 0) {
            [SAVORXAPI postUMHandleWithContentId:@"details_page_cancel_collection" key:@"details_page_cancel_collection" value:@"fail"];
        }else{
            [SAVORXAPI postUMHandleWithContentId:@"details_page_collection" key:@"details_page_collection" value:@"fail"];
        }
        [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FailedWithCollect") delay:1.f];
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
    [MBProgressHUD hiddenWebLoadingInView:self.webView];
    [self removeObserver];
    
    if (self.testView.superview) {
        [self.testView removeFromSuperview];
    }
    CGFloat theight =115 + 30;
    CGFloat height = self.webView.scrollView.contentSize.height;
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, theight);
    CGSize contentSize = self.webView.scrollView.contentSize;
    frame.origin.y = height;
    
    self.testView.frame = frame;
    [self.webView.scrollView addSubview:self.testView];
    self.testView.backgroundColor = UIColorFromRGB(0xf6f2ed);
    [self.webView.scrollView setContentSize:CGSizeMake(contentSize.width, contentSize.height + theight )];
    
    [self addObserver];
    
    [self shareBoardByDefined];
}

- (void)shareBoardByDefined {
    if ([self.testView viewWithTag:1000]) {
        [[self.testView viewWithTag:1000] removeFromSuperview];
    }
    HotTopicShareView *shareView = [[HotTopicShareView alloc] initWithModel:self.specilDetailModel andVC:self andCategoryID:self.categoryID andY:30];
    shareView.tag = 1000;
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
    
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_START type:RDLOGTYPE_CONTENT model:self.specilDetailModel categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
    [SAVORXAPI postUMHandleWithContentId:@"details_page" key:@"details_page" value:[NSString stringWithFormat:@"%ld", self.categoryID]];
}

- (void)viewDidDisappear:(BOOL)animated{
    [RDIsOnline cancelRequest];
    [super viewDidDisappear:animated];
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_END type:RDLOGTYPE_CONTENT model:self.specilDetailModel categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
    [SAVORXAPI postUMHandleWithContentId:@"details_page_back" key:nil value:nil];
}

//app进入后台运行
- (void)appWillDidBackground{
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_END type:RDLOGTYPE_CONTENT model:self.specilDetailModel categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
}

//app进入前台运行
- (void)appBecomeActivePlayground{
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_START type:RDLOGTYPE_CONTENT model:self.specilDetailModel categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    if (self.webView.scrollView.contentSize.height - self.webView.scrollView.contentOffset.y - self.webView.frame.size.height <= 100) {
        if (_isComplete == NO) {
            [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_COMPELETE type:RDLOGTYPE_CONTENT model:self.specilDetailModel categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
            _isComplete = YES;
        }
    }
}

- (void)navBackButtonClicked:(UIButton *)sender
{
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dealloc{
    
    [self removeObserver];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
