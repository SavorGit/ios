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
        make.top.mas_equalTo([Helper autoHeightWith:50]);
        make.centerX.mas_equalTo(0);
    }];
    
    NSString * QRURL = [NSString stringWithFormat:@"%@?st=qrcode&clientname=ios&deviceid=%@", RDDownLoadURL, [GCCKeyChain load:keychainID]];
    UIImage * QRImage = [self getRDQRQodeWithURL:QRURL];
    
    UIImageView * codeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:codeImageView];
    [codeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(self.shareView.mas_top).offset(-[Helper autoHeightWith:65]);
        make.size.mas_equalTo(CGSizeMake([Helper autoHeightWith:230], [Helper autoHeightWith:230]));
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
    CGFloat width = kMainBoundsHeight > kMainBoundsWidth ? kMainBoundsWidth : kMainBoundsHeight;
    
    if (self.shareView) {
        [self.shareView removeAllSubviews];
    }
    
    self.shareView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.shareView];
    [self.shareView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo([Helper autoHeightWith:140.f] + 10.f);
    }];
    
    CGFloat lineWidth = (width - 80.f) / 2;
    UIView * leftLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, lineWidth, .5f)];
    leftLineView.backgroundColor = UIColorFromRGB(0xdfdfdf);
    [self.shareView addSubview:leftLineView];
    
    UIView * rightLineView = [[UIView alloc] initWithFrame:CGRectMake(width - lineWidth, 10, lineWidth, .5f)];
    rightLineView.backgroundColor = UIColorFromRGB(0xdfdfdf);
    [self.shareView addSubview:rightLineView];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = UIColorFromRGB(0x666666);
    label.backgroundColor = [UIColor clearColor];
    label.text = @"分享到";
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
//  @[@"微信", @"朋友圈", @"QQ", @"新浪微博", @"复制链接"];
    NSMutableArray * platformArray = [NSMutableArray new];
    
    if ([[UMSocialManager defaultManager] isSupport:UMSocialPlatformType_WechatSession]) {
        [imageArray addObject:@"WeChat"];
        [titleArray addObject:@"微信"];
        [platformArray addObject:[NSNumber numberWithInteger:UMSocialPlatformType_WechatSession]];
    }
    if ([[UMSocialManager defaultManager] isSupport:UMSocialPlatformType_WechatTimeLine]) {
        [imageArray addObject:@"friends"];
        [titleArray addObject:@"朋友圈"];
        [platformArray addObject:[NSNumber numberWithInteger:UMSocialPlatformType_WechatTimeLine]];
    }
    if ([[UMSocialManager defaultManager] isSupport:UMSocialPlatformType_QQ]) {
        [imageArray addObject:@"qq"];
        [titleArray addObject:@"QQ"];
        [platformArray addObject:[NSNumber numberWithInteger:UMSocialPlatformType_QQ]];
    }
    [imageArray addObject:@"weibo"];
    [titleArray addObject:@"新浪微博"];
    [platformArray addObject:[NSNumber numberWithInteger:UMSocialPlatformType_Sina]];
    [imageArray addObject:@"fuzhilianjie"];
    [titleArray addObject:@"复制链接"];
    [platformArray addObject:[NSNumber numberWithInteger:UMSocialPlatformType_UnKnown]];
    
    for (NSInteger i = 0; i < imageArray.count; i++) {
        [self createItemWithImageName:[imageArray objectAtIndex:i] title:[titleArray objectAtIndex:i] index:i type:[[platformArray objectAtIndex:i] integerValue]];
    }
}

- (void)createItemWithImageName:(NSString *)imageName title:(NSString *)title index:(NSInteger)index type:(UMSocialPlatformType)type
{
    CGFloat imageWidth = [Helper autoWidthWith:50.f];
    CGFloat viewWidth = kMainBoundsWidth / 5;
    CGFloat viewHeight = imageWidth + 25.f;
    CGFloat centerY = kMainBoundsWidth / 5 * index + viewWidth / 2;
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectZero];
    view.tag = 101 + type;
    [self.shareView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(10);
        make.centerX.mas_equalTo(self.shareView.mas_left).offset(centerY);
        make.size.mas_equalTo(CGSizeMake(viewWidth, viewHeight));
    }];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [imageView setImage:[UIImage imageNamed:imageName]];
    [view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(imageWidth, imageWidth));
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(5.f);
    }];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = UIColorFromRGB(0x666666);
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(13);
    }];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareItemDidTap:)];
    [view addGestureRecognizer:tap];
}

- (void)shareItemDidTap:(UITapGestureRecognizer *)tap
{
    UMSocialPlatformType type = tap.view.tag - 101;
    
    NSString * text = @"我觉得小热点很好用, 推荐给您~";
    if (self.type == SHARERDTYPE_GAME) {
        text = @"快点儿来参加抽奖活动哦~";
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
            
        case UMSocialPlatformType_UnKnown:
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = [NSString stringWithFormat:@"%@?st=usershare&clientname=ios&deviceid=%@", RDDownLoadURL, [GCCKeyChain load:keychainID]];
            [MBProgressHUD showTextHUDwithTitle:@"复制成功" delay:1.5f];
            
            [SAVORXAPI postUMHandleWithContentId:@"menu_recommend_copy_link" key:nil value:nil];
        }
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
    UIImage * image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:[Helper autoWidthWith:230.f]];
    
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
    UIImage * iconImage = [UIImage imageNamed:@"shareDefalut"];
    
    return [self addIconWithQRCodeImage:QRImage iconImage:iconImage scale:1/3.5f];
}

- (UIImage *)addIconWithQRCodeImage:(UIImage *)image iconImage:(UIImage *)icon scale:(CGFloat)scale
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat iconWidth = imageWidth * scale;
    CGFloat iconHeight = imageHeight * scale;
    
    [image drawInRect:CGRectMake(0, 0, imageWidth, imageHeight)];
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
