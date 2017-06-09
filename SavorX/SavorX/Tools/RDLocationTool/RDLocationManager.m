//
//  RDLocationManager.m
//  定位功能测试
//
//  Created by 郭春城 on 2017/5/23.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDLocationManager.h"

@interface RDLocationManager ()<BMKLocationServiceDelegate>

@property (nonatomic, strong) BMKLocationService * service; //百度地图定位服务
@property (nonatomic, copy) RDCheckUserLocationBlock block;

@end

@implementation RDLocationManager

+ (instancetype)manager
{
    static RDLocationManager *manager;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        manager = [[self alloc] init];
        manager.service = [[BMKLocationService alloc] init];
        manager.service.desiredAccuracy = kCLLocationAccuracyBest;
        manager.service.delegate = manager;
    });
    
    return manager;
}

//开始检测用户当前位置
- (void)startCheckUserLocationWithHandle:(RDCheckUserLocationBlock)block
{
    self.block = block;
    [self.service startUserLocationService];
}

//停止检测用户当前位置
- (void)stopCheckUserLocation
{
    [self.service stopUserLocationService];
}

#pragma mark -- BMKLocationServiceDelegate
/**
 *在将要启动定位时，会调用此函数
 */
- (void)willStartLocatingUser
{
    NSLog(@"将要开始定位");
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [self.service stopUserLocationService];
    
    [GlobalData shared].latitude = userLocation.location.coordinate.latitude;
    [GlobalData shared].longitude = userLocation.location.coordinate.longitude;
    self.block(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
}

/**
 *在停止定位后，会调用此函数
 */
- (void)didStopLocatingUser
{
    NSLog(@"停止定位");
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"请求定位失败，错误信息:\n%@", error.description);
    self.block(0.f, 0.f);
}

- (BOOL)checkLocationDataIsNeedUpdateWithLastPoint:(BMKMapPoint)lastPoint currentPoint:(BMKMapPoint)point
{
    CLLocationDistance distance = BMKMetersBetweenMapPoints(lastPoint,point);
    NSLog(@"移动了%lf米", distance);
    if (distance >= 100.f) {
        return YES;
    }else{
        return NO;
    }
}

@end
