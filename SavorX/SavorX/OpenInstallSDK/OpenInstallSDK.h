//
//  OpenInstallSDK.h
//  OpenInstallSDK
//
//  Created by toby on 16/8/11.
//  Copyright © 2016年 toby. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@protocol OpenInstallDelegate  <NSObject>


/**
 * 安装时获取自定义h5页面参数（返回自定义参数）
 * @param params 动态参数
 * @return void
 */
- (void)getInstallParamsFromOpenInstall:(NSDictionary *) params withError: (NSError *) error;


/**
 * 安装时获取渠道h5页面参数（包括自定义渠道页，返回渠道编号和渠道自定义参数）
 * @param params 动态参数
 * @return void
 */
- (void)getChannelInstallParamsFromOpenInstall:(NSDictionary *) params withError: (NSError *) error;


/**
 * 唤醒时获取h5页面参数（如果是渠道链接，渠道编号会一起返回）
 * @param params 动态参数
 * @return void
 */
- (void)getWakeUpParamsFromOpenInstall: (NSDictionary *) params withError: (NSError *) error;

@end
@interface OpenInstallSDK : UIViewController
@property (nonatomic, weak) id <OpenInstallDelegate> delegate;

/**
 * 初始化OpenInstall SDK
 * @param appKey 控制中心创建应用获取appKey
 * @param launchOptions 该参数存储程序启动的原因
 * @param delegate 委托方法(getInstallParamsFromOpenInstall和 getWakeUpParamsFromOpenInstall)所在的类的对象
 * @return void
 */
+(void)setAppKey:(NSString *)appKey withDelegate:(id)delegate;

/**
 * 处理 URL schemes
 * @param url 系统回调传回的URL
 * @return bool URL是否被OpenInstall识别
 */
+(BOOL)handLinkURL:(NSURL *)URL;

/**
 * 通过 Universal Link 启动应用时会调用 application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray * __nullable
 restorableObjects))restorationHandler ,在此方法中调用  [OpenInstallSDK continueUserActivity:userActivity]
 *  @param userActivity 存储了页面信息，包括url
 * @return bool URL是否被OpenInstall识别
 */
+(BOOL)continueUserActivity:(NSUserActivity*)userActivity;

@end
