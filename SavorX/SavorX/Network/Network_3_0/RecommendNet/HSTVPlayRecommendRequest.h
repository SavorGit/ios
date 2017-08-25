//
//  HSTVPlayRecommendRequest.h
//  SavorX
//
//  Created by 郭春城 on 2017/8/9.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <BGNetwork/BGNetwork.h>

@interface HSTVPlayRecommendRequest : BGNetworkRequest

- (instancetype)initWithArticleId:(NSString *)articleId sortNum:(NSString *)sortNum;

@end
