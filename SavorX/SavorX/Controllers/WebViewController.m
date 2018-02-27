//
//  WebViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/8/8.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "WebViewController.h"
#import "UMCustomSocialManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "RDLogStatisticsAPI.h"
#import "RDHomeStatusView.h"
#import "HSIsOrCollectionRequest.h"
#import "HotPopShareView.h"
#import "HotTopicShareView.h"
#import "HSGetCollectoinStateRequest.h"
#import "HSImTeRecommendRequest.h"
#import "VideoTableViewCell.h"
#import "RDInteractionLoadingView.h"
#import "RDVideoHeaderView.h"
#import "RDFavoriteTableViewCell.h"
#import "RDIsOnline.h"
#import "ImageArrayViewController.h"
#import "ImageTextDetailViewController.h"

@interface WebViewController ()<UIWebViewDelegate, UIGestureRecognizerDelegate, GCCPlayerViewDelegate, UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) MPVolumeView * volumeView;
@property (nonatomic, assign) BOOL isComplete; //内容是否阅读完整
@property (nonatomic, assign) BOOL toolViewIsHidden;

@property (nonatomic, assign) BOOL isOnlyVideo; //是否是纯视频

//纯视频
@property (nonatomic, strong) UITableView * baseTableView; //纯视频展示视图

//非纯视频
@property (nonatomic, strong) UIWebView * webView; //加载Html网页视图
@property (nonatomic, strong) UIView * testView;   //底部视图
@property (nonatomic, strong) UITableView * tableView; //表格展示视图
@property (nonatomic, strong) NSMutableArray * dataSource; //数据源
@property (nonatomic, assign) BOOL hasDidLoad;
@property (nonatomic, assign) BOOL hasWebObserver;

@property (nonatomic, assign) BOOL isNeedHiddenNav; //是否需要隐藏导航栏

@end

@implementation WebViewController

-(void)dealloc{
    
    [self removeObserver];
    
//    [HSImTeRecommendRequest cancelRequest];
    
    //移除页面相关通知监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidBindDeviceNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (instancetype)initWithModel:(CreateWealthModel *)model categoryID:(NSInteger)categoryID
{
    if (self = [super init]) {
        self.model = model;
        self.categoryID = categoryID;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [NSMutableArray new];
    
    [self showLoadingView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkIsOnline];
    });
}

- (void)checkIsOnline
{
    self.isNeedHiddenNav = NO;
    [self showLoadingView];
    RDIsOnline * request = [[RDIsOnline alloc] initWithArtID:self.model.artid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self hiddenLoadingView];
        self.isNeedHiddenNav = YES;
        [self readyToGo];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self hiddenLoadingView];
        if ([[response objectForKey:@"code"] integerValue] == 19002) {
            [self theVideoIsNotOnline];
        }else{
            [self showNoNetWorkViewInView:self.view];
        }
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self hiddenLoadingView];
        [self showNoNetWorkView:NoNetWorkViewStyle_No_NetWork];
    }];
}

- (void)theVideoIsNotOnline
{
    UIView * notOnlineView = [[UIView alloc] init];
    notOnlineView.tag = 44444;
    notOnlineView.backgroundColor = VCBackgroundColor;
    [self.view addSubview:notOnlineView];
    [notOnlineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)notOnlineView;
    
    self.isNeedHiddenNav = NO;
    
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setNavigationBarHidden:self.isNeedHiddenNav animated:NO];
    
    UIView * topView = [[UIView alloc] init];
    [notOnlineView addSubview:topView];
    topView.backgroundColor = VCBackgroundColor;
    CGFloat height = self.view.frame.size.width * 0.45;
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(height);
    }];
    
    UILabel * label = [[UILabel alloc] init];
    label.textColor = UIColorFromRGB(0x434343);
    label.text = @"该内容找不到了~";
    label.font = kPingFangRegular(15);
    label.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(25);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    
    UIImageView * imageView = [[UIImageView alloc] init];
    [imageView setImage:[UIImage imageNamed:@"kong_wenzhang.png"]];
    [topView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.equalTo(label.mas_top).offset(-10);
        make.size.mas_equalTo(CGSizeMake(83 / 5 * 4, 69 / 5 * 4));
    }];
    
//    UIView * lineView = [[UIView alloc] init];
//    lineView.backgroundColor = UIColorFromRGB(0xe0dad2);
//    [topView addSubview:lineView];
//    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.mas_equalTo(0);
//        make.height.mas_equalTo(1);
//    }];
    
    [HSImTeRecommendRequest cancelRequest];
    HSImTeRecommendRequest * request = [[HSImTeRecommendRequest alloc] initWithArticleId:self.model.artid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.dataSource removeAllObjects];
        
        NSDictionary *dic = (NSDictionary *)response;
        NSArray *resultArr = [dic objectForKey:@"result"];
        
        for (int i = 0; i < resultArr.count; i ++) {
            CreateWealthModel *welthModel = [[CreateWealthModel alloc] initWithDictionary:resultArr[i]];
            welthModel.acreateTime = welthModel.updateTime;
            [self.dataSource addObject:welthModel];
        }
        
        if (self.dataSource.count > 0) {
            UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight) style:UITableViewStyleGrouped];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.clipsToBounds = YES;
            tableView.backgroundColor = UIColorFromRGB(0xf6f2ed);
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.tag = 4444;
            [notOnlineView addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(0);
            }];
            
            UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height + 48)];
            headView.backgroundColor = UIColorFromRGB(0xf6f2ed);
            
            [topView removeFromSuperview];
            [headView addSubview:topView];
            [topView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.mas_equalTo(0);
                make.height.mas_equalTo(height);
            }];
            
            UILabel *recommendLabel = [[UILabel alloc] init];
            recommendLabel.textColor = UIColorFromRGB(0x922c3e);
            recommendLabel.font = kPingFangRegular(15);
            recommendLabel.text = RDLocalizedString(@"RDString_RecommendForYou");
            recommendLabel.textAlignment = NSTextAlignmentLeft;
            [headView addSubview:recommendLabel];
            [recommendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(15);
                make.bottom.mas_equalTo(-8);
                make.size.mas_equalTo(CGSizeMake(100, 30));
            }];
            tableView.tableHeaderView = headView;
            
            [tableView reloadData];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)readyToGo
{
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setNavigationBarHidden:self.isNeedHiddenNav animated:NO];
    
    _isComplete = NO;
    
    [self createUI];
}

//初始化界面
- (void)createUI
{
    if (!self.hasDidLoad) {
        
        //初始化播放器
        self.playView = [[GCCPlayerView alloc] initWithURL:self.model.videoURL];
        self.playView.backgroundColor = [UIColor blackColor];
        self.playView.delegate = self;
        [self.playView backgroundImage:self.model.imageURL];
        [self.playView setVideoTitle:self.model.title];
        [self.view addSubview:self.playView];
        self.playView.model = self.model;
        self.playView.categoryID = self.categoryID;
        if ([GlobalData shared].isIphoneX) {
            CGFloat width = kMainBoundsWidth;
            CGFloat height = kMainBoundsHeight - kStatusBarHeight - 34;
            [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(kStatusBarHeight);
                make.left.mas_equalTo(0);
                make.right.mas_equalTo(0);
                make.height.mas_equalTo(self.playView.mas_width).multipliedBy(width / height);
            }];
        }else{
            [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.left.mas_equalTo(0);
                make.right.mas_equalTo(0);
                make.height.equalTo(self.view.mas_width).multipliedBy([UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height);
            }];
        }
        
        self.view.backgroundColor = [UIColor blackColor];
    }
    
    [self refreshPage];
    
    if (!self.hasDidLoad) {
        //添加页面相关的通知监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        // app退到后台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillDidBackground) name:UIApplicationWillResignActiveNotification object:nil];
        // app进入前台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActivePlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    self.hasDidLoad = YES;
}

- (void)refreshPage
{
    [self.playView setVideoTitle:self.model.title];
    [self.playView setPlayItemWithURL:[self.model.videoURL stringByAppendingString:@".f30.mp4"]];
    [self.playView backgroundImage:self.model.imageURL];
    
    if (self.model.type == 4) {
        
        self.isOnlyVideo = YES;
        [self refreshWithOnlyVideo];
        
    }else{
        
        self.isOnlyVideo = NO;
        [self refreshWithVideo];
        
    }
    
    [self setUpDatas];
}

#pragma mark - 非纯视频的页面布局
- (void)refreshWithVideo
{
    if (self.baseTableView.superview) {
        self.baseTableView.delegate = nil;
        self.baseTableView.dataSource = nil;
        [self.baseTableView removeFromSuperview];
    }
    
    if (!self.webView) {
        [self createWebViewWithVideo];
    }
    if (!self.webView.superview) {
        [self.view addSubview:self.webView];
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.playView.mas_bottom);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(kMainBoundsWidth);
            make.bottom.mas_equalTo(0);
        }];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.webView.scrollView.delegate = self;
        self.webView.delegate = self;
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)self.webView;
    }
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    if (!isEmptyString(self.model.contentURL)) {
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[Helper addURLParamsInAPPWith:self.model.contentURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [self.webView loadRequest:request];
        [MBProgressHUD showWebLoadingHUDInView:self.webView];
        [self addObserver];
    }
}

- (void)createWebViewWithVideo
{
    //初始化webView
    self.webView = [[UIWebView alloc] init];
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.backgroundColor = VCBackgroundColor;
    self.webView.opaque = NO;
    
    [self.webView.scrollView addSubview:self.testView];
}

#pragma mark - 纯视频的页面布局
//刷新当前的纯视频视图
- (void)refreshWithOnlyVideo
{
    if (self.webView.superview) {
        //移除非纯视频播放展示的webView
        [self.webView removeFromSuperview];
        [self.testView removeFromSuperview];
        self.webView.delegate = nil;
        self.webView.scrollView.delegate = nil;
        self.tableView.delegate = nil;
        self.tableView.dataSource = nil;
        [self removeObserver];
    }
    
    //添加纯视频播放页面的推荐列表
    if (!self.baseTableView) {
        [self createTableViewWithOnlyVideo];
    }
    if (!self.baseTableView.superview) {
        [self.view addSubview:self.baseTableView];
        [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.playView.mas_bottom).offset(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
        self.baseTableView.dataSource = self;
        self.baseTableView.delegate = self;
    }
    
    //添加用户右滑退出该页面的手势操作
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self.baseTableView;
    RDVideoHeaderView * headerView = (RDVideoHeaderView *)self.baseTableView.tableHeaderView;
    [headerView reloadWithModel:self.model];
    
    [self.dataSource removeAllObjects];
    [self.baseTableView reloadData];
}

- (void)createTableViewWithOnlyVideo
{
    self.baseTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight) style:UITableViewStyleGrouped];
    self.baseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.baseTableView.clipsToBounds = YES;
    self.baseTableView.backgroundColor = UIColorFromRGB(0xf6f2ed);
    
    RDVideoHeaderView * headerView = [[RDVideoHeaderView alloc] init];
    self.baseTableView.tableHeaderView = headerView;
}

//返回按钮被点击
- (void)backButtonDidBeClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

//手机的方向发生了变化
- (void)orientationChanged
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        [self.playView playOrientationPortrait];
        
        if (self.webView.isLoading) {
            [MBProgressHUD showWebLoadingHUDInView:self.webView];
        }
        [self.navigationController setNeedsStatusBarAppearanceUpdate];
        
        if ([GlobalData shared].isIphoneX) {
            [self.playView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(0);
                make.right.mas_equalTo(0);
                make.top.mas_equalTo(kStatusBarHeight);
            }];
        }
        
    }else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        [MBProgressHUD hiddenWebLoadingInView:self.webView];
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [self.playView playOrientationLandscape];
        [MBProgressHUD hideHUDForView:self.webView animated:NO];
        [self.navigationController setNeedsStatusBarAppearanceUpdate];
        if ([GlobalData shared].isIphoneX) {
            [self.playView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(44);
                make.right.mas_equalTo(-34);
                make.top.mas_equalTo(0);
            }];
        }
    }
}

#pragma mark ---收藏按钮点击
- (void)videoShouldBeCollect:(UIButton *)button
{
    NSInteger isCollect;
    if (button.selected == YES) {
        isCollect = 0;
    }else{
        isCollect = 1;
    }
    HSIsOrCollectionRequest * request = [[HSIsOrCollectionRequest alloc] initWithArticleId:self.model.artid withState:isCollect];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSDictionary *dic = (NSDictionary *)response;
        if ([[dic objectForKey:@"code"] integerValue] == 10000) {
            if (isCollect == 0) {
                self.model.collected = 0;
                [self.playView setIsCollect:NO];
                [MBProgressHUD showSuccessHUDInView:self.view title:RDLocalizedString(@"RDString_SuccessWithCancle")];
                [SAVORXAPI postUMHandleWithContentId:@"details_page_cancel_collection" key:@"details_page_cancel_collection" value:@"success"];
            }else{
                self.model.collected = 1;
                [self.playView setIsCollect:YES];
                [MBProgressHUD showSuccessHUDInView:self.view title:RDLocalizedString(@"RDString_SuccessWithCollect")];
                [SAVORXAPI postUMHandleWithContentId:@"details_page_collection" key:@"details_page_collection" value:@"success"];
            }
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

#pragma mark ---视频分享按钮被点击
- (void)videoShouldBeShare
{
    [SAVORXAPI postUMHandleWithContentId:@"details_page_share" key:nil value:nil];
    HotPopShareView *shareView = [[HotPopShareView alloc] initWithModel:self.model  andVC:self andCategoryID:self.categoryID andSourceId:0];
    [self.view addSubview:shareView];
}

- (void)toolViewHiddenStatusDidChangeTo:(BOOL)isHidden
{
    self.toolViewIsHidden = isHidden;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight) {
        [self.navigationController setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [MobClick beginLogPageView:NSStringFromClass([self class])];
    [self.navigationController setNavigationBarHidden:self.isNeedHiddenNav animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_START type:RDLOGTYPE_CONTENT model:self.model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.playView pause];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.navigationController.topViewController == self) {
        return;
    }
    [self shouldRelease];
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_END type:RDLOGTYPE_CONTENT model:self.model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
}

- (void)shouldRelease
{
    [RDIsOnline cancelRequest];
    if (self.playView) {
        [self.playView shouldRelease];
    }
    if (self.webView) {
        self.webView.delegate = nil;
        self.webView.scrollView.delegate = nil;
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString hasSuffix:@"mp4"]) {
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hiddenWebLoadingInView:self.webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self showNoNetWorkViewInView:self.webView];
}

- (void)retryToGetData
{
    [self hideNoNetWorkView];
    [self checkIsOnline];
}

- (BOOL)prefersStatusBarHidden
{
    if (self.isNeedHiddenNav) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (orientation == UIInterfaceOrientationPortrait) {
            
            if ([GlobalData shared].isIphoneX) {
                return NO;
            }else{
                return YES;
            }
            
        }else{
            return self.toolViewIsHidden;
        }
    }else{
        return NO;
    }
}

#pragma mark 屏幕转屏相关

/**
 *  强制屏幕转屏
 *
 *  @param orientation 屏幕方向
 */
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    // arc下
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)navBackButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [SAVORXAPI postUMHandleWithContentId:@"details_page_back" key:nil value:nil];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    if (self.webView.scrollView.contentSize.height - self.webView.scrollView.contentOffset.y - self.webView.frame.size.height <= 100) {
        if (_isComplete == NO) {
            [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_COMPELETE type:RDLOGTYPE_CONTENT model:self.model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
            _isComplete = YES;
        }

    }
}

//app进入后台运行
- (void)appWillDidBackground{
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_END type:RDLOGTYPE_CONTENT model:self.model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
}

//app进入前台运行
- (void)appBecomeActivePlayground{
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_START type:RDLOGTYPE_CONTENT model:self.model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addObserver
{
    if (!self.hasWebObserver) {
        self.hasWebObserver = YES;
        [self.webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeObserver
{
    if (self.hasWebObserver) {
        self.hasWebObserver = NO;
        [self.webView.scrollView removeObserver:self forKeyPath:@"contentSize" context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [MBProgressHUD hiddenWebLoadingInView:self.webView];
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
    //TableView的高度
    CGFloat tabHeight = 0;
    if (self.dataSource.count != 0) {
        tabHeight = self.dataSource.count *96 + 48;
    }
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(tabHeight);
    }];
    
    //底部View总高度
    CGFloat theight = tabHeight + 115 + 30;
    if (self.dataSource.count != 0) {
        theight += 8;
    }
    
    CGFloat cSizeheight = self.webView.scrollView.contentSize.height;
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, theight);
    CGSize contentSize = self.webView.scrollView.contentSize;
    //底部View与顶部网页的间隔为0
    frame.origin.y = cSizeheight;
    self.testView.frame = frame;
    [self.webView.scrollView addSubview:self.testView];
    [self.webView.scrollView setContentSize:CGSizeMake(contentSize.width, contentSize.height + theight)];
    
    [self addObserver];
    
    //不是纯视频类型添加分享部分
    if (self.model.type != 4) {
        [self shareBoardByDefined];
    }
}

- (void)shareBoardByDefined {
    
    if ([self.testView viewWithTag:1000]) {
        [[self.testView viewWithTag:1000] removeFromSuperview];
    }
    HotTopicShareView *shareView = [[HotTopicShareView alloc] initWithModel:self.model andVC:self andCategoryID:self.categoryID andY:30];
    shareView.tag = 1000;
    [self.testView addSubview:shareView];
    
}

#pragma mark - 初始化下方推荐数据
- (void)setUpDatas{
    [self checkCollectStatus];
    [HSImTeRecommendRequest cancelRequest];
    HSImTeRecommendRequest * request = [[HSImTeRecommendRequest alloc] initWithArticleId:self.model.artid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.dataSource removeAllObjects];
        
        NSDictionary *dic = (NSDictionary *)response;
        NSArray *resultArr = [dic objectForKey:@"result"];
        
        for (int i = 0; i < resultArr.count; i ++) {
            CreateWealthModel *welthModel = [[CreateWealthModel alloc] initWithDictionary:resultArr[i]];
            welthModel.acreateTime = welthModel.updateTime;
            [self.dataSource addObject:welthModel];
        }
        // 当返回有推荐数据时调用
        
        if (self.dataSource.count > 0) {
            if (self.isOnlyVideo) {
                [self.baseTableView reloadData];
            }else{
                [self footViewShouldBeReset];
                [self.tableView reloadData];
            }
        }
        
        if (self.isOnlyVideo) {
            RDVideoHeaderView * headerView = (RDVideoHeaderView *)self.baseTableView.tableHeaderView;
            [headerView needRecommand:self.dataSource.count != 0];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (self.isOnlyVideo) {
            RDVideoHeaderView * headerView = (RDVideoHeaderView *)self.baseTableView.tableHeaderView;
            [headerView needRecommand:self.dataSource.count != 0];
        }
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        if (self.isOnlyVideo) {
            RDVideoHeaderView * headerView = (RDVideoHeaderView *)self.baseTableView.tableHeaderView;
            [headerView needRecommand:self.dataSource.count != 0];
        }
        
    }];
}

- (void)checkCollectStatus
{
    [self.playView setIsCollect:NO];
    [self.playView setCollectEnable:NO];
    HSGetCollectoinStateRequest * stateRequest = [[HSGetCollectoinStateRequest alloc] initWithArticleID:self.model.artid];
    [stateRequest sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.playView setCollectEnable:YES];
        NSInteger collect = [[[response objectForKey:@"result"] objectForKey:@"state"] integerValue];
        // 设置收藏按钮状态
        if (collect == 1) {
            [self.playView setIsCollect:YES];
        }else{
            [self.playView setIsCollect:NO];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

#pragma mark -- 懒加载
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = UIColorFromRGB(0xf6f2ed);
        _tableView.backgroundView = nil;
        _tableView.scrollEnabled = NO;
        [self.testView addSubview:_tableView];
        
        CGFloat diatanceToTop = 115+30+8;
        // 纯视频类型去除上边分享部分
        if (self.model.type == 4) {
            diatanceToTop = 8;
        }
        CGFloat tabHeiht;
        if (self.dataSource.count == 0) {
            tabHeiht = 0;
        }else{
            tabHeiht = self.dataSource.count *96 +48;
        }
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(kMainBoundsWidth);
            make.height.mas_equalTo(tabHeiht);
            make.top.mas_equalTo(diatanceToTop);
            make.left.mas_equalTo(0);
        }];
        
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 48)];
        headView.backgroundColor = UIColorFromRGB(0xf6f2ed);
        UILabel *recommendLabel = [[UILabel alloc] init];
        recommendLabel.frame = CGRectMake(15, 10, 100, 30);
        recommendLabel.textColor = UIColorFromRGB(0x922c3e);
        recommendLabel.font = kPingFangRegular(15);
        recommendLabel.text = RDLocalizedString(@"RDString_RecommendForYou");
        recommendLabel.textAlignment = NSTextAlignmentLeft; 
        [headView addSubview:recommendLabel];
        _tableView.tableHeaderView = headView;
    }
    
    return _tableView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"videoTableCell";
    RDFavoriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[RDFavoriteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    //最后一条分割线隐藏
    if (indexPath.row == self.dataSource.count - 1) {
        [cell setLineViewHidden:YES];
    }else{
        [cell setLineViewHidden:NO];
    }
    
    CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configWithModel:model];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 96.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [SAVORXAPI postUMHandleWithContentId:@"details_recommended" key:nil value:nil];
    
    CreateWealthModel *tmpModel = [self.dataSource objectAtIndex:indexPath.row];
    if (tmpModel.type == 1) {
        
        ImageTextDetailViewController * text = [[ImageTextDetailViewController alloc] initWithCategoryID:self.categoryID model:tmpModel];
        
        NSMutableArray * vcs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [vcs removeObject:self];
        [vcs addObject:text];
        [self.navigationController setViewControllers:vcs animated:YES];
        
    }else if (tmpModel.type == 2){
        
        ImageArrayViewController * image = [[ImageArrayViewController alloc] initWithCategoryID:self.categoryID model:tmpModel];
        
        image.parentNavigationController = self.navigationController;
        float version = [UIDevice currentDevice].systemVersion.floatValue;
        if (version < 8.0) {
            self.modalPresentationStyle = UIModalPresentationCurrentContext;
        } else {;
            image.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        image.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        UIViewController * vc = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        [self.navigationController popViewControllerAnimated:NO];
        [vc presentViewController:image animated:NO completion:^{
            
        }];
        
    }else{
        self.model = tmpModel;
        self.isNeedHiddenNav = NO;
        
        [self showLoadingView];
        RDIsOnline * request = [[RDIsOnline alloc] initWithArtID:self.model.artid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [self hiddenLoadingView];
            self.isNeedHiddenNav = YES;
            [self readyToGo];
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [self hiddenLoadingView];
            if ([[response objectForKey:@"code"] integerValue] == 19002) {
                [self theVideoIsNotOnline];
            }else{
                [self showNoNetWorkViewInView:self.view];
                [self setNeedsStatusBarAppearanceUpdate];
                [self.navigationController setNavigationBarHidden:self.isNeedHiddenNav animated:NO];
            }
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            [self hiddenLoadingView];
            [self.navigationController setNavigationBarHidden:self.isNeedHiddenNav animated:NO];
            [self setNeedsStatusBarAppearanceUpdate];
            [self showNoNetWorkView:NoNetWorkViewStyle_No_NetWork];
        }];
    }
}

- (UIView *)testView
{
    if (!_testView) {
        _testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,kMainBoundsWidth, 100)];
        _testView.backgroundColor = UIColorFromRGB(0xf6f2ed);
        _testView.clipsToBounds = YES;
    }
    return _testView;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.isNeedHiddenNav) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
}

@end
