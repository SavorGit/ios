//
//  UMCustomSocialManager.m
//  SavorX
//
//  Created by 郭春城 on 16/11/30.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "UMCustomSocialManager.h"
#import <UMSocialCore/UMSocialCore.h>
#import <UShareUI/UShareUI.h>

@interface UMCustomSocialManager ()

@property (nonatomic, strong) HSVodModel * model;
@property (nonatomic, strong) UIViewController * controller;
@property (nonatomic, strong) NSMutableArray * titles;
@property (nonatomic, strong) NSMutableArray * images;
@property (nonatomic, assign) BOOL isQQInstall;
@property (nonatomic, assign) BOOL isWXInstall;
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, copy) NSString * info;

@end

@implementation UMCustomSocialManager

+ (UMCustomSocialManager *)defaultManager
{
    static dispatch_once_t once;
    static UMCustomSocialManager *manager;
    dispatch_once(&once, ^ {
        manager = [[UMCustomSocialManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.info = @"热点聚焦 , 投你所好";
    }
    return self;
}

- (void)showUMSocialSharedWithModel:(HSVodModel *)model andController:(UIViewController *)controller
{
    self.model = model;
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        
        switch (platformType) {
                //微信聊天
            case UMSocialPlatformType_WechatSession:
                [self shareWebPageToPlatform:UMSocialPlatformType_WechatSession andController:controller];
                break;
                
                //微信朋友圈
            case UMSocialPlatformType_WechatTimeLine:
                [self shareWebPageToPlatform:UMSocialPlatformType_WechatTimeLine andController:controller];
                break;
                
                //微信收藏
            case UMSocialPlatformType_WechatFavorite:
                [self shareWebPageToPlatform:UMSocialPlatformType_WechatFavorite andController:controller];
                break;
                
                //QQ聊天
            case UMSocialPlatformType_QQ:
                [self shareWebPageToPlatform:UMSocialPlatformType_QQ andController:controller];
                break;
                
                //QQ空间
            case UMSocialPlatformType_Qzone:
                [self shareWebPageToPlatform:UMSocialPlatformType_Qzone andController:controller];
                break;
                
                //新浪微博
            case UMSocialPlatformType_Sina:
                
            {
                    NSString * url = [model.contentURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSString * text = [NSString stringWithFormat:@"热点儿 | %@\n%@", model.title, url];
                    if ([self convertToByte:text] > 140) {
                        text = [NSString stringWithFormat:@"热点儿\n%@", url];
                        if ([self convertToByte:text] > 140) {
                            [MBProgressHUD showTextHUDwithTitle:@"该文章暂不支持新浪分享"];
                            return;
                        }
                    }
                    
                    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
                    messageObject.text = text;
                    //创建图片内容对象
                    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
                if ([UMCustomSocialManager defaultManager].image) {
                    shareObject.shareImage = [UMCustomSocialManager defaultManager].image;
                }else{
                    shareObject.shareImage = [UIImage imageNamed:@"shareDefalut"];
                }
                messageObject.shareObject = shareObject;
                
                [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:controller completion:^(id result, NSError *error) {
                    
                }];
            }
                
                break;
                
            default:
                break;
        }
    }];
}

- (NSInteger)convertToByte:(NSString*)str {
    NSInteger strlength = 0;
    char* p = (char*)[str cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[str lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return (strlength+1)/2;
}

/**
 *  分享至平台
 */
- (void)shareWebPageToPlatform:(UMSocialPlatformType)platformType andController:(UIViewController *)VC
{
    NSString * url = [self.model.contentURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    UIImage * image;
    if ([UMCustomSocialManager defaultManager].image) {
        image = [UMCustomSocialManager defaultManager].image;
    }else{
        image = [UIImage imageNamed:@"shareDefalut"];
    }
    
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //创建网页分享类型
    UMShareWebpageObject * object = [UMShareWebpageObject shareObjectWithTitle:[NSString stringWithFormat:@"热点儿 - %@", self.model.title] descr:self.info thumImage:image];
    [object setWebpageUrl:url];
    messageObject.shareObject = object;
    
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:VC completion:^(id result, NSError *error) {
        
    }];
}

@end
