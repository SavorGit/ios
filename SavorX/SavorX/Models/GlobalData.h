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

extern NSString * const RDDidBindDeviceNotification; //已经连接至设备
extern NSString * const RDDidDisconnectDeviceNotification; //已经断开连接
extern NSString * const RDDidFoundHotelIdNotification; //发现了新的酒楼ID
extern NSString * const RDDidNotFoundSenceNotification; //进入了没有设备的环境
extern NSString * const RDDidFoundBoxSenceNotification; //进入了机顶盒设备环境
extern NSString * const RDDidFoundDLNASenceNotification; //进入了DLNA设备环境

extern NSString * const RDQiutScreenNotification; //结束投屏

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

//存储小平台呼出二维码地址
@property (nonatomic, copy) NSString * callQRCodeURL;

//存储二级小平台呼出二维码地址
@property (nonatomic, copy) NSString * secondCallCodeURL;

//存储三级小平台呼出二维码地址
@property (nonatomic, copy) NSString * thirdCallCodeURL;

//存储机顶盒呼出二维码地址
@property (nonatomic, copy) NSString * boxCodeURL;

//热点当前场景
@property (nonatomic, assign) RDScene scene;

//当前酒楼ID
@property (nonatomic, assign) NSInteger hotelId;

//区域ID
@property (nonatomic, copy) NSString * areaId;

//当前缓存的机顶盒信息
@property (nonatomic, strong) RDBoxModel * cacheModel;

//当前机顶盒的操作唯一标识
@property (nonatomic, copy) NSString * projectId;

//当前日志的操作时间
@property (nonatomic, copy) NSString * RDCurrentLogTime;

//当前video日志的操作时间
@property (nonatomic, copy) NSString * RDCurrentVideoLogTime;

//设备唯一标识
@property (nonatomic, copy) NSString * deviceID;

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
 *  连接到小热点机顶盒设备
 *
 *  @param 连接到机顶盒的Box模型信息
 */
- (void)bindToRDBoxDevice:(RDBoxModel *)model;

/**
 *  断开当前的设备连接
 */
- (void)disconnect;

@end
