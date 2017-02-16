//
//  HSGetLastVodList.m
//  SavorX
//
//  Created by 郭春城 on 17/2/15.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSGetLastVodList.h"

@implementation HSGetLastVodList

- (instancetype)initWithCreateTime:(NSInteger)createTime
{
    if (self = [super init]) {
        self.methodName = @"getLastVodList";
        self.httpMethod = BGNetworkRequestHTTPPost;
        
        [self setIntegerValue:createTime forParamKey:@"createTime"];
    }
    return self;
}

@end
