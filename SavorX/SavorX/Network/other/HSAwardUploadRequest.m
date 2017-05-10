//
//  HSAwardUploadRequest.m
//  SavorX
//
//  Created by 郭春城 on 2017/5/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSAwardUploadRequest.h"

@implementation HSAwardUploadRequest

- (instancetype)initWithPrizeid:(NSInteger)prizeid andPrizeTime:(NSString *)prizeTime
{
    if (self = [super init]) {
        
        self.methodName = [@"Award/Award/recordAwardLog?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:[NSString stringWithFormat:@"%ld", prizeid] forParamKey:@"prizeid"];
        [self setValue:prizeTime forParamKey:@"time"];
        
    }
    return self;
}

@end