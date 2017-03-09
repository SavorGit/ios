//
//  DocumentListViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/8/15.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "DocumentListViewController.h"
#import "ScreenDocumentViewController.h"
#import "SXVideoPlayViewController.h"
#import "OpenFileTool.h"
#import "GCCUPnPManager.h"
#import "HomeAnimationView.h"
#import "PhotoTool.h"
#import "VideoGuidedTwoDimensionalCode.h"

#define DocumentListCell @"DocumentListCell"

@interface DocumentListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView; //表格视图展示控件
@property (nonatomic, strong) NSArray * dataSource; //数据源

@property (nonatomic, strong) UIView *guidView; // 引导页视图

@end

@implementation DocumentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = VCBackgroundColor;
    
    NSArray * array = [OpenFileTool getALLDocumentFileList];
    self.dataSource = [NSMutableArray arrayWithArray:array];
    
    [self createUI];
    
    if (self.dataSource.count == 0) {
        [self creatHelpGuide];
        if (self.isHelp) {
        }
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_bangzhu"] style:UIBarButtonItemStyleDone target:self action:@selector(creatHelpGuide)];
    
    //监听程序进入活跃状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)creatHelpGuide{
    
    VideoGuidedTwoDimensionalCode *vgVC = [[VideoGuidedTwoDimensionalCode alloc] init];
    [vgVC showScreenProjectionTitle:@"documentGuide" block:^(NSInteger selectIndex) {
        [self creatGuidTouchView];
    }];
}

- (void)creatGuidTouchView{
    
    self.guidView = [[UIView alloc] init];
    self.guidView.tag = 888;
    self.guidView.backgroundColor = [UIColor clearColor];
    self.guidView.userInteractionEnabled = YES;
    self.guidView.frame = CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight);
    [self.view addSubview:self.guidView];
    
    UILabel *topTextLabel = [[UILabel alloc] init ];
    topTextLabel.text = @"文件列表为空，请先导入文件";
    topTextLabel.textAlignment = NSTextAlignmentCenter;
    topTextLabel.font = [UIFont systemFontOfSize:15];
    topTextLabel.textColor = UIColorFromRGB(0x9a6f45);
    topTextLabel.backgroundColor = UIColorFromRGB(0xffebc3);
    topTextLabel.alpha = 0.95;
    [self.guidView addSubview:topTextLabel];
    [topTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.guidView).offset(0);
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 35));
        make.centerX.equalTo(self.view);
    }];
    
    UIImageView *bgVideoView = [[UIImageView alloc] init];
    bgVideoView.frame = CGRectMake(0, 145, kMainBoundsWidth,215);
    bgVideoView.image = [UIImage imageNamed:@"DocGuided"];
    bgVideoView.backgroundColor = [UIColor lightGrayColor];
    bgVideoView.userInteractionEnabled = YES;
    [self.guidView addSubview:bgVideoView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(creatHelpGuide)];
    tap.numberOfTapsRequired = 1;
    [bgVideoView addGestureRecognizer:tap];
    
    UILabel *textLabel = [[UILabel alloc] init ];
    textLabel.text = @"如何导入文件请查看视频";
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = [UIFont systemFontOfSize:16];
    textLabel.textColor = UIColorFromRGB(0x333333);
    textLabel.backgroundColor = [UIColor clearColor];
    [self.guidView addSubview:textLabel];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgVideoView).offset(230);
        make.size.mas_equalTo(CGSizeMake(200,30));
        make.centerX.equalTo(self.view);
    }];
}

- (void)navBackButtonClicked:(UIButton *)sender{
    
    // 返回时判断引导视图是否存在，存在则移除
    if (self.guidView) {
        [ self.guidView  removeFromSuperview];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

//程序进入活跃状态
- (void)applicationWillActive
{
    [self createDataSource];
    if (self.dataSource.count > 0) {
        UIView * view1 = [self.view viewWithTag:888];
        if (view1) {
            [view1 removeFromSuperview];
        }
        UIView * view2 = [[UIApplication sharedApplication].keyWindow viewWithTag:888];
        if (view2) {
            [view2 removeFromSuperview];
        }
        [self.tableView reloadData];
    }
}

//获取文件列表数据源
- (void)createDataSource
{
    NSArray * array = [OpenFileTool getALLDocumentFileList];
    self.dataSource = [NSMutableArray arrayWithArray:array];
}

- (void)createUI
{
    [self createDataSource];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - NavHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:DocumentListCell];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:DocumentListCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [[self.dataSource objectAtIndex:indexPath.row] lastPathComponent];
    cell.textLabel.font = [UIFont systemFontOfSize:FontSizeDefault];
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * currentPath = [self.dataSource objectAtIndex:indexPath.row];
    FileType type = [OpenFileTool getFileTypeWithPath:currentPath];
    if (type == FileTypeVideo){
        
        NSString * filePath = [VideoDocument stringByAppendingPathComponent:[self.dataSource objectAtIndex:indexPath.row]];
        
        NSURL *movieURL = [NSURL fileURLWithPath:filePath];
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:movieURL options:nil];  // 初始化视频媒体文件
        
        NSInteger totalTime = (NSInteger)urlAsset.duration.value / urlAsset.duration.timescale;
        
        NSString * videoUrl = [NSString stringWithFormat:@"video?%@", [filePath lastPathComponent]];
        NSString *asseturlStr = [NSString stringWithFormat:@"%@%@", [HTTPServerManager getCurrentHTTPServerIP], videoUrl];
        SXVideoPlayViewController * video = [[SXVideoPlayViewController alloc] init];
        video.videoUrl = videoUrl;
        video.totalTime = totalTime;
        video.title = [filePath lastPathComponent];
        if ([GlobalData shared].isBindRD) {
             [MBProgressHUD showCustomLoadingHUDInView:self.view];
            NSDictionary *parameters = @{@"function": @"prepare",
                                         @"action": @"2screen",
                                         @"assettype": @"video",
                                         @"asseturl": [asseturlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                         @"assetname": [filePath lastPathComponent],
                                         @"play": @"0"};
            [SAVORXAPI postWithURL:STBURL parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *result) {
                
                if ([[result objectForKey:@"result"] integerValue] == 0) {
                    
                    UIImage *firstImage = [[PhotoTool sharedInstance] imageWithVideoUrl:movieURL atTime:2];
                    [HomeAnimationView animationView].currentImage = firstImage;
                    [[HomeAnimationView animationView] startScreenWithViewController:video];
                    [self.navigationController pushViewController:video animated:YES];
                }else{
                    [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
                }
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [MBProgressHUD showTextHUDwithTitle:ScreenFailure];
            }];
        }else if ([GlobalData shared].isBindDLNA) {
             [MBProgressHUD showCustomLoadingHUDInView:self.view];
            [[GCCUPnPManager defaultManager] setAVTransportURL:[asseturlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] Success:^{
                UIImage *firstImage = [[PhotoTool sharedInstance] imageWithVideoUrl:movieURL atTime:2];
                [HomeAnimationView animationView].currentImage = firstImage;
                [[HomeAnimationView animationView] startScreenWithViewController:video];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.navigationController pushViewController:video animated:YES];
            } failure:^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [MBProgressHUD showTextHUDwithTitle:ScreenFailure];
            }];
        }else{
            [self.navigationController pushViewController:video animated:YES];
        }
        return;
        
    }
    
    ScreenDocumentViewController * doucment = [[ScreenDocumentViewController alloc] init];
    
    if (type == FileTypePDF) {
        doucment.path = [PDFDocument stringByAppendingPathComponent:[self.dataSource objectAtIndex:indexPath.row]];
    }else if (type == FileTypeDOC){
        doucment.path = [DOCDocument stringByAppendingPathComponent:[self.dataSource objectAtIndex:indexPath.row]];
    }else if (type == FileTypeEXCEL){
        doucment.path = [EXCELDocument stringByAppendingPathComponent:[self.dataSource objectAtIndex:indexPath.row]];
    }else if (type == FileTypePPT){
        doucment.path = [PPTDocument stringByAppendingPathComponent:[self.dataSource objectAtIndex:indexPath.row]];
    }else{
        [MBProgressHUD showTextHUDwithTitle:@"不支持的文件"];
        return;
    }
    doucment.title = [doucment.path lastPathComponent];
    
    if ([GlobalData shared].isBindRD || [GlobalData shared].isBindDLNA) {
        [[HomeAnimationView animationView] startScreenWithViewController:doucment];
        [SAVORXAPI successRing];
    }
    [self.navigationController pushViewController:doucment animated:YES];
}

//创建没有文件提示文案
- (void)createNothingView
{
    [self showNoDataViewInView:self.view noDataString:@"没有发现文件，请导入"];
}

//创建帮助提示控件
- (void)createHelpView
{
    NSArray * array = [NSArray new];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"test"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, -kMainBoundsHeight, kMainBoundsWidth, kMainBoundsHeight)];
    view.tag = 888;
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(removeFromSuperview)];
    tap.numberOfTapsRequired = 1;
    [view addGestureRecognizer:tap];
    
    UIImageView * topImageView = [[UIImageView alloc] init];
    topImageView.contentMode = UIViewContentModeScaleAspectFit;
    [topImageView setImage:[UIImage imageNamed:@"wenjianyindao"]];
    [view addSubview:topImageView];
    [topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [UIView animateWithDuration:.5f animations:^{
        view.frame = [UIScreen mainScreen].bounds;
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
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
