//
//  RDLogStatisticsAPI.m
//  SavorX
//
//  Created by 郭春城 on 2017/4/18.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDLogStatisticsAPI.h"
#import "SSZipArchive.h"
#import <AliyunOSSiOS/OSSService.h>

static NSString * RDCreateLogQueueID = @"com.hottopics.RDCreateLogQueueID";

@implementation RDLogStatisticsAPI

//热点条目（对应文章）的log日志
+ (void)RDItemLogAction:(RDLOGACTION)action type:(RDLOGTYPE)type model:(HSVodModel *)model categoryID:(NSString *)categoryID
{
    const char * RDLogQueueName = [RDCreateLogQueueID UTF8String];
    dispatch_queue_t RDLogQueue = dispatch_queue_create(RDLogQueueName, NULL);
    dispatch_async(RDLogQueue, ^{
        if (action == RDLOGACTION_START) {
            [GlobalData shared].RDCurrentLogTime = [Helper getTimeStamp];
            [RDLogStatisticsAPI RDCreateLogWithAction:action type:type model:model categoryID:categoryID needNewTime:NO];
        }else if (action == RDLOGACTION_OPEN) {
            
            NSString * logitem = [NSString stringWithFormat:@"%@,,,%@,,open,app,,,%@,,ios,",  [RDLogStatisticsAPI checkIsNullOrEmpty:[Helper getTimeStamp]], [RDLogStatisticsAPI checkIsNullOrEmpty:[Helper getTimeStamp]], [RDLogStatisticsAPI checkIsNullOrEmpty:[GlobalData shared].deviceID]];
            [RDLogStatisticsAPI RDLogSaveWithLogItem:logitem];
            
        }else if (action == RDLOGACTION_COMPELETE || action == RDLOGACTION_END){
            [RDLogStatisticsAPI RDCreateLogWithAction:action type:type model:model categoryID:categoryID needNewTime:NO];
        }else {
            [RDLogStatisticsAPI RDCreateLogWithAction:action type:type model:model categoryID:categoryID needNewTime:YES];
        }
    });
}

//热点页面的PV - log日志
+ (void)RDPageLogCategoryID:(NSString *)categoryID volume:(NSString *)volume
{
    const char * RDLogQueueName = [RDCreateLogQueueID UTF8String];
    dispatch_queue_t RDLogQueue = dispatch_queue_create(RDLogQueueName, NULL);
    dispatch_async(RDLogQueue, ^{
        NSString * logItem = [NSString stringWithFormat:@"%@,%@,%@,%@,show,page,,%@,%@,,ios,%@", [RDLogStatisticsAPI checkIsNullOrEmpty:[Helper getTimeStamp]], [RDLogStatisticsAPI checkId:[GlobalData shared].hotelId], [RDLogStatisticsAPI checkId:[GlobalData shared].RDBoxDevice.roomID], [RDLogStatisticsAPI checkIsNullOrEmpty:[Helper getTimeStamp]],[RDLogStatisticsAPI checkIsNullOrEmpty:categoryID],[RDLogStatisticsAPI checkIsNullOrEmpty:[GlobalData shared].deviceID],[RDLogStatisticsAPI checkIsNullOrEmpty:volume]];
        [RDLogStatisticsAPI RDLogSaveWithLogItem:logItem];
    });
}

//创建一条新的日志
+ (void)RDCreateLogWithAction:(RDLOGACTION)action type:(RDLOGTYPE)type model:(HSVodModel *)model categoryID:(NSString *)categoryID needNewTime:(BOOL)needNewTime
{
    NSString * volume;
    switch (model.type) {
        case 0:
            volume = @"text";
            break;
            
        case 1:
            volume = @"pictext";
            break;
            
        case 2:
            volume = @"pic";
            break;
            
        case 3:
        {
            if (type == RDLOGTYPE_VIDEO) {
                volume = @"mp4";
            }else{
                volume = @"video";
            }
        }
            break;
            
        case 4:
        {
            if (type == RDLOGTYPE_VIDEO) {
                volume = @"mp4";
            }else{
                volume = @"video";
            }
        }
            break;
            
        default:
            break;
    }
    
    NSString * time = [GlobalData shared].RDCurrentLogTime;
    if (needNewTime) {
        time = [Helper getTimeStamp];
    }
    
    NSString * logItem = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,ios,%@", [RDLogStatisticsAPI checkIsNullOrEmpty:time], [RDLogStatisticsAPI checkId:[GlobalData shared].hotelId], [RDLogStatisticsAPI checkId:[GlobalData shared].RDBoxDevice.roomID], [RDLogStatisticsAPI checkIsNullOrEmpty:[Helper getTimeStamp]],[RDLogStatisticsAPI getActionStringWithAction:action],[RDLogStatisticsAPI getTypeStringWithType:type],[RDLogStatisticsAPI checkId:model.cid],[RDLogStatisticsAPI checkIsNullOrEmpty:categoryID],[RDLogStatisticsAPI checkIsNullOrEmpty:[GlobalData shared].deviceID],[RDLogStatisticsAPI checkIsNullOrEmpty:model.name],[RDLogStatisticsAPI checkIsNullOrEmpty:volume]];
    [RDLogStatisticsAPI RDLogSaveWithLogItem:logItem];
}

+ (void)RDShareLogModel:(HSVodModel *)model categoryID:(NSString *)categoryID volume:(NSString *)volume
{
    NSString * logItem = [NSString stringWithFormat:@"%@,%@,%@,%@,share,content,%@,%@,%@,%@,ios,%@", [RDLogStatisticsAPI checkIsNullOrEmpty:[Helper getTimeStamp]], [RDLogStatisticsAPI checkId:[GlobalData shared].hotelId], [RDLogStatisticsAPI checkId:[GlobalData shared].RDBoxDevice.roomID], [RDLogStatisticsAPI checkIsNullOrEmpty:[Helper getTimeStamp]], [RDLogStatisticsAPI checkId:model.cid],[RDLogStatisticsAPI checkIsNullOrEmpty:categoryID],[RDLogStatisticsAPI checkIsNullOrEmpty:[GlobalData shared].deviceID], [RDLogStatisticsAPI checkIsNullOrEmpty:model.name],[RDLogStatisticsAPI checkIsNullOrEmpty:volume]];
    [RDLogStatisticsAPI RDLogSaveWithLogItem:logItem];
}

//开启保存日志的线程队列
+ (void)RDLogSaveWithLogItem:(NSString *)logItem
{
    logItem = [logItem stringByAppendingString:@"\n"];
    [RDLogStatisticsAPI RDLogWriteLogFileWith:logItem];
}

//将日志写入本地log文件
+ (void)RDLogWriteLogFileWith:(NSString *)logItem
{
    NSLog(@"%@", [NSThread currentThread]);
    
    NSFileManager * manager = [NSFileManager defaultManager];
    
    NSString * path = RDLogPath;
    if ([manager fileExistsAtPath:path]) {
        NSData * data = [logItem dataUsingEncoding:NSUTF8StringEncoding];
        NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:path];
        [handle seekToEndOfFile];
        [handle writeData:data];
        [handle closeFile];
    }else{
        [logItem writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

//通过动作类型获取log类型值
+ (NSString *)getActionStringWithAction:(RDLOGACTION)action
{
    NSString * actionString = @"";
    switch (action) {
        case RDLOGACTION_OPEN:
            actionString = @"open";
            break;
            
        case RDLOGACTION_START:
            actionString = @"start";
            break;
            
        case RDLOGACTION_COMPELETE:
            actionString = @"compelete";
            break;
            
        case RDLOGACTION_END:
            actionString = @"end";
            break;
            
        case RDLOGACTION_SHARE:
            actionString = @"share";
            break;
            
        case RDLOGACTION_CLICK:
            actionString = @"click";
            break;
            
        case RDLOGACTION_SHOW:
            actionString = @"show";
            break;
            
        default:
            break;
    }
    return actionString;
}

//通过类型获取log类型值
+ (NSString *)getTypeStringWithType:(RDLOGTYPE)type
{
    NSString * typeString = @"";
    switch (type) {
        case RDLOGTYPE_APP:
            typeString = @"app";
            break;
            
        case RDLOGTYPE_CONTENT:
            typeString = @"content";
            break;
            
        case RDLOGTYPE_VIDEO:
            typeString = @"video";
            break;
            
        case RDLOGTYPE_EXTURL:
            typeString = @"exturl";
            break;
            
        case RDLOGTYPE_PAGE:
            typeString = @"page";
            break;
            
        default:
            break;
    }
    return typeString;
}

+ (NSString *)checkIsNullOrEmpty:(NSString *)str
{
    if (isEmptyString(str)) {
        return @"";
    }
    
    return str;
}

+ (NSString *)checkId:(NSInteger)checkID
{
    if (checkID == 0) {
        return @"";
    }
    
    return [NSString stringWithFormat:@"%ld", checkID];
}

+ (void)checkAndUploadLog
{
    const char * RDLogQueueName = [RDCreateLogQueueID UTF8String];
    dispatch_queue_t RDLogQueue = dispatch_queue_create(RDLogQueueName, NULL);
    dispatch_async(RDLogQueue, ^{
        NSFileManager * manager = [NSFileManager defaultManager];
        
        NSString * logPath = RDLogPath;
        NSString * logCachePath = RDLogCachePath;
        
        NSString * tempFileName = [NSString stringWithFormat:@"%@_%@", [GlobalData shared].deviceID, [Helper getCurrentTimeWithFormat:@"yyyyMMddHHmm"]];
        
        NSString * zipPath = [logCachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", tempFileName]];
        
        if ([manager fileExistsAtPath:logCachePath]) {
            //清理之前的日志压缩文件
            NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:logCachePath] objectEnumerator];
            NSString* fileName;
            while ((fileName = [childFilesEnumerator nextObject]) != nil){
                NSString* fileAbsolutePath = [logCachePath stringByAppendingPathComponent:fileName];
                [manager removeItemAtPath:fileAbsolutePath error:nil];
            }
        }
        
        //对log文件进行压缩
        if ([manager fileExistsAtPath:logPath]) {
            
            if (![manager fileExistsAtPath:logCachePath]) {
                [manager createDirectoryAtPath:logCachePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            NSString * tempLogPath = [logCachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.log", tempFileName]];
            
            [manager copyItemAtPath:logPath toPath:tempLogPath error:nil];
            
            if ([manager fileExistsAtPath:tempLogPath]) {
                if ([SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:@[tempLogPath]]) {
                    //压缩成功后进行上传
                    [RDLogStatisticsAPI uploadZipFileToAliyunWithPath:zipPath success:^{
                        
                        //上传成功后删除log文件
                        NSLog(@"OSS文件上传成功");
                        [manager removeItemAtPath:logPath error:nil];
                    } failure:^{
                        
                        //上传失败后若本地log文件大于200M，则对log进行删除
                        NSLog(@"OSS文件上传失败");
                        long long folderSize = 0;
                        folderSize += [[manager attributesOfItemAtPath:logPath error:nil] fileSize];
                        if (folderSize > 200 * 1024 * 1024) {
                            [manager removeItemAtPath:logPath error:nil];
                        }
                        
                    }];
                }
            }
        }
    });
}

+ (void)uploadZipFileToAliyunWithPath:(NSString *)path success:(void(^)())successBlock failure:(void(^)())failureBlock;
{
    NSString *endpoint = AliynEndPoint;
    
    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 3; // 网络请求遇到异常失败后的重试次数
    
    
    // 由阿里云颁发的AccessKeyId/AccessKeySecret构造一个CredentialProvider。
    // 明文设置secret的方式建议只在测试时使用，更多鉴权模式请参考后面的访问控制章节。
    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:AliyunAccessKeyID secretKey:AliyunAccessKeySecret];
    OSSClient * client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential clientConfiguration:conf];
    
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.bucketName = @"redian-development";
    put.objectKey = [NSString stringWithFormat:@"log/mobile/ios/1/%@/%@", [Helper getCurrentTimeWithFormat:@"yyyyMMdd"], path.lastPathComponent];
    put.uploadingFileURL = [NSURL fileURLWithPath:path];
    OSSTask * putTask = [client putObject:put];
    [putTask continueWithBlock:^id _Nullable(OSSTask * _Nonnull task) {
        if (task.error) {
            if (failureBlock) {
                failureBlock();
            }
        }else{
            if (successBlock) {
                successBlock();
            }
        }
        return nil;
    }];
}

+ (void)wantToSeeSee
{
    
    NSFileManager * manager = [NSFileManager defaultManager];
    
    NSString * logPath = RDLogPath;
    NSString * logCachePath = RDLogCachePath;
    
    NSString * tempFileName = [NSString stringWithFormat:@"%@_%@", [GlobalData shared].deviceID, [Helper getCurrentTimeWithFormat:@"yyyyMMddHHmm"]];
    
    if ([manager fileExistsAtPath:logCachePath]) {
        //清理之前的日志压缩文件
        NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:logCachePath] objectEnumerator];
        NSString* fileName;
        while ((fileName = [childFilesEnumerator nextObject]) != nil){
            NSString* fileAbsolutePath = [logCachePath stringByAppendingPathComponent:fileName];
            [manager removeItemAtPath:fileAbsolutePath error:nil];
        }
    }
    
    //对log文件进行压缩
    if ([manager fileExistsAtPath:logPath]) {
        
        if (![manager fileExistsAtPath:logCachePath]) {
            [manager createDirectoryAtPath:logCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString * tempLogPath = [logCachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.log", tempFileName]];
        
        [manager copyItemAtPath:logPath toPath:tempLogPath error:nil];
        
        if ([manager fileExistsAtPath:tempLogPath]) {
            
            [[NSFileManager defaultManager] copyItemAtPath:tempLogPath toPath:[NSString stringWithFormat:@"/Users/guochuncheng/Desktop/%@_%@.log", [GlobalData shared].deviceID, [Helper getCurrentTimeWithFormat:@"yyyyMMddHHmm"]] error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:logPath error:nil];
        }
    }
}

@end
