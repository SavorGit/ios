//
//  HSTVPlayRecommendRequest.m
//  SavorX
//
//  Created by 郭春城 on 2017/8/9.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSTVPlayRecommendRequest.h"

@implementation HSTVPlayRecommendRequest

- (instancetype)initWithArticleId:(NSString *)articleId sortNum:(NSString *)sortNum
{
    if (self = [super init]) {
        self.methodName = [@"APP3/Recommend/getRecommendInfo?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:articleId forParamKey:@"articleId"];
        [self setValue:sortNum forParamKey:sortNum];
    }
    return self;
}

@end
