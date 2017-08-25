//
//  HSGetCollectoinStateRequest.m
//  SavorX
//
//  Created by 郭春城 on 2017/7/13.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSGetCollectoinStateRequest.h"

@implementation HSGetCollectoinStateRequest

- (instancetype)initWithArticleID:(NSString *)articleId
{
    if (self = [super init]) {
        self.methodName = [@"APP3/UserCollection/getCollectoinState?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPGet;
        [self setValue:articleId forParamKey:@"articleId"];
    }
    return self;
}

@end
