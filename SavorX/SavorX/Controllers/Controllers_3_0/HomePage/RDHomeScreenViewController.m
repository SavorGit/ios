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
#import "RDIsDemand.h"

@interface RDHomeScreenViewController ()<RDTabScrollViewDelegate>

@property (nonatomic, strong) RDTabScrollView * tabScroll;
@property (nonatomic, strong) UIView * bottomView;
@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, assign) NSInteger categoryID;
@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) RDHomeStatusView * statusView;

@property (nonatomic, strong) CreateWealthModel * demandModel;

@end

@implementation RDHomeScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.categoryID = -2;
    self.dataSource = [NSMutableArray new];
    [self setupViews];
    [self setupDatas];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [SAVORXAPI postUMHandleWithContentId:@"home_toscreen_state" key:nil value:nil];
    
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
        if (self.dataSource.count == 0) {
            [self showNoNetWorkViewInView:self.topView centerY:-80 style:NoNetWorkViewStyle_Load_Fail];
        }
        [self createUI];
        [loadingView hiddenLoaingAnimation];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [loadingView hiddenLoaingAnimation];
        [self showNoNetWorkViewInView:self.topView centerY:-80 style:NoNetWorkViewStyle_No_NetWork];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [loadingView hiddenLoaingAnimation];
        [self showNoNetWorkViewInView:self.topView centerY:-80 style:NoNetWorkViewStyle_Load_Fail];
    }];
}

- (void)retryToGetData
{
    [self hideNoNetWorkView];
    [self setupDatas];
}

- (void)createUI
{
    CGFloat width = kMainBoundsHeight > kMainBoundsWidth ? kMainBoundsWidth : kMainBoundsHeight;
    CGFloat height = (width - 40) * 0.646 + 20 + 59 + 40 + 40;
    self.tabScroll = [[RDTabScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height) modelArray:self.dataSource];
    self.tabScroll.delegate = self;
    [self.view addSubview:self.tabScroll];
    [self.tabScroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(height);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkDemandModel) name:RDDidBindDeviceNotification object:nil];
}

- (void)setupViews
{
    CGFloat mainWidth = kMainBoundsHeight > kMainBoundsWidth ? kMainBoundsWidth : kMainBoundsHeight;
    
    self.view.backgroundColor = UIColorFromRGB(0xece6de);
    
    CGFloat height = (mainWidth - 40) * 0.646 + 20 + 59 + 40 + 40;
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, kNaviBarHeight + kStatusBarHeight, mainWidth, height)];
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
    [SAVORXAPI postUMHandleWithContentId:@"home_local_tv" key:nil value:nil];
    WebViewController * web = [[WebViewController alloc] initWithModel:model categoryID:-2];
    [self.navigationController pushViewController:web animated:YES];
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_CLICK type:RDLOGTYPE_CONTENT model:model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
}

- (void)RDTabScrollViewTVButtonDidClickedWithModel:(CreateWealthModel *)model index:(NSInteger)index
{
    [SAVORXAPI postUMHandleWithContentId:@"home_click_bunch_video" key:nil value:nil];
    [SAVORXAPI postUMHandleWithContentId:@"home_advertising_video" key:nil value:nil];
    if ([GlobalData shared].isBindRD) {
        
        [self checkDemandWithModel:model];
        
    }else{
        self.demandModel = model;
        [[RDHomeStatusView defaultView] scanQRCode];
    }
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_CLICK type:RDLOGTYPE_CONTENT model:model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
}

- (void)RDTabScrollViewDidScrollToIndex:(NSInteger)index
{
    CreateWealthModel * model = [self.dataSource objectAtIndex:index];
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_SHOW type:RDLOGTYPE_CONTENT model:model categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
}

- (void)checkDemandWithModel:(CreateWealthModel *)model
{
    [self demandVideoWithModel:model force:0];
}

- (void)demandVideoWithModel:(CreateWealthModel *)model force:(NSInteger)force{
    
    RDInteractionLoadingView * hud = [[RDInteractionLoadingView alloc] initWithView:self.view title:RDLocalizedString(@"RDString_Demanding")];
    [SAVORXAPI demandWithURL:STBURL name:model.name type:1 position:0  force:force success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        self.demandModel = nil;
        if ([[result objectForKey:@"result"] integerValue] == 0) {
            
            DemandViewController *view = [[DemandViewController alloc] initWithModelSource:self.dataSource categroy:self.categoryID model:model];
            [SAVORXAPI successRing];
            [[RDHomeStatusView defaultView] startScreenWithViewController:view withStatus:RDHomeStatus_Demand];
            [self.navigationController pushViewController:view animated:YES];
            [SAVORXAPI postUMHandleWithContentId:@"home_click_bunch_video" key:nil value:nil];
        }else if ([[result objectForKey:@"result"] integerValue] == 4) {
            
            NSString *infoStr = [result objectForKey:@"info"];
            RDAlertView *alertView = [[RDAlertView alloc] initWithTitle:RDLocalizedString(@"RDString_AlertWithScreen") message:[NSString stringWithFormat:@"%@%@%@", RDLocalizedString(@"RDString_ScreenContinuePre"), infoStr, RDLocalizedString(@"RDString_ScreenContinueSuf")]];
            RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:RDLocalizedString(@"RDString_Cancle") handler:^{
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" withParmDic:@{@"to_screen_competition_hint" : @"cancel",@"type" : @"vod"} ];
            } bold:NO];
            RDAlertAction * actionOne = [[RDAlertAction alloc] initWithTitle:RDLocalizedString(@"RDString_ContinueScreen") handler:^{
                [self demandVideoWithModel:model force:1];
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" withParmDic:@{@"to_screen_competition_hint" : @"ensure",@"type" : @"vod"} ];
            } bold:YES];
            [alertView addActions:@[action,actionOne]];
            [alertView show];
            
        }else{
            [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
        }
        [hud hidden];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        self.demandModel = nil;
        [hud hidden];
        [MBProgressHUD showTextHUDwithTitle:DemandFailure];
    }];
}

- (void)photoButtonDidBeCicked
{
    [SAVORXAPI postUMHandleWithContentId:@"home_album_toscreen" key:nil value:nil];
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
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:RDLocalizedString(@"RDString_Alert") message:RDLocalizedString(@"RDString_PhotoLibrarySetting") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:RDLocalizedString(@"RDString_Cancle") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:RDLocalizedString(@"RDString_GoToSetting") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)fileButtonDidBeCicked
{
    [SAVORXAPI postUMHandleWithContentId:@"home_file_toscreen" key:nil value:nil];
    DocumentListViewController * document = [[DocumentListViewController alloc] init];
    [self.navigationController pushViewController:document animated:YES];
}

- (void)checkDemandModel
{
    if (self.demandModel) {
        
        if ([GlobalData shared].isBindRD) {
            [self checkDemandWithModel:self.demandModel];
        }
        
    }else{
        
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidBindDeviceNotification object:nil];
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
