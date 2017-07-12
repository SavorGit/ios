//
//  FavoriteViewController.m
//  SavorX
//
//  Created by 郭春城 on 2017/7/11.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "FavoriteViewController.h"
#import "RDFavoriteTableViewCell.h"
#import "HSCollectoinListRequest.h"
#import "MJRefresh.h"

@interface FavoriteViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, strong) UITableView * tableView;

@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [NSMutableArray new];
    
    [self setupViews];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.mj_header beginRefreshing];
    });
}

- (void)createNoDataView
{
    
}

- (void)setupDatas
{
    HSCollectoinListRequest * request = [[HSCollectoinListRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSArray * array = [[response objectForKey:@"result"] objectForKey:@"list"];
        
        if (array) {
            if (array.count == 0) {
                [self createNoDataView];
            }else{
                [self.dataSource removeAllObjects];
                for (NSDictionary * dict in array) {
                    CreateWealthModel * model = [[CreateWealthModel alloc] initWithDictionary:dict];
                    [self.dataSource addObject:model];
                }
                [self.tableView reloadData];
                [self.tableView.mj_header endRefreshing];
                if (self.dataSource.count >= 20) {
                    self.tableView.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMoreData)];
                }
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self.tableView.mj_header endRefreshing];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)getMoreData
{
    if (self.dataSource.count == 0) {
        return;
    }
    CreateWealthModel * model = [self.dataSource lastObject];
    HSCollectoinListRequest * request = [[HSCollectoinListRequest alloc] initWithCreateTime:model.ucreateTime];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSArray * array = [[response objectForKey:@"result"] objectForKey:@"list"];
        
        if (array) {
            if (array.count == 0) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                for (NSDictionary * dict in array) {
                    CreateWealthModel * model = [[CreateWealthModel alloc] initWithDictionary:dict];
                    [self.dataSource addObject:model];
                }
                [self.tableView reloadData];
                [self.tableView.mj_footer endRefreshing];
            }
        }else{
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self.tableView.mj_footer endRefreshing];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self.tableView.mj_footer endRefrenshWithNoNetWork];
    }];
}

- (void)setupViews
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    [self.tableView registerClass:[RDFavoriteTableViewCell class] forCellReuseIdentifier:@"FavoriteCell"];
    [self.view addSubview:self.tableView];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(setupDatas)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"FavoriteCell";
    RDFavoriteTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    [cell configWithModel:[self.dataSource objectAtIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 96;
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
