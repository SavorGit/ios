//
//  HSLauchImageOrVideoRequest.m
//  SavorX
//
//  Created by 王海朋 on 17/3/23.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSLauchImageOrVideoRequest.h"

@implementation HSLauchImageOrVideoRequest

- (instancetype)init;
{
    if(self = [super init]){
        self.methodName = [@"clientstart/clientstart/getInfo?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPGet;
    }
    return self;
}

@end
