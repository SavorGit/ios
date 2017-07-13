//
//  UMCustomSocialManager.h
//  SavorX
//
//  Created by 郭春城 on 16/11/30.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UMSocialCore/UMSocialCore.h>
#import "HSVodModel.h"
#import "CreateWealthModel.h"

@interface UMCustomSocialManager : NSObject

/**
 *  单例       用户管理友盟分享视图
 */
+ (UMCustomSocialManager *)defaultManager;

/**
 *
 *  展示分享视图
 *  dict         需要分享的条目信息
 *  controller   需要展示视图的控制器
 */
- (void)showUMSocialSharedWithModel:(HSVodModel *)model andController:(UIViewController *)controller;

/**
 *
 *  展示分享视图
 *  dict         需要分享的条目信息
 *  controller   需要展示视图的控制器
 *  type         页面来源
 */
- (void)showUMSocialSharedWithModel:(HSVodModel *)model andController:(UIViewController *)controller andType:(NSUInteger)type categroyID:(NSInteger)categroyID;

- (void)shareRDApplicationToPlatform:(UMSocialPlatformType)type currentViewController:(UIViewController *)VC title:(NSString *)text;

/**
 *  分享至平台3.0改版调用
 */
- (void)sharedToPlatform:(UMSocialPlatformType)platformType andController:(UIViewController *)VC withModel:(CreateWealthModel *)model;

@end
