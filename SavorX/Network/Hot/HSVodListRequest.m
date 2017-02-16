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

- (instancetype)initWithPageNo:(NSInteger)pageNo andPageSize:(NSInteger)pageSize createTime:(NSInteger)createTime
{
    if(self = [super init]){
        self.methodName = @"getVodList";
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setIntegerValue:pageNo forParamKey:@"pageNo"];
        [self setIntegerValue:pageSize forParamKey:@"pageSize"];
        if (createTime > 0) {
            [self setIntegerValue:createTime forParamKey:@"createTime"];
        }
    }
    return self;
}

@end
