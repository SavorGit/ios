//
//  HSCollectoinListRequest.m
//  SavorX
//
//  Created by 郭春城 on 2017/7/12.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSCollectoinListRequest.h"

@implementation HSCollectoinListRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.methodName = [@"APP3/UserCollection/getLastCollectoinList?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
    }
    return self;
}

- (instancetype)initWithCreateTime:(NSString *)createTime
{
    if (self = [super init]) {
        self.methodName = [@"APP3/UserCollection/getLastCollectoinList?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:createTime forParamKey:@"createTime"];
    }
    return self;
}

@end
