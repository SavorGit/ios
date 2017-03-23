//
//  SAVORXAPI.m
//  SavorX
//
//  Created by 郭春城 on 16/8/4.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "SAVORXAPI.h"
#import "GCCGetInfo.h"
#import "GCCKeyChain.h"
#import "GCCUPnPManager.h"
#import "HomeAnimationView.h"

#import <AudioToolbox/AudioToolbox.h>

#import <UMSocialCore/UMSocialCore.h>
#import "IQKeyboardManager.h"
#import "BGNetworkManager.h"
#import "NetworkConfiguration.h"
#import "HSWebServerManager.h"
#import "HSversionUpgradeRequest.h"
#import "UIImageView+WebCache.h"
#import "RDAlertView.h"

#define version_code @"version_code"

@implementation SAVORXAPI

+ (void)configApplication
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];//背景
    [[UINavigationBar appearance] setTintColor:UIColorFromRGB(0xffffff)];//item颜色
    
    //item字体大小
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xffffff), NSFontAttributeName : [UIFont systemFontOfSize:16]} forState:UIControlStateNormal];
    
    //设置标题颜色和字体
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xffffff), NSFontAttributeName : [UIFont boldSystemFontOfSize:17]}];
    
    //设置图片缓存策略
    [[SDImageCache sharedImageCache] setShouldDecompressImages:NO];
    [[SDWebImageDownloader sharedDownloader] setShouldDecompressImages:NO];
    
    //设置URL缓存策略
    [[NSURLCache sharedURLCache] setMemoryCapacity:5 * 1024 * 1024];
    [[NSURLCache sharedURLCache] setDiskCapacity:40 * 1024 * 1024];
    
    [[HSWebServerManager manager] start];
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    //友盟分享
    [[UMSocialManager defaultManager] setUmSocialAppkey:UmengAppkey];
    
    //设置微信的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wx59643f058e9b544c" appSecret:@"ad5cf8b259673427421a1181614c33c7" redirectURL:@"http://itunes.apple.com/cn/app/id1144051586"];
    
    //设置新浪的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"258257010"  appSecret:@"7b2701caad98239314089869bec08982" redirectURL:@"http://itunes.apple.com/cn/app/id1144051586"];
    
    //设置分享到QQ互联的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1105974848"  appSecret:@"j2l2GwJFxSOyzflj" redirectURL:@"http://itunes.apple.com/cn/app/id1144051586"];
    
    //友盟统计
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    [UMConfigInstance setAppKey:UmengAppkey];
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance];
    
    NSString* identifierNumber = [[UIDevice currentDevice].identifierForVendor UUIDString];
    if ([[GCCKeyChain load:keychainID] isEqualToString:@"unknow"]) {
        [GCCKeyChain save:keychainID data:identifierNumber];
    }
    
    [[BGNetworkManager sharedManager] setNetworkConfiguration:[NetworkConfiguration configuration]];
}

+ (AFHTTPSessionManager *)sharedManager {
    static dispatch_once_t once;
    static AFHTTPSessionManager *manager;
    dispatch_once(&once, ^ {
        manager = [[AFHTTPSessionManager alloc] init];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager.requestSerializer setValue:@"1.0" forHTTPHeaderField:@"version"];
        manager.requestSerializer.timeoutInterval = 15.f;
    });
    return manager;
}

+ (NSURLSessionDataTask *)postWithURL:(NSString *)urlStr parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask * task = [[self sharedManager] POST:urlStr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:kNilOptions
                                                               error:&error];
        if ([json objectForKey:@"projectId"]) {
            [GlobalData shared].projectId = [json objectForKey:@"projectId"];
        }
        success(task, json);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(task, error);
    }];
    return task;
}

+ (NSURLSessionDataTask *)getWithURL:(NSString *)urlStr parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask * task = [[self sharedManager] GET:urlStr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:kNilOptions
                                                               error:&error];
        if ([json objectForKey:@"projectId"]) {
            [GlobalData shared].projectId = [json objectForKey:@"projectId"];
        }
        success(task, json);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(task, error);
    }];
    return task;
}

//投屏图片
+ (NSURLSessionDataTask *)postImageWithURL:(NSString *)urlStr data:(NSData *)data name:(NSString *)name type:(NSInteger)type isThumbnail:(BOOL)isThumbnail rotation:(NSInteger)rotation success:(void (^)())success failure:(void (^)())failure
{
    urlStr = [NSString stringWithFormat:@"%@/pic?isThumbnail=%d&imageId=%@&deviceId=%@&deviceName=%@&imageType=%ld&rotation=%ld", urlStr, isThumbnail, name, [GCCKeyChain load:keychainID], [GCCGetInfo getIphoneName], type, rotation];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask * task = [[self sharedManager] POST:urlStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"fileUpload" fileName:name mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError* error;
        NSDictionary* response = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:kNilOptions
                                                               error:&error];
        if ([response objectForKey:@"projectId"]) {
            [GlobalData shared].projectId = [response objectForKey:@"projectId"];
        }
        
        if ([[response objectForKey:@"result"] integerValue] == 0) {
            if (success) {
                success();
            }
        }else if ([[response objectForKey:@"result"] integerValue] == 2) {
            
        }else{
            if (failure) {
                
                RDAlertView * alert = [[RDAlertView alloc] initWithTitle:@"提示" message:[response objectForKey:@"info"]];
                RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"我知道了" handler:^{
                    
                } bold:YES];
                [alert addActions:@[action]];
                [alert show];
                
                failure();
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD showTextHUDwithTitle:ScreenFailure];
        failure();
    }];
    
    return task;
}

//点播视频
+ (NSURLSessionDataTask *)demandWithURL:(NSString *)urlStr name:(NSString *)name type:(NSInteger)type position:(CGFloat)position success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    urlStr = [urlStr stringByAppendingString:@"/vod"];
    
    NSDictionary * parameters = @{@"deviceId" : [GCCKeyChain load:keychainID],
                                  @"type" : [NSNumber numberWithInteger:type],
                                  @"name" : name,
                                  @"deviceName" : [GCCGetInfo getIphoneName],
                                  @"position" : [NSNumber numberWithFloat:position]};
    
    NSURLSessionDataTask * task = [self getWithURL:urlStr parameters:parameters success:success failure:failure];
    return task;
}

//音量控制
+ (NSURLSessionDataTask *)volumeWithURL:(NSString *)urlStr action:(NSInteger)action success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    urlStr = [urlStr stringByAppendingString:@"/volume"];
    
    NSDictionary * parameters = @{@"deviceId" : [GCCKeyChain load:keychainID],
                                  @"action" : [NSNumber numberWithInteger:action],
                                  @"projectId" : [GlobalData shared].projectId};
    
    NSURLSessionDataTask * task = [self getWithURL:urlStr parameters:parameters success:success failure:failure];
    return task;
}

//图片旋转
+ (NSURLSessionDataTask *)rotateWithURL:(NSString *)urlStr success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    urlStr = [urlStr stringByAppendingString:@"/rotate"];
    
    NSDictionary * parameters = @{@"deviceId" : [GCCKeyChain load:keychainID],
                                  @"projectId" : [GlobalData shared].projectId};
    
    NSURLSessionDataTask * task = [self getWithURL:urlStr parameters:parameters success:success failure:failure];
    return task;
}

//视频投屏
+ (NSURLSessionDataTask *)postVideoWithURL:(NSString *)urlStr mediaPath:(NSString *)mediaPath position:(NSString *)position success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    urlStr = [NSString stringWithFormat:@"%@/video?deviceId=%@&deviceName=%@", urlStr,[GCCKeyChain load:keychainID], [GCCGetInfo getIphoneName]];
    
    NSDictionary * parameters = @{@"mediaPath" : mediaPath,
                                  @"position" : position};
    
    NSURLSessionDataTask * task = [self postWithURL:urlStr parameters:parameters success:success failure:failure];
    return task;
}

//视频暂停
+ (NSURLSessionDataTask *)pauseVideoWithURL:(NSString *)urlStr success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    urlStr = [urlStr stringByAppendingString:@"/pause"];
    
    NSDictionary * parameters = @{@"deviceId" : [GCCKeyChain load:keychainID],
                                  @"projectId" : [GlobalData shared].projectId};
    
    NSURLSessionDataTask * task = [self getWithURL:urlStr parameters:parameters success:success failure:failure];
    return task;
}

//视频恢复播放
+ (NSURLSessionDataTask *)resumeVideoWithURL:(NSString *)urlStr success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    urlStr = [urlStr stringByAppendingString:@"/resume"];
    
    NSDictionary * parameters = @{@"deviceId" : [GCCKeyChain load:keychainID],
                                  @"projectId" : [GlobalData shared].projectId};
    
    NSURLSessionDataTask * task = [self getWithURL:urlStr parameters:parameters success:success failure:failure];
    return task;
}

//视频设置进度请求
+ (NSURLSessionDataTask *)seekVideoWithURL:(NSString *)urlStr position:(NSString *)position success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    urlStr = [urlStr stringByAppendingString:@"/seek"];
    
    NSDictionary * parameters = @{@"deviceId" : [GCCKeyChain load:keychainID],
                                  @"projectId" : [GlobalData shared].projectId,
                                  @"position" : position};
    
    NSURLSessionDataTask * task = [self getWithURL:urlStr parameters:parameters success:success failure:failure];
    return task;
}

//视频获取进度请求
+ (NSURLSessionDataTask *)queryVideoWithURL:(NSString *)urlStr success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    urlStr = [urlStr stringByAppendingString:@"/query"];
    
    NSDictionary * parameters = @{@"deviceId" : [GCCKeyChain load:keychainID],
                                  @"projectId" : [GlobalData shared].projectId};
    
    NSURLSessionDataTask * task = [self getWithURL:urlStr parameters:parameters success:success failure:failure];
    return task;
}

+ (void)screenDLNAImageWithKeyStr:(NSString *)keyStr WithSuccess:(void (^)())successBlock failure:(void (^)())failureBlock
{
    NSString *asseturlStr = [NSString stringWithFormat:@"%@image?%@", [HTTPServerManager getCurrentHTTPServerIP],keyStr];
    [[GCCUPnPManager defaultManager] setAVTransportURL:asseturlStr Success:^{
        if (successBlock) {
            successBlock();
        }
    } failure:^{
        if (failureBlock) {
            [MBProgressHUD showTextHUDwithTitle:ScreenFailure];
            failureBlock();
        }
    }];
}

+ (void)showAlertWithString:(NSString *)str withController:(UIViewController *)VC
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:nil];
    [alert addAction:action];
    [VC presentViewController:alert animated:YES completion:nil];
}

//通过最上层的window以及对应其底层响应者获取当前视图控制器
+ (UIViewController *)getCurrentViewController
{
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows){
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
        
        if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
            
            UIViewController * viewController = nil;
            UIView *frontView = [[window subviews] objectAtIndex:0];
            id nextResponder = [frontView nextResponder];
            
            if ([nextResponder isKindOfClass:[UIViewController class]]){
                viewController = nextResponder;
            }
            else{
                viewController = window.rootViewController;
            }
            return viewController;
            
            break;
        }else{
            return [UIApplication sharedApplication].keyWindow.rootViewController;
        }
    }
    return nil;
}

+ (void)ScreenDemandShouldBackToTV
{
    if ([GlobalData shared].isBindRD) {
        NSString * urlStr = [STBURL stringByAppendingString:@"/stop"];
        
        NSDictionary * parameters = @{@"deviceId" : [GCCKeyChain load:keychainID],
                                      @"projectId" : [GlobalData shared].projectId};
        
        [self getWithURL:urlStr parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }else if ([GlobalData shared].isBindDLNA) {
        [[GCCUPnPManager defaultManager] stopSuccess:^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
            
        } failure:^{
            
        }];
    }
}

+ (void)ScreenDemandShouldBackToTVWithSuccess:(void (^)())successBlock failure:(void (^)())failureBlock
{
    if ([GlobalData shared].isBindRD) {
        NSString * urlStr = [STBURL stringByAppendingString:@"/stop"];
        
        NSDictionary * parameters = @{@"deviceId" : [GCCKeyChain load:keychainID],
                                      @"projectId" : [GlobalData shared].projectId};
        
        [self getWithURL:urlStr parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
            successBlock();
        } failure:failureBlock];
    }else if ([GlobalData shared].isBindDLNA) {
        [[GCCUPnPManager defaultManager] stopSuccess:^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
            
            successBlock();
        } failure:^{
            failureBlock();
        }];
    }
}

+ (void)postUMHandleWithContentId:(NSInteger)contentId withType:(handleType)type
{
    NSDictionary * parameters = @{@"contentID" : [NSString stringWithFormat:@"%ld", (long)contentId]};
    switch (type) {
        case 1:
            [MobClick event:@"collect" attributes:parameters];
            break;
            
        case 2:
        {
            [MobClick event:@"read" attributes:parameters];
        }
            break;
            
        case 3:
            [MobClick event:@"share" attributes:parameters];
            break;
            
        case 4:
            [MobClick event:@"canleCollect" attributes:parameters];
            break;
            
        case 5:
        {
            [MobClick event:@"demandHandle" attributes:parameters];
        }
            break;
            
        default:
            break;
    }
}

+ (void)postUMHandleWithContentId:(NSString *)eventId key:(NSString *)key value:(NSString *)value
{
    if (key.length > 0 && value.length > 0) {
        [MobClick event:eventId attributes:@{key : value}];
    }else{
        [MobClick event:eventId];
    }
}

+ (void)showAlertWithMessage:(NSString *)message
{
    RDAlertView * alert = [[RDAlertView alloc] initWithTitle:@"提示" message:message];
    RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"我知道了" handler:^{
        
    } bold:YES];
    [alert addActions:@[action]];
    [alert show];
}

+ (void)showConnetToTVAlert
{
    RDAlertView * alert = [[RDAlertView alloc] initWithTitle:@"提示" message:@"请点击\"连接电视\", 即可投屏"];
    RDAlertAction * action1 = [[RDAlertAction alloc] initWithTitle:@"取消" handler:^{
        
    } bold:NO];
    RDAlertAction * action2 = [[RDAlertAction alloc] initWithTitle:@"连接电视" handler:^{
        [[HomeAnimationView animationView] scanQRCode];
    } bold:YES];
    [alert addActions:@[action1, action2]];
    [alert show];
}

+ (void)successRing
{
    SystemSoundID soundID = 1504;
    AudioServicesPlaySystemSound(soundID);
}

+ (void)saveFileOnPath:(NSString *)path withArray:(NSArray *)array
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager * manager = [NSFileManager defaultManager];
        
        if (![manager fileExistsAtPath:FileCachePath]) {
            [manager createDirectoryAtPath:FileCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        if ([manager fileExistsAtPath:path]) {
            [manager removeItemAtPath:path error:nil];
        }
        BOOL temp = [array writeToFile:path atomically:YES];
        if (temp) {
            NSLog(@"缓存成功");
        }else{
            NSLog(@"缓存失败");
        }
    });
}

+ (void)saveFileOnPath:(NSString *)path withDictionary:(NSDictionary *)dict
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager * manager = [NSFileManager defaultManager];
        
        BOOL help = YES;
        if (![manager fileExistsAtPath:FileCachePath isDirectory:&help]) {
            [manager createDirectoryAtPath:FileCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        if ([manager fileExistsAtPath:path]) {
            [manager removeItemAtPath:path error:nil];
        }
        BOOL temp = [dict writeToFile:path atomically:YES];
        if (temp) {
            NSLog(@"缓存成功");
        }else{
            NSLog(@"缓存失败");
        }
    });
}

+ (void)checkVersionUpgrade
{
    UINavigationController * na = [Helper getRootNavigationController];
    if ([NSStringFromClass([na class]) isEqualToString:@"BaseNavigationController"]) {
        HSversionUpgradeRequest * request = [[HSversionUpgradeRequest alloc] init];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            NSDictionary * info = [response objectForKey:@"result"];
            
            if ([[info objectForKey:@"device_type"] integerValue] == 4) {
                
                NSString * detail = [NSString stringWithFormat:@"本次更新内容:\n%@", info[@"remark"]];
                
                NSInteger update_type = [[info objectForKey:@"update_type"] integerValue];
                
                UIView * view = [[UIView alloc] initWithFrame:CGRectZero];
                view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7f];
                view.tag = 4444;
                [[UIApplication sharedApplication].keyWindow addSubview:view];
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(0);
                }];
                
                UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [Helper autoWidthWith:320], [Helper autoHeightWith:344])];
                [imageView setImage:[UIImage imageNamed:@"banbengengxin_bg"]];
                imageView.center = CGPointMake(kMainBoundsWidth / 2, kMainBoundsHeight / 2);
                imageView.userInteractionEnabled = YES;
                [view addSubview:imageView];
                
                UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, [Helper autoHeightWith:75], imageView.frame.size.width - 40, imageView.frame.size.height - [Helper autoHeightWith:155])];
                [imageView addSubview:scrollView];
                
                CGRect rect = [detail boundingRectWithSize:CGSizeMake(scrollView.frame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
                
                UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height + 20)];
                label.textColor = [UIColor blackColor];
                label.numberOfLines = 0;
                label.font = [UIFont systemFontOfSize:15];
                label.text = detail;
                [scrollView addSubview:label];
                scrollView.contentSize = label.frame.size;
                
                if (update_type == 1) {
                    RDAlertAction * leftButton = [[RDAlertAction alloc] initVersionWithTitle:@"立即更新" handler:^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/id1144051586?mt=8"]];
                    } bold:YES];
                    leftButton.frame = CGRectMake(scrollView.frame.origin.x - 10, imageView.frame.size.height - [Helper autoHeightWith:50], scrollView.frame.size.width + 20, [Helper autoHeightWith:35]);
                    [imageView addSubview:leftButton];
                }else if (update_type == 0) {
                    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(imageView.frame.size.width / 2, imageView.frame.size.height - [Helper autoHeightWith:50], .5f, [Helper autoHeightWith:35])];
                    lineView.backgroundColor = UIColorFromRGB(0xb6a482);
                    [imageView addSubview:lineView];
                    
                    RDAlertAction * leftButton = [[RDAlertAction alloc] initVersionWithTitle:@"取消" handler:^{
                        [view removeFromSuperview];
                    } bold:NO];
                    leftButton.frame = CGRectMake(scrollView.frame.origin.x - 10, imageView.frame.size.height - [Helper autoHeightWith:50], scrollView.frame.size.width / 2 + 10, [Helper autoHeightWith:35]);
                    [imageView addSubview:leftButton];
                    
                    RDAlertAction * righButton = [[RDAlertAction alloc] initVersionWithTitle:@"立即更新" handler:^{
                        [view removeFromSuperview];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/id1144051586?mt=8"]];
                    } bold:YES];
                    righButton.frame =  CGRectMake(leftButton.frame.size.width + leftButton.frame.origin.x, imageView.frame.size.height - [Helper autoHeightWith:50], scrollView.frame.size.width / 2 + 10, [Helper autoHeightWith:35]);
                    [imageView addSubview:righButton];
                }
            }
            
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
        }];
    }
}

+ (void)showAlert:(UIAlertController *)alert
{
    [[Helper getRootNavigationController] presentViewController:alert animated:YES completion:nil];
}

@end
