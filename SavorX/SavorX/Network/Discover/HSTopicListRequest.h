//
//  HSTopicListRequest.h
//  HotSpot
//
//  Created by lijiawei on 16/12/8.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <BGNetwork/BGNetwork.h>

@interface HSTopicListRequest : BGNetworkRequest

- (instancetype)initWithCategoryId:(NSInteger)categoryId time:(NSInteger)time;

@end
