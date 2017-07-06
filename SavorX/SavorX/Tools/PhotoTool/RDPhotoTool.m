//
//  RDPhotoTool.m
//  SavorX
//
//  Created by 郭春城 on 2017/7/4.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDPhotoTool.h"

@implementation RDPhotoTool

+ (void)loadPHAssetWithHander:(void (^)(NSArray *, RDPhotoLibraryModel *))success
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //初始化手机相册数组
        NSMutableArray * collections = [[NSMutableArray alloc] init];
        
        //初始化手机相册遍历参数
        PHFetchOptions *userAlbumsOptions = [PHFetchOptions new];
        //设定只获取手机相册中的相片数量大于0的相册
        userAlbumsOptions.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
        
        //列出手机自带相册
        PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                               subtype:PHAssetCollectionSubtypeAlbumSyncedEvent options:userAlbumsOptions];
        
        //列出所有用户创建
        PHFetchResult *userCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        
        NSArray * collectionsFetchResults = @[syncedAlbums, userCollections];
        
        // 获得相机胶卷
        PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
        if (cameraRoll) {
            PHFetchResult * cameraResult = [PHAsset fetchAssetsInAssetCollection:cameraRoll options:nil];
            if (cameraResult && cameraResult.count > 0) {
                RDPhotoLibraryModel * model = [[RDPhotoLibraryModel alloc] init];
                model.fetchResult = cameraResult;
                model.title = cameraRoll.localizedTitle;
                model.createTime = [self transformAblumTitle:cameraRoll.localizedTitle];
                model.localIdentifier = cameraRoll.localIdentifier;
                [collections addObject:model];
            }
        }
        
        //列出所有相册智能相册
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
        [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
            if (collection) {
                //            PHFetchOptions * option = [[PHFetchOptions alloc] init];
                //            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
                if (assetsFetchResult.count > 0) {
                    RDPhotoLibraryModel * model = [[RDPhotoLibraryModel alloc] init];
                    model.fetchResult = assetsFetchResult;
                    model.createTime = [self transformDate:collection.startDate];
                    model.title = [self transformAblumTitle:collection.localizedTitle];
                    model.localIdentifier = collection.localIdentifier;
                    if ([model.title isEqualToString:@"最近删除"]) {
                        
                    }else{
                        if (collections.count > 0) {
                            RDPhotoLibraryModel * first = collections.firstObject;
                            if ([first.localIdentifier isEqualToString:model.localIdentifier]) {
                                
                            }else{
                                [collections addObject:model];
                            }
                        }
                    }
                }
            }
        }];
        
        for (int i = 0; i < collectionsFetchResults.count; i ++) {
            PHFetchResult *fetchResult = collectionsFetchResults[i];
            if (fetchResult.count > 0) {
                [fetchResult enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
                    if (collection) {
                        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
                        if (assetsFetchResult.count > 0) {
                            RDPhotoLibraryModel * model = [[RDPhotoLibraryModel alloc] init];
                            
                            model.fetchResult = assetsFetchResult;
                            model.title = collection.localizedTitle;
                            model.createTime = [self transformAblumTitle:collection.localizedTitle];
                            model.localIdentifier = collection.localIdentifier;
                            if (![model.title isEqualToString:@"最近删除"]) {
                                [collections addObject:model];
                            }
                        }
                    }
                }];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            success([NSArray arrayWithArray:collections], [collections objectAtIndex:0]);
        });
    });
}

/**
 *  对相册的缩略图进行处理
 *
 *  @param size 需要得到的size大小
 *  @param img  需要转换的image
 *
 *  @return 返回一个UIImage对象，即为所需展示缩略图
 */
+ (UIImage *)makeThumbnailOfSize:(CGSize)size image:(UIImage *)img
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    // draw scaled image into thumbnail context
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    // pop the context
    UIGraphicsEndImageContext();
    return newThumbnail;
}

+ (void)checkUserLibraryAuthorizationStatusWithSuccess:(void (^)())success failure:(ResFailed)failure
{
    //判断用户是否拥有权限
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    success();
                }else{
                    NSError * error = [NSError errorWithDomain:@"com.userLibrary" code:101 userInfo:nil];
                    failure(error);
                }
            });
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
        dispatch_async(dispatch_get_main_queue(), ^{
            success();
        });
    } else{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError * error = [NSError errorWithDomain:@"com.userLibrary" code:102 userInfo:nil];
            failure(error);
        });
    }
}

+ (NSString *)transformDate:(NSDate *)date
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:date];
}

+ (NSString *)transformAblumTitle:(NSString *)title
{
    if ([title isEqualToString:@"Slo-mo"]) {
        return @"慢动作";
    } else if ([title isEqualToString:@"Recently Added"]) {
        return @"最近添加";
    } else if ([title isEqualToString:@"Favorites"]) {
        return @"最爱";
    } else if ([title isEqualToString:@"Recently Deleted"]) {
        return @"最近删除";
    } else if ([title isEqualToString:@"Videos"]) {
        return @"视频";
    } else if ([title isEqualToString:@"All Photos"]) {
        return @"所有照片";
    } else if ([title isEqualToString:@"Selfies"]) {
        return @"自拍";
    } else if ([title isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    } else if ([title isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    }
    return title;
}

+ (void)getImageFromPHAssetSourceWithAsset:(PHAsset *)asset success:(void (^)(UIImage *))success
{
    //导出图片的参数
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.synchronous = YES; //开启线程同步
    option.resizeMode = PHImageRequestOptionsResizeModeExact; //标准的图片尺寸
    option.version = PHImageRequestOptionsVersionCurrent; //获取用户操作的图片
    option.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat; //高质量
    
    CGFloat width = asset.pixelWidth;
    CGFloat height = asset.pixelHeight;
    CGFloat scale = width / height;
    CGFloat tempScale = 1920 / 1080.f;
    CGSize size;
    if (scale > tempScale) {
        size = CGSizeMake(1920, 1920 / scale);
    }else{
        size = CGSizeMake(1080 * scale, 1080);
    }
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        success(result);
    }];
}

+ (void)compressImageWithImage:(UIImage *)image finished:(void (^)(NSData *, NSData *))finished
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData*  data = [NSData data];
        data = UIImageJPEGRepresentation(image, 1);
        float tempX = 0.9;
        NSInteger length = data.length;
        while (data.length > ImageSize) {
            data = UIImageJPEGRepresentation(image, tempX);
            tempX -= 0.1;
            if (data.length == length) {
                break;
            }
            length = data.length;
        }
        
        UIImage * tempImage = [UIImage imageWithData:data];
        
        CGFloat scale = 1920 / 1080 > tempImage.size.width / tempImage.size.height ? 152 / tempImage.size.height : 270 / tempImage.size.width;
        
        tempImage = [tempImage scaleToSize:CGSizeMake((NSInteger)(tempImage.size.width * scale), (NSInteger)(tempImage.size.height * scale))];
        NSData * tempData = UIImageJPEGRepresentation(tempImage, 1);
        
        finished(tempData, data);
    });
}

@end
