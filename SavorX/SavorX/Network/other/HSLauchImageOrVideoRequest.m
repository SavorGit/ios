//
//  HSLauchImageOrVideoRequest.m
//  SavorX
//
//  Created by 王海朋 on 17/3/23.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSLauchImageOrVideoRequest.h"

@implementation HSLauchImageOrVideoRequest

- (instancetype)initWithDeviceIdentification:(NSString *)identification
{
    if(self = [super init]){
        self.methodName = @"getLauchImageOrVideo";
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:identification forParamKey:@"identification"];
    }
    return self;
}

@end
