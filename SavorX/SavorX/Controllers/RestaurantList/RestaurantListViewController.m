//
//  RestaurantListViewController.m
//  SavorX
//
//  Created by 王海朋 on 2017/5/23.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RestaurantListViewController.h"
#import "RestaurantListTableViewCell.h"
#import "RestaurantListModel.h"
#import "MJRefresh.h"
#import "HSRestaurantListRequest.h"
#import "RDLocationManager.h"
#import "RDAlertView.h"
#import "RD_MJRefreshHeader.h"

@interface RestaurantListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView; //表格展示视图
@property (nonatomic, strong) NSMutableArray * dataSource; //数据源
@property (nonatomic, strong) UILabel * TopFreshLabel;
@property (nonatomic, copy) NSString * cachePath;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) NSString *latitudeStr;
@property (nonatomic, strong) NSString *longitudeStr;
@property (nonatomic, assign) BOOL isScreenAlert;

@end

@implementation RestaurantListViewController

- (instancetype)initWithScreenAlert
{
    if (self = [super init]) {
        self.isScreenAlert = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = RDLocalizedString(@"RDString_CanScreenRestaurant");
    [SAVORXAPI postUMHandleWithContentId:@"hotel_map_list" key:nil value:nil];
    
    self.dataSource = [NSMutableArray new];
    self.cachePath = [NSString stringWithFormat:@"%@RestaurantList.plist", CategoryCache];
    
    _page = 1;
    [self readCacheData];
    
    if (self.isScreenAlert) {
        [self showScreenAlert];
    }

}

// 读取缓存的数据
- (void)readCacheData{
    [self showLoadingView];
    [[RDLocationManager manager] startCheckUserLocationWithHandle:^(CLLocationDegrees latitude, CLLocationDegrees longitude) {
        if ([GlobalData shared].VCLatitude == 0.f) {
            
            [GlobalData shared].VCLatitude = latitude;
            [GlobalData shared].VCLongitude = longitude;
            
            self.latitudeStr = [NSString stringWithFormat:@"%lf", latitude];
            self.longitudeStr = [NSString stringWithFormat:@"%lf", longitude];
            
            [self showLoadingView];
            [self setupDatas];
            
        }else if ([[RDLocationManager manager] checkLocationDataIsNeedUpdateWithLastPoint:BMKMapPointForCoordinate(CLLocationCoordinate2DMake([GlobalData shared].VCLatitude, [GlobalData shared].VCLongitude)) currentPoint:BMKMapPointForCoordinate(CLLocationCoordinate2DMake(latitude, longitude))]){
            
            [GlobalData shared].VCLatitude = latitude;
            [GlobalData shared].VCLongitude = longitude;
            
            self.latitudeStr = [NSString stringWithFormat:@"%lf", latitude];
            self.longitudeStr = [NSString stringWithFormat:@"%lf", longitude];
            
            [self showLoadingView];
            [self setupDatas];
            
        }else{
            
            [self showLoadingView];
            [self setupDatas];
            
        }
    }];
    
}

//初始化请求第一页，下拉刷新
- (void)setupDatas{

    HSRestaurantListRequest *request = [[HSRestaurantListRequest alloc] initWithHotelId:[GlobalData shared].hotelId lng:self.longitudeStr lat:self.latitudeStr pageNum:_page];
    
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.dataSource removeAllObjects];
        NSDictionary *dic = (NSDictionary *)response;
        NSArray * listArray = [dic objectForKey:@"result"];
        
        [SAVORXAPI saveFileOnPath:self.cachePath withArray:listArray];
        //解析获取当前分类下数据列表
        for(NSDictionary *dict in listArray){
            RestaurantListModel *model = [[RestaurantListModel alloc] initWithDictionary:dict];
            [self.dataSource addObject:model];
        }
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer resetNoMoreData];
        [self.tableView reloadData];
        [self hiddenLoadingView];
        
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

- (void)retryToGetData
{
    [self hideNoNetWorkView];
    [self setupDatas];
}

- (void)upMoreDatas{
    
    HSRestaurantListRequest *request = [[HSRestaurantListRequest alloc] initWithHotelId:[GlobalData shared].hotelId lng:self.longitudeStr lat:self.latitudeStr pageNum:_page];
    
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSDictionary *dic = (NSDictionary *)response;
        NSArray * listArray = [dic objectForKey:@"result"];
        
        if (listArray.count == 0) {
            _page = _page -1;
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            return;
        }
        
        //解析获取当前分类下数据列表
        for(NSDictionary *dict in listArray){
            RestaurantListModel *model = [[RestaurantListModel alloc] initWithDictionary:dict];
            [self.dataSource addObject:model];
        }
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        _page = _page -1;
        [self.tableView.mj_footer endRefreshing];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        _page = _page -1;
        [self showTopFreshLabelWithTitle:RDLocalizedString(@"RDString_NetFailedWithBadNet")];
        [self.tableView.mj_footer endRefrenshWithNoNetWork];
    }];
}

#pragma mark -- 懒加载
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[RestaurantListTableViewCell class] forCellReuseIdentifier:@"RestauranCell"];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.backgroundView = nil;
        _tableView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_tableView];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
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
    RestaurantListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RestauranCell" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    cell.bgView.layer.cornerRadius = 3.0;
    cell.bgView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    cell.bgView.layer.shadowOffset = CGSizeMake(0,0);
    cell.bgView.layer.shadowOpacity = 0.30;//阴影透明度，默认0
    cell.bgView.layer.shadowRadius = 2;//阴影半径，默认3
    
    RestaurantListModel * model = [self.dataSource objectAtIndex:indexPath.row];
    
    [cell configModelData:model];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return [Helper autoHeightWith:15.f];
//}

#pragma mark - 下拉刷新，上拉加载更多
//页面顶部下弹状态栏显示
- (void)showTopFreshLabelWithTitle:(NSString *)title
{
    //移除当前动画
    [self.TopFreshLabel.layer removeAllAnimations];
    
    //取消延时重置状态栏
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetTopFreshLabel) object:nil];
    
    //重新设置状态栏下弹动画
    self.TopFreshLabel.text = title;
    self.TopFreshLabel.frame = CGRectMake(0, -35, kMainBoundsWidth, 35);
    [UIView animateWithDuration:.5f animations:^{
        self.TopFreshLabel.frame = CGRectMake(0, 0, kMainBoundsWidth, 35);
    } completion:^(BOOL finished) {
        [self performSelector:@selector(resetTopFreshLabel) withObject:nil afterDelay:2.f];
    }];
}

//重置页面顶部下弹状态栏
- (void)resetTopFreshLabel
{
    [UIView animateWithDuration:.5f animations:^{
        self.TopFreshLabel.frame = CGRectMake(0, -35, kMainBoundsWidth, 35);
    }];
}

- (UILabel *)TopFreshLabel
{
    if (!_TopFreshLabel) {
        _TopFreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -35, kMainBoundsWidth, 35)];
        _TopFreshLabel.textAlignment = NSTextAlignmentCenter;
        _TopFreshLabel.backgroundColor = [UIColorFromRGB(0xffebc3) colorWithAlphaComponent:.96f];
        _TopFreshLabel.font = [UIFont systemFontOfSize:15];
        _TopFreshLabel.textColor = UIColorFromRGB(0x9a6f45);
        [self.view addSubview:_TopFreshLabel];
    }
    return _TopFreshLabel;
}

//下拉刷新页面数据
- (void)refreshData{
    
    [SAVORXAPI postUMHandleWithContentId:@"hotel_map_list_refresh" key:nil value:nil];
    
    _page = 1;
    [self setupDatas];
}

- (void)getMoreData{
    
    [SAVORXAPI postUMHandleWithContentId:@"hotel_map_list_last" key:nil value:nil];
    
    _page = _page + 1;
    [self upMoreDatas];
}

- (void)navBackButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showScreenAlert
{
    RDAlertView * alert = [[RDAlertView alloc] initWithTitle:RDLocalizedString(@"RDString_Alert") message:RDLocalizedString(@"RDString_ReataurantAlert")];
    RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:RDLocalizedString(@"RDString_IKnewIt") handler:^{
        
    } bold:YES];
    [alert addActions:@[action]];
    [alert show];
}

@end
