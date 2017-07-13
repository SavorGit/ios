//
//  HSImTeRecommendRequest.h
//  SavorX
//
//  Created by 王海朋 on 2017/7/12.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <BGNetwork/BGNetwork.h>

@interface HSImTeRecommendRequest : BGNetworkRequest

- (instancetype)initWithArticleId:(NSString *)articleId;

@end
