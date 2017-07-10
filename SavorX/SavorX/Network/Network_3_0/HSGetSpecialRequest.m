//
//  HSGetSpecialRequest.m
//  SavorX
//
//  Created by 郭春城 on 2017/7/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSGetSpecialRequest.h"

@implementation HSGetSpecialRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.methodName = [@"APP3/Special/getSpecialName?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
    }
    return self;
}

@end
