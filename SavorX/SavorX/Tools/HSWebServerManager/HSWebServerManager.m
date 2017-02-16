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
    
    [webServer startWithPort:1680 bonjourName:nil];
}

- (void)stop
{
    [webServer stop];
}

@end
