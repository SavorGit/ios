//
//  ScreenProjectionView.h
//  SavorX
//
//  Created by lijiawei on 17/1/20.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseView.h"

typedef void(^ScreenProjectionSelectViewSelectBlock)(NSInteger selectIndex);

typedef enum {
    kWifi_NolinkDevice = 0, //无可连接设备
    KWifi_NoLinkWifi,       //无可连接wifi
    kWifi_HaveRDBox,        //有小热点盒子
    kWifi_HaveDLNA,         //有DLNA
    kWifi_LinkRDBox,        //连接到小热点机顶盒
    kWifi_LinkDLNA          //连接到DLNA设备
} WifiState;

@interface ScreenProjectionView : BaseView

+ (instancetype)shareStance;
/**
 *  显示可选视图
 *
 *  @param items       数组，里面全是字符串
 *  @param selectBlock 回调block
 */
- (instancetype)showScreenProjectionTitle:(NSString *)title wifiState:(WifiState)wifistate  block:(ScreenProjectionSelectViewSelectBlock)selectBlock;

@end
