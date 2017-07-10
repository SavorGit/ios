//
//  RDHomeScreenViewController.m
//  小热点3.0
//
//  Created by 郭春城 on 2017/7/3.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDHomeScreenViewController.h"
#import "RDTabScrollView.h"
#import "RDPhotoTool.h"
#import "PhotoLibraryViewController.h"
#import "DocumentListViewController.h"
#import "Masonry.h"
#import "HSDemandListRequest.h"
#import "RDHotelItemModel.h"

@interface RDHomeScreenViewController ()

@property (nonatomic, strong) RDTabScrollView * tabScroll;
@property (nonatomic, strong) UIView * bottomView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation RDHomeScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [NSMutableArray new];
    [self setupViews];
    [self setupDatas];
}

- (void)setupDatas
{
    HSDemandListRequest * request = [[HSDemandListRequest alloc] initWithHotelID:[GlobalData shared].hotelId];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSArray * listArray = [response objectForKey:@"result"];
        if (listArray) {
            
            for (NSDictionary * dict in listArray) {
                RDHotelItemModel * model = [[RDHotelItemModel alloc] initWithDictionary:dict];
                [self.dataSource addObject:model];
            }
            
        }
        [self createUI];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)createUI
{
    CGFloat height = (kMainBoundsWidth - 40) * 0.646 + 20 + 59 + 40 + 40;
    self.tabScroll = [[RDTabScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height) modelArray:self.dataSource];
    [self.view addSubview:self.tabScroll];
    [self.tabScroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(height);
    }];
}

- (void)setupViews
{
    CGFloat height = (kMainBoundsWidth - 40) * 0.646 + 20 + 59 + 40 + 40;
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(height);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    UIButton * photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoBtn setBackgroundImage:[UIImage imageNamed:@"xiangce"] forState:UIControlStateNormal];
    [photoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];;
    [photoBtn addTarget:self action:@selector(photoButtonDidBeCicked) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:photoBtn];
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - 40) / 2;
    [photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.size.mas_equalTo(CGSizeMake(width, width * 0.49));
        make.centerY.mas_equalTo(0);
    }];
    
    UIButton * fileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fileBtn setBackgroundImage:[UIImage imageNamed:@"wenjian"] forState:UIControlStateNormal];
    [fileBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [fileBtn addTarget:self action:@selector(fileButtonDidBeCicked) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:fileBtn];
    [fileBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(photoBtn.mas_right).offset(10);
        make.size.mas_equalTo(CGSizeMake(width, width * 0.49));
        make.centerY.mas_equalTo(0);
    }];
}

- (void)photoButtonDidBeCicked
{
    [RDPhotoTool checkUserLibraryAuthorizationStatusWithSuccess:^{
        
        PhotoLibraryViewController * photo = [[PhotoLibraryViewController alloc] init];
        [self.navigationController pushViewController:photo animated:YES];
        
    } failure:^(NSError *error) {
        [self openSetting];
    }];
}

//打开用户应用设置
- (void)openSetting
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"该功能需要开启相册权限，是否前往进行设置" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)fileButtonDidBeCicked
{
    DocumentListViewController * document = [[DocumentListViewController alloc] init];
    [self.navigationController pushViewController:document animated:YES];
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
