//
//  HSSubmitFeedbackRequest.h
//  SavorX
//
//  Created by lijiawei on 16/12/8.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <BGNetwork/BGNetwork.h>

@interface HSSubmitFeedbackRequest : BGNetworkRequest

- (instancetype)initWithSuggestion:(NSString *)suggestion contactWay:(NSString *)contactWay;

@end
