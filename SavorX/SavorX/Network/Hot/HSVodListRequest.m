//
//  HSVodListRequest.m
//  HotSpot
//
//  Created by lijiawei on 16/12/7.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "HSVodListRequest.h"
#import "HSVodModel.h"

@implementation HSVodListRequest

- (instancetype)initWithCreateTime:(NSInteger)createTime
{
    if(self = [super init]){
        self.methodName = [@"content/Home/getVodList?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        if (createTime > 0) {
            [self setIntegerValue:createTime forParamKey:@"createTime"];
        }
    }
    return self;
}

@end
