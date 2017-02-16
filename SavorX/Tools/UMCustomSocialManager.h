//
//  UMCustomSocialManager.h
//  SavorX
//
//  Created by 郭春城 on 16/11/30.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "HSVodModel.h"

@interface UMCustomSocialManager : NSObject

@property (nonatomic, strong) UIImage * image;

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

@end
