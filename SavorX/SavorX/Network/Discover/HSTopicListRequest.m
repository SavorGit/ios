//
//  HSTopicListRequest.m
//  HotSpot
//
//  Created by lijiawei on 16/12/8.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "HSTopicListRequest.h"

@implementation HSTopicListRequest


- (instancetype)initWithCategoryId:(NSInteger)categoryId time:(NSInteger)time
{
    if (self = [super init]) {
        self.methodName = [@"catvideo/catvideo/getTopList?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setIntegerValue:categoryId forParamKey:@"categoryId"];
        [self setIntegerValue:time forParamKey:@"createTime"];
    }
    return self;
}

-(id)processResponseObject:(id)responseObject{
    
    return responseObject;
}

@end
