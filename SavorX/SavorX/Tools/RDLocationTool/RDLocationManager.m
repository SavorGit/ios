//
//  RDLocationManager.m
//  定位功能测试
//
//  Created by 郭春城 on 2017/5/23.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDLocationManager.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

@interface RDLocationManager ()<BMKLocationServiceDelegate>

@property (nonatomic, assign) CLLocationDegrees lastLatitude; //记录上次的纬度
@property (nonatomic, assign) CLLocationDegrees lastLongitude; //记录上次的经度
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
        manager.lastLatitude = 0.f;
        manager.lastLongitude = 0.f;
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
    
    if (self.lastLatitude != 0 && self.lastLongitude != 0) {
        [self handleUserLocation:userLocation];
    }else{
        self.lastLatitude = userLocation.location.coordinate.latitude;
        self.lastLongitude = userLocation.location.coordinate.longitude;
        self.block(self.lastLatitude, self.lastLongitude);
    }
}

//处理获取的用户当前位置
- (void)handleUserLocation:(BMKUserLocation *)location
{
    CLLocationDegrees latitude = location.location.coordinate.latitude;
    CLLocationDegrees longitude = location.location.coordinate.longitude;
    
    NSLog(@"当前定位纬度 %lf,当前定位经度 %lf",latitude,longitude);
    
    NSLog(@"上次当前定位纬度 %lf,当前定位经度 %lf", self.lastLatitude, self.lastLongitude);
    
    BMKMapPoint lastPotion = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(self.lastLatitude, self.lastLongitude));
    BMKMapPoint currentPoint = BMKMapPointForCoordinate(location.location.coordinate);
    CLLocationDistance distance = BMKMetersBetweenMapPoints(lastPotion,currentPoint);
    NSLog(@"移动了%lf米", distance);
    if (distance >= 5.f) {
        self.lastLatitude = latitude;
        self.lastLongitude = longitude;
        self.block(latitude, longitude);
    }
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
}

@end
