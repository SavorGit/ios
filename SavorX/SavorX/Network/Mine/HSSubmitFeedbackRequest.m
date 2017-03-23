//
//  HSSubmitFeedbackRequest.m
//  SavorX
//
//  Created by lijiawei on 16/12/8.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "HSSubmitFeedbackRequest.h"
#import "GCCKeyChain.h"

@implementation HSSubmitFeedbackRequest

- (instancetype)initWithSuggestion:(NSString *)suggestion contactWay:(NSString *)contactWay {
    if (self = [super init]) {
        self.methodName = [@"feed/feedback/feedInsert?" stringByAppendingString:[Helper getURLPublic]];
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:[GCCKeyChain load:keychainID] forParamKey:@"deviceId"];
        [self setValue:suggestion forParamKey:@"suggestion"];
        [self setValue:contactWay forParamKey:@"contactWay"];
        
    }
    return self;
}

@end
