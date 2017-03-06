//
//  GCCCodeScanning.m
//  二维码扫描
//
//  Created by 郭春城 on 16/7/5.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "GCCCodeScanning.h"
#import <AVFoundation/AVFoundation.h>
#import "HomeAnimationView.h"

@interface GCCCodeScanning ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession * session;
@property (nonatomic, strong) CAShapeLayer * alertLayer; //上方动画layer
@property (nonatomic, strong) CALayer * upLayer; //响应区间layer

@end

@implementation GCCCodeScanning

- (instancetype)initWithFrame:(CGRect)frame1 andScanViewFrame:(CGRect)frame2
{
    if (self = [super initWithFrame:frame1]) {
        [self customMyself:frame2];
    }
    return self;
}

- (void)customMyself:(CGRect)frame
{
    //创建响应区间layer
    self.upLayer = [CALayer layer];
    self.upLayer.bounds = frame;
    self.upLayer.position = self.layer.position;
    self.upLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    [self createCaptureLayer];
}

- (void)createCaptureLayer
{
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc] init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //初始化链接对象
    self.session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [self.session addInput:input];
    [self.session addOutput:output];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode];
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.layer.bounds;
    
    [self.layer addSublayer:layer];
    [self.layer addSublayer:self.upLayer];
    
    [self createTopAlertLineWithColor:[UIColor cyanColor]];
    [self createBorderLayerWithColor:[UIColor cyanColor]];
    
    //修正扫描区域为上方upLayer的区域
    CGFloat screenHeight = self.frame.size.height;
    CGFloat screenWidth = self.frame.size.width;
    CGRect cropRect = CGRectMake(self.upLayer.frame.origin.x - 50,
                                 self.upLayer.frame.origin.y - 50,
                                 self.upLayer.frame.size.width + 100,
                                 self.upLayer.frame.size.height + 100);
    
    [output setRectOfInterest:CGRectMake(cropRect.origin.y / screenHeight,
                                          cropRect.origin.x / screenWidth,
                                          cropRect.size.height / screenHeight,
                                          cropRect.size.width / screenWidth)];
    
    //创建四周黑色的半透明view，为了突出扫描区域
    [self createBlackView];
    
    NSError * error;
    [device lockForConfiguration:&error];
    if (!error) {
        //为提高精确度，进行焦距调整
        if (device.activeFormat.videoMaxZoomFactor > 1.6) {
            
            device.videoZoomFactor = 1.6;
            
        }else{
            
            device.videoZoomFactor = device.activeFormat.videoMaxZoomFactor;
            
        }
        [device unlockForConfiguration];
    }
    [self performSelector:@selector(start) withObject:nil afterDelay:.2f];
}

/**
 *  创建四周黑色的半透明view，为了突出扫描区域
 */
- (void)createBlackView
{
    //上
    UIView * view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.upLayer.frame.origin.y)];
    view1.backgroundColor = [UIColor blackColor];
    view1.alpha = 0.5f;
    [self addSubview:view1];
    
    //左
    UIView * view2 = [[UIView alloc] initWithFrame:CGRectMake(0, self.upLayer.frame.origin.y, self.upLayer.frame.origin.x, self.upLayer.frame.size.height)];
    view2.backgroundColor = [UIColor blackColor];
    view2.alpha = 0.5f;
    [self addSubview:view2];
    
    //下
    UIView * view3 = [[UIView alloc] initWithFrame:CGRectMake(0, self.upLayer.frame.origin.y + self.upLayer.frame.size.height, self.frame.size.width, self.frame.size.height - self.upLayer.frame.origin.y + self.upLayer.frame.size.height)];
    view3.backgroundColor = [UIColor blackColor];
    view3.alpha = 0.5f;
    [self addSubview:view3];
    
    //右
    UIView * view4 = [[UIView alloc] initWithFrame:CGRectMake(self.upLayer.frame.origin.x + self.upLayer.frame.size.width, self.upLayer.frame.origin.y, self.frame.size.width - self.upLayer.frame.origin.x + self.upLayer.frame.size.width, self.upLayer.frame.size.height)];
    view4.backgroundColor = [UIColor blackColor];
    view4.alpha = 0.5f;
    [self addSubview:view4];
    
    CGFloat labelY2 = self.upLayer.frame.origin.y - 70;
    CGFloat labelY = self.upLayer.frame.origin.y + self.upLayer.frame.size.height + 30;
    UILabel * label2 = [[UILabel alloc] initWithFrame:CGRectMake(25, labelY, self.bounds.size.width - 50, 50)];
    label2.numberOfLines = 0;
    label2.text = @"没显示二维码？\n检查手机与电视是否连接同一WiFi";
    label2.textColor = [UIColor colorWithHexString:@"#ffc116"];
    label2.font = [UIFont boldSystemFontOfSize:17];
    label2.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label2];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(25, labelY2, self.bounds.size.width - 50, 60)];
    label.numberOfLines = 0;
    label.text = @"扫描电视中出现的二维码进行连接投屏";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    
    UIButton *reScanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [reScanBtn setTitle:@"重新连接" forState:UIControlStateNormal];
    reScanBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [reScanBtn setBackgroundColor:[UIColor colorWithRed:215.0/255.0 green:190.0/255.0 blue:126.0/255.0 alpha:1.0]];
    [reScanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [reScanBtn addTarget:self action:@selector(reScanAction) forControlEvents:UIControlEventTouchUpInside];
    reScanBtn.layer.masksToBounds = YES;
    reScanBtn.layer.cornerRadius = 5.0;
    reScanBtn.layer.borderWidth = 1.0;
    reScanBtn.layer.borderColor = [[UIColor clearColor] CGColor];
    
    [self addSubview:reScanBtn];
    
    [reScanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(label2.bottom + 10);
        make.size.mas_equalTo(CGSizeMake(80, 32));
        make.centerX.equalTo(self);
//        make.centerY.equalTo(self).offset(120);215 190 126
    }];

}
// 重新连接
- (void)reScanAction{
    [[HomeAnimationView animationView] CameroIsReady];
}
/**
 *  创建上方动画layer
 *
 *  @param color 动画layer的颜色
 */
- (void)createTopAlertLineWithColor:(UIColor *)color
{
    self.alertLayer = [CAShapeLayer new];
    self.alertLayer.fillColor = [UIColor clearColor].CGColor;
    self.alertLayer.strokeColor = color.CGColor;
    self.alertLayer.lineWidth = 1.5f;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 10, 20);
    CGPathAddLineToPoint(path, NULL, self.upLayer.bounds.size.width - 10, 20);
    self.alertLayer.path = path;
    CGPathRelease(path);
    [self.upLayer addSublayer:self.alertLayer];
}

/**
 *  创建上方动画效果
 */
- (void)createAlertAnimation
{
    CABasicAnimation * animation1 = [[CABasicAnimation alloc] init];
    animation1.keyPath = @"transform.translation.y";
    animation1.toValue = [NSNumber numberWithFloat:self.upLayer.bounds.size.height - 40];
    animation1.duration = 1.f;
    animation1.removedOnCompletion = NO;
    animation1.fillMode = kCAFillModeForwards;
    
    CABasicAnimation * animation2 = [[CABasicAnimation alloc] init];
    animation2.keyPath = @"transform.translation.y";
    animation2.toValue = [NSNumber numberWithFloat:0];
    animation2.duration = 1.f;
    animation2.beginTime = 1.f;
    
    CAAnimationGroup * group = [CAAnimationGroup animation];
    group.animations = @[animation1, animation2];
    group.duration = 2.f;
    group.repeatCount = MAXFLOAT;
    
    [self.alertLayer addAnimation:group forKey:ScanAnimationKey];
}

/**
 *  创建四个角的边框
 *
 *  @param color 边框颜色
 */
- (void)createBorderLayerWithColor:(UIColor *)color
{
    CGPoint point1 = CGPointMake(2.f, self.upLayer.bounds.size.width / 6);
    CGPoint point2 = CGPointMake(2.f, 2.f);
    CGPoint point3 = CGPointMake(self.upLayer.bounds.size.width / 6, 2.f);
    [self layerSolidLinePoints:@[[NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point3]] Color:color Width:4.f];
    
    CGPoint point4 = CGPointMake(self.upLayer.bounds.size.width * 5 / 6, 2.f);
    CGPoint point5 = CGPointMake(self.upLayer.bounds.size.width - 2.f, 2.f);
    CGPoint point6 = CGPointMake(self.upLayer.bounds.size.width - 2.f, self.upLayer.bounds.size.width / 6);
    [self layerSolidLinePoints:@[[NSValue valueWithCGPoint:point4], [NSValue valueWithCGPoint:point5], [NSValue valueWithCGPoint:point6]] Color:color Width:4.f];
    
    CGPoint point7 = CGPointMake(2.f, self.upLayer.bounds.size.height - self.upLayer.bounds.size.width / 6);
    CGPoint point8 = CGPointMake(2.f, self.upLayer.bounds.size.height - 2.f);
    CGPoint point9 = CGPointMake(self.upLayer.bounds.size.width / 6, self.upLayer.bounds.size.height - 2.f);
    [self layerSolidLinePoints:@[[NSValue valueWithCGPoint:point7], [NSValue valueWithCGPoint:point8], [NSValue valueWithCGPoint:point9]] Color:color Width:4.f];
    
    CGPoint point10 = CGPointMake(self.upLayer.bounds.size.width * 5 / 6, self.upLayer.bounds.size.height - 2.f);
    CGPoint point11 = CGPointMake(self.upLayer.bounds.size.width - 2.f, self.upLayer.bounds.size.height - 2.f);
    CGPoint point12 = CGPointMake(self.upLayer.bounds.size.width - 2.f, self.upLayer.bounds.size.height - self.upLayer.bounds.size.width / 6);
    [self layerSolidLinePoints:@[[NSValue valueWithCGPoint:point10], [NSValue valueWithCGPoint:point11], [NSValue valueWithCGPoint:point12]] Color:color Width:4.f];
}

/**
 *  在相应区间上进行绘制提醒标志线
 *
 *  @param points 线段的坐标集合
 *  @param color  线段的颜色
 *  @param width  线段的宽度
 */
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
    [self.upLayer addSublayer:layer];
}

/**
 *  用户相机捕捉到图片后执行的代理
 *
 *  @param captureOutput   输出流
 *  @param metadataObjects 扫描的结果信息的集合
 *  @param connection      相机连接信息
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        [self.session stopRunning];
        AVMetadataMachineReadableCodeObject * object = [metadataObjects objectAtIndex:0];
        if ([_delegate respondsToSelector:@selector(GCCCodeScanningSuccessGetSomeInfo:)]) {
            [_delegate GCCCodeScanningSuccessGetSomeInfo:object.stringValue];
        }
    }
}

//开始进行扫描
- (void)start
{
    [self.session startRunning];
    if (!self.alertLayer.superlayer) {
        [self.upLayer addSublayer:self.alertLayer];
    }
    [self createAlertAnimation];
}

//结束扫描
- (void)stop
{
    [self.session stopRunning];
    if (self.alertLayer.superlayer) {
        [self.alertLayer removeFromSuperlayer];
    }
}

@end
