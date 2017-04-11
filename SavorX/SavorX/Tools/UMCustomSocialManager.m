//
//  UMCustomSocialManager.m
//  SavorX
//
//  Created by 郭春城 on 16/11/30.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "UMCustomSocialManager.h"
#import <UShareUI/UShareUI.h>
#import "GCCKeyChain.h"

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
        [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession), @(UMSocialPlatformType_WechatTimeLine), @(UMSocialPlatformType_WechatFavorite), @(UMSocialPlatformType_QQ), @(UMSocialPlatformType_Qzone), @(UMSocialPlatformType_Sina)]];
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
                    NSString * text = [NSString stringWithFormat:@"小热点 | %@\n%@", model.title, url];
                    if ([self convertToByte:text] > 140) {
                        text = [NSString stringWithFormat:@"小热点\n%@", url];
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
                    
                    if (error) {
                        [MBProgressHUD showTextHUDwithTitle:@"分享失败" delay:1.5f];
                    }else{
                        [MBProgressHUD showTextHUDwithTitle:@"分享成功" delay:1.5f];
                    }
                    
                }];
            }
                
                break;
                
            default:
                break;
        }
    }];
}

- (void)showUMSocialSharedWithModel:(HSVodModel *)model andController:(UIViewController *)controller andType:(NSUInteger)type{
    
    self.model = model;
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        
        switch (platformType) {
                //微信聊天
            case UMSocialPlatformType_WechatSession:
                if (type == 0) {
                   [self shareWebPageToPlatform:UMSocialPlatformType_WechatSession andController:controller andType:type andUmKeyString:@"details_page_share_weixin"];
                }else if (type == 1) {
                   [self shareWebPageToPlatform:UMSocialPlatformType_WechatSession andController:controller andType:type andUmKeyString:@"bunch planting_page_share_weixin"];
                }

                break;
                
                //微信朋友圈
            case UMSocialPlatformType_WechatTimeLine:
                if (type == 0) {
                   [self shareWebPageToPlatform:UMSocialPlatformType_WechatTimeLine andController:controller andType:type andUmKeyString:@"details_page_share_weixin_friends"];
                }else if (type == 1){
                   [self shareWebPageToPlatform:UMSocialPlatformType_WechatTimeLine andController:controller andType:type andUmKeyString:@"bunch planting_page_share_weixin_friends"];
                }

                break;
                
                //微信收藏
            case UMSocialPlatformType_WechatFavorite:
                if (type == 0) {
                    [self shareWebPageToPlatform:UMSocialPlatformType_WechatFavorite andController:controller andType:type andUmKeyString:@"details_page_share_weixin_collection"];
                }else if (type == 1){
                    [self shareWebPageToPlatform:UMSocialPlatformType_WechatFavorite andController:controller andType:type andUmKeyString:@"bunch planting_page_share_weixin_collection"];
                }

                break;
                
                //QQ聊天
            case UMSocialPlatformType_QQ:
                if (type == 0) {
                    [self shareWebPageToPlatform:UMSocialPlatformType_QQ andController:controller andType:type andUmKeyString:@"details_page_share_qq"];
                }else if (type == 1){
                    [self shareWebPageToPlatform:UMSocialPlatformType_QQ andController:controller andType:type andUmKeyString:@"bunch planting_page_share_qq"];
                }
                
                break;
                
                //QQ空间
            case UMSocialPlatformType_Qzone:
                if (type == 0) {
                    [self shareWebPageToPlatform:UMSocialPlatformType_Qzone andController:controller andType:type andUmKeyString:@"details_page_share_qq_zone"];
                }else if (type == 1){
                    [self shareWebPageToPlatform:UMSocialPlatformType_Qzone andController:controller andType:type andUmKeyString:@"bunch planting_page_share_qq_zone"];
                }

                break;
                
                //新浪微博
            case UMSocialPlatformType_Sina:
                
            {
                NSString * url = [model.contentURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString * text = [NSString stringWithFormat:@"小热点 | %@\n%@", model.title, url];
                if ([self convertToByte:text] > 140) {
                    text = [NSString stringWithFormat:@"小热点\n%@", url];
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
                    
                    if (error) {
                        [MBProgressHUD showTextHUDwithTitle:@"分享失败" delay:1.5f];
                        if (type == 0) {
                            [SAVORXAPI postUMHandleWithContentId:@"details_page_share_sina" key:@"details_page_share_sina" value:@"fail"];
                        }else if (type == 1){
                            [SAVORXAPI postUMHandleWithContentId:@"bunch planting_page_share_sina" key:@"bunch planting_page_share_sina" value:@"fail"];
                        }
                    }else{
                        [MBProgressHUD showTextHUDwithTitle:@"分享成功" delay:1.5f];
                        if (type == 0) {
                            [SAVORXAPI postUMHandleWithContentId:@"details_page_share_sina" key:@"details_page_share_sina" value:@"success"];
                        }else if (type == 1){
                            [SAVORXAPI postUMHandleWithContentId:@"planting_page_share_sina" key:@"planting_page_share_sina" value:@"success"];
                        }
                    }
                    
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
    UMShareWebpageObject * object = [UMShareWebpageObject shareObjectWithTitle:[NSString stringWithFormat:@"小热点 - %@", self.model.title] descr:self.info thumImage:image];
    [object setWebpageUrl:url];
    messageObject.shareObject = object;
    
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:VC completion:^(id result, NSError *error) {
        
        if (error) {
            [MBProgressHUD showTextHUDwithTitle:@"分享失败" delay:1.5f];
        }else{
            [MBProgressHUD showTextHUDwithTitle:@"分享成功" delay:1.5f];
        }
        
    }];
}

/**
 *  分享至平台
 */
- (void)shareWebPageToPlatform:(UMSocialPlatformType)platformType andController:(UIViewController *)VC andType:(NSUInteger)type andUmKeyString:(NSString *)keyString
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
    UMShareWebpageObject * object = [UMShareWebpageObject shareObjectWithTitle:[NSString stringWithFormat:@"小热点 - %@", self.model.title] descr:self.info thumImage:image];
    [object setWebpageUrl:url];
    messageObject.shareObject = object;
    
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:VC completion:^(id result, NSError *error) {
        
        if (error) {
            [MBProgressHUD showTextHUDwithTitle:@"分享失败" delay:1.5f];
            [SAVORXAPI postUMHandleWithContentId:keyString key:keyString value:@"success"];
        }else{
            [MBProgressHUD showTextHUDwithTitle:@"分享成功" delay:1.5f];
            [SAVORXAPI postUMHandleWithContentId:keyString key:keyString value:@"fail"];
        }
        
    }];
}

- (void)shareRDApplicationToPlatform:(UMSocialPlatformType)type currentViewController:(UIViewController *)VC
{
    NSString * url = [NSString stringWithFormat:@"%@?st=usershare&clientname=ios&deviceid=%@", RDDownLoadURL, [GCCKeyChain load:keychainID]];
    NSString * title = @"我觉得小热点很好用, 推荐给您~";
    NSString * description = @"投屏神器, 进入饭局的才是热点";
    
    UIImage * image;
    image = [UIImage imageNamed:@"shareDefalut"];
    
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //创建网页分享类型
    UMShareWebpageObject * object;
    
    if (type == UMSocialPlatformType_Sina) {
        UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
        shareObject.shareImage = image;
        messageObject.text = [NSString stringWithFormat:@"%@\n%@\n%@", title, description, url];
        messageObject.shareObject = shareObject;
        [[UMSocialManager defaultManager] shareToPlatform:type messageObject:messageObject currentViewController:VC completion:^(id result, NSError *error) {
            
            if (error) {
                [MBProgressHUD showTextHUDwithTitle:@"分享失败" delay:1.5f];
                [SAVORXAPI postUMHandleWithContentId:@"menu_recommend_sina" key:@"menu_recommend_sina" value:@"fail"];
            }else{
                [MBProgressHUD showTextHUDwithTitle:@"分享成功" delay:1.5f];
                [SAVORXAPI postUMHandleWithContentId:@"menu_recommend_sina" key:@"menu_recommend_sina" value:@"success"];
            }
            
        }];
    }else{
        if(type == UMSocialPlatformType_WechatTimeLine) {
            object = [UMShareWebpageObject shareObjectWithTitle:title descr:description thumImage:image];
        }else{
            object = [UMShareWebpageObject shareObjectWithTitle:title descr:description thumImage:image];
        }
        [object setWebpageUrl:url];
        messageObject.shareObject = object;
        
        [[UMSocialManager defaultManager] shareToPlatform:type messageObject:messageObject currentViewController:VC completion:^(id result, NSError *error) {
            
            if (error) {
                [MBProgressHUD showTextHUDwithTitle:@"分享失败" delay:1.5f];
                if (type == UMSocialPlatformType_QQ) {
                    [SAVORXAPI postUMHandleWithContentId:@"menu_recommend_share_qq" key:@"menu_recommend_share_qq" value:@"fail"];
                }else if (type == UMSocialPlatformType_WechatSession){
                    [SAVORXAPI postUMHandleWithContentId:@"menu_recommend_share_weixin" key:@"menu_recommend_share_weixin" value:@"fail"];
                }else if (type == UMSocialPlatformType_WechatTimeLine){
                    [SAVORXAPI postUMHandleWithContentId:@"menu_recommend_share_weixin_friends" key:@"menu_recommend_share_weixin_friends" value:@"fail"];
                }
            }else{
                [MBProgressHUD showTextHUDwithTitle:@"分享成功" delay:1.5f];
                
                if (type == UMSocialPlatformType_QQ) {
                    [SAVORXAPI postUMHandleWithContentId:@"menu_recommend_share_qq" key:@"menu_recommend_share_qq" value:@"success"];
                }else if (type == UMSocialPlatformType_WechatSession){
                    [SAVORXAPI postUMHandleWithContentId:@"menu_recommend_share_weixin" key:@"menu_recommend_share_weixin" value:@"success"];
                }else if (type == UMSocialPlatformType_WechatTimeLine){
                    [SAVORXAPI postUMHandleWithContentId:@"menu_recommend_share_weixin_friends" key:@"menu_recommend_share_weixin_friends" value:@"success"];
                }
            }
            
        }];
    }
}

@end
