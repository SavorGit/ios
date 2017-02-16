//
//  SXDlnaViewController.m
//  SavorX
//
//  Created by lijiawei on 16/12/13.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "SXDlnaViewController.h"
#import "SXDlnaView.h"
#import "SXWiFiCell.h"
#import "SXWiFiHelpView.h"
#import "GCCDLNA.h"
#import "DeviceModel.h"
#import "UINavigationBar+PS.h"
#import "SXEmptyCell.h"


#define Max_OffsetY  50
#define WeakSelf(x)      __weak typeof (self) x = self
#define  Statur_HEIGHT   [[UIApplication sharedApplication] statusBarFrame].size.height
#define  NAVIBAR_HEIGHT  (self.navigationController.navigationBar.frame.size.height)

#define  INVALID_VIEW_HEIGHT (Statur_HEIGHT + NAVIBAR_HEIGHT)

@interface SXDlnaViewController ()<SXDlnaViewDelegate,SXWiFiCellDelegate,GCCDLNADelegate>{
     CGFloat _lastPosition;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) SXDlnaView * headBackView;
@property (nonatomic,strong) SXWiFiHelpView *footerView;


@property (nonatomic, strong) NSMutableArray * deviceSource;
@property (nonatomic, strong) GCCDLNA * DLNAManager;

@end

@implementation SXDlnaViewController

- (void)dealloc
{
    _headBackView = nil;
    _footerView = nil;
    self.DLNAManager.delegate = nil;
    self.DLNAManager = nil;
    [UIApplication sharedApplication].statusBarStyle = UISearchBarStyleDefault;
}


#pragma mark -懒加载-

- (UIView*)headBackView
{
    if (!_headBackView) {
        _headBackView = [SXDlnaView loadFromXib];
        _headBackView.userInteractionEnabled = YES;
        _headBackView.delegate = self;
        _headBackView.frame = CGRectMake(0, 0, kMainBoundsWidth,270);
    }
    return _headBackView;
}

-(UIView *)footerView{
    if(!_footerView){
        _footerView = [SXWiFiHelpView loadFromXib];
        _footerView.userInteractionEnabled = YES;
        _footerView.frame = CGRectMake(0, 0, kMainBoundsWidth,231);
    }
    return _footerView;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scrollViewDidScroll:self.tableView];

    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar ps_reset];
    [self.DLNAManager stopSearchDevice];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = VCBackgroundColor;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [[GCCDLNA defaultManager] stopSearchDevice];
    
    [self setupDatas];
    [self setupViews];
}

-(void)setupDatas{
    self.deviceSource = [[NSMutableArray alloc] init];
    self.DLNAManager = [[GCCDLNA alloc] init];
    self.DLNAManager.delegate = self;
    [self.DLNAManager startSearchDevice];
}

-(void)setupViews{
    self.automaticallyAdjustsScrollViewInsets = NO;
    //导航
    [self.navigationController.navigationBar ps_setBackgroundColor:[UIColor clearColor]];
    [self setNavBackArrow];
    
     self.tableView.tableHeaderView = self.headBackView;
     self.tableView.tableFooterView =  self.footerView;
    [self.headBackView startWiFiAnimation];
    NSInteger deviceCount = self.deviceSource.count;
    if(deviceCount == 0){
        self.headBackView.wifiCountLabel.text = @"正在检测设备";
    }else{
        self.headBackView.wifiCountLabel.text = [NSString stringWithFormat:@"已检测到%ld个设备",deviceCount];
    }
}

-(void)navBackButtonClicked:(UIButton *)sender{
    
    [self.headBackView stopWiFiAnimation];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

#pragma mark - GCCDLNADelegate
- (void)GCCDLNA:(GCCDLNA *)DLNA didGetDevice:(DeviceModel *)device
{
    [self.deviceSource addObject:device];
    NSInteger deviceCount = self.deviceSource.count;
    if(deviceCount == 0){
        self.headBackView.wifiCountLabel.text = @"正在检测设备";
    }else{
        self.headBackView.wifiCountLabel.text = [NSString stringWithFormat:@"已检测到%ld个设备",deviceCount];
    }
    [self.tableView reloadData];
}

- (void)GCCDLNADidEndSearchDevice:(GCCDLNA *)DLNA
{
    if(self.deviceSource.count == 0){
        self.headBackView.wifiCountLabel.text = @"没有检测到设备";
    }
    [self.headBackView stopWiFiAnimation];
}

//重新搜索设备
- (void)research
{
    //如果在搜索过程中可以重新扫描
    self.headBackView.wifiCountLabel.text = @"正在检测设备";
    [NSObject cancelPreviousPerformRequestsWithTarget:self.DLNAManager selector:@selector(stopSearchDevice) object:nil];
    [self.DLNAManager stopSearchDevice];
    
    [self.deviceSource removeAllObjects];
    [self.tableView reloadData];
    [self.DLNAManager startSearchDevice];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        SXEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:[SXEmptyCell cellIdentifier]];
        if(cell == nil){
            cell = [SXEmptyCell loadFromXib];
        }
        return cell;
    }else{
        SXWiFiCell * cell = [tableView dequeueReusableCellWithIdentifier:[SXWiFiCell cellIdentifier]];
        if(cell == nil){
            cell = [SXWiFiCell loadFromXib];
            cell.delegate = self;
        }
        
        DeviceModel * model = [self.deviceSource objectAtIndex:indexPath.row-1];
        cell.deviceModel = model;

        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceSource.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return 30;
    }
    return 44.f;
}


#pragma mark SXDlnaViewDelegate
//重新扫描
-(void)dlnaView:(SXDlnaView *)view{
    [view startWiFiAnimation];
    
    [self research];
}

#pragma mark SXWiFiCellDelegate
//连接电视
-(void)wifiCell:(SXWiFiCell *)cell didSelected:(BOOL)isSelected{
    [[GlobalData shared] bindToDLNADevice:cell.deviceModel];
    [self.tableView reloadData];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    self.headBackView.wifiBgView.frame = self.headBackView.bounds;
    CGFloat offset_Y = scrollView.contentOffset.y;
    //1.处理图片放大
    CGFloat imageH = self.headBackView.size.height;
    CGFloat imageW = kMainBoundsWidth;
    
    //下拉
    if (offset_Y < 0)
    {
        CGFloat totalOffset = imageH + ABS(offset_Y);
        CGFloat f = totalOffset / imageH;
        
        //如果想下拉固定头部视图不动，y和h 是要等比都设置。如不需要则y可为0
        self.headBackView.wifiBgView.frame = CGRectMake(-(imageW * f - imageW) * 0.5, offset_Y, imageW * f, totalOffset);
    }
    else
    {
        self.headBackView.wifiBgView.frame = self.headBackView.bounds;
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
