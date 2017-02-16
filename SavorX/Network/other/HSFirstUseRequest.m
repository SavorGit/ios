//
//  HSFirstUseRequest.m
//  SavorX
//
//  Created by 郭春城 on 17/2/12.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSFirstUseRequest.h"
#import "GCCKeyChain.h"

@implementation HSFirstUseRequest

- (instancetype)initWithHotelId:(NSInteger)hotelId
{
    if (self = [super init]) {
        self.methodName = @"fisrtUse";
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:[GCCKeyChain load:keychainID] forParamKey:@"deviceId"];
        [self setIntegerValue:hotelId forParamKey:@"hotelId"];
        [self setIntegerValue:[Helper getCurrentTime] forParamKey:@"useTime"];
    }
    return self;
}

@end
