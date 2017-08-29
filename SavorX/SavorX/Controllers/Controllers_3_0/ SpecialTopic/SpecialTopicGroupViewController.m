//
//  SpecialTopicGroupViewController.m
//  SavorX
//
//  Created by 王海朋 on 2017/8/29.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "SpecialTopicGroupViewController.h"
#import "SpecialTextCell.h"
#import "SpecialImageCell.h"
#import "SpecialArtCell.h"
#import "SpecialTitleCell.h"
#import "SpecialHeaderView.h"
#import "RDFrequentlyUsed.h"

@interface SpecialTopicGroupViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView; //表格展示视图
@property (nonatomic, strong) NSMutableArray * dataSource; //数据源
@property (nonatomic, assign) NSInteger categoryID;
@property (nonatomic, copy) NSString * cachePath;

@end

@implementation SpecialTopicGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initInfo];
    [self initDatas];
}

- (void)initInfo{
    self.categoryID = 103;
    _dataSource = [[NSMutableArray alloc] initWithCapacity:100];
    self.cachePath = [NSString stringWithFormat:@"%@%@.plist", CategoryCache, @"SpecialTopicGroup"];
}

- (void)initDatas{
    
    for(int i = 0; i < 10; i ++){
        
        CreateWealthModel *tmpModel = [[CreateWealthModel alloc] init];
        tmpModel.type = 1;
        if (i == 0) {
            tmpModel.type = 1;
        }else if (i == 1){
            tmpModel.type = 2;
        }else if (i == 2){
            tmpModel.type = 3;
        }else if (i == 3){
            tmpModel.type = 4;
        }else if (i == 4){
            tmpModel.type = 4;
        }else if (i == 5){
            tmpModel.type = 2;
        }
        tmpModel.title = @"我是文章标题,我是文章标题,我是文章标题。";
        tmpModel.imageURL = @"http://oss.littlehotspot.com/media/resource/RNZhJmpWJ5.jpg";
        tmpModel.updateTime = @"2017-08-26";
        tmpModel.shareTitle = @"我是文章副标题，我是文章简介，我是文章简介。我是文章简介，我是文章简介。";
        
        
        [self.dataSource addObject:tmpModel];
        
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
        

        CreateWealthModel * model = [self.dataSource objectAtIndex:0];
        SpecialHeaderView *topView = [[SpecialHeaderView alloc] initWithFrame:CGRectZero];
        topView.backgroundColor = UIColorFromRGB(0xf6f2ed);
        
        CGFloat imgHeight =kMainBoundsWidth *802.f/1242.f;//113
        CGFloat totalHeight = imgHeight + 25 + 40;// 25为下方留白 40为控件间隔
        CGFloat subTitleHeight = [RDFrequentlyUsed getHeightByWidth:kMainBoundsWidth - 30 title:model.shareTitle font:[UIFont systemFontOfSize:14]];
        if (subTitleHeight > 20) {
            totalHeight = totalHeight + 40;
        }else{
            totalHeight = totalHeight + 20;
        }
        CGFloat titleHeight = [RDFrequentlyUsed getHeightByWidth:kMainBoundsWidth - 30 title:model.title font:kPingFangMedium(22)];
        if (titleHeight > 31) {
            totalHeight = totalHeight + 62;
        }else{
            totalHeight = totalHeight + 31;
        }
        
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, totalHeight)];
        [headView addSubview:topView];
        
        [topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(totalHeight);
        }];
        [topView configModelData:model];
        
        _tableView.tableHeaderView = headView;
        
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
    if (model.type == 1){
        static NSString *cellID = @"SpecialTitleCell";
        SpecialTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[SpecialTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = UIColorFromRGB(0xf6f2ed);
        
        [cell configWithText:@"我是标题字段"];
        
        return cell;
        
    }else if (model.type == 2){
        static NSString *cellID = @"SpecialImgCell";
        SpecialImageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[SpecialImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = UIColorFromRGB(0xf6f2ed);
        
        [cell configWithImageURL:@"http://oss.littlehotspot.com/media/resource/RNZhJmpWJ5.jpg"];
        
        return cell;
        
    }else if (model.type == 3){
        static NSString *cellID = @"SpecialTextCell";
        SpecialTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[SpecialTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = UIColorFromRGB(0xf6f2ed);
        
        [cell configWithText:@"这是测试文字数据,这是测试文字数据，这是测试文字数据"];
        
        return cell;
        
    }else if (model.type == 4){
        
        static NSString *cellID = @"SpecialArtCell";
        SpecialArtCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[SpecialArtCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = UIColorFromRGB(0xf6f2ed);
        
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
    CGFloat bottomBlank;
    if (indexPath.row < self.dataSource.count - 1) {
        bottomBlank = [self getBottomBlankWith:model nextModel:[self.dataSource objectAtIndex:indexPath.row + 1]];
    }else{
        bottomBlank = [self getBottomBlankWith:model nextModel:nil];
    }
    if (model.type == 2) {
        CGFloat imgHeight =  (kMainBoundsWidth - 15) *(802.f/1242.f);
        return  imgHeight + bottomBlank;
    }else if (model.type == 4){
        CGFloat artHeight= 130 *802.f/1242.f + 10;
        return  artHeight + bottomBlank;
    }
    return 22.5 + bottomBlank;
}

- (CGFloat)getBottomBlankWith:(CreateWealthModel *)tmpModel nextModel:(CreateWealthModel *)nextModel{
   // 1 标题  2 图片  3 文字  4 文章
    if (nextModel != nil) {
        if (tmpModel.type == 1) {
            if (nextModel.type == 1) {
                return 25;
            }else if (nextModel.type == 2){
                return 20;
            }else if (nextModel.type == 3){
                return 20;
            }else if (nextModel.type == 4){
                return 20;
            }
        }else if (tmpModel.type == 2){
            if (nextModel.type == 1) {
                return 25;
            }else if (nextModel.type == 2){
                return 5;
            }else if (nextModel.type == 3){
                return 15;
            }else if (nextModel.type == 4){
                return 20;
            }
        }else if (tmpModel.type == 3){
            if (nextModel.type == 1) {
                return 25;
            }else if (nextModel.type == 2){
                return 15;
            }else if (nextModel.type == 3){
                return 25;
            }else if (nextModel.type == 4){
                return 25;
            }
        }else if (tmpModel.type == 4){
            if (nextModel.type == 1) {
                return 25;
            }else if (nextModel.type == 2){
                return 20;
            }else if (nextModel.type == 3){
                return 25;
            }else if (nextModel.type == 4){
                return 5;
            }
        }
    }else{
        return 0.0;
    }
    return 0.0;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


@end
