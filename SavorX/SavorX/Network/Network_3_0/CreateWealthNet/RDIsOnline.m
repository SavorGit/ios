//
//  RDIsOnline.m
//  SavorX
//
//  Created by 郭春城 on 2017/7/21.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDIsOnline.h"

@implementation RDIsOnline

- (instancetype)initWithArtID:(NSString *)artID
{
    if (self = [super init]) {
        self.methodName = [@"APP3/Content/isOnlie?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:artID forParamKey:@"artid"];
    }
    return self;
}

@end
