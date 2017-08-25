//
//  HSIsOrCollectionRequest.m
//  SavorX
//
//  Created by 王海朋 on 2017/7/12.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSIsOrCollectionRequest.h"

@implementation HSIsOrCollectionRequest

- (instancetype)initWithArticleId:(NSString *)articleId withState:(NSInteger )state{
    if (self = [super init]) {
        self.methodName = [@"APP3/UserCollection/addMyCollection?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:articleId forParamKey:@"articleId"];
        [self setValue:[NSString stringWithFormat:@"%ld",state] forParamKey:@"state"];
    }
    return self;
}

@end
