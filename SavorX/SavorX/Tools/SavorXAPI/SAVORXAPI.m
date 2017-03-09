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
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wx9663b3234c565a7a" appSecret:@"1fb27ff272313bb4c9fe382af98de80b" redirectURL:@"http://www.savor.cn"];
    
    //设置新浪的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"3225976487"  appSecret:@"f107b91769da4dd5e6a1987f553cfc73" redirectURL:@"http://itunes.apple.com/cn/app/id1144051586?mt=8"];
    
    //设置分享到QQ互联的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1105447330"  appSecret:@"dBxguLhCwtYdGGsH" redirectURL:@"http://itunes.apple.com/cn/app/id1144051586?mt=8"];
    
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
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    return manager;
}

+ (NSURLSessionDataTask *)postWithURL:(NSString *)urlStr parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    [self sharedManager].requestSerializer.timeoutInterval = 15.f;
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [dict setObject:[GCCKeyChain load:keychainID] forKey:@"deviceId"];
    if ([dict objectForKey:@"function"]) {
        if ([[dict objectForKey:@"function"] isEqualToString:@"prepare"]) {
            [dict setObject:[GCCGetInfo getIphoneName] forKey:@"deviceName"];
        }
    }
    parameters = [NSDictionary dictionaryWithDictionary:dict];
    
    NSURLSessionDataTask * task = [[self sharedManager] POST:urlStr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:kNilOptions
                                                               error:&error];
        success(task, json);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(task, error);
    }];
    return task;
}

+ (NSURLSessionDataTask *)getWithURL:(NSString *)urlStr parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    [self sharedManager].requestSerializer.timeoutInterval = 6.f;
    NSURLSessionDataTask * task = [[self sharedManager] GET:urlStr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:kNilOptions
                                                               error:&error];
        success(task, json);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(task, error);
    }];
    return task;
}

+ (BGNetworkRequest *)postImageWithURL:(NSString *)urlStr data:(NSData *)data name:(NSString *)name type:(NSInteger)type success:(void (^)())success failure:(void (^)())failure
{
    BGUploadRequest * request = [[BGUploadRequest alloc] initWithData:data];
    request.mimeType = @"image/jpeg";
    request.fileName = name;
    
    [request setValue:name forParamKey:@"imageId"];
    [request setValue:@"prepare" forParamKey:@"function"];
    [request setValue:@"2screen" forParamKey:@"action"];
    [request setValue:@"pic" forParamKey:@"assettype"];
    [request setValue:@"0" forParamKey:@"play"];
    [request setIntegerValue:type forParamKey:@"isThumbnail"];
    [request setValue:[GCCKeyChain load:keychainID] forParamKey:@"deviceId"];
    [request setValue:[GCCGetInfo getIphoneName] forParamKey:@"deviceName"];
    
    [request sendRequestWithBaseURL:urlStr Progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
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
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
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
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        if (failure) {
            [MBProgressHUD showTextHUDwithTitle:ScreenFailure];
            failure();
        }
    }];
    
    return request;
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
    [[HomeAnimationView animationView] stopScreen];
    [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
    if ([GlobalData shared].isBindRD) {
        NSDictionary *parameters = @{@"function": @"stop",
                                     @"sessionid": [NSNumber numberWithInt:-1],
                                     @"reason": [NSNumber numberWithInt:0]};
        [SAVORXAPI postWithURL:STBURL parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }else if ([GlobalData shared].isBindDLNA) {
        [[GCCUPnPManager defaultManager] stopSuccess:^{
            
        } failure:^{
            
        }];
    }
}

+ (void)ScreenDemandShouldBackToTVWithSuccess:(void (^)())successBlock failure:(void (^)())failureBlock
{
    [[HomeAnimationView animationView] stopScreen];
    [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
    if ([GlobalData shared].isBindRD) {
        NSDictionary *parameters = @{@"function": @"stop",
                                     @"sessionid": [NSNumber numberWithInt:-1],
                                     @"reason": [NSNumber numberWithInt:0]};
        [SAVORXAPI postWithURL:STBURL parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            successBlock();
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failureBlock();
        }];
    }else if ([GlobalData shared].isBindDLNA) {
        [[GCCUPnPManager defaultManager] stopSuccess:^{
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
                
                NSString * str = [[NSUserDefaults standardUserDefaults] objectForKey:version_code];
                if ([str isEqualToString:[info objectForKey:version_code]]) {
                    return;
                }
                
                NSString * title = @"有新的版本可以使用";
                NSString * detail = [NSString stringWithFormat:@"本次更新内容:\n%@", info[@"remark"]];
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:detail preferredStyle:UIAlertControllerStyleAlert];
                
                if ([[info objectForKey:@"update_type"] integerValue] == 1) {
                    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/id1144051586?mt=8"]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SAVORXAPI showAlert:alert];
                        });
                    }];
                    [alert addAction:action];
                    [[Helper getRootNavigationController] presentViewController:alert animated:YES completion:nil];
                }else if ([[info objectForKey:@"update_type"] integerValue] == 0) {
                    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"忽略此版本" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [[NSUserDefaults standardUserDefaults] setObject:[info objectForKey:version_code] forKey:version_code];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }];
                    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/id1144051586?mt=8"]];
                        });
                    }];
                    [alert addAction:action1];
                    [alert addAction:action2];
                    [[Helper getRootNavigationController] presentViewController:alert animated:YES completion:nil];
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
