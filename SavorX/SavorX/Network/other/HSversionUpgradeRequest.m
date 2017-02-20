//
//  HSversionUpgradeRequest.m
//  SavorX
//
//  Created by 郭春城 on 17/2/12.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSversionUpgradeRequest.h"

@implementation HSversionUpgradeRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.methodName = @"versionUpgrade";
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setIntegerValue:2017022001 forParamKey:@"versionCode"];
        [self setIntegerValue:4 forParamKey:@"deviceType"];
    }
    return self;
}

@end
