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

@end
