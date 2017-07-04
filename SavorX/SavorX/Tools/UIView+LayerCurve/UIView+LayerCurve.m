//
//  UIView+LayerCurve.m
//  多次曲线
//
//  Created by 郭春城 on 16/6/14.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "UIView+LayerCurve.h"

@implementation UIView (LayerCurve)

- (void)layerSolidLinePoints:(NSArray<NSValue *> *)points Color:(UIColor *)color Width:(CGFloat)width
{
    CAShapeLayer * layer = [CAShapeLayer new];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = color.CGColor;
    layer.lineWidth = width;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, [points[0] CGPointValue].x, [points[0] CGPointValue].y);
    for (int i = 1; i < points.count; i++) {
        CGPathAddLineToPoint(path, NULL, [points[i] CGPointValue].x, [points[i] CGPointValue].y);
    }
    layer.path = path;
    CGPathRelease(path);
    [self.layer addSublayer:layer];
}

- (void)layerDotteLinePoints:(NSArray<NSValue *> *)points Color:(UIColor *)color Width:(CGFloat)width SolidLength:(CGFloat)solid DotteLength:(CGFloat)dotte
{
    CAShapeLayer * layer = [CAShapeLayer new];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = color.CGColor;
    layer.lineWidth = width;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, [points[0] CGPointValue].x, [points[0] CGPointValue].y);
    for (int i = 1; i < points.count; i++) {
        CGPathAddLineToPoint(path, NULL, [points[i] CGPointValue].x, [points[i] CGPointValue].y);
    }
    NSArray * array = @[[NSNumber numberWithFloat:solid], [NSNumber numberWithFloat:dotte]];
    [layer setLineDashPattern:array];
    layer.path = path;
    CGPathRelease(path);
    [self.layer addSublayer:layer];
}

- (void)layerQuadCurveStrat:(CGPoint)start Control:(CGPoint)control End:(CGPoint)end Color:(UIColor *)color Width:(CGFloat)width
{
    CAShapeLayer * layer = [CAShapeLayer new];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = color.CGColor;
    layer.lineWidth = width;
    UIBezierPath * path = [UIBezierPath new];
    [path moveToPoint:start];
    [path addQuadCurveToPoint:end controlPoint:control];
    layer.path = path.CGPath;
    [self.layer addSublayer:layer];
}

- (void)layerCurveStrat:(CGPoint)start Control1:(CGPoint)control1 Control2:(CGPoint)control2 End:(CGPoint)end Color:(UIColor *)color Width:(CGFloat)width
{
    CAShapeLayer * layer = [CAShapeLayer new];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = color.CGColor;
    layer.lineWidth = width;
    UIBezierPath * path = [UIBezierPath new];
    [path moveToPoint:start];
    [path addCurveToPoint:end controlPoint1:control1 controlPoint2:control2];
    layer.path = path.CGPath;
    [self.layer addSublayer:layer];
}

@end
