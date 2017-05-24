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

@interface RestaurantListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView; //表格展示视图
@property (nonatomic, strong) NSMutableArray * dataSource; //数据源
@property (nonatomic, strong) UILabel * TopFreshLabel;
@property (nonatomic, copy) NSString * cachePath;

@end

@implementation RestaurantListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [NSMutableArray new];
    self.cachePath = [NSString stringWithFormat:@"%@RestaurantList.plist", CategoryCache];
    [self setUpDatas];
}

- (void)setUpDatas{
    
    [MBProgressHUD showCustomLoadingHUDInView:self.view];
    
    [self.dataSource removeAllObjects];
    MBProgressHUD * hud;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.cachePath]) {
        
        //如果本地缓存的有数据，则先从本地读取缓存的数据
        NSArray * listArray = [NSArray arrayWithContentsOfFile:self.cachePath];
        for(NSDictionary *dict in listArray){
            
            RestaurantListModel *model = [[RestaurantListModel alloc] initWithDictionary:dict];
            [self.dataSource addObject:model];
        }
        [self.tableView reloadData];
        
    }else{
        hud = [MBProgressHUD showCustomLoadingHUDInView:self.view];
    }

    
    HSRestaurantListRequest *request = [[HSRestaurantListRequest alloc] initWithHotelId:[GlobalData shared].hotelId lng:@"116.479168" lat:@"35.462766" pageNum:1];
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
        [self.tableView reloadData];

        if (hud) {
            [hud hideAnimated:NO];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (hud) {
            [self showNoNetWorkView:NoNetWorkViewStyle_Load_Fail];
            [hud hideAnimated:NO];
        }
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        if (hud) {
            [self showNoNetWorkView];
            [hud hideAnimated:NO];
        }
    }];
    
    
//    for (int i = 0; i < 10; i ++ ) {
//        RestaurantListModel *model = [[RestaurantListModel alloc] init];
//        model.title = @"餐厅名字";
//        model.distance = @"100m";
//        model.address = @"地址：北京市朝阳区大望路永峰大厦六楼";
//        [self.dataSource addObject:model];
//    }
//    [self.tableView reloadData];
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
        _tableView.backgroundColor = UIColorFromRGB(0xf5f5f5);
        [self.view addSubview:_tableView];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
        
        //创建tableView动画加载头视图
        
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
        
        
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
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RestauranCell" forIndexPath:indexPath];
    
    RestaurantListModel * model = [self.dataSource objectAtIndex:indexPath.section];

    cell.titleLabel.text = model.name;
    cell.distanceLabel.text = model.km;
    cell.addressLabel.text = model.addr;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140;
}

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
    [self.tableView.mj_header endRefreshing];
}

- (void)getMoreData{
    [self.tableView.mj_footer endRefreshing];
}

- (void)navBackButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
