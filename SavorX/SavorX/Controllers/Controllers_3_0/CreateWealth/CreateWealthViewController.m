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
#import "CreateWealthModel.h"
#import "ImageTextDetailViewController.h"
#import "WebViewController.h"
#import "CreateWealthModel.h"
#import "HSCreateWealthRequest.h"
#import "RDLogStatisticsAPI.h"
#import "RD_MJRefreshHeader.h"
#import "RD_MJRefreshFooter.h"
#import "ImageArrayViewController.h"

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
    
    [self.view setBackgroundColor:VCBackgroundColor];
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
    [SAVORXAPI postUMHandleWithContentId:@"home_refresh" key:nil value:nil];
    HSCreateWealthRequest * request = [[HSCreateWealthRequest alloc] initWithCateId:self.categoryID withSortNum:nil];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.tableView.mj_header endRefreshing];
        [self hiddenLoadingView];
        
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
            CreateWealthModel *welthModel = [[CreateWealthModel alloc] initWithDictionary:resultArr[i]];
            [self.dataSource addObject:welthModel];
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
    [SAVORXAPI postUMHandleWithContentId:@"home_load" key:nil value:nil];
    CreateWealthModel *welthModel = [self.dataSource lastObject];
    HSCreateWealthRequest * request = [[HSCreateWealthRequest alloc] initWithCateId:self.categoryID withSortNum:welthModel.sort_num];
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
        RD_MJRefreshFooter* footer = [RD_MJRefreshFooter footerWithRefreshingBlock:^{
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
        if (model.type == 2) {
            cell.countLabel.hidden = NO;
            cell.countVideoLabel.hidden = YES;
        }else if (model.type == 3 || model.type == 4){
            cell.countLabel.hidden = YES;
            cell.countVideoLabel.hidden = NO;
        }else{
            cell.countLabel.hidden = YES;
            cell.countVideoLabel.hidden = YES;
        }
        [cell configModelData:model];
        
        return cell;
        
    }else if (model.type == 3 || model.type == 4) {
        static NSString *cellID = @"VideoTableCell";
        VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[VideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = UIColorFromRGB(0xf6f2ed);
        
        [cell configModelData:model];
        
        return cell;
        
    }else if (model.type == 2){
        static NSString *cellID = @"imageTableCell";
        ImageAtlasTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[ImageAtlasTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = UIColorFromRGB(0xf6f2ed);
        
        [cell configModelData:model];
        
        return cell;
    }else if (model.type == 1){
        
        //当图文类型为大图时 imgStyle 2 为大图
        if (model.imgStyle == 2) {
            static NSString *cellID = @"imageTableCell";
            ImageAtlasTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[ImageAtlasTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }
            cell.countLabel.hidden = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = UIColorFromRGB(0xf6f2ed);
            
            [cell configModelData:model];
            
            return cell;
            
        }else{
            static NSString *cellID = @"imageTextTableCell";
            ImageTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[ImageTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = UIColorFromRGB(0xf6f2ed);
            
            [cell configModelData:model];
            
            return cell;
        }
    }
    
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

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
    if (!isEmptyString(model.indexImageUrl)){
        CGFloat imgHeight= (kMainBoundsWidth - 30) *(844.f/1142.f);
        return imgHeight + 98;
    }else if (model.type == 2 || model.type == 3 || model.type == 4) {
        CGFloat imgHeight= (kMainBoundsWidth - 30) *802.f/1242.f;
        return imgHeight + 95;
    }else if (model.type == 1){
        //当图文类型为大图时 imgStyle 2 为大图
        if (model.imgStyle == 2) {
            CGFloat imgHeight= (kMainBoundsWidth - 30) *802.f/1242.f;
            return imgHeight + 95;
        }else{
            CGFloat igTextHeight= 130 *802.f/1242.f;
            return igTextHeight + 12;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_CLICK type:RDLOGTYPE_CONTENT model:model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
    if (!isEmptyString(model.indexImageUrl)){
        [SAVORXAPI postUMHandleWithContentId:@"home_click_headlines" key:nil value:nil];
    }
    
    //1 图文 2 图集 3 视频
    if (model.type == 1) {
        [SAVORXAPI postUMHandleWithContentId:@"home_click_article" key:nil value:nil];
        ImageTextDetailViewController *imtVC = [[ImageTextDetailViewController alloc] init];
        imtVC.imgTextModel = model;
        imtVC.categoryID = self.categoryID;
        [self.navigationController pushViewController:imtVC animated:YES];
        
    }else if (model.type == 2) {
        
        [SAVORXAPI postUMHandleWithContentId:@"home_click_pic" key:nil value:nil];
        ImageArrayViewController *iatVC = [[ImageArrayViewController alloc] initWithCategoryID:self.categoryID model:model];
        
        iatVC.parentNavigationController = self.navigationController;
        float version = [UIDevice currentDevice].systemVersion.floatValue;
        if (version < 8.0) {
            self.modalPresentationStyle = UIModalPresentationCurrentContext;
        } else {;
            iatVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        iatVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentViewController:iatVC animated:YES completion:nil];

        
    } else if (model.type == 3 || model.type == 4){
        [SAVORXAPI postUMHandleWithContentId:@"home_click_video" key:nil value:nil];
        WebViewController * web = [[WebViewController alloc] initWithModel:model categoryID:self.categoryID];
        [self.navigationController pushViewController:web animated:YES];
    }
}

- (void)showSelfAndCreateLog
{
    if (_tableView) {
        NSArray * cells = self.tableView.visibleCells;
        for (UITableViewCell * cell in cells) {
            NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
            CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.section];
            [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_SHOW type:RDLOGTYPE_CONTENT model:model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
