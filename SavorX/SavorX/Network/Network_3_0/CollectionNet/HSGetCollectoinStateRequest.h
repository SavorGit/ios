//
//  HSGetCollectoinStateRequest.h
//  SavorX
//
//  Created by 郭春城 on 2017/7/13.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <BGNetwork/BGNetwork.h>

@interface HSGetCollectoinStateRequest : BGNetworkRequest

- (instancetype)initWithArticleID:(NSString *)articleId;

@end
