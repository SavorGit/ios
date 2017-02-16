//
//  HSHotelVodListRequest.m
//  SavorX
//
//  Created by 郭春城 on 17/2/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSHotelVodListRequest.h"

@implementation HSHotelVodListRequest

- (instancetype)initWithHotelID:(NSInteger)hotelID andPageNo:(NSInteger)pageNo andPageSize:(NSInteger)pageSize createTime:(NSInteger)createTime
{
    if(self = [super init]){
        self.methodName = @"getHotelVodList";
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setIntegerValue:hotelID forParamKey:@"hotelId"];
        [self setIntegerValue:pageNo forParamKey:@"pageNo"];
        [self setIntegerValue:pageSize forParamKey:@"pageSize"];
        
        if (createTime > 0) {
            [self setIntegerValue:createTime forParamKey:@"createTime"];
        }
    }
    return self;
}

@end
