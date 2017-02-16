//
//  OpenFileTool.h
//  SavorX
//
//  Created by 郭春城 on 16/8/14.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>

//文件类型
typedef NS_ENUM(NSInteger, FileType) {
    FileTypePDF,
    FileTypeDOC,
    FileTypeEXCEL,
    FileTypePPT,
    FileTypeVideo,
    FileTypeImage
};

/**
 *  文件工具类，主要用于对其它程序调转的文件进行操作
 */
@interface OpenFileTool : NSObject

+ (void)screenFileWithPath:(NSString *)path;

/**
 *  拷贝文档文件到指定的缓存目录
 *
 *  @param path 当前文件所在的路径
 *  @param type 当前文件的类型
 *
 *  @return 拷贝之后的路径
 */
+ (NSString *)copyDocmentFileWithPath:(NSString *)path andType:(FileType)type;

/**
 *  获取文件列表
 *
 *  @param path 需要获取文件列表的目录
 *  @param type 需要获取文件列表的类型
 *
 *  @return 返回一个所需文件路径数组
 */
+ (NSArray<NSString *> *)getFileListUrlAtPath:(NSString *)path andFileType:(FileType)type;

/**
 *  通过路径获得该文件类型
 *
 *  @param path 文件路径
 *
 *  @return 文件类型
 */
+ (FileType)getFileTypeWithPath:(NSString *)path;

/**
 *  将图片压缩保存至沙盒
 *
 *  @param Image 需要压缩保存的图片
 *  @param name  图片的名字
 */
+ (void)writeImageToSysImageCacheWithImage:(UIImage *)Image andName:(NSString *)name handle:(void (^)(NSString * keyStr))success;

/**
 *  删除文件夹下的子文件
 *
 *  @param path 文件夹路径
 */
+ (void)deleteFileSubPath:(NSString *)path;

/**
 *  获取所有的文件数
 *
 *  @return 文件总数
 */
+ (NSInteger)getAllNumberOfDocumentFile;

//获取所有文件名称
+ (NSArray *)getALLDocumentFileList;

@end
