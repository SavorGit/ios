//
//  RDRightConnetItem.m
//  Test - 2.1
//
//  Created by 郭春城 on 17/3/8.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDRightConnetItem.h"

@interface RDRightConnetItem ()

@property (nonatomic, assign) NSUInteger number;

@end

@implementation RDRightConnetItem

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void)showAnimation
{
    self.number = 1;
    [self createAnimationLayer];
}

- (void)stopAnimation
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showAnimation) object:nil];
}

- (void)createAnimationLayer
{
    if (self.number < 3) {
        [self performSelector:@selector(createAnimationLayer) withObject:nil afterDelay:.4f];
    }else{
        [self performSelector:@selector(showAnimation) withObject:nil afterDelay:5.f];
    }
    
    self.number += 1;
    
    CAShapeLayer * layer = [CAShapeLayer layer];
    
    layer.frame = CGRectMake(0, 0, self.titleLabel.frame.size.width, self.titleLabel.frame.size.width);
    layer.backgroundColor = [UIColor whiteColor].CGColor;
    layer.cornerRadius = self.titleLabel.frame.size.width / 2;
    layer.masksToBounds = YES;
    layer.position = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    CABasicAnimation *scale = [CABasicAnimation animation];
    scale.keyPath = @"transform.scale";
    scale.fromValue =[NSNumber numberWithFloat:0.0];
    scale.toValue =[NSNumber numberWithFloat:1.0];
    CABasicAnimation *opacity = [CABasicAnimation animation];
    opacity.keyPath = @"opacity";
    opacity.fromValue =[NSNumber numberWithFloat:1.0];
    opacity.toValue =[NSNumber numberWithFloat:0.0];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[scale, opacity];
    group.duration =1.5f;
    group.repeatCount = 1;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    [layer addAnimation:group forKey:nil];
    
    [self.layer addSublayer:layer];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [layer removeFromSuperlayer];
    });
}

@end
