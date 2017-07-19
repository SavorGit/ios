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
#import "CreateWealthModel.h"
#import "RDHomeStatusView.h"
#import "DemandViewController.h"
#import "WebViewController.h"
#import "RDLogStatisticsAPI.h"
#import "RDAlertView.h"
#import "RDLogStatisticsAPI.h"
#import "RDInteractionLoadingView.h"

@interface RDHomeScreenViewController ()<RDTabScrollViewDelegate>

@property (nonatomic, strong) RDTabScrollView * tabScroll;
@property (nonatomic, strong) UIView * bottomView;
@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, assign) NSInteger categoryID;
@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) RDHomeStatusView * statusView;

@end

@implementation RDHomeScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.categoryID = -2;
    self.dataSource = [NSMutableArray new];
    [self setupViews];
    [self setupDatas];
}

- (void)setupDatas
{
    RDLoadingView * loadingView = [MBProgressHUD showWebLoadingHUDInView:self.topView];
    
    HSDemandListRequest * request = [[HSDemandListRequest alloc] initWithHotelID:[GlobalData shared].hotelId];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSArray * listArray = [response objectForKey:@"result"];
        if (listArray) {
            
            for (NSDictionary * dict in listArray) {
                CreateWealthModel * model = [[CreateWealthModel alloc] initWithDictionary:dict];
                [self.dataSource addObject:model];
            }
            
        }
        [self createUI];
        [loadingView hiddenLoaingAnimation];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [loadingView hiddenLoaingAnimation];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [loadingView hiddenLoaingAnimation];
    }];
}

- (void)createUI
{
    CGFloat height = (kMainBoundsWidth - 40) * 0.646 + 20 + 59 + 40 + 40;
    self.tabScroll = [[RDTabScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height) modelArray:self.dataSource];
    self.tabScroll.delegate = self;
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
    self.view.backgroundColor = UIColorFromRGB(0xece6de);
    
    CGFloat height = (kMainBoundsWidth - 40) * 0.646 + 20 + 59 + 40 + 40;
    
    self.topView = [[UIView alloc] init];
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.height.mas_equalTo(height);
        make.right.mas_equalTo(0);
    }];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = UIColorFromRGB(0xf1efeb);
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(height);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    [self.bottomView addSubview:[RDHomeStatusView defaultView]];
    
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

- (void)RDTabScrollViewPhotoButtonDidClickedWithModel:(CreateWealthModel *)model index:(NSInteger)index
{
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_CLICK type:RDLOGTYPE_CONTENT model:model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
    WebViewController * web = [[WebViewController alloc] initWithModel:model categoryID:0];
    [self.navigationController pushViewController:web animated:YES];
}

- (void)RDTabScrollViewTVButtonDidClickedWithModel:(CreateWealthModel *)model index:(NSInteger)index
{
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_CLICK type:RDLOGTYPE_CONTENT model:model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
    if ([GlobalData shared].isBindRD) {
        [self demandVideoWithModel:model force:0];
    }else{
        [[RDHomeStatusView defaultView] scanQRCode];
    }
}

- (void)RDTabScrollViewDidScrollToIndex:(NSInteger)index
{
    CreateWealthModel * model = [self.dataSource objectAtIndex:index];
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_SHOW type:RDLOGTYPE_CONTENT model:model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
}

- (void)demandVideoWithModel:(CreateWealthModel *)model force:(NSInteger)force{
    
    RDInteractionLoadingView * hud = [[RDInteractionLoadingView alloc] initWithView:self.view title:@"正在点播"];
    [SAVORXAPI demandWithURL:STBURL name:model.name type:1 position:0  force:force success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        if ([[result objectForKey:@"result"] integerValue] == 0) {
            
            DemandViewController *view = [[DemandViewController alloc] init];
            view.model = model;
            view.categroyID = self.categoryID;
            [SAVORXAPI successRing];
            [self.navigationController pushViewController:view animated:YES];
            [SAVORXAPI postUMHandleWithContentId:@"home_click_bunch_video" key:nil value:nil];
        }else if ([[result objectForKey:@"result"] integerValue] == 4) {
            
            NSString *infoStr = [result objectForKey:@"info"];
            RDAlertView *alertView = [[RDAlertView alloc] initWithTitle:@"抢投提示" message:[NSString stringWithFormat:@"当前%@正在投屏，是否继续投屏?",infoStr]];
            RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"取消" handler:^{
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" withParmDic:@{@"to_screen_competition_hint" : @"cancel",@"type" : @"vod"} ];
            } bold:NO];
            RDAlertAction * actionOne = [[RDAlertAction alloc] initWithTitle:@"继续投屏" handler:^{
                [self demandVideoWithModel:model force:1];
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" withParmDic:@{@"to_screen_competition_hint" : @"ensure",@"type" : @"vod"} ];
            } bold:NO];
            [alertView addActions:@[action,actionOne]];
            [alertView show];
            
        }else{
            [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
        }
        [hud hidden];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [hud hidden];
        [MBProgressHUD showTextHUDwithTitle:DemandFailure];
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
