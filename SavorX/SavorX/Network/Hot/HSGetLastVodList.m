//
//  HSGetLastVodList.m
//  SavorX
//
//  Created by 郭春城 on 17/2/15.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSGetLastVodList.h"

@implementation HSGetLastVodList

- (instancetype)initWithFlag:(NSString *)flag
{
    if (self = [super init]) {
        self.methodName = [@"content/Home/getLastVodList?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        
        [self setValue:flag forParamKey:@"flag"];
    }
    return self;
}

@end
