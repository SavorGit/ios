//
//  HSSmashEggsRequest.m
//  SavorX
//
//  Created by 王海朋 on 2017/7/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSSmashEggsRequest.h"

@implementation HSSmashEggsRequest

- (instancetype)initWithHotelId:(NSString *)hotelId
{
    if (self = [super init]) {
        self.methodName = [@"APP3/Activity/smashEgg?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:hotelId forParamKey:@"hotelId"];
    }
    return self;
}

@end
