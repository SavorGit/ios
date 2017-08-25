//
//  HSRecordSmashEggsRequest.m
//  SavorX
//
//  Created by 王海朋 on 2017/7/11.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSRecordSmashEggsRequest.h"

@implementation HSRecordSmashEggsRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.methodName = [@"APP3/Activity/geteggAwardRecord?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
    }
    return self;
}

@end
