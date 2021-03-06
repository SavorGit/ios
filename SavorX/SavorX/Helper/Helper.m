//
//  Helper.m
//  HotSpot
//
//  Created by lijiawei on 16/12/8.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "Helper.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "LGSideMenuController.h"
#import "WMPageController.h"
#import <CommonCrypto/CommonDigest.h>
#import "GCCKeyChain.h"
#import "GCCGetInfo.h"

@implementation Helper

+ (BOOL) isBlankString:(NSString *)string {
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

+ (UINavigationController *)getRootNavigationController
{
    if ([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[LGSideMenuController class]]) {
        LGSideMenuController * sideVC = (LGSideMenuController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController * na = (UINavigationController *)sideVC.rootViewController;
        return na;
    }
    
    return [UINavigationController new];
}

+ (UIViewController *)getCurrentControllerInWMPage
{
    if ([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[LGSideMenuController class]]) {
        LGSideMenuController * sideVC = (LGSideMenuController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController * na = (UINavigationController *)sideVC.rootViewController;
        WMPageController * page = (WMPageController *)[na.viewControllers firstObject];
        
        return page.currentViewController;
    }
    
    return [UIViewController new];
}

+ (NSInteger)getCurrentTime
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSInteger result = (NSInteger)time;
    return result;
}

+ (UIImage *)getLaunchImage
{
    UIImage * image;
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (height == 480) {
        image = [UIImage imageNamed:@"image480"];
    }else if (height == 568){
        image = [UIImage imageNamed:@"image568"];
    }else if (height == 667){
        image = [UIImage imageNamed:@"image667"];
    }else if (height == 736){
        image = [UIImage imageNamed:@"image736h"];
    }else{
        image = [UIImage imageNamed:@"image667"];
    }
    
    return image;
}

//获取当前时间戳
+(NSString *)getTimeStamp {
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    return timeString;
}

+ (NSString *)getTimeStampMS
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

//获取NSBundele中的资源图片
+ (UIImage *)imageAtApplicationDirectoryWithName:(NSString *)fileName {
    if(fileName) {
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[fileName stringByDeletingPathExtension]];
        path = [NSString stringWithFormat:@"%@@2x.%@",path,[fileName pathExtension]];
        if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            path = nil;
        }
        
        if(!path) {
            path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
        }
        return [UIImage imageWithContentsOfFile:path];
    }
    return nil;
}

+ (NSString *)getWifiName
{
    NSString *wifiName = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiName;
}

+ (BOOL)isWifiStatus
{
    NSString *wifiName = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (!wifiInterfaces) {
        return NO;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            if (wifiName.length > 0) {
                return YES;
            }
        }
    }
    
    CFRelease(wifiInterfaces);
    return NO;
}

+ (CGFloat)autoWidthWith:(CGFloat)width
{
    CGFloat result = (width / 375.f) * kMainBoundsWidth;
    return result;
}

+ (CGFloat)autoHeightWith:(CGFloat)height
{
    CGFloat result = (height / 667.f) * kMainBoundsHeight;
    return result;
}

+ (CGFloat)autoHomePageCellImageHeight
{
    CGFloat scale = 400.f / 750;
    CGFloat width = MIN(kMainBoundsHeight, kMainBoundsWidth);
    CGFloat result = width * scale;
    return result;
}

+ (CGFloat)autoHomePageCellTitleLabelHeight
{
    CGFloat scale = 100.f / 750;
    CGFloat height = MAX(kMainBoundsWidth, kMainBoundsHeight);
    CGFloat result = height * scale;
    return result;
}

+ (NSString *)getImageNameWithPath:(NSString *)path
{
    NSRange range = [path rangeOfString:@"/image?"];
    
    NSString *name = [path substringFromIndex:(range.location + range.length)];
    
    return name;
}

+ (NSString *)getVideoNameWithPath:(NSString *)path
{
    NSRange range = [path rangeOfString:@"video?"];
    
    NSString *name = [path substringFromIndex:(range.location + range.length)];
    
    if (name == nil || [name isEqualToString:@""]) {
        return @"视频";
    }
    
    return name;
}

+ (UIView *)createHomePageSecondHelp
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight)];
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    view.userInteractionEnabled = YES;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    UIBezierPath *pOtherPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(5, kNaviBarHeight + kStatusBarHeight + 5, 45, 30) cornerRadius:3];
    
    [pOtherPath appendPath:path];
    shapeLayer.path = pOtherPath.CGPath;
    //重点
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    
    [view.layer setMask:shapeLayer];
    
    CGFloat width = kMainBoundsWidth - 34 > 340 ? 340 : kMainBoundsWidth - 34;
    CGFloat height = width * 53 / 340;
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kMainBoundsWidth - width - 17, kNaviBarHeight + kStatusBarHeight + 40, width, height)];
    [imageView setImage:[UIImage imageNamed:@"yindao_dianbo"]];
    [view addSubview:imageView];
    
    return view;
}

+ (NSString *)getMd5_32Bit:(NSString *)mdStr
{
    const char *original_str = [mdStr UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (int)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

+ (NSString *)getURLPublic
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    NSString *mdStr = [timeString stringByAppendingString:@"savor4321abcd1234"];
    NSString * result = [Helper getMd5_32Bit:mdStr];
    result = [NSString stringWithFormat:@"time=%@&sign=%@&deviceId=%@", timeString, result, [GCCKeyChain load:keychainID]];
    if (!isEmptyString([GlobalData shared].deviceToken)) {
        result = [NSString stringWithFormat:@"%@&deviceToken=%@", result, [GlobalData shared].deviceToken];
    }
    return result;
}

+ (NSString *)getHTTPHeaderValue
{
    NSString * result = [NSString stringWithFormat:@"versionname=%@;versioncode=%d;osversion=%@;model=%@;appname=hotSpot;clientname=ios;channelName=appstore;deviceid=%@;location=%lf,%lf", kSoftwareVersion, kVersionCode, [UIDevice currentDevice].systemVersion, [GCCGetInfo getDeviceName], [GCCKeyChain load:keychainID], [GlobalData shared].longitude, [GlobalData shared].latitude];
    return result;
}

+ (NSString *)getCurrentTimeWithFormat:(NSString *)format
{
    NSDate * date = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

+ (NSString *)addURLParamsInAPPWith:(NSString *)url
{
    if ([url containsString:@"?"]) {
        return [url stringByAppendingString:@"&location=newRead&app=inner"];
    }else{
        return [url stringByAppendingString:@"?location=newRead&app=inner"];
    }
}

+ (NSString *)addURLParamsShareWith:(NSString *)url
{
    if ([url containsString:@"?"]) {
        return [url stringByAppendingString:@"&app=inner"];
    }else{
        return [url stringByAppendingString:@"?app=inner"];
    }
}

/**
 *  强制屏幕转屏
 *
 *  @param orientation 屏幕方向
 */
+ (void)interfaceOrientation:(UIInterfaceOrientation)orientation
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

+ (NSString *)transformDate:(NSDate *)date
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:date];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    @autoreleasepool {
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context,color.CGColor);
        CGContextFillRect(context, rect);
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return img;
    }
}

@end
