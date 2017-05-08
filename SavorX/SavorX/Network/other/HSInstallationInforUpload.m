//
//  HSInstallationInforUpload.m
//  SavorX
//
//  Created by 王海朋 on 2017/5/2.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSInstallationInforUpload.h"

@implementation HSInstallationInforUpload

- (instancetype)initWithHotelId:(NSString *)hotelId waiterId:(NSString *)waiterId andSt:(NSString *)st
{
    if (self = [super init]) {
        self.methodName = [@"download/DownloadCount/recordCount?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:hotelId forParamKey:@"hotelid"];
        [self setValue:waiterId forParamKey:@"waiterid"];
        [self setValue:st forParamKey:@"st"];
    }
    return self;
}

@end
