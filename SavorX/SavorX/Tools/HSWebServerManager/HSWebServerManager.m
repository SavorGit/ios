//
//  HSWebServerManager.m
//  SavorX
//
//  Created by 郭春城 on 16/12/14.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "HSWebServerManager.h"
#import "GCDWebServerDataResponse.h"
#import "GCDWebServerFileResponse.h"
#import "RDAlertView.h"

@implementation HSWebServerManager

@synthesize webServer;

+ (instancetype)manager
{
    static HSWebServerManager *manager;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        manager = [[self alloc] init];
        
    });
    
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        webServer = [[GCDWebServer alloc] init];
    }
    return self;
}

- (void)start
{
    [webServer removeAllHandlers];
    
    [webServer addHandlerForMethod:@"GET" path:@"/stopProjection" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse *(__kindof GCDWebServerRequest *request) {
        
        NSDictionary * params = request.query;
        
        if ([params objectForKey:@"type"]) {
            
            /*获取操作type
             type = 1 投屏被抢投，手机退出投屏
             type = 2 机顶盒主动或者意外退出投屏，通知手机退出投屏
             */
            NSInteger type = [[params objectForKey:@"type"] integerValue];
            
            //获取机顶盒当前的状态信息
            NSString * tipMsg = @"电视已经退出投屏";
            if ([params objectForKey:@"tipMsg"]) {
                tipMsg = [params objectForKey:@"tipMsg"];
            }
            
            if (type == 1) {
                //type = 1 投屏被抢投，手机退出投屏
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:RDBoxQuitScreenNotification object:nil];
                    
                    RDAlertView * view = [[RDAlertView alloc] initWithTitle:@"提示" message:tipMsg];
                    RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"知道了" handler:^{
                        
                    } bold:YES];
                    [view addActions:@[action]];
                    [view show];
                });
            }else if (type == 2){
                //type = 2 机顶盒主动或者意外退出投屏，通知手机退出投屏
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:RDBoxQuitScreenNotification object:nil];
                    
                    RDAlertView * view = [[RDAlertView alloc] initWithTitle:@"提示" message:tipMsg];
                    RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"知道了" handler:^{
                        
                    } bold:YES];
                    [view addActions:@[action]];
                    [view show];
                });
            }
            NSLog(@"请求状态为: %ld， 请求信息为: %@", type, tipMsg);
        }
        
        return [GCDWebServerResponse responseWithStatusCode:200];
        
    }];
    
    [webServer addHandlerForMethod:@"GET" path:@"/image" requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
        
        NSString *url = request.URL.absoluteString;
        
        NSRange range = [url rangeOfString:@"/image?"];
        
        NSString *name = [url substringFromIndex:(range.location + range.length)];
        
        if (name == nil || [name isEqualToString:@""]) {
            
            completionBlock([GCDWebServerResponse responseWithStatusCode:404]);
            
            return;
            
        }
        
        NSString * path = [SystemImage stringByAppendingPathComponent:name];
        NSData * data = [NSData dataWithContentsOfFile:path];
        
        if (data == nil) {
            completionBlock([GCDWebServerResponse responseWithStatusCode:404]);
            
            return;
        }
        
        GCDWebServerDataResponse *response = [GCDWebServerDataResponse responseWithData:data contentType:@"image/jpeg"];
        
        completionBlock(response);
    }];
    
    [webServer addHandlerForMethod:@"GET" path:@"/video" requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
        
        NSString *url = request.URL.absoluteString;
        
        NSRange range = [url rangeOfString:@"/video?"];
        
        NSString *name = [url substringFromIndex:(range.location + range.length)];
        
        if (name == nil || [name isEqualToString:@""]) {
            
            completionBlock([GCDWebServerResponse responseWithStatusCode:404]);
            
            return;
            
        }
        
        NSString * filePath;
        
        if ([name isEqualToString:@"media-Redianer-TempCache.mp4"]) {
            filePath = [HTTPServerDocument stringByAppendingPathComponent:name];
        }else if ([name hasSuffix:@".mp4"]) {
            filePath = [[VideoDocument stringByAppendingPathComponent:name] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }else if ([name hasSuffix:@".mov"]) {
            PHAsset *asset = (PHAsset *)[[GlobalData shared].serverDic objectForKey:name];
            if (asset == nil) {
                
                completionBlock([GCDWebServerResponse responseWithStatusCode:404]);
                
                return;
            }
            
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            
            options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
            
            options.version = PHVideoRequestOptionsVersionCurrent;
            
            [options setNetworkAccessAllowed:YES];
            
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                
                AVURLAsset *avUrlAsset = (AVURLAsset *)asset;
                
                NSString *filePath = avUrlAsset.URL.path;
                
                GCDWebServerFileResponse *response = [GCDWebServerFileResponse responseWithFile:filePath byteRange:request.byteRange];
                completionBlock(response);
                
            }];
        }
        
        GCDWebServerFileResponse *response = [GCDWebServerFileResponse responseWithFile:filePath byteRange:request.byteRange];
        
        completionBlock(response);
        
    }];
    
    [webServer startWithPort:8080 bonjourName:nil];
}

- (void)stop
{
    [webServer stop];
}

@end
