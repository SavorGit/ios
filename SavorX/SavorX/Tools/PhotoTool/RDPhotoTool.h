//
//  RDPhotoTool.h
//  SavorX
//
//  Created by 郭春城 on 2017/7/4.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "RDPhotoLibraryModel.h"

typedef void(^ResSuccess)(NSDictionary * item);
typedef void(^ResFailed)(NSError * error);
@interface RDPhotoTool : NSObject

+ (void)loadPHAssetWithHander:(void(^)(NSArray *result, RDPhotoLibraryModel * cameraResult))success;

+ (UIImage *)makeThumbnailOfSize:(CGSize)size image:(UIImage *)img;

//检查用户是否开启相机权限
+ (void)checkUserLibraryAuthorizationStatusWithSuccess:(void(^)())success failure:(ResFailed)failure;

+ (void)getImageFromPHAssetSourceWithAsset:(PHAsset *)asset success:(void (^)(UIImage * result))success;

+ (void)compressImageWithImage:(UIImage *)image finished:(void (^)(NSData *, NSData *))finished;

/**
 *  从PHAsset中导出对应视频对象
 *
 *  @param asset PHAsset资源对象
 *  @param startHandler 开始导出视频的回调，session是导出类的相关信息
 *  @param endHandler 导出视频的回调，path表示导出的路径，session是导出类的相关信息
 */
+ (void)exportVideoToMP4WithAsset:(PHAsset *)asset startHandler:(void (^)(AVAssetExportSession * session))startHandler endHandler:(void (^)(NSString * filePath, NSString * url, AVAssetExportSession * session))endHandler;

@end
