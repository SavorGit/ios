//
//  GlobalData.h
//  SavorX
//
//  Created by 郭春城 on 16/7/19.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceModel.h"
#import "RDBoxModel.h"

typedef enum : NSUInteger {
    RDSceneHaveRDBox,
    RDSceneHaveDLNA,
    RDSceneNothing,
} RDScene;

extern NSString * const RDDidBindDeviceNotification;
extern NSString * const RDDidDisconnectDeviceNotification;
extern NSString * const RDDidFoundHotelIdNotification;
extern NSString * const RDDidNotFoundSenceNotification;
extern NSString * const RDDidFoundSenceNotification;

@interface GlobalData : NSObject 

// 本地服务器信息
@property (nonatomic, strong)NSMutableDictionary *serverDic;

//当前是否绑定机顶盒
@property (nonatomic, assign) BOOL isBindRD;

//当前绑定的机顶盒
@property (nonatomic, strong) RDBoxModel * RDBoxDevice;

//当前是否绑定了DLNA设备
@property (nonatomic, assign) BOOL isBindDLNA;

//当前绑定的DLNA设备
@property (nonatomic, strong) DeviceModel * DLNADevice;

//当前是否处于wifi网络状态
@property (nonatomic, assign) BOOL isWifiStatus;

//存储呼出二维码地址
@property (nonatomic, strong) NSString * callQRCodeURL;

//热点当前场景
@property (nonatomic, assign) RDScene scene;

//当前酒楼ID
@property (nonatomic, assign) NSInteger hotelId;

//当前是否有投屏页
@property (nonatomic, assign) BOOL isScreenProjectionView;

/**
 *  创建单例
 *
 *  @return GlobalData
 */
+ (GlobalData *)shared;

/**
 *  连接到DLNA设备
 *
 *  @param 连接到设备的DLNA模型信息
 */
- (void)bindToDLNADevice:(DeviceModel *)model;

/**
 *  连接到热点儿机顶盒设备
 *
 *  @param 连接到机顶盒的Box模型信息
 */
- (void)bindToRDBoxDevice:(RDBoxModel *)model;

/**
 *  断开当前的设备连接
 */
- (void)disconnect;

@end
