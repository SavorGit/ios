//
//  CategoryViewController.m
//  SavorX
//
//  Created by 郭春城 on 17/1/17.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "CategoryViewController.h"
#import "BasicTableViewCell.h"
#import "MJRefresh.h"
#import "HSVodModel.h"
#import "UIImageView+WebCache.h"
#import "HSTopicListRequest.h"
#import "HSLatestTopicListRequest.h"
#import "WebViewController.h"
#import "DemandViewController.h"
#import "GCCUPnPManager.h"
#import "HomeAnimationView.h"
#import "SXVideoPlayViewController.h"
#import "ArticleReadViewController.h"

@interface CategoryViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) NSInteger categoryID;

@property (nonatomic, strong) UITableView * tableView; //表格展示视图
@property (nonatomic, strong) NSMutableArray * dataSource; //数据源
@property (nonatomic, assign) NSInteger pageNo; //当前数据页面
@property (nonatomic, assign) NSInteger pageSize; //页面数据大小
@property (nonatomic, copy) NSString * cachePath;
@property (nonatomic, assign) NSInteger currentTime;
@property (nonatomic, strong) UILabel * TopFreshLabel;
@property (nonatomic, assign) NSInteger minTime;
@property (nonatomic, assign) NSInteger maxTime;
@property (nonatomic, copy) NSString * flag;

@end

@implementation CategoryViewController

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
    
    self.dataSource = [NSMutableArray new];
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
    self.currentTime = (NSInteger)time;
    
    [self setupDatas];
}

- (void)showTopFreshLabelWithTitle:(NSString *)title
{
    [self.TopFreshLabel.layer removeAllAnimations];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetTopFreshLabel) object:nil];
    self.TopFreshLabel.text = title;
    self.TopFreshLabel.frame = CGRectMake(0, -35, kMainBoundsWidth, 35);
    [UIView animateWithDuration:.5f animations:^{
        self.TopFreshLabel.frame = CGRectMake(0, 0, kMainBoundsWidth, 35);
    } completion:^(BOOL finished) {
        [self performSelector:@selector(resetTopFreshLabel) withObject:nil afterDelay:2.f];
    }];
}

- (void)resetTopFreshLabel
{
    [UIView animateWithDuration:.5f animations:^{
        self.TopFreshLabel.frame = CGRectMake(0, -35, kMainBoundsWidth, 35);
    }];
}

- (void)setupDatas
{
    self.pageNo = 2;
    self.pageSize = 10;
    [MBProgressHUD showCustomLoadingHUDInView:self.view];
    
    [self.dataSource removeAllObjects];
    MBProgressHUD * hud;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.cachePath]) {
        NSDictionary * dataDict = [NSDictionary dictionaryWithContentsOfFile:self.cachePath];
        NSArray * listAry = dataDict[@"list"];
        self.minTime = [[dataDict objectForKey:@"minTime"] integerValue];
        self.maxTime = [[dataDict objectForKey:@"maxTime"] integerValue];
        self.flag = [dataDict objectForKey:@"flag"];
        for(NSDictionary *dict in listAry){
            
            HSVodModel *model = [[HSVodModel alloc] initWithDictionary:dict];
            [self.dataSource addObject:model];
        }
        self.pageNo = 3;
        [self.tableView reloadData];
    }else{
        hud = [MBProgressHUD showCustomLoadingHUDInView:self.view];
    }
    
    HSLatestTopicListRequest * request = [[HSLatestTopicListRequest alloc] initWithCategoryId:self.categoryID updateTime:0];
    
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self.dataSource removeAllObjects];
        NSDictionary *dic = (NSDictionary *)response;
        NSDictionary * dataDict = [dic objectForKey:@"result"];
        NSArray *listAry = dataDict[@"list"];
        self.minTime = [[dataDict objectForKey:@"minTime"] integerValue];
        self.maxTime = [[dataDict objectForKey:@"maxTime"] integerValue];
        self.flag = [dataDict objectForKey:@"flag"];
        [SAVORXAPI saveFileOnPath:self.cachePath withDictionary:dataDict];
        for(NSDictionary *dict in listAry){
            
            HSVodModel *model = [[HSVodModel alloc] initWithDictionary:dict];
            [self.dataSource addObject:model];
        }
        self.pageNo = 3;
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
}

- (void)refreshData
{
    if (self.dataSource.count > 0) {
        HSVodModel * model = [self.dataSource objectAtIndex:0];
        self.currentTime = model.createTime;
    }
    
    HSLatestTopicListRequest * request = [[HSLatestTopicListRequest alloc] initWithCategoryId:self.categoryID updateTime:self.currentTime];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        NSDictionary *dic = (NSDictionary *)response;
        NSDictionary * dataDict = [dic objectForKey:@"result"];
        NSArray *listAry = dataDict[@"list"];
        self.minTime = [[dataDict objectForKey:@"minTime"] integerValue];
        self.maxTime = [[dataDict objectForKey:@"maxTime"] integerValue];
        self.flag = [dataDict objectForKey:@"flag"];
        [SAVORXAPI saveFileOnPath:self.cachePath withDictionary:dataDict];
        [self.dataSource removeAllObjects];
        for(NSDictionary *dict in listAry){
            
            HSVodModel *model = [[HSVodModel alloc] initWithDictionary:dict];
            [self.dataSource addObject:model];
        }
        
        self.pageNo = 3;
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer resetNoMoreData];
        
        NSInteger count = [dataDict[@"count"] integerValue];
        if (count == 0) {
            [self showTopFreshLabelWithTitle:@"当前已为最新内容"];
        }else{
            [self showTopFreshLabelWithTitle:[NSString stringWithFormat:@"本次更新%ld条内容", count]];
        }
        [SAVORXAPI postUMHandleWithContentId:@"home_refresh" key:@"home_refresh" value:@"success"];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self.tableView.mj_header endRefreshing];
         [SAVORXAPI postUMHandleWithContentId:@"home_refresh" key:@"home_refresh" value:@"fail"];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self.tableView.mj_header endRefreshing];
        [self showTopFreshLabelWithTitle:@"无法连接到网络,请检查网络设置"];
         [SAVORXAPI postUMHandleWithContentId:@"home_refresh" key:@"home_refresh" value:@"fail"];
    }];
}

- (void)retryToGetData
{
    [self hideNoNetWorkView];
    [self setupDatas];
}

//根据页面和页面大小获取页面数据
- (void)getVodListWithPageNo:(NSInteger)pageNo andPageSize:(NSInteger)pageSize
{
    HSTopicListRequest * request = [[HSTopicListRequest alloc] initWithCategoryId:self.categoryID pageNo:pageNo pageSize:pageSize time:self.currentTime];
    
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        NSDictionary *dic = (NSDictionary *)response;
        NSDictionary * dataDict = [dic objectForKey:@"result"];
        NSArray *listAry = dataDict[@"list"];
        
        if (listAry.count == 0) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            [SAVORXAPI postUMHandleWithContentId:@"home_load" key:@"home_load" value:@"success"];
            return;
        }
        
        self.maxTime = [[dataDict objectForKey:@"maxTime"] integerValue];
        for(NSDictionary *dict in listAry){
            
            HSVodModel *model = [[HSVodModel alloc] initWithDictionary:dict];
            [self.dataSource addObject:model];
        }
        self.pageNo++;
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
        if (self.dataSource.count == 0) {
            [self showNoDataView];
        }
        [SAVORXAPI postUMHandleWithContentId:@"home_load" key:@"home_load" value:@"success"];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [self.tableView.mj_footer endRefrenshWithNoNetWork];
        [self showTopFreshLabelWithTitle:@"无法连接到网络,请检查网络设置"];
        [SAVORXAPI postUMHandleWithContentId:@"home_load" key:@"home_load" value:@"fail"];

        
    }];
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
    BasicTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"HotTopicCell" forIndexPath:indexPath];
    
    HSVodModel * model = [self.dataSource objectAtIndex:indexPath.section];
    if (model.canPlay == 1) {
        [cell videoCanDemand:YES];
    }else{
        [cell videoCanDemand:NO];
    }
    [cell.bgImageView sd_setImageWithURL:[NSURL URLWithString:[model.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    cell.titleLabel.text = model.title;
    
    if (model.type != 3) {
        cell.timeLabel.hidden = YES;
    }else{
        cell.timeLabel.hidden = NO;
        NSInteger durationInt = model.duration; // some duration from the JSONr
        NSInteger minutesInt = durationInt / 60;
        NSInteger secondsInt = durationInt % 60;
        cell.timeLabel.text = [NSString stringWithFormat:@"%02ld'%02ld\"", (long)minutesInt, (long)secondsInt];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HSVodModel * model = [self.dataSource objectAtIndex:indexPath.section];
    if ([GlobalData shared].isBindRD && model.canPlay == 1) {
        [SAVORXAPI postUMHandleWithContentId:model.cid withType:demandHandle];
        // 获得当前视频图片，回传
        BasicTableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        //如果是绑定状态
        [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在点播"];
        
        [SAVORXAPI demandWithURL:STBURL name:model.name type:1 position:0 success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            if ([[result objectForKey:@"result"] integerValue] == 0) {
                
                if (model.type == 3) {
                    DemandViewController *view = [[DemandViewController alloc] init];
                    view.model = model;
                    [SAVORXAPI successRing];
                    [HomeAnimationView animationView].currentImage = cell.bgImageView.image;
                    [[HomeAnimationView animationView] startScreenWithViewController:view];
                    [self.parentNavigationController pushViewController:view animated:YES];
                    [SAVORXAPI postUMHandleWithContentId:@"home_click_bunch_video" key:nil value:nil];
                }else{
                    SXVideoPlayViewController * play = [[SXVideoPlayViewController alloc] init];
                    play.model = model;
                    [HomeAnimationView animationView].currentImage = cell.bgImageView.image;
                    [[HomeAnimationView animationView] startScreenWithViewController:play];
                    [self.parentNavigationController pushViewController:play animated:YES];
                }
            }else{
                [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showTextHUDwithTitle:DemandFailure];
        }];
        
    }else if ([GlobalData shared].isBindDLNA && model.type == 3){
        [SAVORXAPI postUMHandleWithContentId:model.cid withType:demandHandle];
        // 获得当前视频图片，回传
        BasicTableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        //如果是绑定状态
        [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在点播"];
        [[GCCUPnPManager defaultManager] setAVTransportURL:[model.videoURL stringByAppendingString:@".f20.mp4"] Success:^{
            SXVideoPlayViewController * play = [[SXVideoPlayViewController alloc] init];
            play.model = model;
            [HomeAnimationView animationView].currentImage = cell.bgImageView.image;
            [[HomeAnimationView animationView] startScreenWithViewController:play];
            [self.parentNavigationController pushViewController:play animated:YES];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failure:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showTextHUDwithTitle:DemandFailure];
        }];
    }else{
        [SAVORXAPI postUMHandleWithContentId:model.cid withType:readHandle];
        //如果不是绑定状态
        if (model.type == 3) {
            WebViewController * web = [[WebViewController alloc] init];
            web.model = model;
            BasicTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
            web.image = cell.bgImageView.image;
            [self.parentNavigationController pushViewController:web animated:YES];
            [SAVORXAPI postUMHandleWithContentId:@"home_click_video" key:nil value:nil];
        }else{
            BasicTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
            ArticleReadViewController * article = [[ArticleReadViewController alloc] initWithVodModel:model andImage:cell.bgImageView.image];
            [self.parentNavigationController pushViewController:article animated:YES];
            [SAVORXAPI postUMHandleWithContentId:@"home_click_article" key:nil value:nil];

        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMainBoundsWidth * (500.f / 750);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [Helper autoHeightWith:5.f];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [Helper autoHeightWith:5.f];
}

#pragma mark -- 懒加载
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_tableView registerClass:[BasicTableViewCell class] forCellReuseIdentifier:@"HotTopicCell"];
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
            [self getVodListWithPageNo:self.pageNo andPageSize:self.pageSize];
        }];
        _tableView.mj_footer = footer;
    }
    
    return _tableView;
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
