//
//  GCCCodeScanning.h
//  二维码扫描
//
//  Created by 郭春城 on 16/7/5.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  图片扫描成功之后的代理
 */
@protocol GCCCodeScanningDelegate <NSObject>

/**
 *  成功扫描到相关信息
 *
 *  @param value 扫描到的结果
 */
- (void)GCCCodeScanningSuccessGetSomeInfo:(NSString *)value;

@end

@interface GCCCodeScanning : UIView

@property (nonatomic, assign) id<GCCCodeScanningDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame1 andScanViewFrame:(CGRect)frame2;

/**
 *  开始扫描
 */
- (void)start;

/**
 *  结束扫描
 */
- (void)stop;

@end
