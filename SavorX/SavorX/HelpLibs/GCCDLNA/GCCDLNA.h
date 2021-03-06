//
//  GCCDLNA.h
//  DLNATest
//
//  Created by 郭春城 on 16/10/10.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceModel.h"

@class GCCDLNA;
@protocol GCCDLNADelegate <NSObject>

- (void)GCCDLNA:(GCCDLNA *)DLNA didGetDevice:(DeviceModel *)device;

@optional
- (void)GCCDLNADidStartSearchDevice:(GCCDLNA *)DLNA;
- (void)GCCDLNADidEndSearchDevice:(GCCDLNA *)DLNA;

@end

@interface GCCDLNA : NSObject

@property (nonatomic, assign) id<GCCDLNADelegate> delegate;
@property (nonatomic, assign) BOOL isSearch;

//开始搜索DLNA设备
- (void)startSearchDevice;

//停止搜索DLNA设备
- (void)stopSearchDevice;

//开始搜索小平台
- (void)startSearchPlatform;

//getIP
- (void)callQRcodeFromPlatform;

//单例
+ (GCCDLNA *)defaultManager;

@end
