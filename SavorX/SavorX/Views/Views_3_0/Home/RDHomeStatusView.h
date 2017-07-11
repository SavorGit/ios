//
//  RDHomeStatusView.h
//  SavorX
//
//  Created by 郭春城 on 2017/7/11.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    RDHomeStatus_Normal,
    RDHomeStatus_Bind,
    RDHomeStatus_Photo,
    RDHomeStatus_Video,
    RDHomeStatus_File,
    RDHomeStatus_Demand
} RDHomeStatusType;

@interface RDHomeStatusView : UIView

+ (instancetype)defaultView;

- (void)startScreenWithViewController:(UIViewController *)viewController withStatus:(RDHomeStatusType)status;

- (void)stopScreen;

- (void)scanQRCode;

- (void)callQRcodeFromPlatform;

- (void)stopScreenWithEggGame;

@property (nonatomic, assign) BOOL isScreening; //是否正在投屏

@end
