//
//  FavoriteViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/8/19.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "FavoriteViewController.h"
#import "WebViewController.h"
#import "ArticleReadViewController.h"
#import "HomePageCell.h"
#import "UIImageView+WebCache.h"
#import "UMCustomSocialManager.h"
#import "HSVideoViewController.h"

#define FavoriteCell @"FavoriteCell"

@interface FavoriteViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray * dataSource; //数据源
@property (nonatomic, strong) UITableView * tableView; //视图表格展示控件

@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = VCBackgroundColor;
    [self getDataSource];
    [self createUI];
}

- (void)getDataSource
{
    self.dataSource = [NSMutableArray new];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"MyFavorites"] isKindOfClass:[NSArray class]]) {
        NSArray * array = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyFavorites"];
        NSArray * tempArray = [NSArray arrayWithArray:[[array reverseObjectEnumerator] allObjects]];
        for (NSDictionary * dict in tempArray) {
            [self.dataSource addObject:[[HSVodModel alloc] initWithDictionary:dict]];
        }
        [self.tableView reloadData];
    }
}

- (void)createUI
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - NavHeight) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    if (self.dataSource.count == 0) {
        [self showNoDataViewInView:self.view noDataType:kNoDataType_Favorite];
    }
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HSVodModel * model = [self.dataSource objectAtIndex:indexPath.section];
    model.canPlay = NO;
    BasicTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (model.type == 3) {
        WebViewController * web = [[WebViewController alloc] init];
        web.model = model;
        web.title = model.title;
        web.image = cell.bgImageView.image;
        [self.navigationController pushViewController:web animated:YES];
    }else if (model.type == 4){
        HSVideoViewController * web = [[HSVideoViewController alloc] initWithModel:model image:cell.bgImageView.image];
        [self.navigationController pushViewController:web animated:YES];
    }else{
        ArticleReadViewController * read = [[ArticleReadViewController alloc] initWithVodModel:model andImage:cell.bgImageView.image];
        [self.navigationController pushViewController:read animated:YES];
    }
    [SAVORXAPI postUMHandleWithContentId:@"menu_collection_details" key:nil value:nil];
}

#pragma mark -- UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomePageCell * cell = [tableView dequeueReusableCellWithIdentifier:FavoriteCell];
    if (nil == cell) {
        cell = [[HomePageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FavoriteCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    HSVodModel * model = [self.dataSource objectAtIndex:indexPath.section];
    
    if (model.canPlay == 1) {
        [cell videoCanDemand:YES];
    }else{
        [cell videoCanDemand:NO];
    }
    
//    cell.categroyLabel.text = [NSString stringWithFormat:@"# %@", model.category];
    [cell.bgImageView sd_setImageWithURL:[NSURL URLWithString:[model.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    cell.titleLabel.text = model.title;
    
    if (model.type == 3 || model.type == 4) {
        cell.timeLabel.hidden = NO;
        NSInteger durationInt = model.duration; // some duration from the JSONr
        NSInteger minutesInt = durationInt / 60;
        NSInteger secondsInt = durationInt % 60;
        cell.timeLabel.text = [NSString stringWithFormat:@"%02ld'%02ld\"", (long)minutesInt, (long)secondsInt];
    }else{
        cell.timeLabel.hidden = YES;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == self.dataSource.count - 1) {
        return 2.f;
    }
    return 1.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 2.f;
    }
    return 1.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 250.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"  取消收藏  ";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//返回cell的编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *favoritesArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyFavorites"]];
        
        HSVodModel * model = [self.dataSource objectAtIndex:indexPath.section];
        [favoritesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj objectForKey:@"contentURL"] isEqualToString:model.contentURL]) {
                [favoritesArray removeObject:obj];
                *stop = YES;
            }
        }];
        [self.dataSource removeObjectAtIndex:indexPath.section];
        [tableView beginUpdates];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
        
        if (self.dataSource.count == 0) {
            [self showNoDataViewInView:self.view noDataType:kNoDataType_Favorite];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:favoritesArray forKey:@"MyFavorites"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [MBProgressHUD showSuccessHUDInView:self.view title:@"取消成功"];
//        [SAVORXAPI postUMHandleWithContentId:model.cid withType:cancleCollectHandle];
        [SAVORXAPI postUMHandleWithContentId:@"menu_cancel_collection" key:nil value:nil];
    }
}

- (void)navBackButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [SAVORXAPI postUMHandleWithContentId:@"menu_collection_back" key:nil value:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getDataSource];
    if (self.dataSource.count == 0) {
        [self showNoDataViewInView:self.view noDataType:kNoDataType_Favorite];
    }
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

-(void)viewDidAppear:(BOOL)animated{
    [SAVORXAPI postUMHandleWithContentId:@"menu_collection" key:nil value:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[SDImageCache sharedImageCache] clearMemory];
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
