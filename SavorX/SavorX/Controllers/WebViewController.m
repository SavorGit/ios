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

@end

@implementation WebViewController

-(void)dealloc{
    
    if (!self.isOnlyVideo) {
        [self removeObserver];
    }
    
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
    
    [self checkIsOnline];
}

- (void)checkIsOnline
{
    [self showLoadingView];
    RDIsOnline * request = [[RDIsOnline alloc] initWithArtID:self.model.artid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self readyToGo];
        [self hiddenLoadingView];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self showNoDataViewInView:self.view noDataString:@"啊哦~页面跑丢了"];
        [self hiddenLoadingView];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self showNoNetWorkView:NoNetWorkViewStyle_No_NetWork];
        [self hiddenLoadingView];
    }];
}

- (void)readyToGo
{
    self.dataSource = [[NSMutableArray alloc] initWithCapacity:100];
    
    _isComplete = NO;
    
    [self createUI];
    [self setUpDatas];
}

//初始化界面
- (void)createUI
{
    self.title = self.model.title;
    
    //初始化播放器
    self.playView = [[GCCPlayerView alloc] initWithURL:self.model.videoURL];
    self.playView.backgroundColor = [UIColor blackColor];
    self.playView.delegate = self;
    [self.playView backgroundImage:self.model.imageURL];
    [self.playView setVideoTitle:self.model.title];
    [self.view addSubview:self.playView];
    self.playView.model = self.model;
    self.playView.categoryID = self.categoryID;
    [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.equalTo(self.view.mas_width).multipliedBy([UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height);
    }];
    
    [self refreshPageWithModel:self.model];
    
    //添加页面相关的通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillDidBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActivePlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)refreshPageWithModel:(CreateWealthModel *)model
{
    self.model = model;
    [self.playView setVideoTitle:self.model.title];
    [self.playView setPlayItemWithURL:[self.model.videoURL stringByAppendingString:@".f30.mp4"]];
    [self.playView backgroundImage:self.model.imageURL];
    
    if (model.type == 4) {
        
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
        [self addObserver];
    }
    if (!isEmptyString(self.model.contentURL)) {
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[self.model.contentURL stringByAppendingString:@"?location=newRead"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [self.webView loadRequest:request];
        [MBProgressHUD showWebLoadingHUDInView:self.webView];
    }
    
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
}

- (void)createWebViewWithVideo
{
    //初始化webView
    self.webView = [[UIWebView alloc] init];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    
    self.testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,kMainBoundsWidth, 100)];
    self.testView.backgroundColor = [UIColor clearColor];
    self.testView.clipsToBounds = YES;
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
    }else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        [MBProgressHUD hiddenWebLoadingInView:self.webView];
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [self.playView playOrientationLandscape];
        [MBProgressHUD hideHUDForView:self.webView animated:NO];
        [self.navigationController setNeedsStatusBarAppearanceUpdate];
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
            if (self.model.collected == 1) {
                self.model.collected = 0;
                [self.playView setIsCollect:NO];
                [MBProgressHUD showSuccessHUDInView:self.view title:@"取消成功"];
            }else{
                self.model.collected = 1;
                [self.playView setIsCollect:YES];
                [MBProgressHUD showSuccessHUDInView:self.view title:@"收藏成功"];
            }
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

#pragma mark ---视频分享按钮被点击
- (void)videoShouldBeShare
{
    [SAVORXAPI postUMHandleWithContentId:@"details_page_share" key:nil value:nil];
    HotPopShareView *shareView = [[HotPopShareView alloc] initWithModel:self.model  andVC:self andCategoryID:self.categoryID];
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
    [super viewWillAppear:animated];
//    [self.volumeView setHidden:NO];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
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
    if ([UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.playView shouldRelease];
    self.webView.delegate = nil;
    self.webView.scrollView.delegate = nil;
    
    [super viewDidDisappear:animated];
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_END type:RDLOGTYPE_CONTENT model:self.model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
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
    if (self.playView) {
        [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?location=newRead",self.model.contentURL]]]];
        [MBProgressHUD showWebLoadingHUDInView:self.webView];
    }else{
        [self checkIsOnline];
    }
}

- (BOOL)prefersStatusBarHidden
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == UIInterfaceOrientationPortrait) {
        return YES;
    }else{
        return self.toolViewIsHidden;
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
    [self.webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserver
{
    [self.webView.scrollView removeObserver:self forKeyPath:@"contentSize" context:nil];
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
    CGFloat theight = tabHeight + 100;
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
    self.testView.backgroundColor = UIColorFromRGB(0xece6de);
    
    [self addObserver];
    
    //不是纯视频类型添加分享部分
    if (self.model.type != 4) {
        [self shareBoardByDefined];
    }
}

- (void)shareBoardByDefined {
    
    if ([self.testView viewWithTag:2222]) {
        [[self.testView viewWithTag:2222] removeFromSuperview];
    }
    HotTopicShareView *shareView = [[HotTopicShareView alloc] initWithModel:self.model andVC:self andCategoryID:self.categoryID andY:0];
    shareView.tag = 2222;
    [self.testView addSubview:shareView];
    
}

#pragma mark - 初始化下方推荐数据
- (void)setUpDatas{
    [self checkCollectStatus];
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
        
        CGFloat diatanceToTop = 108;
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
        recommendLabel.frame = CGRectMake(10, 10, 100, 30);
        recommendLabel.textColor = UIColorFromRGB(0x922c3e);
        recommendLabel.font = kPingFangRegular(15);
        recommendLabel.text = @"为您推荐";
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
    CreateWealthModel *tmpModel = [self.dataSource objectAtIndex:indexPath.row];
    [self refreshPageWithModel:tmpModel];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
