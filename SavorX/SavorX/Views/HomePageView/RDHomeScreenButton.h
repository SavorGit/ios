//
//  RDHomeScreenButton.h
//  Test - 2.1
//
//  Created by 郭春城 on 17/3/2.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    RDScreenTypePhoto, //相册
    RDScreenTypeVideo, //精彩视频
    RDScreenTypeSlider, //幻灯片
    RDScreenTypeDocument, //我的文件
    RDScreenTypeNiceVideo //精彩视频
} RDScreenType; //用户手动选择的类型

@protocol RDHomeScreenButtonDelegate <NSObject>

- (void)RDHomeScreenButtonDidChooseType:(RDScreenType)type;

@end

@interface RDHomeScreenButton : UIButton

@property (nonatomic, assign) id<RDHomeScreenButtonDelegate> delegate;

//弹出菜单
- (void)popOptionsWithAnimation;

//关闭菜单
- (void)closeOptionsWithAnimation;

@end
