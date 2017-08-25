//
//  HSCreateWealthRequest.m
//  SavorX
//
//  Created by 王海朋 on 2017/7/11.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSCreateWealthRequest.h"

@implementation HSCreateWealthRequest

- (instancetype)initWithCateId:(NSInteger )cateId withSortNum:(NSString *)sortNum;
{
    if (self = [super init]) {
        self.methodName = [@"APP3/Content/getLastCategoryList?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:[NSString stringWithFormat:@"%ld",cateId] forParamKey:@"cateid"];
        [self setValue:sortNum forParamKey:@"sort_num"];
    }
    return self;
}

@end
