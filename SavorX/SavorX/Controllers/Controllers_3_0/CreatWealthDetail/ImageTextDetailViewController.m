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
#import "ImageTextTableViewCell.h"
#import "HotTopicShareView.h"
#import "HSIsOrCollectionRequest.h"
#import "HSImTeRecommendRequest.h"
#import "HotPopShareView.h"
#import "HSGetCollectoinStateRequest.h"
#import "RDLogStatisticsAPI.h"

@interface ImageTextDetailViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>

@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, strong) UIView * testView;
@property (nonatomic, strong) UITableView * tableView; //表格展示视图
@property (nonatomic, strong) NSMutableArray * dataSource; //数据源
@property (nonatomic, strong) UIButton *collectButton;
@property (nonatomic, assign) BOOL isComplete; //内容是否阅读完整

@end

@implementation ImageTextDetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    _isComplete = NO;
    
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillDidBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActivePlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.view.backgroundColor = VCBackgroundColor;
    _dataSource = [[NSMutableArray alloc] initWithCapacity:100];
    
    [self createWebView];
    [self setUpDatas];
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
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = self.view.bounds.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    self.webView.frame = CGRectMake(0, 0, width, height);
    if (!isEmptyString(self.imgTextModel.contentURL)) {
        NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?location=newRead",self.imgTextModel.contentURL]]];
        [self.webView loadRequest:request];
        [MBProgressHUD showWebLoadingHUDInView:self.webView];
    }
    self.webView.backgroundColor = [UIColor clearColor];
    [self.webView setOpaque:NO];
    [self.view addSubview:self.webView];
    
    self.testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 140)];
    self.testView.backgroundColor = [UIColor clearColor];
    [self.webView.scrollView addSubview:self.testView];
    [self addObserver];
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

//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    [MBProgressHUD hiddenWebLoadingInView:self.webView];
//}

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
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?location=newRead",self.imgTextModel.contentURL]]]];
    [MBProgressHUD showWebLoadingHUDInView:self.webView];
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
                [MBProgressHUD showSuccessHUDInView:self.view title:@"取消成功"];
                [SAVORXAPI postUMHandleWithContentId:@"details_page_cancel_collection" key:@"details_page_cancel_collection" value:@"success"];
            }else{
                self.imgTextModel.collected = 1;
                [MBProgressHUD showSuccessHUDInView:self.view title:@"收藏成功"];
                [SAVORXAPI postUMHandleWithContentId:@"details_page_collection" key:@"details_page_collection" value:@"success"];
            }
            self.collectButton.selected = !self.collectButton.selected;
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        if (isCollect == 0) {
            [SAVORXAPI postUMHandleWithContentId:@"details_page_cancel_collection" key:@"details_page_cancel_collection" value:@"fail"];
        }else{
            [SAVORXAPI postUMHandleWithContentId:@"details_page_collection" key:@"details_page_collection" value:@"fail"];
        }
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        if (isCollect == 0) {
            [SAVORXAPI postUMHandleWithContentId:@"details_page_cancel_collection" key:@"details_page_cancel_collection" value:@"fail"];
        }else{
            [SAVORXAPI postUMHandleWithContentId:@"details_page_collection" key:@"details_page_collection" value:@"fail"];
        }
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
    [self removeObserver];
    
    if (self.testView.superview) {
        [self.testView removeFromSuperview];
    }
    //TableView的高度
    CGFloat tabHeight = 0;
    if (self.dataSource.count != 0) {
        tabHeight = self.dataSource.count *96 + 48 + 8;
    }
    
    //底部View总高度
    CGFloat theight = tabHeight + 100;
    CGFloat height = self.webView.scrollView.contentSize.height;
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, theight);
    CGSize contentSize = self.webView.scrollView.contentSize;
    //底部View与顶部网页的间隔为0
    frame.origin.y = height;
    self.testView.frame = frame;
    [self.webView.scrollView addSubview:self.testView];
    [self.webView.scrollView setContentSize:CGSizeMake(contentSize.width, contentSize.height + theight)];
    self.testView.backgroundColor = UIColorFromRGB(0xece6de);
    
    [self addObserver];
    
    [self shareBoardByDefined];
}

- (void)shareBoardByDefined {

    HotTopicShareView *shareView = [[HotTopicShareView alloc] initWithModel:self.imgTextModel andVC:self andCategoryID:self.categoryID andY:0];
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
        [self.testView addSubview:_tableView];
        
        CGFloat tabHeiht = self.dataSource.count *96 +48;
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, tabHeiht));
            make.top.mas_equalTo(108);
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
    static NSString *cellID = @"imageTextTableCell";
    ImageTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[ImageTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    //最后一条分割线隐藏
    if (indexPath.row == self.dataSource.count - 1) {
        cell.lineView.hidden = YES;
    }
    CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configModelData:model];
    
    
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
    self.imgTextModel = tmpModel;
    [self.testView removeFromSuperview];
    [self setUpDatas];
    if (!isEmptyString(tmpModel.contentURL)) {
        NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?location=newRead",self.imgTextModel.contentURL]]];
        [self.webView loadRequest:request];
        [MBProgressHUD showWebLoadingHUDInView:self.webView];
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

- (void)dealloc{
    
    [self removeObserver];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
