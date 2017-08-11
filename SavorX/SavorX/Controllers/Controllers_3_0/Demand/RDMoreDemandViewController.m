//
//  RDMoreDemandViewController.m
//  SavorX
//
//  Created by 郭春城 on 2017/8/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDMoreDemandViewController.h"
#import "RDDemandTableViewCell.h"
#import "WebViewController.h"
#import "RD_MJRefreshHeader.h"
#import "HSDemandListRequest.h"

@interface RDMoreDemandViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) UILabel * TopFreshLabel;

@property (nonatomic, strong) UIView * topView;

@end

@implementation RDMoreDemandViewController

- (instancetype)initWithModelSource:(NSArray *)source
{
    if (self = [super init]) {
        self.dataSource = [NSMutableArray arrayWithArray:source];
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.topView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.topView.userInteractionEnabled = YES;
    self.topView.contentMode = UIViewContentModeScaleToFill;
    self.topView.backgroundColor = kThemeColor;
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 64));
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];
    
    UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(5,20, 40, 44)];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateSelected];
    [backButton addTarget:self action:@selector(navBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:backButton];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[RDDemandTableViewCell class] forCellReuseIdentifier:@"DemandCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 10)];
    //创建tableView动画加载头视图
    self.tableView.mj_header = [RD_MJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.left.bottom.right.mas_equalTo(0);
    }];
}

- (void)refreshData
{
    HSDemandListRequest * request = [[HSDemandListRequest alloc] initWithHotelID:[GlobalData shared].hotelId];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.tableView.mj_header endRefreshing];
        NSArray * listArray = [response objectForKey:@"result"];
        
        if (listArray && listArray.count != 0) {
            
            [self.dataSource removeAllObjects];
            for (NSDictionary * dict in listArray) {
                CreateWealthModel * model = [[CreateWealthModel alloc] initWithDictionary:dict];
                [self.dataSource addObject:model];
            }
            [self showTopFreshLabelWithTitle:RDLocalizedString(@"RDString_SuccessWithUpdate")];
            [self.tableView reloadData];
            
        }else{
            [self showTopFreshLabelWithTitle:RDLocalizedString(@"RDString_SuccessWithUpdate")];
        }
        
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self.tableView.mj_header endRefreshing];
        if (self.dataSource.count == 0) {
            [self showNoNetWorkView:NoNetWorkViewStyle_Load_Fail];
        }
        [self showTopFreshLabelWithTitle:RDLocalizedString(@"RDString_NetFailedWithData")];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self.tableView.mj_header endRefreshing];
        if (self.dataSource.count == 0) {
            [self showNoNetWorkView:NoNetWorkViewStyle_Load_Fail];
        }
        if (error.code == -1001) {
            [self showTopFreshLabelWithTitle:RDLocalizedString(@"RDString_NetFailedWithTimeOut")];
        }else{
            [self showTopFreshLabelWithTitle:RDLocalizedString(@"RDString_NetFailedWithBadNet")];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RDDemandTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DemandCell" forIndexPath:indexPath];
    
    CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configWithInfo:model];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    __weak typeof(self) weakSelf  = self;
    cell.clickHandel = ^(BOOL isLeftClick, CreateWealthModel *model) {
        
        if (isLeftClick) {
            [weakSelf playOnPhone:model];
        }else{
            [weakSelf playOnTV:model];
        }
        
    };
    
    return cell;
}

- (void)playOnTV:(CreateWealthModel *)model
{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(playOnTVButtonDidClickedWithModel:)]) {
        [self.delegate playOnTVButtonDidClickedWithModel:model];
    }
}

- (void)playOnPhone:(CreateWealthModel *)model
{
    WebViewController * web = [[WebViewController alloc] initWithModel:model categoryID:-2];
    [self.navigationController pushViewController:web animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat scale = kMainBoundsWidth / 375;
    CGFloat contentWidth = kMainBoundsWidth - 30 * scale;
    CGFloat height = contentWidth * .646 + 69;
    return height + 10;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [MobClick beginLogPageView:NSStringFromClass([self class])];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

//页面顶部下弹状态栏显示
- (void)showTopFreshLabelWithTitle:(NSString *)title
{
    //移除当前动画
    [self.TopFreshLabel.layer removeAllAnimations];
    
    //取消延时重置状态栏
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetTopFreshLabel) object:nil];
    
    //重新设置状态栏下弹动画
    self.TopFreshLabel.text = title;
    self.TopFreshLabel.frame = CGRectMake(0, self.topView.frame.size.height - 35, kMainBoundsWidth, 35);
    [UIView animateWithDuration:.5f animations:^{
        self.TopFreshLabel.frame = CGRectMake(0, self.topView.frame.size.height, kMainBoundsWidth, 35);
    } completion:^(BOOL finished) {
        [self performSelector:@selector(resetTopFreshLabel) withObject:nil afterDelay:2.f];
    }];
}

//重置页面顶部下弹状态栏
- (void)resetTopFreshLabel
{
    [UIView animateWithDuration:.5f animations:^{
        self.TopFreshLabel.frame = CGRectMake(0, self.topView.frame.size.height - 35, kMainBoundsWidth, 35);
    }];
}

- (UILabel *)TopFreshLabel
{
    if (!_TopFreshLabel) {
        _TopFreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.topView.frame.size.height - 35, kMainBoundsWidth, 35)];
        _TopFreshLabel.textAlignment = NSTextAlignmentCenter;
        _TopFreshLabel.backgroundColor = [UIColorFromRGB(0xffebc3) colorWithAlphaComponent:.96f];
        _TopFreshLabel.font = [UIFont systemFontOfSize:15];
        _TopFreshLabel.textColor = UIColorFromRGB(0x9a6f45);
        [self.view addSubview:_TopFreshLabel];
        [self.view bringSubviewToFront:self.topView];
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
