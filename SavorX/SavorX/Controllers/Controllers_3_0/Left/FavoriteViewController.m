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
#import "HSIsOrCollectionRequest.h"
#import "RD_MJRefreshHeader.h"
#import "MJRefresh.h"
#import "ImageTextDetailViewController.h"
#import "ImageAtlasDetailViewController.h"
#import "WebViewController.h"

@interface FavoriteViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, strong) UITableView * tableView;

@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [NSMutableArray new];
    
    [self setupViews];
    
    [self showLoadingView];
    
    [self setupDatas];
}

- (void)setupDatas
{
    HSCollectoinListRequest * request = [[HSCollectoinListRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self hiddenLoadingView];
        
        NSArray * array = [[response objectForKey:@"result"] objectForKey:@"list"];
        
        if (array) {
            if (array.count == 0) {
                [self showNoDataViewInView:self.view noDataType:kNoDataType_Favorite];
            }else{
                [self.dataSource removeAllObjects];
                for (NSDictionary * dict in array) {
                    CreateWealthModel * model = [[CreateWealthModel alloc] initWithDictionary:dict];
                    [self.dataSource addObject:model];
                }
                [self.tableView reloadData];
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer resetNoMoreData];
                if (self.dataSource.count >= 20) {
                    self.tableView.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMoreData)];
                }
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self hiddenLoadingView];
        [self.tableView.mj_header endRefreshing];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self hiddenLoadingView];
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
    self.tableView.backgroundColor = VCBackgroundColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    [self.tableView registerClass:[RDFavoriteTableViewCell class] forCellReuseIdentifier:@"FavoriteCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.tableView.mj_header = [RD_MJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(setupDatas)];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @" 删除 ";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
        
        HSIsOrCollectionRequest * request = [[HSIsOrCollectionRequest alloc] initWithArticleId:model.artid withState:0];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            NSDictionary *dic = (NSDictionary *)response;
            if ([[dic objectForKey:@"code"] integerValue] == 10000) {
                model.collected = 0;
                [MBProgressHUD showSuccessHUDInView:self.view title:@"取消成功"];
                
                [self.dataSource removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                if (self.dataSource.count == 0) {
                    [self showNoDataViewInView:self.view noDataType:kNoDataType_Favorite];
                }
            }
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
    
    //1 图文 2 图集 3 视频
    if (model.type == 1) {
        ImageTextDetailViewController *imtVC = [[ImageTextDetailViewController alloc] init];
        imtVC.imgTextModel = model;
        imtVC.categoryID = model.categoryId;
        [self.navigationController pushViewController:imtVC animated:YES];
        
    }else if (model.type == 2) {
        ImageAtlasDetailViewController *iatVC = [[ImageAtlasDetailViewController alloc] init];
        iatVC.imgAtlModel = model;
        iatVC.categoryID = model.categoryId;
        [self.navigationController pushViewController:iatVC animated:YES];
        
    } else if (model.type == 3 || model.type == 4){
        WebViewController * web = [[WebViewController alloc] initWithModel:model categoryID:-1];
        web.categoryID = model.categoryId;
        [self.navigationController pushViewController:web animated:YES];
    }
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
