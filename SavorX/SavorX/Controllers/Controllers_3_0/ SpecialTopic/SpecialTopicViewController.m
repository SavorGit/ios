//
//  SpecialTopicViewController.m
//  SavorX
//
//  Created by 王海朋 on 2017/7/7.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "SpecialTopicViewController.h"
#import "SpecialTopTableViewCell.h"
#import "HeadlinesSTopTableViewCell.h"
#import "Masonry.h"
#import "CreateWealthModel.h"
#import "SpecialTopDetailViewController.h"

@interface SpecialTopicViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView; //表格展示视图
@property (nonatomic, strong) NSMutableArray * dataSource; //数据源

@end

@implementation SpecialTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:UIColorFromRGB(0xece6de)];
    [self initInfo];
    [self setUpDatas];
}

- (void)initInfo{
    _dataSource = [[NSMutableArray alloc] initWithCapacity:100];
}

//初始化请求第一页，下拉刷新
- (void)setUpDatas{
    
    NSArray *imageArr = [NSArray arrayWithObjects:@"https://dn-brknqdxv.qbox.me/a70592e5162cb7df8391.jpg",@"https://dn-brknqdxv.qbox.me/d6e24a57b763c14b7731.jpg",@"https://dn-brknqdxv.qbox.me/5fb13268c2d1ef3bfe69.jpg",@"https://dn-brknqdxv.qbox.me/fea55faa880653633cc8.jpg",@"https://dn-brknqdxv.qbox.me/8401b45695d7fea371ca.jpg",@"https://dn-brknqdxv.qbox.me/59bda095dcb55dd91347.jpg",@"https://dn-brknqdxv.qbox.me/ec1379afc23d6afc3d90.jpg",@"https://dn-brknqdxv.qbox.me/51b10338ffdf7016a599.jpg",@"https://dn-brknqdxv.qbox.me/4b82c3574058ea94a2c8.jpg",@"https://dn-brknqdxv.qbox.me/a0287e02c7889227d5c7.jpg", nil];
    for (int i = 0; i < 30; i ++) {
        CreateWealthModel *model = [[CreateWealthModel alloc] init];
        model.type = 0;
        if (i == 0) {
            model.type = 1;
        }
        model.title = @"这是新闻的标题";
        model.subTitle = @"这是新闻的副标题，这是新闻的简介，这是新闻的副标题，这是新闻的简介，这是新闻的副标题，这是新闻的简介，这是新闻的副标题，这是新闻的简介，这是新闻的副标题，这是新闻的简介，这是新闻的副标题，这是新闻的简介，这是新闻的副标题，这是新闻的简介。";
        model.imageUrl = @"http://devp.oss.littlehotspot.com/media/resource/WehQBiCyQk.jpg";
        if (i < 10) {
            model.imageUrl = imageArr[i];
        }
        model.source = @"网易新闻";
        model.time = @"2017.06.19";
        model.sourceImage = @"sourceImage";
        [_dataSource addObject:model];
    }
    [self.tableView reloadData];
}

#pragma mark -- 懒加载
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
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
        
        //        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
        //
        //
        //        MJRefreshFooter* footer = [MJRefreshAutoGifFooter footerWithRefreshingBlock:^{
        //            [self getMoreData];
        //        }];
        //        _tableView.mj_footer = footer;
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
    if (model.type == 1) {
        
        static NSString *cellID = @"HeadlineTableCell";
        HeadlinesSTopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[HeadlinesSTopTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        [cell configModelData:model];
        
        return cell;
        
    }else if (model.type == 0){
        static NSString *cellID = @"SpecialTopCell";
        SpecialTopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[SpecialTopTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        [cell configModelData:model];
        
        return cell;
        
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
    if (model.type == 1) {
        return 361.5;
    }else if (model.type == 0){
        return 96;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SpecialTopDetailViewController *stVC = [[SpecialTopDetailViewController alloc] init];
    [self.navigationController pushViewController:stVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
