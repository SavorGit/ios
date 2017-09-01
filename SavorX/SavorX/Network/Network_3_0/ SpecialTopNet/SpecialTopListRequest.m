//
//  SpecialTopListRequest.m
//  SavorX
//
//  Created by 王海朋 on 2017/9/1.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "SpecialTopListRequest.h"

@implementation SpecialTopListRequest

- (instancetype)initWithId:(NSString *)id;
{
    if (self = [super init]) {
        self.methodName = [@"APP3/Special/specialGroupList?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:id forParamKey:@"id"];
    }
    return self;
}

@end
