//
//  RDScreenLocationView.h
//  定位功能测试
//
//  Created by 郭春城 on 2017/5/23.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    RDScreenLocation_Compelete, //加载完成
    RDScreenLocation_Loading, //正在加载
    RDScreenLocation_Faild, //加载失败
} RDScreenLocationStatus;

@class RDScreenLocationView;
@protocol RDScreenLocationViewDelegate <NSObject>

- (void)RDScreenLocationViewDidSelectTabButtonWithIndex:(NSInteger)index;

- (void)RDScreenLocationViewDidSelectMoreButton;

@end

@interface RDScreenLocationView : UIView

@property (nonatomic, assign) id <RDScreenLocationViewDelegate>delegate;

- (void)showWithStatus:(RDScreenLocationStatus)status;

//动画隐藏
- (void)hiddenWithAnimation;

@end
