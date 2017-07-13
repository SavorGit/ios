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

@interface ImageTextDetailViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, strong) UIView * testView;
@property (nonatomic, strong) UITableView * tableView; //表格展示视图
@property (nonatomic, strong) NSMutableArray * dataSource; //数据源
@property (nonatomic, strong) UIButton *collectButton;

@end

@implementation ImageTextDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
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
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = self.view.bounds.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
    self.webView = [[UIWebView alloc] init];
    self.webView.frame = CGRectMake(0, 0, width, height);
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?sourceid=1",self.imgTextModel.contentURL]]];
    [self.webView loadRequest:request];
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    
    self.testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 140)];
    self.testView.backgroundColor = [UIColor clearColor];
    [self.webView.scrollView addSubview:self.testView];
    [self addObserver];
}

#pragma mark ---分享按钮点击
- (void)shareAction{
    
    HotPopShareView *shareView = [[HotPopShareView alloc] initWithModel:self.imgTextModel andVC:self];
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
            if (self.imgTextModel.collected == 1) {
                self.imgTextModel.collected = 0;
                [MBProgressHUD showSuccessHUDInView:self.view title:@"取消成功"];
            }else{
                self.imgTextModel.collected = 1;
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
    //底部View总高度
    CGFloat theight = (self.dataSource.count *96 + 48) + 130;
    CGFloat height = self.webView.scrollView.contentSize.height;
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, theight);
    CGSize contentSize = self.webView.scrollView.contentSize;
    //底部View与顶部网页的间隔为40
    frame.origin.y = height + 40;
    self.testView.frame = frame;
    [self.webView.scrollView addSubview:self.testView];
    [self.webView.scrollView setContentSize:CGSizeMake(contentSize.width, contentSize.height + theight + 40)];
    self.testView.backgroundColor = [UIColor colorWithRed:235/255.0 green:230/255.0 blue:223/255.0 alpha:1.0];
    
    [self addObserver];
    
    [self shareBoardByDefined];
}

- (void)shareBoardByDefined {

    HotTopicShareView *shareView = [[HotTopicShareView alloc] initWithModel:self.imgTextModel andVC:self andY:0];
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
    
    HSImTeRecommendRequest * request = [[HSImTeRecommendRequest alloc] initWithArticleId:self.imgTextModel.artid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.dataSource removeAllObjects];
        
        NSDictionary *dic = (NSDictionary *)response;
        NSArray *resultArr = [dic objectForKey:@"result"];
        
        for (int i = 0; i < resultArr.count; i ++) {
            CreateWealthModel *welthModel = [[CreateWealthModel alloc] initWithDictionary:resultArr[i]];
            [self.dataSource addObject:welthModel];
        }
        [self footViewShouldBeReset];
        [self.tableView reloadData];

        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];

    
//    _dataSource = [[NSMutableArray alloc] initWithCapacity:100];
//    
//    for (int i = 0; i < 3; i ++) {
//        CreateWealthModel *model = [[CreateWealthModel alloc] init];
//        model.type = 0;
//        if (i == 2) {
//            model.type = 1;
//        }else if (i == 3 || i == 5 || i == 6){
//            model.type = 2;
//        }
//        model.title = @"这是新闻的标题";
//        model.imageUrl = @"https://dn-brknqdxv.qbox.me/a70592e5162cb7df8391.jpg";
//        model.source = @"网易新闻";
//        model.time = @"2017.06.19";
//        model.sourceImage = @"sourceImage";
//        [_dataSource addObject:model];
//    }
//    [self.tableView reloadData];
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
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(130);
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
    
    CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configModelData:model];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 96.f;
}

- (void)dealloc{
    
    [self removeObserver];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
