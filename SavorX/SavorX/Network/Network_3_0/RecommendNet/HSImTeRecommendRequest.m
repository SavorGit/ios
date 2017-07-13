//
//  HSImTeRecommendRequest.m
//  SavorX
//
//  Created by 王海朋 on 2017/7/12.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSImTeRecommendRequest.h"

@implementation HSImTeRecommendRequest

- (instancetype)initWithArticleId:(NSString *)articleId{
    if (self = [super init]) {
        self.methodName = [@"APP3/Recommend/getRecommendInfo?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:articleId forParamKey:@"articleId"];
    }
    return self;
}

@end
