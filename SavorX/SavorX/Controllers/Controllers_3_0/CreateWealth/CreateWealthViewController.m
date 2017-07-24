//
//  CreateWealthViewController.m
//  小热点餐厅端Demo
//
//  Created by 王海朋 on 2017/7/3.
//  Copyright © 2017年 wanghaipeng. All rights reserved.
//

#import "CreateWealthViewController.h"
#import "VideoTableViewCell.h"
#import "ImageAtlasTableViewCell.h"
#import "ImageTextTableViewCell.h"
#import "HeadlinesTableViewCell.h"
#import "Masonry.h"
#import "MJRefresh.h"
#import "CreateWealthModel.h"
#import "ImageTextDetailViewController.h"
#import "ImageAtlasDetailViewController.h"
#import "WebViewController.h"
#import "CreateWealthModel.h"
#import "HSCreateWealthRequest.h"
#import "RDLogStatisticsAPI.h"
#import "RD_MJRefreshHeader.h"

@interface CreateWealthViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView; //表格展示视图
@property (nonatomic, strong) NSMutableArray * dataSource; //数据源
@property (nonatomic, assign) NSInteger categoryID;
@property (nonatomic, copy) NSString * cachePath;

@end

@implementation CreateWealthViewController

- (instancetype)initWithCategoryID:(NSInteger)categoryID
{
    if (self = [super init]) {
        self.categoryID = categoryID;
        self.cachePath = [NSString stringWithFormat:@"%@%ld.plist", CategoryCache, self.categoryID];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    [self initInfo];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.cachePath]) {
        
        //如果本地缓存的有数据，则先从本地读取缓存的数据
        NSArray * dataArr = [NSArray arrayWithContentsOfFile:self.cachePath];
        for(NSDictionary *dict in dataArr){
            CreateWealthModel *tmpModel = [[CreateWealthModel alloc] initWithDictionary:dict];
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
}

//下拉刷新页面数据
- (void)refreshData
{
    HSCreateWealthRequest * request = [[HSCreateWealthRequest alloc] initWithCateId:self.categoryID withSortNum:nil];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.dataSource removeAllObjects];
        NSDictionary *dic = (NSDictionary *)response;
        NSArray *resultArr = [dic objectForKey:@"result"];
        [SAVORXAPI saveFileOnPath:self.cachePath withArray:resultArr];
        for (int i = 0; i < resultArr.count; i ++) {
            CreateWealthModel *welthModel = [[CreateWealthModel alloc] initWithDictionary:resultArr[i]];
            [self.dataSource addObject:welthModel];
        }
        
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer resetNoMoreData];
        [self hideNoNetWorkView];
        [self hiddenLoadingView];
        
        [self showTopFreshLabelWithTitle:@"更新成功"];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self showTopFreshLabelWithTitle:@"更新失败"];
        [self.tableView.mj_header endRefreshing];
        if (self.dataSource.count == 0) {
             [self showNoNetWorkView:NoNetWorkViewStyle_No_NetWork];
        }

    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [self.tableView.mj_header endRefreshing];
        if (self.dataSource.count == 0) {
            [self showNoNetWorkView:NoNetWorkViewStyle_No_NetWork];
        }
        if (error.code == -999) {
            [self showTopFreshLabelWithTitle:@"数据加载超时"];
        }else{
            [self showTopFreshLabelWithTitle:@"无法连接到网络，请检查网络设置"];
        }
        
    }];
}

//上拉获取更多数据
- (void)getMoreData
{
    CreateWealthModel *welthModel = [self.dataSource lastObject];
    HSCreateWealthRequest * request = [[HSCreateWealthRequest alloc] initWithCateId:self.categoryID withSortNum:welthModel.sort_num];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSDictionary *dic = (NSDictionary *)response;
        NSArray *resultArr = [dic objectForKey:@"result"];
        
        if (resultArr.count == 0) {
            //如果获取数据的数量为0，则状态为没有更多数据了
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            return;
        }
        
        //如果获取的数据数量不为0，则将数据添加至数据源，刷新当前列表
        for(NSDictionary *dict in resultArr){
            CreateWealthModel *welthModel = [[CreateWealthModel alloc] initWithDictionary:dict];
            [self.dataSource addObject:welthModel];
        }
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
        
        if (self.dataSource.count == 0) {
            [self showNoDataView];
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.tableView.mj_footer endRefreshing];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [self.tableView.mj_footer endRefrenshWithNoNetWork];
        
    }];
}

-(void)retryToGetData{
    [self refreshData];
}

#pragma mark -- 懒加载
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = UIColorFromRGB(0xece6de);
        _tableView.backgroundView = nil;
        _tableView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
        
        //创建tableView动画加载头视图
        
        _tableView.mj_header = [RD_MJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
        MJRefreshFooter* footer = [MJRefreshAutoGifFooter footerWithRefreshingBlock:^{
           [self getMoreData];
        }];
        _tableView.mj_footer = footer;
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
    CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
    if ([Helper getCurrentControllerInWMPage] == self) {
        [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_SHOW type:RDLOGTYPE_CONTENT model:model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
    }
    
    if (!isEmptyString(model.indexImageUrl)) {
        
        static NSString *cellID = @"HeadlineTableCell";
        HeadlinesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[HeadlinesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        [cell configModelData:model];
        
        return cell;
        
    }else if (model.type == 3 || model.type == 4) {
        static NSString *cellID = @"VideoTableCell";
        VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[VideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        [cell configModelData:model];
        
        return cell;
        
    }else if (model.type == 2){
        static NSString *cellID = @"imageTableCell";
        ImageAtlasTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[ImageAtlasTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        [cell configModelData:model];
        
        return cell;
    }else if (model.type == 1){
        static NSString *cellID = @"imageTextTableCell";
        ImageTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[ImageTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        [cell configModelData:model];
        
        return cell;
    }else{
        static NSString *cellID = @"defaultCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
    if (!isEmptyString(model.indexImageUrl)){
        return 353;
    }else if (model.type == 2 || model.type == 3 || model.type == 4) {
        return 285;
    }else if (model.type == 1){
        return 96;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_CLICK type:RDLOGTYPE_CONTENT model:model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
    
    //1 图文 2 图集 3 视频
    if (model.type == 1) {
        ImageTextDetailViewController *imtVC = [[ImageTextDetailViewController alloc] init];
        imtVC.imgTextModel = model;
        imtVC.categoryID = self.categoryID;
        [self.navigationController pushViewController:imtVC animated:YES];
        
    }else if (model.type == 2) {
        ImageAtlasDetailViewController *iatVC = [[ImageAtlasDetailViewController alloc] init];
        iatVC.imgAtlModel = model;
        iatVC.categoryID = self.categoryID;
        [self.navigationController pushViewController:iatVC animated:YES];
        
    } else if (model.type == 3 || model.type == 4){
        WebViewController * web = [[WebViewController alloc] initWithModel:model categoryID:-1];
        [self.navigationController pushViewController:web animated:YES];
    }
}

- (void)showSelfAndCreateLog
{
    NSArray * cells = self.tableView.visibleCells;
    for (UITableViewCell * cell in cells) {
        NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
        CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.section];
        [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_SHOW type:RDLOGTYPE_CONTENT model:model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
