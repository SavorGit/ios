//
//  ShareRDViewController.m
//  SavorX
//
//  Created by 郭春城 on 2017/4/7.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "ShareRDViewController.h"
#import "UMCustomSocialManager.h"
#import "GCCKeyChain.h"

@interface ShareRDViewController ()

@property (nonatomic, strong) UIView * shareView;
@property (nonatomic, assign) SHARERDTYPE type;

@end

@implementation ShareRDViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}


- (instancetype)initWithType:(SHARERDTYPE)type
{
    if (self = [super init]) {
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createShareButtonsView) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)setupViews
{
    //创建背景图
    UIImageView * backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [backgroundImageView setImage:[UIImage imageNamed:@"tj_bg"]];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:backgroundImageView];
    [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self createShareButtonsView];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [imageView setImage:[UIImage imageNamed:@"tj_slogan"]];
    [backgroundImageView addSubview:imageView];
    CGFloat sloganWidth = [Helper autoWidthWith:317];
    CGFloat sloganGHeight = sloganWidth / 317 * 85;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(sloganWidth, sloganGHeight));
        make.top.mas_equalTo([Helper autoWidthWith:50]);
        make.centerX.mas_equalTo(0);
    }];
    
    UIView * QRCodeBackView = [[UIView alloc] init];
    [self.view addSubview:QRCodeBackView];
    [QRCodeBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(-[Helper autoWidthWith:30]);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.shareView.mas_top);
    }];
    
    UIImageView * QRCodeBackImageView = [[UIImageView alloc] init];
    [QRCodeBackImageView setImage:[UIImage imageNamed:@"tj_panzi"]];
    [QRCodeBackView addSubview:QRCodeBackImageView];
    [QRCodeBackImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(300);
    }];
    
    NSString * QRURL = [NSString stringWithFormat:@"%@?st=qrcode&clientname=ios&deviceid=%@", RDDownLoadURL, [GCCKeyChain load:keychainID]];
    UIImage * QRImage = [self getRDQRQodeWithURL:QRURL];
    
    UIImageView * codeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [QRCodeBackImageView addSubview:codeImageView];
    [codeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo([Helper autoWidthWith:125]);
    }];
    if (QRImage) {
        [codeImageView setImage:QRImage];
    }else{
        [codeImageView setImage:[UIImage imageNamed:@"tjxzm"]];
    }
    codeImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    codeImageView.layer.shadowOpacity = .2f;
    codeImageView.layer.shadowRadius = 6.f;
    codeImageView.layer.shadowOffset = CGSizeMake(1.f, 1.f);
}

- (void)createShareButtonsView
{
    CGFloat width = kMainBoundsWidth;
    
    if (self.shareView) {
        [self.shareView removeAllSubviews];
    }
    
    self.shareView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.shareView];
    [self.shareView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo([Helper autoWidthWith:120.f]);
    }];
    
    CGFloat lineWidth = (width - 80.f) / 2;
    UIView * leftLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, lineWidth, .5f)];
    leftLineView.backgroundColor = [UIColor grayColor];
    [self.shareView addSubview:leftLineView];
    
    UIView * rightLineView = [[UIView alloc] initWithFrame:CGRectMake(width - lineWidth, 10, lineWidth, .5f)];
    rightLineView.backgroundColor = [UIColor grayColor];
    [self.shareView addSubview:rightLineView];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = UIColorFromRGB(0x666666);
    label.backgroundColor = [UIColor clearColor];
    label.text = RDLocalizedString(@"RDString_ShareTo");
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    [self.shareView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(70, 20));
        make.top.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
    }];
    
    NSMutableArray * imageArray = [NSMutableArray new];
//    @[@"WeChat", @"friends", @"qq", @"weibo", @"fuzhilianjie"];
    NSMutableArray * titleArray = [NSMutableArray new];
//  @[RDLocalizedString(@"RDString_WeChat"), RDLocalizedString(@"RDString_WeChatTimeLine"), @"QQ", RDLocalizedString(@"RDString_Sina"), RDLocalizedString(@"RDString_CopyLink")];
    NSMutableArray * platformArray = [NSMutableArray new];
    
    if ([[UMSocialManager defaultManager] isSupport:UMSocialPlatformType_WechatSession]) {
        [imageArray addObject:@"tj_weixin"];
        [titleArray addObject:RDLocalizedString(@"RDString_WeChat")];
        [platformArray addObject:[NSNumber numberWithInteger:UMSocialPlatformType_WechatSession]];
    }
    if ([[UMSocialManager defaultManager] isSupport:UMSocialPlatformType_WechatTimeLine]) {
        [imageArray addObject:@"tj_pyq"];
        [titleArray addObject:RDLocalizedString(@"RDString_WeChatTimeLine")];
        [platformArray addObject:[NSNumber numberWithInteger:UMSocialPlatformType_WechatTimeLine]];
    }
    if ([[UMSocialManager defaultManager] isSupport:UMSocialPlatformType_QQ]) {
        [imageArray addObject:@"tj_qq"];
        [titleArray addObject:@"QQ"];
        [platformArray addObject:[NSNumber numberWithInteger:UMSocialPlatformType_QQ]];
    }
    [imageArray addObject:@"tj_weibo"];
    [titleArray addObject:RDLocalizedString(@"RDString_Sina")];
    [platformArray addObject:[NSNumber numberWithInteger:UMSocialPlatformType_Sina]];
//    [imageArray addObject:@"fuzhilianjie"];
//    [titleArray addObject:RDLocalizedString(@"RDString_CopyLink")];
//    [platformArray addObject:[NSNumber numberWithInteger:UMSocialPlatformType_UnKnown]];
    
    for (NSInteger i = 0; i < imageArray.count; i++) {
        [self createItemWithImageName:[imageArray objectAtIndex:i] title:[titleArray objectAtIndex:i] index:i type:[[platformArray objectAtIndex:i] integerValue]];
    }
}

- (void)createItemWithImageName:(NSString *)imageName title:(NSString *)title index:(NSInteger)index type:(UMSocialPlatformType)type
{
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    button.tag = 101 + type;
    [self.shareView addSubview:button];
    [button addTarget:self action:@selector(shareItemDidTap:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat buttonWidth = [Helper autoWidthWith:60.f];
    CGFloat distance = (kMainBoundsWidth - buttonWidth * 4) / 5 * (index + 1) + buttonWidth * index;
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(buttonWidth);
        make.left.mas_equalTo(distance);
        make.centerY.mas_equalTo(5);
    }];
    
    
//    CGFloat imageWidth = [Helper autoWidthWith:50.f];
//    CGFloat viewWidth = kMainBoundsWidth / 4;
//    CGFloat viewHeight = imageWidth + 10.f;
//    CGFloat centerX = kMainBoundsWidth / 4 * index + viewWidth / 2;
//    
//    UIView * view = [[UIView alloc] initWithFrame:CGRectZero];
//    view.tag = 101 + type;
//    [self.shareView addSubview:view];
//    [view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(10);
//        make.centerX.mas_equalTo(self.shareView.mas_left).offset(centerX);
//        make.size.mas_equalTo(CGSizeMake(viewWidth, viewHeight));
//    }];
//    
//    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//    [imageView setImage:[UIImage imageNamed:imageName]];
//    [view addSubview:imageView];
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(imageWidth, imageWidth));
//        make.center.mas_equalTo(0);
//    }];
//
//    UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
//    label.font = [UIFont systemFontOfSize:12];
//    label.textColor = UIColorFromRGB(0x666666);
//    label.textAlignment = NSTextAlignmentCenter;
//    label.text = title;
//    [view addSubview:label];
//    [label mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(0);
//        make.bottom.mas_equalTo(0);
//        make.right.mas_equalTo(0);
//        make.height.mas_equalTo(13);
//    }];
    
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareItemDidTap:)];
//    [view addGestureRecognizer:tap];
}

- (void)shareItemDidTap:(UIButton *)button
{
    UMSocialPlatformType type = button.tag - 101;
    
    NSString * text = RDLocalizedString(@"RDString_ShareAPPTitle");
    if (self.type == SHARERDTYPE_GAME) {
        text = RDLocalizedString(@"RDString_ShareAPPDetail");
    }
    
    switch (type) {
        case UMSocialPlatformType_WechatSession:
            [[UMCustomSocialManager defaultManager] shareRDApplicationToPlatform:UMSocialPlatformType_WechatSession currentViewController:self title:text];
            break;
            
        case UMSocialPlatformType_WechatTimeLine:
            [[UMCustomSocialManager defaultManager] shareRDApplicationToPlatform:UMSocialPlatformType_WechatTimeLine currentViewController:self title:text];
            break;
            
        case UMSocialPlatformType_QQ:
            [[UMCustomSocialManager defaultManager] shareRDApplicationToPlatform:UMSocialPlatformType_QQ currentViewController:self title:text];
            break;
            
        case UMSocialPlatformType_Sina:
            [[UMCustomSocialManager defaultManager] shareRDApplicationToPlatform:UMSocialPlatformType_Sina currentViewController:self title:text];
            break;
            
//        case UMSocialPlatformType_UnKnown:
//        {
//            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//            pasteboard.string = [NSString stringWithFormat:@"%@?st=usershare&clientname=ios&deviceid=%@", RDDownLoadURL, [GCCKeyChain load:keychainID]];
//            [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_SuccessWithCopy") delay:1.5f];
//            
//            [SAVORXAPI postUMHandleWithContentId:@"menu_recommend_copy_link" key:nil value:nil];
//        }
            break;
            
        default:
            break;
    }
}

- (UIImage *)getRDQRQodeWithURL:(NSString *)url
{
    
    // 1.创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 2.恢复默认
    [filter setDefaults];
    
    // 3.给过滤器添加数据(正则表达式/账号和密码)
    NSString *dataString = url;
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];
    
    // 4.获取输出的二维码
    CIImage *outputImage = [filter outputImage];
    
    //因为生成的二维码模糊，所以通过createNonInterpolatedUIImageFormCIImage:outputImage来获得高清的二维码图片
    
    // 5.显示二维码
    UIImage * image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:[Helper autoWidthWith:125.f]];
    
    return image;
}

/**
 *  根据CIImage生成指定大小的UIImage
 *
 *  @param image CIImage
 *  @param size  图片宽度
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    UIImage * QRImage = [UIImage imageWithCGImage:scaledImage];
    UIImage * result = [self qrCodeImageWithImage:QRImage]; //改变二维码颜色
    UIImage * iconImage = [UIImage imageNamed:@"shareDefalut"];
    
    return [self addIconWithQRCodeImage:result iconImage:iconImage scale:1/3.5f];
}


void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

//改变二维码颜色
- (UIImage *)qrCodeImageWithImage:(UIImage *)image{
    int imageWidth = image.size.width;
    int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpaceRef, kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    
    CGFloat total = hypot(image.size.width, image.size.height);
    
    int currentX = 0;
    int currentY = 0;
    //遍历像素, 改变像素点颜色
    int pixelNum = imageWidth * imageHeight;
    uint32_t *pCurPtr = rgbImageBuf;
    for (int i = 0; i<pixelNum; i++, pCurPtr++) {
        
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900) {
            currentY = i % imageHeight;
            currentX = i / imageWidth;
            CGFloat currentHy = hypot(imageWidth - currentX, imageHeight - currentY);
            CGFloat scale = currentHy / total;
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = 64 + (118 - 64) * scale;
            ptr[2] = 37 + (152 - 37) * scale;
            ptr[1] = 55 + (199 - 55) * scale;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    //取出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpaceRef,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage *resultImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpaceRef);
    return resultImage;
}

- (UIImage *)addIconWithQRCodeImage:(UIImage *)image iconImage:(UIImage *)icon scale:(CGFloat)scale
{
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat iconWidth = imageWidth * scale;
    CGFloat iconHeight = imageHeight * scale;
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, imageHeight);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, 3 * M_PI_2);
    CGContextTranslateCTM(context, -imageHeight, 0);
    
    CGContextScaleCTM(context, imageHeight/imageWidth, imageWidth/imageHeight);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    UIImage *QRCode = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    
    [QRCode drawInRect:CGRectMake(0, 0, imageWidth, imageHeight)];
    [icon drawInRect:CGRectMake((imageWidth - iconWidth) / 2, (imageHeight - iconHeight) / 2, iconWidth, iconHeight)];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (void)navBackButtonClicked:(UIButton *)sender {
    
    [SAVORXAPI postUMHandleWithContentId:@"menu_recommend_back" key:nil value:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
