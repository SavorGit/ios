//
//  OpenFileTool.m
//  SavorX
//
//  Created by 郭春城 on 16/8/14.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "OpenFileTool.h"
#import "ScreenDocumentViewController.h"
#import "SXVideoPlayViewController.h"
#import "PhotoSliderViewController.h"
#import "PhotoManyViewController.h"
#import "DemandViewController.h"
#import "GCCUPnPManager.h"
#import "HomeAnimationView.h"
#import "PhotoTool.h"
#import "RDAlertView.h"
#import "RDAlertAction.h"

@implementation OpenFileTool

+ (void)screenFileWithPath:(NSString *)path
{
    NSArray * tempArray = [path componentsSeparatedByString:NSHomeDirectory()];
    NSString * inboxPath = [NSHomeDirectory() stringByAppendingString:[tempArray lastObject]];
    FileType type = [OpenFileTool getFileTypeWithPath:inboxPath];
    NSString * filePath = [OpenFileTool copyDocmentFileWithPath:inboxPath andType:type];
    if (nil == filePath) {
        return;
    }
    if (type == FileTypeVideo) {
        [OpenFileTool screenVideoFileWithPath:filePath];
        return;
    }
    
    [OpenFileTool screenDocmentWithPath:filePath];
}

+ (void)screenVideoFileWithPath:(NSString *)filePath
{
    MBProgressHUD * hud = [MBProgressHUD showCustomLoadingHUDInView:[UIApplication sharedApplication].keyWindow];
    
    UINavigationController * na = [Helper getRootNavigationController];
    if ([na.topViewController isKindOfClass:[SXVideoPlayViewController class]] ||
        [na.topViewController isKindOfClass:[ScreenDocumentViewController class]] ||
        [na.topViewController isKindOfClass:[PhotoSliderViewController class]] ||
        [na.topViewController isKindOfClass:[PhotoManyViewController class]] ||
        [na.topViewController isKindOfClass:[DemandViewController class]]) {
        [na.topViewController.navigationController popViewControllerAnimated:NO];
    }
    
    NSURL *movieURL = [NSURL fileURLWithPath:filePath];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:movieURL options:nil];  // 初始化视频媒体文件
    NSInteger totalTime = (NSInteger)urlAsset.duration.value / urlAsset.duration.timescale;
    
    NSString * videoUrl = [NSString stringWithFormat:@"video?%@", [filePath lastPathComponent]];
    NSString *asseturlStr = [NSString stringWithFormat:@"%@%@", [HTTPServerManager getCurrentHTTPServerIP], videoUrl];
    
    if ([GlobalData shared].isBindRD) {
        
        [OpenFileTool demandVideoWithMediaPath:[asseturlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] force:0 videoUrl:videoUrl movieURL:movieURL totalTime:totalTime filePath:filePath];
        
         [hud hideAnimated:NO];
        
    }else if ([GlobalData shared].isBindDLNA) {
        [[GCCUPnPManager defaultManager] setAVTransportURL:[asseturlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] Success:^{
            [hud hideAnimated:NO];
            
            SXVideoPlayViewController * video = [[SXVideoPlayViewController alloc] init];
            video.videoUrl = videoUrl;
            video.totalTime = totalTime;
            video.title = [filePath lastPathComponent];
            UIImage *firstImage = [[PhotoTool sharedInstance] imageWithVideoUrl:movieURL atTime:2];
            [HomeAnimationView animationView].currentImage = firstImage;
            [[HomeAnimationView animationView] startScreenWithViewController:video];
            [[Helper getRootNavigationController] pushViewController:video animated:YES];

        } failure:^{
            [hud hideAnimated:NO];
        }];
    }
}

+ (void)demandVideoWithMediaPath:(NSString *)mediaPath force:(NSInteger)force  videoUrl:(NSString *)videoUrl  movieURL:(NSURL *)movieURL totalTime:(NSInteger )totalTime filePath:(NSString *)filePath{
    
    [SAVORXAPI postVideoWithURL:STBURL mediaPath:mediaPath position:@"0" force:force success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        if ([[result objectForKey:@"result"] integerValue] == 0) {
            SXVideoPlayViewController * video = [[SXVideoPlayViewController alloc] init];
            video.videoUrl = videoUrl;
            video.totalTime = totalTime;
            video.title = [filePath lastPathComponent];
            UIImage *firstImage = [[PhotoTool sharedInstance] imageWithVideoUrl:movieURL atTime:2];
            [HomeAnimationView animationView].currentImage = firstImage;
            [[HomeAnimationView animationView] startScreenWithViewController:video];
            [[Helper getRootNavigationController] pushViewController:video animated:YES];
        }else if ([[result objectForKey:@"result"] integerValue] == 4) {
            
            NSString *infoStr = [result objectForKey:@"info"];
            RDAlertView *alertView = [[RDAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"当前%@正在投屏，是否继续投",infoStr]];
            RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"取消" handler:^{
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" withParmDic:@{@"to_screen_competition_hint" : @"cancel",@"type" : @"video"}];
            } bold:NO];
            RDAlertAction * actionOne = [[RDAlertAction alloc] initWithTitle:@"继续投屏" handler:^{
                [self demandVideoWithMediaPath:mediaPath force:1 videoUrl:videoUrl movieURL:movieURL totalTime:totalTime filePath:filePath];
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" withParmDic:@{@"to_screen_competition_hint" : @"ensure",@"type" : @"video"}];
            } bold:NO];
            [alertView addActions:@[action,actionOne]];
            [alertView show];
            
        }
        else{
            [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
        }
       
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}

+ (void)screenDocmentWithPath:(NSString *)filePath
{
    UINavigationController * na = [Helper getRootNavigationController];
    BaseViewController * base = (BaseViewController *)na.topViewController;
    if ([base isKindOfClass:[ScreenDocumentViewController class]] ||
        [base isKindOfClass:[PhotoSliderViewController class]] ||
        [base isKindOfClass:[PhotoManyViewController class]]) {
        [base.navigationController popViewControllerAnimated:NO];
    }else if ([base isKindOfClass:[SXVideoPlayViewController class]]) {
        SXVideoPlayViewController * vc = (SXVideoPlayViewController *)base;
        if (vc.model) {
            UIViewController * firstVC = [na.viewControllers firstObject];
            [vc.navigationController popToViewController:firstVC animated:NO];
        }else{
            [vc.navigationController popViewControllerAnimated:NO];
        }
    }else if ([base isKindOfClass:[DemandViewController class]]) {
        UIViewController * vc = [na.viewControllers firstObject];
        [base.navigationController popToViewController:vc animated:NO];
    }
    
    ScreenDocumentViewController * viewController = [[ScreenDocumentViewController alloc] init];
    viewController.title = [filePath lastPathComponent];
    viewController.path = filePath;
    [base.navigationController pushViewController:viewController animated:YES];
}

+ (NSString *)copyDocmentFileWithPath:(NSString *)path andType:(FileType)type
{
    NSString * superPath;
    
    switch (type) {
        case FileTypePDF:
            
            superPath = PDFDocument;
            
            break;
            
        case FileTypeDOC:
            
            superPath = DOCDocument;
            
            break;
            
        case FileTypeEXCEL:
            
            superPath = EXCELDocument;
            
            break;
            
        case FileTypePPT:
            
            superPath = PPTDocument;
            
            break;
            
        case FileTypeVideo:
            
            superPath = VideoDocument;
            
            break;
            
        case FileTypeImage:
            
            superPath = ImageDocument;
            
            break;
            
        default:
            
            return nil;
            
            break;
    }
    
    NSFileManager * manager = [NSFileManager defaultManager];
    BOOL temp = NO;
    NSError * error;
    if ([manager fileExistsAtPath:superPath isDirectory:&temp]) {
        if (!temp) {
            [manager createDirectoryAtPath:superPath withIntermediateDirectories:YES attributes:nil error:&error];
        }
    }else{
        [manager createDirectoryAtPath:superPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    if (error) {
        
    }
    
    NSString * result = [superPath stringByAppendingPathComponent:[path lastPathComponent]];
    if ([manager fileExistsAtPath:result isDirectory:&temp]) {
        if (temp) {
            
            [manager copyItemAtPath:path toPath:result error:&error];
        }else{
            [manager removeItemAtPath:result error:&error];
            
            [manager copyItemAtPath:path toPath:result error:&error];
        }
    }else{
        [manager copyItemAtPath:path toPath:result error:&error];
    }
    if (error) {
        
    }
    
    [manager removeItemAtPath:path error:&error];
    if (error) {
        
    }
    
    return result;
}

+ (NSArray<NSString *> *)getFileListUrlAtPath:(NSString *)path andFileType:(FileType)type
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    
    NSFileManager * manager = [NSFileManager defaultManager];
    NSArray * pathArray = [manager subpathsAtPath:path];
    
    if (type == FileTypePDF) {
        
        for (NSString * str in pathArray) {
            NSString * lowerStr = [str lowercaseString];
            if ([lowerStr hasSuffix:@".pdf"]) {
                [array addObject:str];
            }
        }
        
    }else if (type == FileTypeDOC){
        
        for (NSString * str in pathArray) {
            NSString * lowerStr = [str lowercaseString];
            if ([lowerStr hasSuffix:@".doc"] || [lowerStr hasSuffix:@".docx"]) {
                [array addObject:str];
            }
        }
        
    }else if (type == FileTypeEXCEL){
        
        for (NSString * str in pathArray) {
            NSString * lowerStr = [str lowercaseString];
            if ([lowerStr hasSuffix:@".xls"] || [lowerStr hasSuffix:@".xlsx"]) {
                [array addObject:str];
            }
        }
        
    }else if (type == FileTypeVideo){
        
        for (NSString * str in pathArray) {
            NSString * lowerStr = [str lowercaseString];
            if ([lowerStr hasSuffix:@".mp4"]) {
                [array addObject:str];
            }
        }
        
    }else if (type == FileTypePPT){
        
        for (NSString * str in pathArray) {
            NSString * lowerStr = [str lowercaseString];
            if ([lowerStr hasSuffix:@".ppt"] || [lowerStr hasSuffix:@".pptx"]) {
                [array addObject:str];
            }
        }
        
    }else{
        
        
        
    }
    
    return array;
}

+ (FileType)getFileTypeWithPath:(NSString *)path
{
    path = [path lowercaseString];
    if ([path hasSuffix:@".pdf"]) {
        return FileTypePDF;
    }else if ([path hasSuffix:@".doc"] || [path hasSuffix:@".docx"]){
        return FileTypeDOC;
    }else if ([path hasSuffix:@".xls"] || [path hasSuffix:@".xlsx"]){
        return FileTypeEXCEL;
    }else if ([path hasSuffix:@".ppt"] || [path hasSuffix:@".pptx"]){
        return FileTypePPT;
    }else if ([path hasSuffix:@".mp4"]){
        return FileTypeVideo;
    }
    
    return FileTypeImage;
}

+ (void)writeImageToSysImageCacheWithImage:(UIImage *)Image andName:(NSString *)name handle:(void (^)(NSString *))success
{
    name = [[name componentsSeparatedByString:@"/"].firstObject stringByAppendingString:@".jpg"];
    NSString * result = [SystemImage stringByAppendingPathComponent:name];
    NSFileManager * manager = [NSFileManager defaultManager];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData*  data = [NSData data];
        data = UIImageJPEGRepresentation(Image, 1);
        float tempX = 0.9;
        NSInteger length = data.length;
        while (data.length > ImageSize) {
            data = UIImageJPEGRepresentation(Image, tempX);
            tempX -= 0.1;
            if (data.length == length) {
                if ([manager fileExistsAtPath:result]) {
                    [manager removeItemAtPath:result error:nil];
                }
                [data writeToFile:result atomically:YES];
                success(name);
                return;
            }
            length = data.length;
        }
        
        BOOL temp = NO;
        NSError * error;
        if ([manager fileExistsAtPath:SystemImage isDirectory:&temp]) {
            if (!temp) {
                [manager createDirectoryAtPath:SystemImage withIntermediateDirectories:YES attributes:nil error:&error];
            }
        }else{
            [manager createDirectoryAtPath:SystemImage withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if ([manager fileExistsAtPath:result]) {
            [manager removeItemAtPath:result error:&error];
        }
        [data writeToFile:result atomically:YES];
        success(name);
    });
}

+ (void)deleteFileSubPath:(NSString *)path
{
    NSFileManager * manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:path] objectEnumerator];
        NSString* fileName;
        while ((fileName = [childFilesEnumerator nextObject]) != nil){
            NSString* fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
            if ([manager fileExistsAtPath:fileAbsolutePath]) {
                [manager removeItemAtPath:fileAbsolutePath error:nil];
            }
        }
    }
}

+ (NSInteger)getAllNumberOfDocumentFile
{
    NSInteger number = 0;
    NSFileManager * manager = [NSFileManager defaultManager];
    NSArray * array = @[PDFDocument, DOCDocument, EXCELDocument, PPTDocument, VideoDocument];
    for (NSInteger i = 0; i < array.count; i++) {
        NSString * path = [array objectAtIndex:i];
        BOOL isDirectory;
        if ([manager fileExistsAtPath:path isDirectory:&isDirectory]) {
            if (isDirectory) {
                number = number + [manager subpathsAtPath:path].count;
            }
        }
    }
    return number;
}

+ (NSArray *)getALLDocumentFileList
{
    NSMutableArray * dataSource = [NSMutableArray new];
    NSFileManager * manager = [NSFileManager defaultManager];
    NSArray * array = @[PDFDocument, DOCDocument, EXCELDocument, PPTDocument, VideoDocument];
    for (NSInteger i = 0; i < array.count; i++) {
        NSString * path = [array objectAtIndex:i];
        BOOL isDirectory;
        if ([manager fileExistsAtPath:path isDirectory:&isDirectory]) {
            if (isDirectory) {
                NSArray * pathArray = [manager subpathsAtPath:path];
                for (NSString * str in pathArray) {
                    NSString * lowerStr = [str lowercaseString];
                    if ([lowerStr hasSuffix:@".pdf"] ||
                        [lowerStr hasSuffix:@".doc"] ||
                        [lowerStr hasSuffix:@".docx"]||
                        [lowerStr hasSuffix:@".xls"] ||
                        [lowerStr hasSuffix:@".xlsx"]||
                        [lowerStr hasSuffix:@".ppt"] ||
                        [lowerStr hasSuffix:@".pptx"]||
                        [lowerStr hasSuffix:@".mp4"]) {
                        [dataSource addObject:str];
                    }
                }
            }
        }
    }
    return [NSArray arrayWithArray:dataSource];
}

@end
