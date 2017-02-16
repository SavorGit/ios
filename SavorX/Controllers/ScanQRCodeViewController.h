//
//  ScanQRCodeViewController.h
//  SavorX
//
//  Created by 郭春城 on 16/8/4.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "BaseViewController.h"
#import "GCCPlayerView.h"

typedef NS_ENUM(NSInteger, QRResultType) {
    QRResultTypeSuccess, //二维码扫描成功
    QRResultTypeWIFIError, //WIFI链接错误
    QRResultTypeQRError //二维码错误
};

@protocol QRCodeDidBindDelegate <NSObject>

- (void)QRCodeDidBindSuccessWithType:(QRResultType)type andWifiName:(NSString *)name;

@end


/**
 *	热点儿二维码扫描界面
 */
@interface ScanQRCodeViewController : BaseViewController

@property (nonatomic, assign) id<QRCodeDidBindDelegate> delegate;
@property (nonatomic, strong) GCCPlayerView * playView;

@end
