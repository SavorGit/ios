//
//  HSGetLastHotelVodList.m
//  SavorX
//
//  Created by 郭春城 on 17/2/14.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSGetLastHotelVodList.h"

@implementation HSGetLastHotelVodList

- (instancetype)initWithHotelId:(NSInteger)hotelId createTime:(NSInteger)createTime
{
    if (self = [super init]) {
        self.methodName = @"getLastHotelVodList";
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setIntegerValue:hotelId forParamKey:@"hotelId"];
        [self setIntegerValue:createTime forParamKey:@"createTime"];
    }
    return self;
}

@end
