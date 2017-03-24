//
//  HSLatestTopicListRequest.m
//  SavorX
//
//  Created by lijiawei on 16/12/8.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "HSLatestTopicListRequest.h"

@implementation HSLatestTopicListRequest

- (instancetype)initWithCategoryId:(NSInteger)categoryId flag:(NSString *)flag
{
    if (self = [super init]) {
        self.methodName = [@"catvideo/catvideo/getLastTopList?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        
        [self setIntegerValue:categoryId forParamKey:@"categoryId"];
        [self setValue:flag forParamKey:@"flag"];
    }
    return self;
}


@end
