//
//  SpecialTopGroupRequest.m
//  SavorX
//
//  Created by 王海朋 on 2017/8/29.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "SpecialTopGroupRequest.h"

@implementation SpecialTopGroupRequest

- (instancetype)initWithId:(NSString *)id;
{
    if (self = [super init]) {
        self.methodName = [@"APP3/Special/specialGroupDetail?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:id forParamKey:@"id"];
    }
    return self;
}

@end
