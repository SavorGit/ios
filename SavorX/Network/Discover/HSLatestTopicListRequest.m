//
//  HSLatestTopicListRequest.m
//  SavorX
//
//  Created by lijiawei on 16/12/8.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "HSLatestTopicListRequest.h"

@implementation HSLatestTopicListRequest

- (instancetype)initWithCategoryId:(NSInteger)categoryId updateTime:(NSInteger)updateTime{
    if (self = [super init]) {
        self.methodName = @"getLastTopList";
        self.httpMethod = BGNetworkRequestHTTPPost;
        
        [self setIntegerValue:categoryId forParamKey:@"categoryId"];
        [self setIntegerValue:updateTime forParamKey:@"createTime"];
        
    }
    return self;
}


@end
