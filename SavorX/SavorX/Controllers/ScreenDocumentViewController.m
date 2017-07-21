//
//  ScreenDocumentViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/8/4.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "ScreenDocumentViewController.h"
#import "GCCScreenImage.h"
#import "OpenFileTool.h"
#import "RDPhotoTool.h"
#import "UIImage+Custom.h"
#import "GCCUPnPManager.h"
#import "RDAlertView.h"
#import "RDAlertAction.h"

#import "RDHomeStatusView.h"

@interface ScreenDocumentViewController ()<UIScrollViewDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIWebView * webView; //文件浏览控件
@property (nonatomic, strong) NSURLSessionDataTask * task; //记录当前最后一次请求任务
@property (nonatomic, strong) UIButton * lockButton;
@property (nonatomic, assign) CGPoint content;
@property (nonatomic, copy)   NSString * seriesId;
@property (nonatomic, assign) BOOL isScreen;
@property (nonatomic, assign) float currentContentH;

@end

@implementation ScreenDocumentViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.seriesId = [Helper getTimeStamp];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [OpenFileTool deleteFileSubPath:SystemImage];
    [self createUI];
}

- (void)createUI
{
    self.orientation = [UIApplication sharedApplication].statusBarOrientation;
    self.view.backgroundColor = VCBackgroundColor;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(PageBack)];
    self.navigationItem.leftBarButtonItem.imageInsets = UIEdgeInsetsMake(2, -8, -2, 8);
    self.edgesForExtendedLayout = UIRectEdgeNone;
//    
    //初始化webView
    self.webView = [[UIWebView alloc] init];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    [self.view addSubview:self.webView];

    //为竖屏添加约束
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);  
    }];
    
//    //webView加载文档
    NSURL * url = [NSURL fileURLWithPath:self.path];
    self.webView.scalesPageToFit = YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.webView.scrollView.delegate = self;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(screenDocment)];
    self.isScreen = NO;
    
//    if (![GlobalData shared].isBindRD) {
//        [SAVORXAPI showConnetToTVAlert:@"doc"];
//    }
//    if ([GlobalData shared].isBindRD) {
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出投屏" style:UIBarButtonItemStyleDone target:self action:@selector(stopScreenDocment:)];
//        self.isScreen = YES;
//    }else{
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(screenDocment)];
//        [SAVORXAPI showConnetToTVAlert:@"doc"];
//        self.isScreen = NO;
//    }
    
    self.lockButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.lockButton setBackgroundImage:[UIImage imageNamed:@"suoping"] forState:UIControlStateNormal];
    [self.lockButton setBackgroundImage:[UIImage imageNamed:@"yisuoping"] forState:UIControlStateSelected];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lockButtonDidClicked)];
    tap.numberOfTapsRequired = 1;
    [self.lockButton addGestureRecognizer:tap];
    [self.view addSubview:self.lockButton];
    [self.lockButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(45, 45));
        make.top.mas_equalTo(18);
        make.right.mas_equalTo(-15);
    }];

    [self.navigationController.barHideOnTapGestureRecognizer requireGestureRecognizerToFail:tap];
    //监听用户手机屏幕方向变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ApplicationDidBindToDevice) name:RDDidBindDeviceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidQiutWithBox) name:RDBoxQuitScreenNotification object:nil];
}

- (void)screenDidQiutWithBox
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(screenDocment)];
    self.seriesId = [Helper getTimeStamp];
    self.isScreen = NO;
}

- (void)lockButtonDidClicked
{
    if (self.lockButton.selected) {
        self.isLockScreen = NO;
    }else{
        [SAVORXAPI postUMHandleWithContentId:@"file_to_screen_lock" key:nil value:nil];
        self.isLockScreen = YES;
    }
    self.lockButton.selected = !self.lockButton.selected;
}

- (void)ApplicationDidBindToDevice
{
    self.isScreen = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(screenDocment)];
}

- (void)stopScreenDocment:(BOOL)fromHomeType
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [SAVORXAPI ScreenDemandShouldBackToTVWithSuccess:^{
        [self stop];
        [SAVORXAPI postUMHandleWithContentId:@"file_to_screen_exit" key:nil value:nil];
        if (fromHomeType == YES) {
            [SAVORXAPI postUMHandleWithContentId:@"home_quick_back" key:@"home_quick_back" value:@"success"];
        }
    } failure:^{
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if (fromHomeType == YES) {
            [SAVORXAPI postUMHandleWithContentId:@"home_quick_back" key:@"home_quick_back" value:@"fail"];
        }
    }];
}

- (void)stop
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(screenDocment)];
    self.seriesId = [Helper getTimeStamp];
    self.isScreen = NO;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)screenDocment
{
    [SAVORXAPI postUMHandleWithContentId:@"file_to_screen_details_play" key:nil value:nil];
    if (![GlobalData shared].isBindRD) {
        [[RDHomeStatusView defaultView] scanQRCode];
        return;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self screenButtonDidClickedWithSuccess:^{
        
        [[RDHomeStatusView defaultView] startScreenWithViewController:self withStatus:RDHomeStatus_File];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出投屏" style:UIBarButtonItemStyleDone target:self action:@selector(stopScreenDocment:)];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.isScreen = YES;
    } failure:^{
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
}

- (void)orientationChanged
{
    UIInterfaceOrientation  orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait) {
        self.orientation = orientation;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController setHidesBarsOnTap:NO];
        if (self.isScreen) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self screenButtonDidClickedWithSuccess:nil failure:nil];
            });
        }
        CGRect rect = self.navigationController.navigationBar.frame;
        if (rect.size.height < 44) {
            rect.size.height = 44.f;
            [self.navigationController.navigationBar setFrame:rect];
        }
    }else if (orientation == UIInterfaceOrientationLandscapeLeft ||
              orientation == UIInterfaceOrientationLandscapeRight){
        self.orientation = orientation;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController setHidesBarsOnTap:YES];
        [self.webView reload];
        if (self.isScreen) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self screenButtonDidClickedWithSuccess:nil failure:nil];
            });
        }
    }
    [SAVORXAPI postUMHandleWithContentId:@"file_to_screen_rotating" key:nil value:nil];
}

- (void)resetCurrentItemWithPath:(NSString *)path
{
    self.seriesId = [Helper getTimeStamp];
    
    self.path = path;
    //webView加载文档
    NSURL * url = [NSURL fileURLWithPath:self.path];
    self.webView.scalesPageToFit = YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.title = [path lastPathComponent];
    [OpenFileTool deleteFileSubPath:SystemImage];
}

- (void)screenButtonDidClickedWithSuccess:(void (^)())successBlock failure:(void (^)())failureBlock
{
    for (UIView * view in self.webView.subviews) {
        if (view.subviews.count) {
            for (UIView * subView in view.subviews) {
                if ([NSStringFromClass(subView.class) isEqualToString:@"UIWebPDFLabelView"]) {
                    [subView removeFromSuperview];
                }
            }
        }
    }
    
    UIImage * screenImage = [GCCScreenImage screenView:self.webView]; //获取截屏
    
    //机顶盒输出尺寸为你1920*1080，为保证全屏显示对尺寸进行对应调整
    CGSize size;
    CGFloat scale = screenImage.size.width / screenImage.size.height;
    CGFloat tempScale = 1920 / 1080.f;
    if (scale > tempScale) {
        size = CGSizeMake(1920, 1920 / scale);
    }else{
        size = CGSizeMake(1080 * scale, 1080);
    }
    
    if (self.task) {
        [self.task cancel];
    }
    
    UIImage * image = [screenImage ScalingToSize:size];
    NSString * keyStr = [NSString stringWithFormat:@"savorPhoto%@.png", [Helper getTimeStamp]];
        if ([GlobalData shared].isBindRD) {
            [RDPhotoTool compressImageWithImage:image finished:^(NSData *minData, NSData *maxData) {
                
                [self.task cancel];
                
                self.task = [SAVORXAPI postFileImageWithURL:STBURL data:minData name:keyStr type:2 isThumbnail:YES rotation:0 seriesId:self.seriesId force:0 success:^(NSURLSessionDataTask *task, id responseObject) {
                    if (successBlock) {
                        successBlock();
                        if (_isScreen == NO) {
                            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出投屏" style:UIBarButtonItemStyleDone target:self action:@selector(stopScreenDocment:)];
                            self.isScreen = YES;
                        }
                    }
                    self.task = [SAVORXAPI postFileImageWithURL:STBURL data:maxData name:keyStr type:2 isThumbnail:NO rotation:0 seriesId:self.seriesId force:0 success:^(NSURLSessionDataTask *task, id responseObject) {
                        
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        
                    }];
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    
                    if (failureBlock) {
                        failureBlock();
                    }
                    if ([error.domain isEqualToString:@"cancleFileScreen"]) {
                        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(screenDocment)];
                        self.isScreen = NO;
                    }
                    if ([error.domain isEqualToString:@"fileScreen"]) {
                        RDAlertView * alert = [[RDAlertView alloc] initWithTitle:@"提示" message:error.localizedDescription];
                        RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"我知道了" handler:^{
                            
                        } bold:YES];
                        [alert addActions:@[action]];
                        [alert show];
                        [self stop];
                    }else{
                        if (error.code != -999) {
                            [MBProgressHUD showTextHUDwithTitle:ScreenFailure];
                        }else{
                            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(screenDocment)];
                            self.isScreen = NO;
                        }
                    }
                }];
            }];
        }else{
            if (failureBlock) {
                failureBlock();
            }
        }
}

- (void)PageBack
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 屏幕转屏相关

/**
 *  强制屏幕转屏
 *
 *  @param orientation 屏幕方向
 */
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    // arc下
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setHidesBarsOnTap:NO];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    if ([GlobalData shared].isBindRD) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self screenButtonDidClickedWithSuccess:^{
            
                // 获得点击图片，回传给缩略图
                if (self.isScreen) {
                    [[RDHomeStatusView defaultView] startScreenWithViewController:self withStatus:RDHomeStatus_File];
                    [SAVORXAPI postUMHandleWithContentId:@"file_to_screen_play" key:nil value:nil];
                }
                
            } failure:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
                
                [[RDHomeStatusView defaultView] stopScreen];
            }];
        });
    }else{
        [SAVORXAPI showConnetToTVAlert:@"doc"];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL * requestURL = [request URL];
    if ([[requestURL scheme] isEqualToString: @"http"] || [[requestURL scheme] isEqualToString:@"https"]) {
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.webView.scrollView setContentOffset:self.content animated:NO];
    _currentContentH = self.webView.scrollView.contentSize.height;
}

//浏览滑动停止的时候
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.isScreen) {
        [self screenButtonDidClickedWithSuccess:nil failure:nil];
    }
    self.content = scrollView.contentOffset;
}

//浏览手动停止的时候
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [SAVORXAPI postUMHandleWithContentId:@"file_to_screen_drag" key:nil value:nil];
    if (!decelerate) {
        if (self.isScreen) {
            [self screenButtonDidClickedWithSuccess:nil failure:nil];
        }
    }
    self.content = scrollView.contentOffset;
}

//浏览缩放停止的时候
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (scrollView.contentSize.height < _currentContentH) {
        NSLog(@"suoxiao");
        [SAVORXAPI postUMHandleWithContentId:@"file_to_screen_shrink" key:nil value:nil];
    }else if (scrollView.contentSize.height > _currentContentH){
        NSLog(@"zengda");
        [SAVORXAPI postUMHandleWithContentId:@"file_to_screen_blow_up" key:nil value:nil];
    }
    
    _currentContentH = scrollView.contentSize.height;
    if (self.isScreen) {
        [self screenButtonDidClickedWithSuccess:nil failure:nil];
    }
    self.content = scrollView.contentOffset;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidBindDeviceNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDBoxQuitScreenNotification object:nil];
}

- (void)navBackButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [SAVORXAPI postUMHandleWithContentId:@"file_to_screen_back" key:nil value:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    NSLog(@"zheshi shoushi");
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight) {
        return YES;
    }
    return NO;
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
