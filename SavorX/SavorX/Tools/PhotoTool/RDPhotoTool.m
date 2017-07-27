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

/**
 *  从PHAsset中导出对应视频对象
 *
 *  @param asset   PHAsset资源对象
 *  @param handler 导出视频的回调，path表示导出的路径，session是导出类的相关信息
 */
+ (void)exportVideoToMP4WithAsset:(PHAsset *)asset startHandler:(void (^)(AVAssetExportSession * session))startHandler endHandler:(void (^)(NSString * filePath, NSString * url, AVAssetExportSession * session))endHandler
{
    //配置导出参数
    PHVideoRequestOptions *options = [PHVideoRequestOptions new];
    options.networkAccessAllowed = YES;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    
    //通过PHAsset获取AVAsset对象
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        
        NSURL * filePath;
        
        //配置导出相关的信息，包括类型，翻转角度等
        AVURLAsset * urlAsset = (AVURLAsset *)asset;
        if ([urlAsset respondsToSelector:@selector(URL)]) {
            filePath = urlAsset.URL;
        }else{
            NSString * value = [info objectForKey:@"PHImageFileSandboxExtensionTokenKey"];
            NSString * path = [value substringFromIndex:[value rangeOfString:@"/var"].location];
            filePath = [NSURL fileURLWithPath:path];
        }
        NSInteger degrees = [self degressFromVideoFileWithURL:filePath];
        NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform translateToCenter;
        CGAffineTransform mixedTransform;
        AVMutableVideoComposition *waterMarkVideoComposition = [AVMutableVideoComposition videoComposition];
        
        //视频转换导出地址
        NSString *documentsDirectory = HTTPServerDocument;
        NSString* str = [documentsDirectory stringByAppendingPathComponent:RDScreenVideoName];
        
        NSURL * outputURL = [NSURL fileURLWithPath:str];
        
        //如果在目录下已经有视频文件了，就移除该文件后再执行导出操作，避免文件名冲突错误
        if ([[NSFileManager defaultManager] fileExistsAtPath:str]) {
            [[NSFileManager defaultManager] removeItemAtPath:str error:nil];
        }
        
        if (degrees == 0) {
            AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset     presetName:AVAssetExportPresetMediumQuality];
            session.outputURL = outputURL;
            session.outputFileType = AVFileTypeMPEG4;
            startHandler(session);
            //导出视频
            [session exportAsynchronouslyWithCompletionHandler:^(void)
             {
                 endHandler(filePath.path, str, session);
             }];
        }else{
            if(degrees == 90){
                //顺时针旋转90°
                translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0.0);
                mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2);
                waterMarkVideoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            }else if(degrees == 180){
                //顺时针旋转180°
                translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
                mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI);
                waterMarkVideoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width,videoTrack.naturalSize.height);
            }else {
                //顺时针旋转270°
                translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
                mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2*3.0);
                waterMarkVideoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            }
            
            
            AVMutableVideoCompositionInstruction *roateInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            roateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [asset duration]);
            AVMutableVideoCompositionLayerInstruction *roateLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
            
            roateInstruction.layerInstructions = @[roateLayerInstruction];
            //将视频方向旋转加入到视频处理中
            waterMarkVideoComposition.instructions = @[roateInstruction];
            waterMarkVideoComposition.frameDuration = CMTimeMake(1, 30);
            
            AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset     presetName:AVAssetExportPresetMediumQuality];
            session.outputURL = outputURL;
            session.videoComposition = waterMarkVideoComposition;
            session.outputFileType = AVFileTypeMPEG4;
            startHandler(session);
            //导出视频
            [session exportAsynchronouslyWithCompletionHandler:^(void)
             {
                 endHandler(filePath.path, str, session);
             }];
        }
        
    }];
}

//获取当前视频的偏移角度
+ (NSUInteger)degressFromVideoFileWithURL:(NSURL *)url
{
    NSUInteger degress = 0;
    AVAsset *asset = [AVAsset assetWithURL:url];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            degress = 90;
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            degress =270;
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            degress = 0;
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            degress = 180;
        }
    }
    return degress;
}


+ (void)saveImageInSystemPhoto:(UIImage *)image withAlert:(BOOL)alert
{
    //判断用户是否拥有相机权限
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                
            }else{
                return;
            }
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
        
    } else{
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 相册的标题
        NSString *title = @"小热点";
        
        PHAssetCollection * myCollection;
        
        // 获得所有的自定义相册
        PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *collection in collections) {
            if ([collection.localizedTitle isEqualToString:title]) {
                myCollection = collection;
            }
        }
        
        if (!myCollection) {
            // 代码执行到这里，说明还没有自定义相册
            __block NSString *createdCollectionId = nil;
            
            // 创建一个新的相册
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                createdCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
            } error:nil];
            myCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionId] options:nil].firstObject;
        }
        
        __block NSString *createdAssetId = nil;
        // 添加图片到【相机胶卷】
        // 同步方法,直接创建图片,代码执行完,图片没创建完,所以使用占位ID (createdAssetId)
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
        } error:nil];
        
        // 在保存完毕后取出图片
        PHFetchResult<PHAsset *> *createdAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
        
        if (!createdAssets || !myCollection) {
            return;
        }
        
        // 将刚才添加到【相机胶卷】的图片，引用（添加）到【自定义相册】
        NSError *error = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:myCollection];
            // 自定义相册封面默认保存第一张图,所以使用以下方法把最新保存照片设为封面
            [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:myCollection.estimatedAssetCount]];
        } error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (alert) {
                if (error) {
                    [MBProgressHUD showTextHUDwithTitle:@"保存失败"];
                }else{
                    [MBProgressHUD showTextHUDwithTitle:@"图片已保存" delay:1.5f];
                }
            }
        });
    });
}

@end
