//
//  HSDemandListRequest.m
//  SavorX
//
//  Created by 郭春城 on 2017/7/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSDemandListRequest.h"

@implementation HSDemandListRequest

- (instancetype)initWithHotelID:(NSInteger)hotelID
{
    if (self = [super init]) {
        self.methodName = [@"APP3/Content/demandList?" stringByAppendingString:[Helper getURLPublic]];
        [self setIntegerValue:hotelID forParamKey:@"hotelId"];
        self.httpMethod = BGNetworkRequestHTTPPost;
    }
    return self;
}

@end
