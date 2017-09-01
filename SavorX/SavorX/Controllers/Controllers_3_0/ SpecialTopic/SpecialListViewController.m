//
//  SpecicalListViewController.m
//  SavorX
//
//  Created by 郭春城 on 2017/8/28.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "SpecialListViewController.h"
#import "SpecialListTableViewCell.h"
#import "RD_MJRefreshHeader.h"
#import "RD_MJRefreshFooter.h"
#import "SpecialTopListRequest.h"
#import "SingleSpecialTopicViewController.h"

@interface SpecialListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource; //数据源
@property (nonatomic, assign) NSInteger categoryID;
@property (nonatomic, copy) NSString * cachePath;

@end

@implementation SpecialListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initInfo];
    [self setupViews];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.cachePath]) {
        
        //如果本地缓存的有数据，则先从本地读取缓存的数据
        NSArray * dataArr = [NSArray arrayWithContentsOfFile:self.cachePath];
        for(int i = 0; i < dataArr.count; i ++){
            
            CreateWealthModel *tmpModel = [[CreateWealthModel alloc] initWithDictionary:dataArr[i]];
            [self.dataSource addObject:tmpModel];
        }
        [self.tableView reloadData];
        [self.tableView.mj_header beginRefreshing];
    }else{
        [self showLoadingView];
        [self refreshData];
    }

}

- (void)initInfo{
    _dataSource = [[NSMutableArray alloc] initWithCapacity:100];
    self.cachePath = [NSString stringWithFormat:@"%@%@.plist", CategoryCache, @"SpecialTopicList"];
}

//下拉刷新页面数据
- (void)refreshData
{
    SpecialTopListRequest * request = [[SpecialTopListRequest alloc] initWithId:nil];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self hiddenLoadingView];
        [self.tableView.mj_header endRefreshing];
        
        NSDictionary *dic = (NSDictionary *)response;
        
        NSDictionary * dataDict = [dic objectForKey:@"result"];
        if (nil == dataDict || ![dataDict isKindOfClass:[NSDictionary class]] || dataDict.count == 0) {
            if (self.dataSource.count == 0) {
                [self showNoNetWorkView:NoNetWorkViewStyle_Load_Fail];
            }else{
                [self showTopFreshLabelWithTitle:RDLocalizedString(@"RDString_NetFailedWithData")];
            }
            return;
        }
        
        NSArray *resultArr = [dataDict objectForKey:@"list"];
        
        [SAVORXAPI saveFileOnPath:self.cachePath withArray:resultArr];
        [self.dataSource removeAllObjects];
        for (int i = 0; i < resultArr.count; i ++) {
            CreateWealthModel *tmpModel = [[CreateWealthModel alloc] initWithDictionary:resultArr[i]];
            [self.dataSource addObject:tmpModel];
        }
        
        [self.tableView reloadData];
        
        if ([[dataDict objectForKey:@"nextpage"] integerValue] == 0) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [self.tableView.mj_footer resetNoMoreData];
        }
        
        [self showTopFreshLabelWithTitle:RDLocalizedString(@"RDString_SuccessWithUpdate")];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self hiddenLoadingView];
        if (self.dataSource.count == 0) {
            [self showNoNetWorkView:NoNetWorkViewStyle_Load_Fail];
        }
        if (_tableView) {
            [self.tableView.mj_header endRefreshing];
            [self showTopFreshLabelWithTitle:RDLocalizedString(@"RDString_NetFailedWithData")];
        }
        
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [self hiddenLoadingView];
        if (self.dataSource.count == 0) {
            [self showNoNetWorkView:NoNetWorkViewStyle_No_NetWork];
        }
        if (_tableView) {
            
            [self.tableView.mj_header endRefreshing];
            if (error.code == -1001) {
                [self showTopFreshLabelWithTitle:RDLocalizedString(@"RDString_NetFailedWithTimeOut")];
            }else{
                [self showTopFreshLabelWithTitle:RDLocalizedString(@"RDString_NetFailedWithBadNet")];
            }
        }
        
    }];
}

//上拉获取更多数据
- (void)getMoreData
{
    
    CreateWealthModel *welthModel = [self.dataSource lastObject];
    SpecialTopListRequest * request = [[SpecialTopListRequest alloc] initWithId:[NSString stringWithFormat:@"%ld",welthModel.id]];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSDictionary *dic = (NSDictionary *)response;
        
        NSDictionary * dataDict = [dic objectForKey:@"result"];
        
        if (nil == dataDict || ![dataDict isKindOfClass:[NSDictionary class]] || dataDict.count == 0) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            return;
        }
        
        NSArray *resultArr = [dataDict objectForKey:@"list"];
        
        if ([[dataDict objectForKey:@"nextpage"] integerValue] == 0) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [self.tableView.mj_footer endRefreshing];
        }
        
        //如果获取的数据数量不为0，则将数据添加至数据源，刷新当前列表
        for(NSDictionary *dict in resultArr){
            CreateWealthModel *welthModel = [[CreateWealthModel alloc] initWithDictionary:dict];
            [self.dataSource addObject:welthModel];
        }
        [self.tableView reloadData];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.tableView.mj_footer endRefreshing];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [self.tableView.mj_footer endRefrenshWithNoNetWork];
        
    }];
}

-(void)retryToGetData{
    [self hideNoNetWorkView];
    if (self.dataSource.count == 0)  {
        [self showLoadingView];
    }
    [self refreshData];
}

- (void)setupViews
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.tableView registerClass:[SpecialListTableViewCell class] forCellReuseIdentifier:@"SpecicalCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 10-7.5)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 10-7.5)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = VCBackgroundColor;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    //创建tableView动画加载头视图
    self.tableView.mj_header = [RD_MJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    RD_MJRefreshFooter* footer = [RD_MJRefreshFooter footerWithRefreshingBlock:^{
        [self getMoreData];
    }];
    self.tableView.mj_footer = footer;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SpecialListTableViewCell * cell = (SpecialListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SpecicalCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    static BOOL line = NO;
//    if (line) {
//        [cell configWithTitile:@"小热点专题列表的标题小热点专题列表的标题"];
//    }else{
//        [cell configWithTitile:@"小热点专题列表的标题"];
//    }
//    line = !line;
    
    CreateWealthModel *tmpModel = [self.dataSource objectAtIndex:indexPath.row];
    [cell configWithModel:tmpModel];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 145 + (kMainBoundsWidth - 20) * 802.f/1242.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CreateWealthModel *model = [self.dataSource objectAtIndex:indexPath.row];
    SingleSpecialTopicViewController *singleVC = [[SingleSpecialTopicViewController alloc] initWithtopGroupID:model.id];
    [self.navigationController pushViewController:singleVC animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
