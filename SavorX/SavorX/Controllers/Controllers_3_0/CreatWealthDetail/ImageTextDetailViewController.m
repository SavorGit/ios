//
//  ImageTextDetailViewController.m
//  小热点餐厅端Demo
//
//  Created by 王海朋 on 2017/7/4.
//  Copyright © 2017年 wanghaipeng. All rights reserved.
//

#import "ImageTextDetailViewController.h"
#import "Masonry.h"
#import "CreateWealthModel.h"
#import "RDFavoriteTableViewCell.h"
#import "HotTopicShareView.h"
#import "HSIsOrCollectionRequest.h"
#import "HSImTeRecommendRequest.h"
#import "HotPopShareView.h"
#import "HSGetCollectoinStateRequest.h"
#import "RDLogStatisticsAPI.h"
#import "RDIsOnline.h"
#import "WebViewController.h"
#import "ImageArrayViewController.h"

#define  igTextHeight (130 *802.f/1242.f + 12)

@interface ImageTextDetailViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>

@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, strong) UIView * testView;
@property (nonatomic, strong) UITableView * tableView; //表格展示视图
@property (nonatomic, strong) NSMutableArray * dataSource; //数据源
@property (nonatomic, strong) UIButton *collectButton;
@property (nonatomic, assign) BOOL isComplete; //内容是否阅读完整
@property (nonatomic, assign) BOOL isAd; //是否是广告网页

@property (nonatomic, assign) BOOL isReady;

@end

@implementation ImageTextDetailViewController

- (instancetype)initWithCategoryID:(NSInteger)categoryID model:(CreateWealthModel *)model
{
    if (self = [super init]) {
        self.imgTextModel = model;
        self.categoryID = categoryID;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self checkIsOnLine];
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillDidBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActivePlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
    self.view.backgroundColor = VCBackgroundColor;
    _dataSource = [[NSMutableArray alloc] initWithCapacity:100];
}

- (void)checkIsOnLine
{
    self.isReady = NO;
    self.isAd = NO;
    [self showLoadingView];
    RDIsOnline * request = [[RDIsOnline alloc] initWithArtID:self.imgTextModel.artid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        self.isReady = YES;
        [self hiddenLoadingView];
        [self setupViews];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        if ([[response objectForKey:@"code"] integerValue] == 19002) {
            [self theArtIsNotOnline];
        }else{
            [self showNoNetWorkViewInView:self.view];
        }
        [self hiddenLoadingView];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self showNoNetWorkViewInView:self.view];
        [self hiddenLoadingView];
    }];
}

- (void)theArtIsNotOnline
{
    UIView * notOnlineView = [[UIView alloc] init];
    notOnlineView.tag = 44444;
    notOnlineView.backgroundColor = VCBackgroundColor;
    [self.view addSubview:notOnlineView];
    [notOnlineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)notOnlineView;
    
    [self setNeedsStatusBarAppearanceUpdate];
    
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
    HSImTeRecommendRequest * request = [[HSImTeRecommendRequest alloc] initWithArticleId:self.imgTextModel.artid];
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
            tableView.backgroundColor = VCBackgroundColor;
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

- (void)setupViews
{
    _isComplete = NO;
    
    if (!self.webView) {
        
        UIBarButtonItem * shareItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_share"] style:UIBarButtonItemStyleDone target:self action:@selector(shareAction)];
        self.collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.collectButton setImage:[UIImage imageNamed:@"icon_collect"] forState:UIControlStateNormal];
        [self.collectButton setImage:[UIImage imageNamed:@"icon_collect_yes"] forState:UIControlStateSelected];
        self.collectButton.frame = CGRectMake(0, 0, 40, 35);
        [self.collectButton addTarget:self action:@selector(collectAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * collectItem = [[UIBarButtonItem alloc] initWithCustomView:self.collectButton];
        self.navigationItem.rightBarButtonItems = @[shareItem, collectItem];
    }else{
        [self removeObserver];
        [self.tableView removeFromSuperview];
        [self.testView removeFromSuperview];
        [self.webView removeFromSuperview];
    }
    
    [self createWebView];
    
    [self setUpDatas];
}

- (void)createWebView
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    self.webView = [[UIWebView alloc] init];
    
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    
    self.testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    self.testView.backgroundColor = UIColorFromRGB(0xf6f2ed);
    [self.webView.scrollView addSubview:self.testView];
    [self addObserver];
    
    self.webView.frame = CGRectMake(0, 0, width, height);
    if (!isEmptyString(self.imgTextModel.contentURL)) {
        NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[Helper addURLParamsInAPPWith:self.imgTextModel.contentURL]]];
        [self.webView loadRequest:request];
    }
    self.webView.backgroundColor = VCBackgroundColor;
    [self.webView setOpaque:NO];
    [self.view addSubview:self.webView];
    
    [self.testView addSubview:self.tableView];
    CGFloat tabHeiht = self.dataSource.count *(130 *802.f/1242.f + 12) +48;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(CGSizeMake(kMainBoundsWidth, tabHeiht));
        make.top.mas_equalTo(123+30);
        make.left.mas_equalTo(0);
    }];
}

- (void)checkCollectStatus
{
    self.collectButton.selected = NO;
    self.collectButton.userInteractionEnabled = NO;
    HSGetCollectoinStateRequest * stateRequest = [[HSGetCollectoinStateRequest alloc] initWithArticleID:self.imgTextModel.artid];
    [stateRequest sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        self.collectButton.userInteractionEnabled = YES;
        NSInteger collect = [[[response objectForKey:@"result"] objectForKey:@"state"] integerValue];
        // 设置收藏按钮状态
        if (collect == 1) {
            self.collectButton.selected = YES;
        }else{
            self.collectButton.selected = NO;
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hiddenWebLoadingInView:self.webView];
    
    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    NSLog(@"%@",currentURL);
    if ([currentURL containsString:@"pure=1"]) {
        self.isAd = YES;
        [self footViewShouldBeReset];
        webView.scrollView.bounces = NO;
    }else{
        // 如果当前是广告页切换至非广告页
        if (self.isAd == YES) {
            self.isAd = NO;
            [self footViewShouldBeReset];
            webView.scrollView.bounces = YES;
        }
    }
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
        [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[Helper addURLParamsInAPPWith:self.imgTextModel.contentURL]]]];
    }else{
        [self checkIsOnLine];
    }
}

#pragma mark ---分享按钮点击
- (void)shareAction{
    [SAVORXAPI postUMHandleWithContentId:@"details_page_share" key:nil value:nil];
    HotPopShareView *shareView = [[HotPopShareView alloc] initWithModel:self.imgTextModel andVC:self  andCategoryID:self.categoryID andSourceId:0];
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
    HSIsOrCollectionRequest * request = [[HSIsOrCollectionRequest alloc] initWithArticleId:self.imgTextModel.artid withState:isCollect];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSDictionary *dic = (NSDictionary *)response;
        if ([[dic objectForKey:@"code"] integerValue] == 10000) {
            if (isCollect == 0) {
                self.imgTextModel.collected = 0;
                [MBProgressHUD showSuccessHUDInView:self.view title:RDLocalizedString(@"RDString_SuccessWithCancle")];
                [SAVORXAPI postUMHandleWithContentId:@"details_page_cancel_collection" key:@"details_page_cancel_collection" value:@"success"];
            }else{
                self.imgTextModel.collected = 1;
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
    [MBProgressHUD hiddenWebLoadingInView:self.webView];
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self footViewShouldBeReset];
    }
}

- (void)footViewShouldBeReset
{
    [MBProgressHUD hiddenWebLoadingInView:self.webView];
    
    [self removeObserver];
    
    CGSize contentSize = self.webView.scrollView.contentSize;
    if (self.isAd == YES) {
        [self.webView.scrollView setContentSize:CGSizeMake(contentSize.width, contentSize.height - self.testView.height)];
        if (self.testView.superview) {
            [self.testView removeFromSuperview];
        }
        [self addObserver];
        return;
    }

    if (self.testView.superview) {
        [self.testView removeFromSuperview];
    }

    //TableView的高度
    CGFloat tabHeight = 0;
    if (self.dataSource.count != 0) {
        tabHeight = self.dataSource.count *(130 *802.f/1242.f + 12) + 48 + 8;
    }
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(tabHeight);
    }];
    
    //底部View总高度
    CGFloat theight = tabHeight + 115 + 30;
    if (self.dataSource.count != 0) {
        theight += 8;
    }
    CGFloat height = self.webView.scrollView.contentSize.height;
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, theight);
    //底部View与顶部网页的间隔为0
    frame.origin.y = height;
    self.testView.frame = frame;
    [self.webView.scrollView addSubview:self.testView];
    [self.webView.scrollView setContentSize:CGSizeMake(contentSize.width, contentSize.height + theight)];
    
    [self addObserver];
    
    [self shareBoardByDefined];
}

- (void)shareBoardByDefined {

    if ([self.testView viewWithTag:1000]) {
        [[self.testView viewWithTag:1000] removeFromSuperview];
    }
    HotTopicShareView *shareView = [[HotTopicShareView alloc] initWithModel:self.imgTextModel andVC:self andCategoryID:self.categoryID andY:30];
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

#pragma mark - 初始化下方推荐数据
- (void)setUpDatas{
    [self checkCollectStatus];
    HSImTeRecommendRequest * request = [[HSImTeRecommendRequest alloc] initWithArticleId:self.imgTextModel.artid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.dataSource removeAllObjects];
        
        NSDictionary *dic = (NSDictionary *)response;
        NSArray *resultArr = [dic objectForKey:@"result"];
        
        for (int i = 0; i < resultArr.count; i ++) {
            CreateWealthModel *welthModel = [[CreateWealthModel alloc] initWithDictionary:resultArr[i]];
            [self.dataSource addObject:welthModel];
        }
        
        // 当返回有推荐数据时调用
        if (self.dataSource.count > 0) {
            [self footViewShouldBeReset];
            [self.tableView reloadData];
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
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.backgroundView = nil;
        _tableView.scrollEnabled = NO;
        
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
    static NSString *cellID = @"imageTextTableCell";
    RDFavoriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[RDFavoriteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = UIColorFromRGB(0xf6f2ed);
    //最后一条分割线隐藏
    if (indexPath.row == self.dataSource.count - 1) {
        [cell setLineViewHidden:YES];
    }else{
        [cell setLineViewHidden:NO];
    }
    CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configWithModel:model];
    [cell reConfigWithTimeStr:model.updateTime];
    
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat tmpHeight = 130 *802.f/1242.f;
    return tmpHeight + 12;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [SAVORXAPI postUMHandleWithContentId:@"details_recommended" key:nil value:nil];
    
    CreateWealthModel *tmpModel = [self.dataSource objectAtIndex:indexPath.row];
    
    if (tmpModel.type == 4 || tmpModel.type == 3) {
        WebViewController * web = [[WebViewController alloc] initWithModel:tmpModel categoryID:self.categoryID];
        
        NSMutableArray * vcs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [vcs removeObject:self];
        [vcs addObject:web];
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
        self.imgTextModel = tmpModel;
        
        [self.dataSource removeAllObjects];
        [self footViewShouldBeReset];
        [self.tableView reloadData];
        
        [self checkIsOnLine];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    if (self.webView.scrollView.contentSize.height - self.webView.scrollView.contentOffset.y - self.webView.frame.size.height <= 100) {
        if (_isComplete == NO) {
            [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_COMPELETE type:RDLOGTYPE_CONTENT model:self.imgTextModel categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
            _isComplete = YES;
        }
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_START type:RDLOGTYPE_CONTENT model:self.imgTextModel categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
    [SAVORXAPI postUMHandleWithContentId:@"details_page" key:@"details_page" value:[NSString stringWithFormat:@"%ld", self.categoryID]];
    [SAVORXAPI postUMHandleWithContentId:@"details_begin_reading" key:@"details_begin_reading" value:[Helper getCurrentTimeWithFormat:@"YYYYMMddHHmmss"]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [RDIsOnline cancelRequest];
    [super viewDidDisappear:animated];
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_END type:RDLOGTYPE_CONTENT model:self.imgTextModel categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
    [SAVORXAPI postUMHandleWithContentId:@"details_page_back" key:nil value:nil];
    [SAVORXAPI postUMHandleWithContentId:@"details_end_reading" key:@"details_end_reading" value:[Helper getCurrentTimeWithFormat:@"YYYYMMddHHmmss"]];
}

//app进入后台运行
- (void)appWillDidBackground{
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_END type:RDLOGTYPE_CONTENT model:self.imgTextModel categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
}

//app进入前台运行
- (void)appBecomeActivePlayground{
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_START type:RDLOGTYPE_CONTENT model:self.imgTextModel categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
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
