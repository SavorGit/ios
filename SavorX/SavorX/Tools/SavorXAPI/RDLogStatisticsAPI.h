//
//  RDLogStatisticsAPI.h
//  SavorX
//
//  Created by 郭春城 on 2017/4/18.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSVodModel.h"

typedef enum : NSUInteger {
    RDLOGACTION_OPEN,
    RDLOGACTION_START,
    RDLOGACTION_COMPELETE,
    RDLOGACTION_END,
    RDLOGACTION_SHARE,
    RDLOGACTION_CLICK,
    RDLOGACTION_SHOW
} RDLOGACTION; //log的动作类型

typedef enum : NSUInteger {
    RDLOGTYPE_APP,
    RDLOGTYPE_CONTENT,
    RDLOGTYPE_VIDEO,
    RDLOGTYPE_EXTURL,
    RDLOGTYPE_PAGE,
    RDLOGTYPE_ADS
} RDLOGTYPE; //log的类型

@interface RDLogStatisticsAPI : NSObject

//热点条目（对应文章）的log日志
+ (void)RDItemLogAction:(RDLOGACTION)action type:(RDLOGTYPE)type model:(HSVodModel *)model categoryID:(NSString *)categoryID;

//热点页面的PV - log日志
+ (void)RDPageLogCategoryID:(NSString *)categoryID volume:(NSString *)volume;

//热点分享的log日志
+ (void)RDShareLogModel:(HSVodModel *)model categoryID:(NSString *)categoryID volume:(NSString *)volume;

+ (void)checkAndUploadLog;

//+ (void)wantToSeeSee;

@end
