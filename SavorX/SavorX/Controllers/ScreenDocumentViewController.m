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
#import "PhotoTool.h"
#import "UIImage+Custom.h"
#import "GCCUPnPManager.h"
#import "HomeAnimationView.h"

@interface ScreenDocumentViewController ()<UIScrollViewDelegate,UIWebViewDelegate>

@property (nonatomic, strong) UIWebView * webView; //文件浏览控件
@property (nonatomic, strong) NSURLSessionDataTask * task; //记录当前最后一次请求任务
@property (nonatomic, strong) UIButton * lockButton;
@property (nonatomic, assign) CGPoint content;

@property (nonatomic, assign) BOOL isScreen;

@end

@implementation ScreenDocumentViewController

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
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    [self.view addSubview:self.webView];
//
    //为竖屏添加约束
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
//
//    //webView加载文档
    NSURL * url = [NSURL fileURLWithPath:self.path];
    self.webView.scalesPageToFit = YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.webView.scrollView.delegate = self;
//
    if ([GlobalData shared].isBindDLNA || [GlobalData shared].isBindRD) {
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"quit"] style:UIBarButtonItemStyleDone target:self action:@selector(stopScreenDocment)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出投屏" style:UIBarButtonItemStyleDone target:self action:@selector(stopScreenDocment)];
        self.isScreen = YES;
    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(screenDocment)];
        [SAVORXAPI showConnetToTVAlert];
        self.isScreen = NO;
    }
    
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
    self.isScreen = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出投屏" style:UIBarButtonItemStyleDone target:self action:@selector(stopScreenDocment)];
}

- (void)stopScreenDocment
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [SAVORXAPI ScreenDemandShouldBackToTVWithSuccess:^{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(screenDocment)];
        self.isScreen = NO;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [SAVORXAPI postUMHandleWithContentId:@"file_to_screen_exit" key:nil value:nil];
    } failure:^{
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
}

- (void)screenDocment
{
    [SAVORXAPI postUMHandleWithContentId:@"file_to_screen_details_play" key:nil value:nil];
    if (![GlobalData shared].isBindRD && ![GlobalData shared].isBindDLNA) {
        [[HomeAnimationView animationView] scanQRCode];
        return;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self screenButtonDidClickedWithSuccess:^{
        
        UIImage *currentWebImage =  [GCCScreenImage screenView:self.webView];
        [HomeAnimationView animationView].currentImage = currentWebImage;
        [[HomeAnimationView animationView] startScreenWithViewController:self];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出投屏" style:UIBarButtonItemStyleDone target:self action:@selector(stopScreenDocment)];
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self screenButtonDidClickedWithSuccess:nil failure:nil];
        });
    }else if (orientation == UIInterfaceOrientationLandscapeLeft ||
              orientation == UIInterfaceOrientationLandscapeRight){
        self.orientation = orientation;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController setHidesBarsOnTap:YES];
        [self.webView reload];
    }
    [SAVORXAPI postUMHandleWithContentId:@"file_to_screen_rotating" key:nil value:nil];
}

- (void)resetCurrentItemWithPath:(NSString *)path
{
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
    if (self.isScreen && !self.isScreen) {
        return;
    }
    
    for (UIView * view in self.webView.subviews) {
        if (view.subviews.count) {
            for (UIView * subView in view.subviews) {
                if ([NSStringFromClass(subView.class) isEqualToString:@"UIWebPDFLabelView"]) {
                    [subView removeFromSuperview];
                }
            }
        }
    }
    
    if (self.task) {
        [self.task cancel];
    }
    
    static NSInteger index = 0; //为保证缓存不影响文件投屏，需要给每次投屏一个标识
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
    UIImage * image = [screenImage ScalingToSize:size];
    NSString * keyStr = [NSString stringWithFormat:@"savorPhoto%ld.png", index++];
        if ([GlobalData shared].isBindRD) {
            [[PhotoTool sharedInstance] compressImageWithImage:image finished:^(NSData *minData, NSData *maxData) {
                [SAVORXAPI postImageWithURL:STBURL data:minData name:keyStr type:2 isThumbnail:YES rotation:0 success:^{
                    if (successBlock) {
                        successBlock();
                    }
                    [SAVORXAPI postImageWithURL:STBURL data:maxData name:keyStr type:2 isThumbnail:NO rotation:0 success:^{
                        
                    } failure:^{
                        
                    }];
                } failure:^{
                    if (failureBlock) {
                        failureBlock();
                    }
                }];
            }];
        }else if ([GlobalData shared].isBindDLNA) {
            [OpenFileTool writeImageToSysImageCacheWithImage:image andName:keyStr handle:^(NSString *keyStr) {
                NSString *asseturlStr = [NSString stringWithFormat:@"%@image?%@", [HTTPServerManager getCurrentHTTPServerIP],keyStr];
                [[GCCUPnPManager defaultManager] setAVTransportURL:asseturlStr Success:^{
                    if (successBlock) {
                        successBlock();
                    }
                } failure:^{
                    if (failureBlock) {
                        failureBlock();
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
    if (self.isScreen) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self screenButtonDidClickedWithSuccess:^{
            
                // 获得点击图片，回传给缩略图
                if (self.isScreen) {
                    UIImage *currentWebImage =  [GCCScreenImage screenView:self.webView];
                    [HomeAnimationView animationView].currentImage = currentWebImage;
                    [[HomeAnimationView animationView] startScreenWithViewController:self];
                    [SAVORXAPI postUMHandleWithContentId:@"file_to_screen_play" key:nil value:nil];
                }
                
            } failure:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
                
                [[HomeAnimationView animationView] stopScreen];
                
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(screenDocment)];
                self.isScreen = NO;
            }];
        });
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
    if (self.isScreen) {
        [self screenButtonDidClickedWithSuccess:^{
            
            [SAVORXAPI postUMHandleWithContentId:@"file_to_screen_play" key:nil value:nil];
            
        } failure:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(screenDocment)];
            self.isScreen = NO;
        }];
    }
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
    if (self.isScreen) {
        [self screenButtonDidClickedWithSuccess:nil failure:nil];
    }
    self.content = scrollView.contentOffset;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidBindDeviceNotification object:nil];
}

- (void)navBackButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [SAVORXAPI postUMHandleWithContentId:@"file_to_screen_back" key:nil value:nil];
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
