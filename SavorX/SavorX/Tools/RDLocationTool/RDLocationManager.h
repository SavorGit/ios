//
//  RDLocationManager.h
//  定位功能测试
//
//  Created by 郭春城 on 2017/5/23.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

typedef void (^RDCheckUserLocationBlock)(CLLocationDegrees latitude, CLLocationDegrees longitude);
@interface RDLocationManager : NSObject

+ (instancetype)manager;

//开始检测用户当前位置
- (void)startCheckUserLocationWithHandle:(RDCheckUserLocationBlock)block;

//停止检测用户当前位置
- (void)stopCheckUserLocation;

@end
