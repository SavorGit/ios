//
//  RecommendViewController.m
//  SavorX
//
//  Created by 郭春城 on 17/1/17.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RecommendViewController.h"
#import "HomePageCell.h"
#import "HSVodModel.h"
#import "UIImageView+WebCache.h"
#import "HSHotelVodListRequest.h"
#import "MJRefresh.h"
#import "WebViewController.h"
#import "DemandViewController.h"
#import "GCCUPnPManager.h"
#import "HomeAnimationView.h"
#import "SDCycleScrollView.h"
#import "HSAdsModel.h"
#import "SXVideoPlayViewController.h"
#import "ArticleReadViewController.h"
#import "HSGetLastHotelVodList.h"

@interface RecommendViewController ()<UITableViewDelegate, UITableViewDataSource, SDCycleScrollViewDelegate>

@property (nonatomic, strong) SDCycleScrollView * scrollView;
@property (nonatomic, strong) UITableView * tableView; //表格展示视图
@property (nonatomic, strong) NSMutableArray * dataSource; //数据源
@property (nonatomic, strong) UIView * headView; //头视图
@property (nonatomic, assign) NSInteger pageNo; //当前数据页面
@property (nonatomic, assign) NSInteger pageSize; //页面数据大小
@property (nonatomic, strong) NSMutableArray * adSourcel;
@property (nonatomic, strong) UILabel * TopFreshLabel;
@property (nonatomic, copy) NSString * hotelName;
@property (nonatomic, assign) NSInteger lastTopTime;
@property (nonatomic, assign) NSInteger lastDownTime;

@end

@implementation RecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = [NSMutableArray new];
    self.adSourcel = [NSMutableArray new];
    self.lastDownTime = 0;
    
    self.hotelName = @"";
    
    [self setupDatas];
}

- (void)retryToGetData
{
    [self hideNoNetWorkView];
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
    [self.dataSource removeAllObjects];
    MBProgressHUD * hud;
    if ([[NSFileManager defaultManager] fileExistsAtPath:HotelCache]) {
        NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:HotelCache];
        NSArray * vodArray = [dict objectForKey:@"vodList"];
        for (NSInteger i = 0; i < vodArray.count; i++) {
            NSDictionary * vodDict = [vodArray objectAtIndex:i];
            HSVodModel * model = [[HSVodModel alloc] initWithDictionary:vodDict];
            [self.dataSource addObject:model];
        }
        NSArray * adArray = [dict objectForKey:@"adsList"];
        for (NSInteger i = 0; i < adArray.count; i++) {
            NSDictionary * adDict = [adArray objectAtIndex:i];
            HSAdsModel * model = [[HSAdsModel alloc] initWithDictionary:adDict];
            [self.adSourcel addObject:model];
        }
        self.hotelName = [dict objectForKey:@"hotelName"];
        self.lastTopTime = [[dict objectForKey:@"time"] integerValue];
        self.lastDownTime = [[dict objectForKey:@"minTime"] integerValue];
        [self setupTopScrollView];
        [self.tableView reloadData];
        self.pageNo = 3;
    }else{
        hud = [MBProgressHUD showCustomLoadingHUDInView:self.view];
    }
    
    HSGetLastHotelVodList * request = [[HSGetLastHotelVodList alloc] initWithHotelId:[GlobalData shared].hotelId createTime:0];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        NSDictionary * dict = response[@"result"];
        [SAVORXAPI saveFileOnPath:HotelCache withDictionary:dict];
        [self.dataSource removeAllObjects];
        [self.adSourcel removeAllObjects];
        NSArray * vodArray = [dict objectForKey:@"vodList"];
        for (NSInteger i = 0; i < vodArray.count; i++) {
            NSDictionary * vodDict = [vodArray objectAtIndex:i];
            HSVodModel * model = [[HSVodModel alloc] initWithDictionary:vodDict];
            [self.dataSource addObject:model];
        }
        NSArray * adArray = [dict objectForKey:@"adsList"];
        for (NSInteger i = 0; i < adArray.count; i++) {
            NSDictionary * adDict = [adArray objectAtIndex:i];
            HSAdsModel * model = [[HSAdsModel alloc] initWithDictionary:adDict];
            [self.adSourcel addObject:model];
        }
        self.hotelName = [dict objectForKey:@"hotelName"];
        self.lastTopTime = [[dict objectForKey:@"time"] integerValue];
        self.lastDownTime = [[dict objectForKey:@"minTime"] integerValue];
        [self setupTopScrollView];
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

- (void)getDataWithPageNo:(NSInteger)pageNo andPageSize:(NSInteger)pageSize
{
    HSHotelVodListRequest * request = [[HSHotelVodListRequest alloc] initWithHotelID:[GlobalData shared].hotelId andPageNo:pageNo andPageSize:pageSize createTime:self.lastDownTime];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSDictionary * dict = response[@"result"];
        
        NSArray * vodArray = [dict objectForKey:@"vodList"];
        for (NSInteger i = 0; i < vodArray.count; i++) {
            NSDictionary * vodDict = [vodArray objectAtIndex:i];
            HSVodModel * model = [[HSVodModel alloc] initWithDictionary:vodDict];
            [self.dataSource addObject:model];
        }
        self.pageNo++;
        self.lastDownTime = [[dict objectForKey:@"time"] integerValue];
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        if ([[response objectForKey:@"code"] integerValue] == 10060) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [self.tableView.mj_footer endRefreshing];
        }
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self.tableView.mj_footer endRefreshing];
        [self showTopFreshLabelWithTitle:@"无法连接到网络,请检查网络设置"];
    }];
}

- (void)refreshDataSource
{
    HSGetLastHotelVodList * request = [[HSGetLastHotelVodList alloc] initWithHotelId:[GlobalData shared].hotelId createTime:self.lastTopTime];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        NSDictionary * dict = response[@"result"];
        [SAVORXAPI saveFileOnPath:HotelCache withDictionary:dict];
        [self.dataSource removeAllObjects];
        [self.adSourcel removeAllObjects];
        NSArray * vodArray = [dict objectForKey:@"vodList"];
        for (NSInteger i = 0; i < vodArray.count; i++) {
            NSDictionary * vodDict = [vodArray objectAtIndex:i];
            HSVodModel * model = [[HSVodModel alloc] initWithDictionary:vodDict];
            [self.dataSource addObject:model];
        }
        NSArray * adArray = [dict objectForKey:@"adsList"];
        for (NSInteger i = 0; i < adArray.count; i++) {
            NSDictionary * adDict = [adArray objectAtIndex:i];
            HSAdsModel * model = [[HSAdsModel alloc] initWithDictionary:adDict];
            [self.adSourcel addObject:model];
        }
        self.hotelName = [dict objectForKey:@"hotelName"];
        self.lastTopTime = [[dict objectForKey:@"time"] integerValue];
        self.lastDownTime = [[dict objectForKey:@"minTime"] integerValue];
        [self setupTopScrollView];
        self.pageNo = 3;
        [self.tableView reloadData];
        [self.tableView.mj_footer resetNoMoreData];
        [self.tableView.mj_header endRefreshing];
        
        NSInteger count = [[dict objectForKey:@"count"] integerValue];
        if (count == 0) {
            [self showTopFreshLabelWithTitle:@"当前已为最新内容"];
        }else{
            [self showTopFreshLabelWithTitle:[NSString stringWithFormat:@"本次更新%ld条内容", count]];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        if ([[response objectForKey:@"code"] integerValue] == 10060) {
            [self showTopFreshLabelWithTitle:@"当前已为最新内容"];
            [self.tableView.mj_footer resetNoMoreData];
        }
        [self.tableView.mj_header endRefreshing];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self.tableView.mj_header endRefreshing];
        [self showTopFreshLabelWithTitle:@"无法连接到网络,请检查网络设置"];
    }];
}

- (void)setupTopScrollView
{
    if (self.adSourcel.count == 0) {
        return;
    }
    
    NSMutableArray * array = [NSMutableArray new];
    
    for (NSInteger i = 0; i < self.adSourcel.count; i++) {
        HSAdsModel * model = [self.adSourcel objectAtIndex:i];
        [array addObject:model.imageURL];
    }
    self.scrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 5, kMainBoundsWidth, [Helper autoHomePageCellImageHeight]) imageURLStringsGroup:array];
    [self.scrollView setHotelTitle:self.hotelName];
    self.scrollView.delegate = self;
    [self.headView addSubview:self.scrollView];
    [self.scrollView setPageDotImage:[UIImage imageNamed:@"banner_default.png"]];
    [self.scrollView setCurrentPageDotImage:[UIImage imageNamed:@"banner_chose.png"]];
    self.tableView.tableHeaderView = self.headView;
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
    HomePageCell * cell = [tableView dequeueReusableCellWithIdentifier:@"HotTopicCell" forIndexPath:indexPath];
    
    HSVodModel * model = [self.dataSource objectAtIndex:indexPath.section];
    [cell videoCanDemand:NO];
    
    cell.categroyLabel.text = [NSString stringWithFormat:@"# %@", model.category];
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
    // 获得当前视频图片  回传
    HomePageCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [HomeAnimationView animationView].currentImage = cell.bgImageView.image;
    DemandViewController *view = [[DemandViewController alloc] init];
    [[HomeAnimationView animationView] startScreenWithViewController:view];
    
    HSVodModel * model = [self.dataSource objectAtIndex:indexPath.section];
    if ([GlobalData shared].isBindRD && model.canPlay == 1) {
        //如果是绑定状态
        [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在点播"];
        NSDictionary *parameters = @{@"function": @"prepare",
                                     @"action": @"vod",
                                     @"assettype": @"video",
                                     @"vodType"  : [NSNumber numberWithInt:1],
                                     @"assetname": model.name,
                                     @"play": @"0"};
        
        [SAVORXAPI postWithURL:STBURL parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            if ([[result objectForKey:@"result"] integerValue] == 0) {
                if (model.type == 3) {
                    DemandViewController *view = [[DemandViewController alloc] init];
                    view.model = model;
                    [SAVORXAPI successRing];
                    [[HomeAnimationView animationView] startScreenWithViewController:view];
                    [self.parentNavigationController pushViewController:view animated:YES];
                }else{
                    SXVideoPlayViewController * play = [[SXVideoPlayViewController alloc] init];
                    play.model = model;
                    [[HomeAnimationView animationView] startScreenWithViewController:play];
                    [self.navigationController pushViewController:play animated:YES];
                }
            }else{
                [MBProgressHUD showTextHUDwithTitle:[result objectForKey:@"info"]];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showTextHUDwithTitle:DemandFailure];
        }];
    }else if ([GlobalData shared].isBindDLNA && model.type == 3){
        //如果是绑定状态
        [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在点播"];
        [[GCCUPnPManager defaultManager] setAVTransportURL:[model.videoURL stringByAppendingString:@".f20.mp4"] Success:^{
            SXVideoPlayViewController * play = [[SXVideoPlayViewController alloc] init];
            play.model = model;
            [[HomeAnimationView animationView] startScreenWithViewController:play];
            [self.navigationController pushViewController:play animated:YES];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failure:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showTextHUDwithTitle:DemandFailure];
        }];
    }else if ([GlobalData shared].scene == RDSceneHaveRDBox) {
        [[HomeAnimationView animationView] scanQRCode];
    }else{
        //如果不是绑定状态
        if (model.type == 3) {
            WebViewController * web = [[WebViewController alloc] init];
            web.model = model;
            BasicTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
            web.image = cell.bgImageView.image;
            [self.parentNavigationController pushViewController:web animated:YES];
        }else{
            BasicTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
            ArticleReadViewController * article = [[ArticleReadViewController alloc] initWithVodModel:model andImage:cell.bgImageView.image];
            [self.navigationController pushViewController:article animated:YES];
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
    if (section == 0) {
        if (self.adSourcel.count != 0) {
            return 0.1f;
        }
    }
    return [Helper autoHeightWith:5.f];
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    HSAdsModel * model = [self.adSourcel objectAtIndex:index];
    if ([GlobalData shared].isBindRD) {
        [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在点播"];
        NSDictionary *parameters = @{@"function": @"prepare",
                                     @"action": @"vod",
                                     @"assettype": @"video",
                                     @"assetname": model.name,
                                     @"vodType"  : [NSNumber numberWithInt:2],
                                     @"play": @"0"};
        
        [SAVORXAPI postWithURL:STBURL parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            if ([[result objectForKey:@"result"] integerValue] == 0) {
                SXVideoPlayViewController * play = [[SXVideoPlayViewController alloc] init];
                play.type = 2;
                HSVodModel * hsVod = [[HSVodModel alloc] init];
                hsVod.duration = model.duration;
                hsVod.name = model.name;
                hsVod.imageURL = model.imageURL;
                play.model = hsVod;
                [[HomeAnimationView animationView] startScreenWithViewController:play];
                [self.navigationController pushViewController:play animated:YES];
            }else{
                [MBProgressHUD showTextHUDwithTitle:[result objectForKey:@"info"]];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showTextHUDwithTitle:DemandFailure];
        }];
    }else if ([GlobalData shared].isBindDLNA) {
        [MBProgressHUD showTextHUDwithTitle:@"DLNA暂不支持该操作"];
    }else if ([GlobalData shared].scene == RDSceneHaveRDBox) {
        [[HomeAnimationView animationView] scanQRCode];
    }else {
        [MBProgressHUD showTextHUDwithTitle:@"未连接电视，请稍后重试"];
    }
}

#pragma mark -- 懒加载
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_tableView registerClass:[HomePageCell class] forCellReuseIdentifier:@"HotTopicCell"];
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
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshDataSource)];
        MJRefreshFooter* footer = [MJRefreshAutoGifFooter footerWithRefreshingBlock:^{
            [self getDataWithPageNo:self.pageNo andPageSize:self.pageSize];
        }];
        _tableView.mj_footer = footer;
    }
    
    return _tableView;
}

- (UIView *)headView
{
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, [Helper autoHomePageCellImageHeight] + 55)];
        _headView.backgroundColor = VCBackgroundColor;
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, [Helper autoHomePageCellImageHeight] + 5, kMainBoundsWidth, 55)];
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = UIColorFromRGB(0x666666);
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"—— ◆ 精彩视频 ◆ ——";
        [_headView addSubview:label];
    }
    return _headView;
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
