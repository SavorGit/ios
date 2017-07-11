//
//  SpecialTopRequest.m
//  SavorX
//
//  Created by 王海朋 on 2017/7/11.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "SpecialTopRequest.h"

@implementation SpecialTopRequest

- (instancetype)initWithSortNum:(NSString *)sortNum;
{
    if (self = [super init]) {
        self.methodName = [@"APP3/Content/getLastCategoryList?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:sortNum forParamKey:@"sort_num"];
    }
    return self;
}

@end
