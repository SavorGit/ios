//
//  SAVORXAPI.h
//  SavorX
//
//  Created by 郭春城 on 16/8/4.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "BGUploadRequest.h"
#import "CreateWealthModel.h"

typedef NS_ENUM(NSInteger, handleType) {
    collectHandle = 1, //收藏
    readHandle, //阅读
    shareHandle, //分享
    cancleCollectHandle, //取消收藏
    demandHandle, //点播
    clickHandel = 7, //点击
    allOpenHandle //完全打开量
};

typedef NS_ENUM(NSInteger, interactType) {
    interactDemand = 1, //点播
    interactScreen, //投屏
    interactDiscover //发现
};

@interface SAVORXAPI : NSObject

+ (void)configApplication;

/**
 *  POST网络请求
 *
 *  @param urlStr     请求地址
 *  @param parameters 请求参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *  @return NSURLSessionDataTask对象
 */
+ (NSURLSessionDataTask *)postWithURL:(NSString *)urlStr parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask * task, NSDictionary * result))success failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure;

/**
 *  GET网络请求
 *
 *  @param urlStr     请求地址
 *  @param parameters 请求参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 * @return NSURLSessionDataTask对象
 */
+ (NSURLSessionDataTask *)getWithURL:(NSString *)urlStr parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask * task, NSDictionary * result))success failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure;

/**
 *  游戏投蛋请求
 *
 *  @param urlStr     请求地址
 *  @param hunger     期望中奖
 *  @param date       投蛋时间
 * @return NSURLSessionDataTask对象
 */
+ (NSURLSessionDataTask *)gameForEggsWithURL:(NSString *)urlStr  hunger:(NSInteger)hunger date:(NSString *)date force:(NSInteger)force success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

/**
 *  游戏砸蛋请求
 *
 *  @param urlStr     请求地址
 * @return NSURLSessionDataTask对象
 */
+ (NSURLSessionDataTask *)gameSmashedEggWithURL:(NSString *)urlStr success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

/**
 *  点播视频请求
 *
 *  @param urlStr     请求地址
 *  @param name       点播的视频名称
 *  @param type       点播的视频类型
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *  @param position   点播视频的初始进度
 * @return NSURLSessionDataTask对象
 */
+ (NSURLSessionDataTask *)demandWithURL:(NSString *)urlStr name:(NSString *)name type:(NSInteger)type position:(CGFloat)position force:(NSInteger)force success:(void (^)(NSURLSessionDataTask * task, NSDictionary * result))success failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure;

/**
 *  音量控制请求
 *
 *  @param urlStr     请求地址
 *  @param action     音量控制的动作类型
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 * @return NSURLSessionDataTask对象
 */
+ (NSURLSessionDataTask *)volumeWithURL:(NSString *)urlStr action:(NSInteger)action success:(void (^)(NSURLSessionDataTask * task, NSDictionary * result))success failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure;

/**
 *  投屏图片请求
 *
 *  @param urlStr       请求地址
 *  @param data         投屏的图片数据
 *  @param name         投屏的图片名称
 *  @param type         投屏的图片类型
 *  @param isThumbnail  是否是缩略图
 *  @param rotation     投屏的图片角度
 *  @param success      请求成功的回调
 *  @param seriesId     投屏图片的标识
 *  @param failure      请求失败的回调
 * @return NSURLSessionDataTask对象
 */
+ (NSURLSessionDataTask *)postImageWithURL:(NSString *)urlStr data:(NSData *)data name:(NSString *)name type:(NSInteger)type isThumbnail:(BOOL)isThumbnail rotation:(NSInteger)rotation seriesId:(NSString *)seriesId  force:(NSInteger)force success:(void (^)())success failure:(void (^)())failure;

/**
 *  投屏文件图片请求
 *
 *  @param urlStr       请求地址
 *  @param data         投屏的图片数据
 *  @param name         投屏的图片名称
 *  @param type         投屏的图片类型
 *  @param isThumbnail  是否是缩略图
 *  @param rotation     投屏的图片角度
 *  @param success      请求成功的回调
 *  @param seriesId     投屏图片的标识
 *  @param failure      请求失败的回调
 * @return NSURLSessionDataTask对象
 */
+ (NSURLSessionDataTask *)postFileImageWithURL:(NSString *)urlStr data:(NSData *)data name:(NSString *)name type:(NSInteger)type isThumbnail:(BOOL)isThumbnail rotation:(NSInteger)rotation seriesId:(NSString *)seriesId force:(NSInteger)force success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  投屏视频请求
 *
 *  @param urlStr       请求地址
 *  @param mediaPath    投屏的视频地址
 *  @param position     投屏的初始进度
 *  @param success      请求成功的回调
 *  @param failure      请求失败的回调
 * @return NSURLSessionDataTask对象
 */
+ (NSURLSessionDataTask *)postVideoWithURL:(NSString *)urlStr mediaPath:(NSString *)mediaPath position:(NSString *)position force:(NSInteger)force success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

/**
 *  视频暂停请求
 *
 *  @param urlStr       请求地址
 *  @param success      请求成功的回调
 *  @param failure      请求失败的回调
 * @return NSURLSessionDataTask对象
 */
+ (NSURLSessionDataTask *)pauseVideoWithURL:(NSString *)urlStr success:(void (^)(NSURLSessionDataTask * task, NSDictionary * result))success failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure;

/**
 *  视频恢复播放请求
 *
 *  @param urlStr       请求地址
 *  @param success      请求成功的回调
 *  @param failure      请求失败的回调
 * @return NSURLSessionDataTask对象
 */
+ (NSURLSessionDataTask *)resumeVideoWithURL:(NSString *)urlStr success:(void (^)(NSURLSessionDataTask * task, NSDictionary * result))success failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure;

/**
 *  视频设置进度请求
 *
 *  @param urlStr       请求地址
 *  @param success      请求成功的回调
 *  @param position     设置的进度
 *  @param failure      请求失败的回调
 * @return NSURLSessionDataTask对象
 */
+ (NSURLSessionDataTask *)seekVideoWithURL:(NSString *)urlStr position:(NSString *)position success:(void (^)(NSURLSessionDataTask * task, NSDictionary * result))success failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure;

/**
 *  视频获取进度请求
 *
 *  @param urlStr       请求地址
 *  @param success      请求成功的回调
 *  @param failure      请求失败的回调
 * @return NSURLSessionDataTask对象
 */
+ (NSURLSessionDataTask *)queryVideoWithURL:(NSString *)urlStr success:(void (^)(NSURLSessionDataTask * task, NSDictionary * result))success failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure;

/**
 *  旋转图片请求
 *
 * @return NSURLSessionDataTask对象
 */
+ (NSURLSessionDataTask *)rotateWithURL:(NSString *)urlStr success:(void (^)(NSURLSessionDataTask * task, NSDictionary * result))success failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure;

+ (void)screenDLNAImageWithKeyStr:(NSString *)keyStr WithSuccess:(void(^)())successBlock failure:(void(^)())failureBlock;

/**
 *  展示一个只带确认按钮的信息提示框
 *
 *  @param str 提示信息
 *  @param VC  需要提示的控制器
 */
+ (void)showAlertWithString:(NSString *)str withController:(UIViewController *)VC;

/**
 *  获取最上层试图控制器
 *
 *  @return UIViewController控制器对象
 */
+ (UINavigationController *)getCurrentViewController;

/**
 *  电视机退出投屏点播
 */
+ (void)ScreenDemandShouldBackToTV:(BOOL)fromHomeType success:(void(^)())successBlock failure:(void(^)())failureBlock;


/**
 *  电视机退出投屏点播
 */
+ (void)ScreenDemandShouldBackToTVWithSuccess:(void(^)())successBlock failure:(void(^)())failureBlock;

/**
 *  友盟上传事件
 *
 *  @param contentId 文章ID
 *  @param type      事件的类型
 */
+ (void)postUMHandleWithContentId:(NSInteger)contentId withType:(handleType)type;

/**
 *  友盟上传事件
 *
 *  @param eventId   事件ID
 *  @param key       事件参数对应的key
 *  @param key       事件参数对应的value
 */
+ (void)postUMHandleWithContentId:(NSString *)eventId key:(NSString *)key value:(NSString *)value;

/**
 *  友盟上传事件
 *
 *  @param eventId   事件ID
 *  @param parmDic   事件参数对应的字典
 */
+ (void)postUMHandleWithContentId:(NSString *)eventId withParmDic:(NSDictionary *)parmDic;

+ (void)showAlertWithMessage:(NSString *)message;

+ (void)showConnetToTVAlert:(NSString *)type;

//投屏成功的铃声
+ (void)successRing;

+ (void)saveFileOnPath:(NSString *)path withArray:(NSArray *)array;
+ (void)saveFileOnPath:(NSString *)path withDictionary:(NSDictionary *)dict;

+ (void)checkVersionUpgrade;

+ (void)screenEggsStopGame;

+ (void)cancelAllURLTask;

@end
