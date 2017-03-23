//
//  HSGetLastHotelVodList.m
//  SavorX
//
//  Created by 郭春城 on 17/2/14.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSGetLastHotelVodList.h"

@implementation HSGetLastHotelVodList

- (instancetype)initWithHotelId:(NSInteger)hotelId createTime:(NSInteger)createTime flag:(NSString *)flag
{
    if (self = [super init]) {
        self.methodName = [@"content/home/getLastHotelList?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setIntegerValue:hotelId forParamKey:@"hotelId"];
        if (createTime != 0) {
            [self setIntegerValue:createTime forParamKey:@"createTime"];
        }
        [self setValue:flag forParamKey:@"flag"];
    }
    return self;
}

@end
