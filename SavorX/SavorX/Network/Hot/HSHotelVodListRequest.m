//
//  HSHotelVodListRequest.m
//  SavorX
//
//  Created by 郭春城 on 17/2/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSHotelVodListRequest.h"

@implementation HSHotelVodListRequest

- (instancetype)initWithHotelID:(NSInteger)hotelID createTime:(NSInteger)createTime
{
    if(self = [super init]){
        self.methodName = [@"content/home/getHotelList?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setIntegerValue:hotelID forParamKey:@"hotelId"];
        
        if (createTime > 0) {
            [self setIntegerValue:createTime forParamKey:@"createTime"];
        }
    }
    return self;
}

@end
