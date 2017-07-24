//
//  LeftViewController.m
//  SavorX
//
//  Created by lijiawei on 17/1/17.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "LeftViewController.h"
#import "BaseNavigationController.h"
#import "UIViewController+LGSideMenuController.h"
#import "FavoriteViewController.h"
#import "AdviceViewController.h"
#import "HelpViewController.h"
#import "SDImageCache.h"
#import "LeftCell.h"
#import "LeftTableHeaderView.h"
#import "ShareRDViewController.h"
#import "RestaurantListViewController.h"
#import "SmashEggsGameViewController.h"

@interface LeftViewController ()<UINavigationControllerDelegate>{
    
    NSArray *_itemArys;
    NSArray *_imageArys;
}
@property (weak, nonatomic) IBOutlet UITableView *leftTableView;
@property (nonatomic, assign) long long totalSize; //总大小
@property (nonatomic, strong) CALayer *redLayer;
@property (nonatomic, strong) LeftTableHeaderView * headerView;
@property (nonatomic, strong) UIView * footView;

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.delegate = self;
    [self setupDatas];
    self.leftTableView.backgroundColor = kThemeColor;
    CGFloat width = kMainBoundsHeight > kMainBoundsWidth ? kMainBoundsWidth : kMainBoundsHeight;
    self.headerView = [[LeftTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, width / 3 * 2, width / 3 * 2 - 80)];
    self.leftTableView.tableHeaderView = self.headerView;
    [self.view addSubview:self.footView];
    [self.footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.leftTableView.mas_bottom);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    self.leftTableView.showsVerticalScrollIndicator = NO;
    
    // Do any additional setup after loading the view from its nib.
}

-(void)setupDatas{

    _itemArys = @[@"我的收藏",@"意见反馈",@"帮助中心",@"优惠活动",@"提供投屏的餐厅",@"清除缓存",@"当前版本"];
    _imageArys = @[@"cdh_shoucang", @"cdh_yijianfankui", @"cdh_bangzhu",@"cdh_yhhd",@"cdh_canting", @"cdh_qingchu", @"cdh_banben"];
}

#pragma mark -- UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LeftCell * cell = [tableView dequeueReusableCellWithIdentifier:[LeftCell cellIdentifier]];
    if(cell == nil){
        cell = [LeftCell loadFromXib];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell bottomLineHidden:NO];
    NSString *content;
    if (indexPath.section == 0) {
        if (indexPath.row == 4) {
            [cell bottomLineHidden:YES];
        }
    }else if(indexPath.section == 1){
        
        if (indexPath.row == 0) {
            content = [self getApplicationCache];
        }else if (indexPath.row == 1){
            content = [NSString stringWithFormat:@"V%@", kSoftwareVersion];
            [cell bottomLineHidden:YES];
        }
    }
    [cell fillCellTitle:[_itemArys objectAtIndex:indexPath.section * 5 + indexPath.row] content:content];
    [cell.iconImageView setImage:[UIImage imageNamed:[_imageArys objectAtIndex:indexPath.section * 5 + indexPath.row]]];
    
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 5;
    }
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.sideMenuController.leftViewAnimationSpeed = .2f;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self hideLeftViewAnimated:nil];
            FavoriteViewController * favorite = [[FavoriteViewController alloc] init];
            favorite.title = [_itemArys objectAtIndex:indexPath.row];
            [(UINavigationController *)self.sideMenuController.rootViewController pushViewController:favorite  animated:NO];
        }else if (indexPath.row == 1) {
            [self hideLeftViewAnimated:nil];
            AdviceViewController * advice = [[AdviceViewController alloc] init];
            advice.hidesBottomBarWhenPushed = YES;
            advice.title = [_itemArys objectAtIndex:indexPath.row];
            [(UINavigationController *)self.sideMenuController.rootViewController  pushViewController:advice  animated:NO];
        }else if (indexPath.row == 2){
            [self hideLeftViewAnimated:nil];
            HelpViewController * help = [[HelpViewController alloc] initWithURL:@"http://h5.littlehotspot.com/Public/html/help3"];
            help.title = [_itemArys objectAtIndex:indexPath.row];
            [(UINavigationController *)self.sideMenuController.rootViewController  pushViewController:help  animated:NO];
        }else if (indexPath.row == 3){
            [SAVORXAPI postUMHandleWithContentId:@"menu_game" key:nil value:nil];
            if ([GlobalData shared].hotelId != 0) {
                [self hideLeftViewAnimated:nil];
                SmashEggsGameViewController * segvVC = [[SmashEggsGameViewController alloc] init];
                [(UINavigationController *)self.sideMenuController.rootViewController  pushViewController:segvVC  animated:NO];
            }else{
                [MBProgressHUD showTextHUDwithTitle:@"请在酒店环境下使用该功能"];
            }

        }
        else if (indexPath.row == 4){
            [self hideLeftViewAnimated:nil];
            RestaurantListViewController * restVC = [[RestaurantListViewController alloc] init];
            [(UINavigationController *)self.sideMenuController.rootViewController  pushViewController:restVC  animated:NO];
            [SAVORXAPI postUMHandleWithContentId:@"menu_hotel_map_list" key:nil value:nil];
        }
    }
    else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            [self showAlertWithClearCache];
        }
    }
    self.sideMenuController.leftViewAnimationSpeed = .5f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 82.f;
}

- (UIView *)footView
{
    if (!_footView) {
        _footView = [[UIView alloc] initWithFrame:CGRectZero];
        _footView.backgroundColor = self.leftTableView.backgroundColor;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareRDToFriends)];
        tap.numberOfTapsRequired = 1;
        [_footView addGestureRecognizer:tap];
        
        UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
        lineView.backgroundColor = UIColorFromRGB(0xb45a6a);
        [_footView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(.5f);
        }];
        
        UIImageView * recommendImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [recommendImageView setImage:[UIImage imageNamed:@"tuijian"]];
        [_footView addSubview:recommendImageView];
        [recommendImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(35, 35));
        }];
        
        UIImageView * peopleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [peopleImageView setImage:[UIImage imageNamed:@"cdh_py"]];
        [_footView addSubview:peopleImageView];
        [peopleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_equalTo(recommendImageView.mas_right);
            make.size.mas_equalTo(CGSizeMake(17, 18));
        }];
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
        if (kMainBoundsWidth < 375) {
            label.font = kPingFangLight(12.5);
        }else{
            label.font = kPingFangLight(16);
        }
        label.textColor = UIColorFromRGB(0xece6de);
        label.text = @"向朋友推荐小热点";
        [_footView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(peopleImageView.mas_right).offset(10);
            make.right.mas_equalTo(-40);
            make.height.mas_equalTo(30);
            make.centerY.mas_equalTo(0);
        }];
        
        UIImageView * rightMode = [[UIImageView alloc] initWithFrame:CGRectZero];
        [rightMode setImage:[UIImage imageNamed:@"cdh_more"]];
        [_footView addSubview:rightMode];
        [rightMode mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-20);
            make.width.mas_equalTo(8);
            make.height.mas_equalTo(14);
            make.centerY.mas_equalTo(0);
        }];
    }
    
    return _footView;
}

- (void)shareRDToFriends
{
    self.sideMenuController.leftViewAnimationSpeed = .2f;
    [self hideLeftViewAnimated:nil];
    ShareRDViewController * share = [[ShareRDViewController alloc] initWithType:SHARERDTYPE_APPLICATION];
    share.title = @"推荐";
   [(UINavigationController *)self.sideMenuController.rootViewController pushViewController:share  animated:NO];
    self.sideMenuController.leftViewAnimationSpeed = .5f;
    [SAVORXAPI postUMHandleWithContentId:@"menu_recommend" key:nil value:nil];
}

- (void)willShow
{
    [self.leftTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

//提示用户是否确认清除缓存
- (void)showAlertWithClearCache
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:@"本次清除缓存，将清除图片、视频、以及您的文件缓存，请确认您的操作" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [SAVORXAPI postUMHandleWithContentId:@"menu_clear_cache" key:@"menu_clear_cache" value:@"fail"];
    }];
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self clearApplicationCache];
        [SAVORXAPI postUMHandleWithContentId:@"menu_clear_cache" key:@"menu_clear_cache" value:@"success"];
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 清除当前系统缓存
- (void)clearApplicationCache
{
    [MBProgressHUD showDeleteCacheHUDInView:self.view];
    
    [[SDImageCache sharedImageCache] clearDisk];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    NSString * mp4Str = [HTTPServerDocument stringByAppendingPathComponent:RDScreenVideoName];
    //检测导出视频缓存地址
    if ([manager fileExistsAtPath:mp4Str]) {
        [manager removeItemAtPath:mp4Str error:nil];
    }
    
    //检测图片,PDF,DOC,EXCEL,PPT,VIDEO,PHASSET缓存
    NSArray * paths = @[ImageDocument, PDFDocument, DOCDocument, EXCELDocument, PPTDocument, VideoDocument, SystemImage, FileCachePath];
    for (NSString * path in paths) {
        BOOL isDirectory;
        if ([manager fileExistsAtPath:path isDirectory:&isDirectory]) {
            if (isDirectory) {
                NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:path] objectEnumerator];
                NSString* fileName;
                while ((fileName = [childFilesEnumerator nextObject]) != nil){
                    NSString* fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
                    if ([manager fileExistsAtPath:fileAbsolutePath]) {
                        [manager removeItemAtPath:fileAbsolutePath error:nil];
                    }
                }
            }else{
                [manager removeItemAtPath:path error:nil];
            }
        }
    }
    [self.leftTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    
    [MBProgressHUD showSuccessHUDInView:self.view title:@"清理完成"];
}

#pragma mark -- 获取当前系统的缓存大小
- (NSString *)getApplicationCache
{
    NSFileManager* manager = [NSFileManager defaultManager];
    
    long long folderSize = 0;
    
    folderSize += [self fileSizeAtPath:ImageDocument];
    folderSize += [self fileSizeAtPath:PDFDocument];
    folderSize += [self fileSizeAtPath:DOCDocument];
    folderSize += [self fileSizeAtPath:EXCELDocument];
    folderSize += [self fileSizeAtPath:PPTDocument];
    folderSize += [self fileSizeAtPath:VideoDocument];
    folderSize += [self fileSizeAtPath:SystemImage];
    folderSize += [self fileSizeAtPath:FileCachePath];
    
    NSString * mp4Str = [HTTPServerDocument stringByAppendingPathComponent:RDScreenVideoName];
    if ([manager fileExistsAtPath:mp4Str]) {
        folderSize += [self fileSizeAtPath:mp4Str];
    }
    
    folderSize += [[SDImageCache sharedImageCache] getSize];
    
    self.totalSize = folderSize;
    if (folderSize > 1024 * 100) {
        return [NSString stringWithFormat:@"%.2lf M", folderSize/(1024.0*1024.0)];
    }else if(folderSize > 1024){
        return [NSString stringWithFormat:@"%.2lf KB", folderSize/1024.0];
    }else if (folderSize < 10){
        return [NSString stringWithFormat:@"%lld B", folderSize];
    }
    return [NSString stringWithFormat:@"%.2lld B", folderSize];
}

//获取某路径下对应文件的大小
- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    
    BOOL isDirectory;
    if ([manager fileExistsAtPath:filePath isDirectory:&isDirectory]){
        
        long long folderSize = 0;
        
        if (isDirectory) {
            NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:filePath] objectEnumerator];
            NSString* fileName;
            
            while ((fileName = [childFilesEnumerator nextObject]) != nil){
                NSString* fileAbsolutePath = [filePath stringByAppendingPathComponent:fileName];
                if ([manager fileExistsAtPath:fileAbsolutePath]) {
                    folderSize += [[manager attributesOfItemAtPath:fileAbsolutePath error:nil] fileSize];
                }
            }
        }else{
            folderSize += [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
        }
        
        return folderSize;
    }
    return 0;
}

/// 设置抽屉视图push后的状态
- (void)settingDrawerWhenPush {
    
    
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if ([viewController isKindOfClass:[LeftViewController class]]) {
        [navigationController setNavigationBarHidden:YES animated:YES];
    } else {
        [navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

//允许屏幕旋转
- (BOOL)shouldAutorotate
{
    return YES;
}

//返回当前屏幕旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
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
