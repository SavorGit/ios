//
//  HSFirstUseRequest.m
//  SavorX
//
//  Created by 郭春城 on 17/2/12.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSFirstUseRequest.h"

@implementation HSFirstUseRequest

- (instancetype)initWithHotelId:(NSInteger)hotelId
{
    if (self = [super init]) {
        self.methodName = [@"basedata/Firstuse/pushData?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setIntegerValue:6 forParamKey:@"hotelId"];
    }
    return self;
}

@end
