//
//  UIView+LayerCurve.h
//  多次曲线
//
//  Created by 郭春城 on 16/6/14.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LayerCurve)

/**
 *  绘制实线
 *
 *  @param points 控制点数组
 *  @param color  线的颜色
 *  @param width  线的宽度
 */
- (void)layerSolidLinePoints:(NSArray<NSValue *> *)points Color:(UIColor *)color Width:(CGFloat)width;

/**
 *  绘制虚线
 *
 *  @param points 控制点数组
 *  @param color  线的颜色
 *  @param width  线的宽度
 *  @param solid  每个虚线的长度
 *  @param dotte  虚线之间的间隔
 */
- (void)layerDotteLinePoints:(NSArray<NSValue *> *)points Color:(UIColor *)color Width:(CGFloat)width SolidLength:(CGFloat)solid DotteLength:(CGFloat)dotte;

/**
 *  绘制二次曲线
 *
 *  @param start   开始点
 *  @param control 控制点
 *  @param end     结束点
 *  @param color   线的颜色
 *  @param width   线的宽度
 */
- (void)layerQuadCurveStrat:(CGPoint)start Control:(CGPoint)control End:(CGPoint)end Color:(UIColor *)color Width:(CGFloat)width;

/**
 *  绘制三次曲线
 *
 *  @param start    开始点
 *  @param control1 控制点1
 *  @param control2 控制点2
 *  @param end      结束点
 *  @param color    线的颜色
 *  @param width    线的宽度
 */
- (void)layerCurveStrat:(CGPoint)start Control1:(CGPoint)control1 Control2:(CGPoint)control2 End:(CGPoint)end Color:(UIColor *)color Width:(CGFloat)width;

@end
