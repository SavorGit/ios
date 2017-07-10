//
//  HSPicDetailRequest.m
//  SavorX
//
//  Created by 王海朋 on 2017/7/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSPicDetailRequest.h"

@implementation HSPicDetailRequest

- (instancetype)initWithContentId:(NSString *)contentId
{
    if (self = [super init]) {
        self.methodName = [@"APP3/Content/picDetail?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:contentId forParamKey:@"content_id"];
    }
    return self;
}

@end
