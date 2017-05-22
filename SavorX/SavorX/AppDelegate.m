//
//  AppDelegate.m
//  SavorX
//
//  Created by 郭春城 on 16/7/19.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "AppDelegate.h"
#import "OpenFileTool.h"

#import <UMSocialCore/UMSocialCore.h>
#import "UMessage.h"
#import <UserNotifications/UserNotifications.h>

#import "GCCDLNA.h"
#import "SplashViewController.h"
#import "OpenInstallSDK.h"

#import "LGSideMenuController.h"
#import "BaseNavigationController.h"
#import "LeftViewController.h"
#import "WMPageController.h"
#import "HomeAnimationView.h"
#import "VideoLauchMovieViewController.h"
#import "HSLauchImageOrVideoRequest.h"
#import "DefalutLaunchViewController.h"
#import "RDLogStatisticsAPI.h"
#import "HotTopicViewController.h"
#import "RecommendViewController.h"
#import "CategoryViewController.h"
#import "HSInstallationInforUpload.h"

@interface AppDelegate ()<UITabBarControllerDelegate, UNUserNotificationCenterDelegate,SplashViewControllerDelegate, WMPageControllerDelegate >

@property (nonatomic, assign) BOOL is3D_Touch;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    //初始化应用window窗口
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    //设置lauch页面
    [self createLaunch];
    
    //配置APP相关信息
    [SAVORXAPI configApplication];
    
    //请求启动效果，图片或者视频
    [self requestGetLauchImageOrVideo];
    
    //处理启动时候的相关事务
    [self handleLaunchWorkWithOptions:launchOptions];
    
    return YES;
}

//处理启动时候的相关事务
- (void)handleLaunchWorkWithOptions:(NSDictionary *)launchOptions
{
    //友盟推送
    [UMessage startWithAppkey:UmengAppkey launchOptions:launchOptions];
    [UMessage setAutoAlert:NO];
    [UMessage registerForRemoteNotifications];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate=self;
        UNAuthorizationOptions types10 = UNAuthorizationOptionBadge|	UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
        [center requestAuthorizationWithOptions:types10 completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //点击允许
                //这里可以添加一些自己的逻辑
            } else {
                //点击不允许
                //这里可以添加一些自己的逻辑
            }
        }];
    }
    
    //初始化OpenInstall
    [OpenInstallSDK setAppKey:@"w7gvub" withDelegate:self];
    
    NSString *isupLoad = [UserDefault objectForKey:@"isUpLoad"];
    // 上传标识不为空且不为isSuccess字段时，调用接口上传
    if (![isupLoad isEqualToString:@"isSuccess"] && !isEmptyString(isupLoad)) {
        NSString *hotelid = [UserDefault objectForKey:@"hotelid"];
        NSString *waiterid = [UserDefault objectForKey:@"waiterid"];
        NSString *st = [UserDefault objectForKey:@"st"];
        [self requestUploadInstallationInfor:hotelid waiterid:waiterid andSt:st failure:^{
            [self requestUploadInstallationInfor:hotelid waiterid:waiterid andSt:st failure:^{
                [self requestUploadInstallationInfor:hotelid waiterid:waiterid andSt:st failure:^{
                }];
            }];
        }];
    }
}

#pragma mark OpenInstall
//通过OpenInstall 获取自定义参数。
- (void)getInstallParamsFromOpenInstall:(NSDictionary *)params withError: (NSError *)error {
    if (!error) {
        if (params) {
            NSDictionary *tmpDic = params;
            NSString *hotelid = isEmptyString(tmpDic[@"hotelid"])?@"":tmpDic[@"hotelid"];
            NSString *waiterid = isEmptyString(tmpDic[@"waiterid"])?@"":tmpDic[@"waiterid"];
            NSString *st = isEmptyString(tmpDic[@"st"])?@"":tmpDic[@"st"];
            
            // 若不成功继续上传，最多上传三次
            [self requestUploadInstallationInfor:hotelid waiterid:waiterid andSt:st failure:^{
                [self requestUploadInstallationInfor:hotelid waiterid:waiterid andSt:st failure:^{
                    [self requestUploadInstallationInfor:hotelid waiterid:waiterid andSt:st failure:^{
                    }];
                }];
            }];
        }
        
    } else {
        NSLog(@"OpenInstall error %@", error);
    }
}

// 上传安装信息到服务器
- (void)requestUploadInstallationInfor:(NSString *)hotelid waiterid:(NSString *)waiterid andSt:(NSString *)st failure:(void(^)())failure{
    
    HSInstallationInforUpload *request = [[HSInstallationInforUpload alloc] initWithHotelId:hotelid waiterId:waiterid andSt:st];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        NSInteger code = [response[@"code"] integerValue];
        if (code == 10000) {
            if ([UserDefault objectForKey:@"hotelid"]) {
                [UserDefault removeObjectForKey:@"hotelid"];
            }
            if ([UserDefault objectForKey:@"waiterid"]) {
                [UserDefault removeObjectForKey:@"waiterid"];
            }
            if ([UserDefault objectForKey:@"st"]) {
                [UserDefault removeObjectForKey:@"st"];
            }
            if ([UserDefault objectForKey:@"isUpLoad"]) {
                [UserDefault removeObjectForKey:@"isUpLoad"];
            }
            
            [UserDefault setObject:@"isSuccess" forKey:@"isUpLoad"];
            [UserDefault synchronize];
            
        }else{
            if (![[UserDefault objectForKey:@"isUpLoad"] isEqualToString:@"noSuccess"]) {
                [UserDefault setObject:@"noSuccess" forKey:@"isUpLoad"];
                [UserDefault setObject:hotelid forKey:@"hotelid"];
                [UserDefault setObject:waiterid forKey:@"waiterid"];
                [UserDefault setObject:st forKey:@"st"];
                [UserDefault synchronize];
            }
            failure();
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (![[UserDefault objectForKey:@"isUpLoad"] isEqualToString:@"noSuccess"]) {
            [UserDefault setObject:@"noSuccess" forKey:@"isUpLoad"];
            [UserDefault setObject:hotelid forKey:@"hotelid"];
            [UserDefault setObject:waiterid forKey:@"waiterid"];
            [UserDefault setObject:st forKey:@"st"];
            [UserDefault synchronize];
        }
        failure();
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        if (![[UserDefault objectForKey:@"isUpLoad"] isEqualToString:@"noSuccess"]) {
            [UserDefault setObject:@"noSuccess" forKey:@"isUpLoad"];
            [UserDefault setObject:hotelid forKey:@"hotelid"];
            [UserDefault setObject:waiterid forKey:@"waiterid"];
            [UserDefault setObject:st forKey:@"st"];
            [UserDefault synchronize];
        }
        failure();
    }];
}

#pragma mark RootViewController
//创建根视图控制器
- (LGSideMenuController *)createRootViewController
{
    LeftViewController *leftVc = [[LeftViewController alloc] init];
    WMPageController *centerVC = [[WMPageController alloc] init];
    centerVC.delegate = self;
    //2、初始化导航控制器
    BaseNavigationController *centerNav = [[BaseNavigationController alloc]initWithRootViewController:centerVC];
    
    LGSideMenuController * sliderVC = [[LGSideMenuController alloc] initWithRootViewController:centerNav leftViewController:leftVc rightViewController:nil];
    sliderVC.willShowLeftView = ^(LGSideMenuController * _Nonnull sideMenuController, UIView * _Nonnull leftView){
        [leftVc willShow];
    };
    CGFloat width = kMainBoundsHeight > kMainBoundsWidth ? kMainBoundsWidth : kMainBoundsHeight;
    sliderVC.leftViewWidth = width / 3 * 2;
    sliderVC.leftViewSwipeGestureRange = LGSideMenuSwipeGestureRangeMake(66, 66);
    
    return sliderVC;
}

- (void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info
{
    if ([viewController isKindOfClass:[HotTopicViewController class]]) {
        
        [RDLogStatisticsAPI RDPageLogCategoryID:@"-1" volume:@"index"];
        HotTopicViewController * vc = (HotTopicViewController *)viewController;
        [vc showSelfAndCreateLog];
        
    }else if ([viewController isKindOfClass:[RecommendViewController class]]){
        
        [RDLogStatisticsAPI RDPageLogCategoryID:@"-2" volume:@"index"];
        RecommendViewController * vc = (RecommendViewController *)viewController;
        [vc showSelfAndCreateLog];
        
    }else if ([viewController isKindOfClass:[CategoryViewController class]]){
        
        CategoryViewController * vc = (CategoryViewController *)viewController;
        [RDLogStatisticsAPI RDPageLogCategoryID:[NSString stringWithFormat:@"%ld", vc.categoryID] volume:@"index"];
        [vc showSelfAndCreateLog];
    }
}

- (void)pageController:(WMPageController *)pageController didFirstEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info
{
    if ([viewController isKindOfClass:[HotTopicViewController class]]) {
        
        [RDLogStatisticsAPI RDPageLogCategoryID:@"-1" volume:@"index"];
        
    }else if ([viewController isKindOfClass:[RecommendViewController class]]){
        
        [RDLogStatisticsAPI RDPageLogCategoryID:@"-2" volume:@"index"];
        
    }else if ([viewController isKindOfClass:[CategoryViewController class]]){
        
        CategoryViewController * vc = (CategoryViewController *)viewController;
        [RDLogStatisticsAPI RDPageLogCategoryID:[NSString stringWithFormat:@"%ld", vc.categoryID] volume:@"index"];
        
    }
}

-(void)gotoGuidePageView
{
    SplashViewController* splashViewController = [[SplashViewController alloc]init];
    splashViewController.delegate = self;
    self.window.rootViewController = splashViewController;
    [self.window makeKeyAndVisible];
    [SAVORXAPI postUMHandleWithContentId:@"guide" key:nil value:nil];
}

#pragma mark splashViewControllerDelegate

-(void)splashViewControllerSureBtnClicked{
    

    LGSideMenuController * sliderVC = [self createRootViewController];
    
    self.window.rootViewController = sliderVC;
    [self.window makeKeyAndVisible];
    [self monitorInternet]; //监控网络状态
}


#pragma mark -- 监控网络状态
- (void)monitorInternet
{
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
            [GlobalData shared].isWifiStatus = YES;
            [[GCCDLNA defaultManager] startSearchPlatform];
        }else{
            [GlobalData shared].isWifiStatus = NO;
            [[GlobalData shared] disconnect];
            [[GCCDLNA defaultManager] stopSearchDevice];
            [[GCCDLNA defaultManager] callQRcodeFromPlatform];
        }
    }];
    
    // 3.开始监控
    [mgr startMonitoring];
}

//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于前台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        
    }else{
        //应用处于前台时的本地推送接受
    }
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

//iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    
    if ([[userInfo objectForKey:@"type"] integerValue] == 1) {
        
    }else if ([[userInfo objectForKey:@"type"] integerValue] == 2){
        
        //如果type等于2，代表是一个进入详情的item推送
        NSDictionary * dict = [userInfo objectForKey:@"params"];
        
        if (dict && [dict isKindOfClass:[NSDictionary class]]) {
            //如果收到的推送是一个节目的推送则初始化该节目的一个model
            HSVodModel * model = [[HSVodModel alloc] initWithDictionary:dict];
            
            if ([self.window.rootViewController isKindOfClass:[LGSideMenuController class]]) {
                //如果根视图是LGSide，则可以正常进行跳转
                LGSideMenuController * side = (LGSideMenuController *)self.window.rootViewController;
                BaseNavigationController * baseNa = (BaseNavigationController *)side.rootViewController;
                if (![baseNa.topViewController isKindOfClass:[WMPageController class]]) {
                    [baseNa popToRootViewControllerAnimated:NO];
                }
                if ([[baseNa topViewController] isKindOfClass:[WMPageController class]]) {
                    WMPageController * page = (WMPageController *)baseNa.topViewController;
                    [page didReceiveRemoteNotification:model];
                }
            }else{
                //如果根视图不是LGSide，则进行存储，等待首页加载完成后进行处理
                [GlobalData shared].isLaunchedByNotification = YES;
                [GlobalData shared].launchModel = model;
            }
        }
        
    }
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        
    }else{
        //应用处于后台时的本地推送接受
    }
    
}

//启动程序欢迎页设置
- (void)createLaunch
{
    BOOL temp = [[[NSUserDefaults standardUserDefaults] objectForKey:HasLaunched] boolValue];
    if (temp) {
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString *status = [user objectForKey:@"status"];
        [user synchronize];
        
        // status为2是视频类型，为1是图片类型
        if ([status isEqualToString:@"2"]) {
            
            NSString *videoPath =  [HTTPServerDocument stringByAppendingPathComponent:@"launch.mp4"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            // 如果视频文件存在，加载视频，否则加载默认图片
            if ([fileManager fileExistsAtPath:videoPath]) {
                VideoLauchMovieViewController *vc = [[VideoLauchMovieViewController alloc] init];
                self.window.rootViewController = vc;
                vc.videoUrlString = videoPath;
                vc.lauchClickedBack = ^(NSDictionary *parmDic){
                    LGSideMenuController * sliderVC = [self createRootViewController];
                    self.window.rootViewController = sliderVC;
                    [self monitorInternet]; //监控网络状态
                };
                [self.window makeKeyAndVisible];
            }else{
                LGSideMenuController * sliderVC = [self createRootViewController];
                self.window.rootViewController = sliderVC;
                [self.window makeKeyAndVisible];
                [self loadLauchImage];
            }

        }else if ([status isEqualToString:@"1"]){
                LGSideMenuController * sliderVC = [self createRootViewController];
                self.window.rootViewController = sliderVC;
                [self.window makeKeyAndVisible];
                [self loadLauchImage];
        }else{
            DefalutLaunchViewController * defalut = [[DefalutLaunchViewController alloc] init];
            defalut.playEnd = ^(){
                LGSideMenuController * sliderVC = [self createRootViewController];
                self.window.rootViewController = sliderVC;
                [self monitorInternet]; //监控网络状态
            };
            self.window.rootViewController = defalut;
            [self.window makeKeyAndVisible];
        }
        [SAVORXAPI postUMHandleWithContentId:@"start_page" key:@"start_page" value:@"success"];
        
    }else{
        //第一次启动应用程序
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:HasLaunched];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [SAVORXAPI postUMHandleWithContentId:@"start_page" key:@"start_page" value:@"success"];
        [self gotoGuidePageView];
    }
}

- (void)loadLauchImage{
    
    NSString *imagePath =  [HTTPServerDocument stringByAppendingPathComponent:@"launch.png"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:imagePath]) {
        NSData *picData = [NSData dataWithContentsOfFile:imagePath];
        UIImage *launchImage = [UIImage imageWithData:picData];
        
        //设置一个图片;
        UIImageView *niceView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        niceView.tag = 1234;
        [niceView setContentMode:UIViewContentModeScaleAspectFill];
        UIView * blackView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        blackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [niceView addSubview:blackView];
        if (launchImage) {
            niceView.image = launchImage;
        }else{
            niceView.image = [UIImage imageNamed:@"DefaultLaunch"];
        }
        
        UIImageView *logoView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        logoView.image = [Helper getLaunchImage];
        
        //添加到场景
        [self.window addSubview:niceView];
        [self.window addSubview:logoView];
        
        NSInteger animationTime = [[[NSUserDefaults standardUserDefaults] objectForKey:@"duration"] integerValue];
        if (!(animationTime > 0)) {
            animationTime = 1.5f;
        }
        
        [UIView animateWithDuration:animationTime animations:^{
            [niceView setTransform:CGAffineTransformMakeScale(1.1, 1.1)];
        } completion:^(BOOL finished) {
            [self monitorInternet];
            [UIView animateWithDuration:1.2 animations:^{
                [niceView setAlpha:0];
                [logoView setAlpha:0];
            } completion:^(BOOL finished) {
                [niceView removeFromSuperview];
                [logoView removeFromSuperview];
            }];
        }];
    }else{
        DefalutLaunchViewController * defalut = [[DefalutLaunchViewController alloc] init];
        defalut.playEnd = ^(){
            LGSideMenuController * sliderVC = [self createRootViewController];
            self.window.rootViewController = sliderVC;
            [self monitorInternet]; //监控网络状态
        };
        self.window.rootViewController = defalut;
        [self.window makeKeyAndVisible];
    }
}

- (void)saveImage:(NSString *)urlStr withType:(NSString *)typeString success:(void(^)())success
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        if ([typeString isEqualToString:@"1"]) {
            NSData *beforImageDate = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
            NSString * filePath = [HTTPServerDocument stringByAppendingPathComponent:@"launch.png"];
            if ([FileManage fileExistsAtPath:filePath]) {
                [FileManage removeItemAtPath:filePath error:nil];   
            }
            [beforImageDate writeToFile:filePath atomically:YES];
            success();
        }else if ([typeString isEqualToString:@"2"]){
            NSData *beforVideoDate = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
            NSString * filePath = [HTTPServerDocument stringByAppendingPathComponent:@"launch.mp4"];
            if ([FileManage fileExistsAtPath:filePath]) {
                [FileManage removeItemAtPath:filePath error:nil];
            }
            [beforVideoDate writeToFile:filePath atomically:YES];
            success();
        }
    });
}

- (void)requestGetLauchImageOrVideo
{
    HSLauchImageOrVideoRequest * request = [[HSLauchImageOrVideoRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSDictionary * dict = response[@"result"];
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        
        NSString *urlString = dict[@"url"];
        if (urlString && urlString.length > 0) {
            NSString *statusString = dict[@"status"];
            NSString *durationString = dict[@"duration"];
            
            // 如果拿到的lauchID和本地存储的id不一致，则存储图片或是视频
            if (![[user objectForKey:@"url"]  isEqualToString:urlString]) {
                [self saveImage:urlString withType:statusString success:^{
                    [user setObject:urlString forKey:@"url"];
                    [user setObject:statusString forKey:@"status"];
                    [user setObject:durationString forKey:@"duration"];
                    [user synchronize];
                }];
            }
        }else{
            [user removeObjectForKey:@"url"];
            [user removeObjectForKey:@"status"];
            [user removeObjectForKey:@"duration"];
            [user synchronize];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}



//app注册推送deviceToken
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString * token = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                         stringByReplacingOccurrencesOfString: @">" withString: @""]
                        stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    [GlobalData shared].deviceToken = token;
    NSLog(@"%@",token);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [UMessage didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    self.is3D_Touch = YES;
    
    if ([self.window.rootViewController isKindOfClass:[LGSideMenuController class]]) {
        if ([GlobalData shared].isBindRD) {
            if (![HTTPServerManager checkHttpServerWithBoxIP:[GlobalData shared].RDBoxDevice.BoxIP]) {
                [[GlobalData shared] disconnect];
                [[GCCDLNA defaultManager] startSearchPlatform];
            }
        }else if ([GlobalData shared].isBindDLNA){
            if (![HTTPServerManager checkHttpServerWithDLNAIP:[GlobalData shared].DLNADevice.headerURL]) {
                [[GlobalData shared] disconnect];
                [[GCCDLNA defaultManager] startSearchPlatform];
            }
        }else if ([Helper isWifiStatus]){
            [GlobalData shared].isWifiStatus = YES;
            if ([[GlobalData shared].cacheModel.sid isEqualToString:[Helper getWifiName]]) {
                if ([HTTPServerManager checkHttpServerWithBoxIP:[GlobalData shared].cacheModel.BoxIP]) {
                    [[GlobalData shared] bindToRDBoxDevice:[GlobalData shared].cacheModel];
                    [GlobalData shared].cacheModel = nil;
                    
                    UIView * view = [[UIApplication sharedApplication].keyWindow viewWithTag:422];
                    if (view) {
                        [view removeFromSuperview];
                    }
                    
                    return;
                }
            }
            [[GCCDLNA defaultManager] startSearchPlatform];
        }else{
            [[GCCDLNA defaultManager] callQRcodeFromPlatform];
        }
        
        //检测当前绑定状态是否断开
        if (![GlobalData shared].isBindRD && ![GlobalData shared].isBindDLNA) {
            [[HomeAnimationView animationView] stopScreen];
        }
        
        if ([shortcutItem.type isEqualToString:@"3dtouch.connet"]) {
            
            [[HomeAnimationView animationView] scanQRCode];
            
        }else if ([shortcutItem.type isEqualToString:@"3dtouch.screen"]) {
            
            LGSideMenuController * side = (LGSideMenuController *)self.window.rootViewController;
            BaseNavigationController * baseNa = (BaseNavigationController *)side.rootViewController;
            if (![baseNa.topViewController isKindOfClass:[WMPageController class]]) {
                [baseNa popToRootViewControllerAnimated:NO];
            }
            if ([[baseNa topViewController] isKindOfClass:[WMPageController class]]) {
                WMPageController * page = (WMPageController *)baseNa.topViewController;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [page.homeButton popOptionsWithAnimation];
                });
            }
            
        }
    }else{
        if ([Helper isWifiStatus]) {
            [GlobalData shared].isWifiStatus = YES;
        }
        
        [GlobalData shared].is3DTouchEnable = YES;
        [GlobalData shared].shortcutItem = shortcutItem;
    }
}

//通过其它应用打开APP时调用
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (result == FALSE) {
        if (options) {
            NSString * path = [[url description] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [OpenFileTool screenFileWithPath:path];
            }
        return YES;
    }
    return result;
}


//iOS老版系统通过其他应用调取打开
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (result == FALSE) {
        if (url) {
            NSString * path = [[url description] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [OpenFileTool screenFileWithPath:path];
            }
        return YES;
    }
    return result;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:[GCCDLNA defaultManager] selector:@selector(startSearchDevice) object:nil];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    self.is3D_Touch = NO;
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    if (self.is3D_Touch) {
        self.is3D_Touch = NO;
        return;
    }
    
    if ([self.window.rootViewController isKindOfClass:[LGSideMenuController class]]) {
        if ([GlobalData shared].isBindRD) {
            if (![HTTPServerManager checkHttpServerWithBoxIP:[GlobalData shared].RDBoxDevice.BoxIP]) {
                [[GlobalData shared] disconnect];
                [[GCCDLNA defaultManager] startSearchPlatform];
            }
            if (![[Helper getWifiName] isEqualToString:[GlobalData shared].RDBoxDevice.sid]) {
                [[GlobalData shared] disconnect];
                [[GCCDLNA defaultManager] startSearchPlatform];
            }
        }else if ([GlobalData shared].isBindDLNA){
            if (![HTTPServerManager checkHttpServerWithDLNAIP:[GlobalData shared].DLNADevice.headerURL]) {
                [[GlobalData shared] disconnect];
                [[GCCDLNA defaultManager] startSearchPlatform];
            }
        }else if ([Helper isWifiStatus]){
            [GlobalData shared].isWifiStatus = YES;
            if ([[GlobalData shared].cacheModel.sid isEqualToString:[Helper getWifiName]]) {
                if ([HTTPServerManager checkHttpServerWithBoxIP:[GlobalData shared].cacheModel.BoxIP]) {
                    [[GlobalData shared] bindToRDBoxDevice:[GlobalData shared].cacheModel];
                    [GlobalData shared].cacheModel = nil;
                    
                    UIView * view = [[UIApplication sharedApplication].keyWindow viewWithTag:422];
                    if (view) {
                        [view removeFromSuperview];
                    }
                    
                    if ([NSStringFromClass([[Helper getRootNavigationController].topViewController class]) isEqualToString:@"HSConnectViewController"]) {
                        [[Helper getRootNavigationController] popViewControllerAnimated:YES];
                    }
                    
                    return;
                }
            }
            if (![self.window viewWithTag:1234] && [self.window.rootViewController isKindOfClass:[LGSideMenuController class]]) {
                [[GCCDLNA defaultManager] startSearchPlatform];
            }
        }else{
            [[GCCDLNA defaultManager] callQRcodeFromPlatform];
        }
        
        //检测当前绑定状态是否断开
        if (![GlobalData shared].isBindRD && ![GlobalData shared].isBindDLNA) {
            [[HomeAnimationView animationView] stopScreen];
        }
    }
}

//APP将要退出生命周期调用的函数
- (void)applicationWillTerminate:(UIApplication *)application {
    //如果是绑定状态，尝试发送退出消息
    if ([GlobalData shared].isBindRD || [GlobalData shared].isBindDLNA) {
        [SAVORXAPI ScreenDemandShouldBackToTV:nil];
    }
}

@end
