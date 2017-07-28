//
//  DocumentListViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/8/15.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "DocumentListViewController.h"
#import "ScreenDocumentViewController.h"
#import "FileVideoViewController.h"
#import "OpenFileTool.h"
#import "GCCUPnPManager.h"
#import "VideoGuidedTwoDimensionalCode.h"
#import "HelpViewController.h"
#import "RDAlertView.h"
#import "RDAlertAction.h"
#import "RDHomeStatusView.h"
#import "RDInteractionLoadingView.h"

#define DocumentListCell @"DocumentListCell"

@interface DocumentListViewController ()<UITableViewDelegate, UITableViewDataSource,UIWebViewDelegate>

@property (nonatomic, strong) UITableView * tableView; //表格视图展示控件
@property (nonatomic, strong) NSArray * dataSource; //数据源
@property (nonatomic, strong) UIView *guidView; // 引导页视图
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) NSString *urlString;

@end

@implementation DocumentListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = VCBackgroundColor;
    self.title = @"我的文件";
    NSArray * array = [OpenFileTool getALLDocumentFileList];
    self.dataSource = [NSMutableArray arrayWithArray:array];
    self.urlString = @"http://h5.littlehotspot.com/Public/html/help3/wenjian_ios.html";
    
    [self createUI];
    
    
    if (self.dataSource.count == 0) {
        
       [self creatGuidTouchView];
       [self creatHelpWebView];

    }else{
       self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bangzhu"] style:UIBarButtonItemStyleDone target:self action:@selector(shouldPushHelp)];
    }
    
    //监听程序进入活跃状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    
    if (self.dataSource.count != 0) {
        if (self.webView) {
            [self.webView removeFromSuperview];
        }
    }
    
    [SAVORXAPI postUMHandleWithContentId:@"file_to_screen_list" key:nil value:nil];
}

- (void)creatHelpWebView
{
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    self.webView.backgroundColor = VCBackgroundColor;
    self.webView.opaque = NO;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    [self.webView loadRequest:request];
}

- (void)shouldPushHelp
{
    HelpViewController * help = [[HelpViewController alloc] initWithURL:self.urlString];
    help.title = @"文件投屏步骤";
    [self.navigationController  pushViewController:help  animated:NO];
}

- (void)creatGuidTouchView{
    
    self.guidView = [[UIView alloc] init];
    self.guidView.tag = 1888;
    self.guidView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.guidView.userInteractionEnabled = YES;
    self.guidView.frame = CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight);
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.guidView.bottom = keyWindow.top;
    [keyWindow addSubview:self.guidView];
    
    [self showViewWithAnimationDuration:.3f];
    
    UIImageView *bgVideoView = [[UIImageView alloc] init];
    float bgVideoHeight = [Helper autoHeightWith:265];
    float bgVideoWidth = [Helper autoWidthWith:266];
    bgVideoView.frame = CGRectZero;
    bgVideoView.image = [UIImage imageNamed:@"wj_kong"];
    bgVideoView.backgroundColor = [UIColor whiteColor];
    bgVideoView.userInteractionEnabled = YES;
    [self.guidView addSubview:bgVideoView];
    [bgVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(bgVideoWidth,bgVideoHeight));
        make.center.mas_equalTo(self.guidView);
    }];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = [UIColor whiteColor];
    [self.guidView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(1,kMainBoundsHeight/2));
        make.bottom.mas_equalTo(bgVideoView.mas_top);
        make.centerX.equalTo(self.guidView);
    }];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(guidPress)];
    tap.numberOfTapsRequired = 1;
    [self.guidView addGestureRecognizer:tap];
    
}

- (void)guidPress{
    
    [self dismissViewWithAnimationDuration:.3f];
    [self.toolbar removeFromSuperview];

}

#pragma mark - show view
-(void)showViewWithAnimationDuration:(float)duration{
    
    [UIView animateWithDuration:duration animations:^{
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        self.guidView.bottom = keyWindow.bottom;
    } completion:^(BOOL finished) {
    }];
}

-(void)dismissViewWithAnimationDuration:(float)duration{
    
    [UIView animateWithDuration:duration animations:^{
        
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        self.guidView.bottom = keyWindow.top;
        
    } completion:^(BOOL finished) {
        
        [self.guidView removeFromSuperview];
        
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
        UIView * view1 = [self.view viewWithTag:1888];
        if (view1) {
            [view1 removeFromSuperview];
        }
        UIView * view2 = [[UIApplication sharedApplication].keyWindow viewWithTag:1888];
        if (view2) {
            [view2 removeFromSuperview];
        }
        if (self.dataSource.count != 0) {
            if (self.webView) {
                [self.webView removeFromSuperview];
            }
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
    self.tableView.backgroundColor = VCBackgroundColor;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.layoutMargins = UIEdgeInsetsZero;
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
    return 68.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:DocumentListCell];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:DocumentListCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSString * path = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = [path lastPathComponent];
    cell.textLabel.font = [UIFont systemFontOfSize:FontSizeDefault];
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    cell.backgroundColor = UIColorFromRGB(0xf6f2ed);
    
    if ([path hasSuffix:@"pdf"]) {
        [cell.imageView setImage:[UIImage imageNamed:@"wj_pdf"]];
    }else if ([path hasSuffix:@"doc"] || [path hasSuffix:@"docx"]) {
        [cell.imageView setImage:[UIImage imageNamed:@"wj_doc"]];
    }else if ([path hasSuffix:@"xls"] || [path hasSuffix:@"xlsx"]) {
        [cell.imageView setImage:[UIImage imageNamed:@"wj_xls"]];
    }else if ([path hasSuffix:@"ppt"] || [path hasSuffix:@"pptx"]) {
        [cell.imageView setImage:[UIImage imageNamed:@"wj_ppt"]];
    }else if ([path hasSuffix:@"mp4"]) {
        [cell.imageView setImage:[UIImage imageNamed:@"mp4"]];
    }
    
    UIImageView *rightImg = [[UIImageView alloc] init];
    [rightImg setImage:[UIImage imageNamed:@"xiangce_more"]];
    [cell addSubview:rightImg];
    [rightImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(8, 14));
        make.top.mas_equalTo(27);
        make.right.mas_equalTo(- 15);
    }];
    
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
        FileVideoViewController * video = [[FileVideoViewController alloc] initWithVideoFileURL:videoUrl totalTime:totalTime];
        video.title = [filePath lastPathComponent];
        if ([GlobalData shared].isBindRD) {
             RDInteractionLoadingView * hud = [[RDInteractionLoadingView alloc] initWithView:self.view title:@"正在投屏"];
            hud.tag = 1010;
            
            [self demandVideoWithMediaPath:[asseturlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] force:0 video:video movieUrl:movieURL];
            
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
    
    if ([GlobalData shared].isBindRD) {
        [SAVORXAPI successRing];
    }
    [self.navigationController pushViewController:doucment animated:YES];
}

- (void)demandVideoWithMediaPath:(NSString *)mediaPath force:(NSInteger)force video:(FileVideoViewController *)video movieUrl:(NSURL *)movieURL{
    
    [SAVORXAPI postVideoWithURL:STBURL mediaPath:mediaPath position:@"0" force:force success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        if ([[result objectForKey:@"result"] integerValue] == 0) {
            [[RDHomeStatusView defaultView] startScreenWithViewController:video withStatus:RDHomeStatus_Video];
            [self.navigationController pushViewController:video animated:YES];
        }else if ([[result objectForKey:@"result"] integerValue] == 4) {
            
            NSString *infoStr = [result objectForKey:@"info"];
            RDAlertView *alertView = [[RDAlertView alloc] initWithTitle:@"抢投提示" message:[NSString stringWithFormat:@"当前%@正在投屏，是否继续投屏?",infoStr]];
            RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"取消" handler:^{
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" withParmDic:@{@"to_screen_competition_hint" : @"cancel",@"type" : @"file"}];
            } bold:NO];
            RDAlertAction * actionOne = [[RDAlertAction alloc] initWithTitle:@"继续投屏" handler:^{
                [self demandVideoWithMediaPath:mediaPath force:1 video:video movieUrl:movieURL];
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" withParmDic:@{@"to_screen_competition_hint" : @"ensure",@"type" : @"file"} ];
            } bold:YES];
            [alertView addActions:@[action,actionOne]];
            [alertView show];
            
        }
        else{
            [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
        }
        
        if ([self.view viewWithTag:1010]) {
            RDInteractionLoadingView * view = (RDInteractionLoadingView *)[self.view viewWithTag:1010];
            [view hidden];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if ([self.view viewWithTag:1010]) {
            RDInteractionLoadingView * view = (RDInteractionLoadingView *)[self.view viewWithTag:1010];
            [view hidden];
        }
        
        [MBProgressHUD showTextHUDwithTitle:ScreenFailure];
    }];
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

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hiddenWebLoadingInView:self.webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hiddenWebLoadingInView:self.webView];
    NSLog(@"error%@",error);
    if ([error code] == NSURLErrorCancelled) {
        return;
    }
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
